CREATE SEQUENCE IF NOT EXISTS seq_storico_id AS BIGINT;

CREATE OR REPLACE FUNCTION fn_autore_modifica()
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_valore TEXT;
BEGIN
    v_valore := current_setting('app.id_responsabile', true);

    IF v_valore IS NULL OR trim(v_valore) = '' THEN
        RAISE EXCEPTION
            'Autore della modifica non indicato: eseguire SET app.id_responsabile = <id_responsabile> prima di modificare i dati';
    END IF;

    RETURN v_valore::INTEGER;
END;
$$;

CREATE OR REPLACE FUNCTION fn_versione_bozza(p_id_azienda INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_id_versione INTEGER;
BEGIN
    SELECT id_versione
      INTO v_id_versione
      FROM versione
     WHERE id_azienda = p_id_azienda
       AND stato_versione = 'bozza'
     ORDER BY numero_versione DESC
     LIMIT 1;

    IF v_id_versione IS NULL THEN
        RAISE EXCEPTION 'Nessuna versione in bozza per l''azienda %', p_id_azienda;
    END IF;

    RETURN v_id_versione;
END;
$$;

CREATE OR REPLACE FUNCTION fn_storico_registra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_rec         JSONB;
    v_autore      INTEGER;
    v_azienda     INTEGER;
    v_versione    INTEGER;
    v_id_record   TEXT;
    v_tipo        TEXT;
    v_descrizione TEXT;
    v_campi       TEXT;
BEGIN
    v_autore := fn_autore_modifica();

    IF TG_OP = 'DELETE' THEN
        v_rec := to_jsonb(OLD);
    ELSE
        v_rec := to_jsonb(NEW);
    END IF;

    v_id_record := CASE TG_TABLE_NAME
        WHEN 'azienda'            THEN v_rec->>'id_azienda'
        WHEN 'responsabile'       THEN v_rec->>'id_responsabile'
        WHEN 'asset'              THEN v_rec->>'id_asset'
        WHEN 'servizio'           THEN v_rec->>'id_servizio'
        WHEN 'fornitore'          THEN v_rec->>'id_fornitore'
        WHEN 'versione'           THEN v_rec->>'id_versione'
        WHEN 'servizio_asset'     THEN (v_rec->>'id_servizio') || ':' || (v_rec->>'id_asset')
        WHEN 'servizio_fornitore' THEN (v_rec->>'id_servizio') || ':' || (v_rec->>'id_fornitore')
    END;

    IF TG_OP = 'INSERT' THEN
        v_tipo := 'inserimento';
        v_descrizione := format('Inserito record %s in %s', v_id_record, TG_TABLE_NAME);

    ELSIF TG_OP = 'DELETE' THEN
        v_tipo := 'eliminazione';
        v_descrizione := format('Eliminato record %s da %s', v_id_record, TG_TABLE_NAME);

    ELSE
        v_tipo := 'aggiornamento';

        SELECT string_agg(
                   n.key || ': ' || coalesce(o.value #>> '{}', 'NULL')
                         || ' -> ' || coalesce(n.value #>> '{}', 'NULL'),
                   '; ' ORDER BY n.key)
          INTO v_campi
          FROM jsonb_each(v_rec)         AS n
          JOIN jsonb_each(to_jsonb(OLD)) AS o ON o.key = n.key
         WHERE n.value IS DISTINCT FROM o.value;

        IF v_campi IS NULL THEN
            RETURN NULL;
        END IF;

        v_descrizione := format('Aggiornato record %s in %s (%s)', v_id_record, TG_TABLE_NAME, v_campi);
    END IF;

    v_azienda := CASE TG_TABLE_NAME
        WHEN 'azienda'      THEN (v_rec->>'id_azienda')::INTEGER
        WHEN 'responsabile' THEN (v_rec->>'id_azienda')::INTEGER
        WHEN 'versione'     THEN (v_rec->>'id_azienda')::INTEGER
        WHEN 'asset'        THEN (SELECT r.id_azienda
                                    FROM responsabile r
                                   WHERE r.id_responsabile = (v_rec->>'id_responsabile')::INTEGER)
        WHEN 'servizio'     THEN (SELECT r.id_azienda
                                    FROM responsabile r
                                   WHERE r.id_responsabile = (v_rec->>'id_responsabile')::INTEGER)
        WHEN 'servizio_asset'     THEN (SELECT r.id_azienda
                                          FROM servizio s
                                          JOIN responsabile r ON r.id_responsabile = s.id_responsabile
                                         WHERE s.id_servizio = (v_rec->>'id_servizio')::INTEGER)
        WHEN 'servizio_fornitore' THEN (SELECT r.id_azienda
                                          FROM servizio s
                                          JOIN responsabile r ON r.id_responsabile = s.id_responsabile
                                         WHERE s.id_servizio = (v_rec->>'id_servizio')::INTEGER)
        ELSE NULL   
    END;

    IF v_azienda IS NULL THEN
        SELECT id_azienda INTO v_azienda
          FROM responsabile
         WHERE id_responsabile = v_autore;
    END IF;

    IF TG_TABLE_NAME = 'versione' THEN
        v_versione := (v_rec->>'id_versione')::INTEGER;
    ELSE
        v_versione := fn_versione_bozza(v_azienda);
    END IF;

    INSERT INTO storico (id_storico, id_versione, id_responsabile,
                         entita_modificata, id_record_modificato,
                         modifica, descrizione)
    VALUES (nextval('seq_storico_id'), v_versione, v_autore,
            TG_TABLE_NAME, v_id_record, v_tipo, v_descrizione);

    RETURN NULL;   
END;
$$;

DROP TRIGGER IF EXISTS trg_storico_azienda            ON azienda;
DROP TRIGGER IF EXISTS trg_storico_responsabile       ON responsabile;
DROP TRIGGER IF EXISTS trg_storico_asset              ON asset;
DROP TRIGGER IF EXISTS trg_storico_servizio           ON servizio;
DROP TRIGGER IF EXISTS trg_storico_fornitore          ON fornitore;
DROP TRIGGER IF EXISTS trg_storico_servizio_asset     ON servizio_asset;
DROP TRIGGER IF EXISTS trg_storico_servizio_fornitore ON servizio_fornitore;
DROP TRIGGER IF EXISTS trg_storico_versione           ON versione;

CREATE TRIGGER trg_storico_azienda
    AFTER INSERT OR UPDATE OR DELETE ON azienda
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_responsabile
    AFTER INSERT OR UPDATE OR DELETE ON responsabile
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_asset
    AFTER INSERT OR UPDATE OR DELETE ON asset
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_servizio
    AFTER INSERT OR UPDATE OR DELETE ON servizio
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_fornitore
    AFTER INSERT OR UPDATE OR DELETE ON fornitore
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_servizio_asset
    AFTER INSERT OR UPDATE OR DELETE ON servizio_asset
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_servizio_fornitore
    AFTER INSERT OR UPDATE OR DELETE ON servizio_fornitore
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();

CREATE TRIGGER trg_storico_versione
    AFTER INSERT OR UPDATE ON versione
    FOR EACH ROW EXECUTE FUNCTION fn_storico_registra();
