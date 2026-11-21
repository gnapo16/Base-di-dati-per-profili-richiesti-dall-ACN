CREATE OR REPLACE FUNCTION fn_versione_archivia_precedente()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.stato_versione = 'approvata'
       AND (TG_OP = 'INSERT' OR OLD.stato_versione IS DISTINCT FROM 'approvata') THEN

        UPDATE versione
           SET stato_versione = 'archiviata'
         WHERE id_azienda = NEW.id_azienda
           AND stato_versione = 'approvata'
           AND id_versione <> NEW.id_versione;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_versione_archivia_precedente ON versione;

CREATE TRIGGER trg_versione_archivia_precedente
    BEFORE INSERT OR UPDATE OF stato_versione
    ON versione
    FOR EACH ROW
    EXECUTE FUNCTION fn_versione_archivia_precedente();

CREATE OR REPLACE FUNCTION fn_versione_crea_bozza()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_nuovo_id     INTEGER;
    v_nuovo_numero INTEGER;
BEGIN

    PERFORM pg_advisory_xact_lock(hashtext('versione_nuova_bozza'));

    IF EXISTS (SELECT 1
                 FROM versione
                WHERE id_azienda = NEW.id_azienda
                  AND stato_versione = 'bozza') THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(MAX(id_versione), 0) + 1
      INTO v_nuovo_id
      FROM versione;

    SELECT COALESCE(MAX(numero_versione), 0) + 1
      INTO v_nuovo_numero
      FROM versione
     WHERE id_azienda = NEW.id_azienda;

    INSERT INTO versione (id_versione, id_azienda, numero_versione, stato_versione)
    VALUES (v_nuovo_id, NEW.id_azienda, v_nuovo_numero, 'bozza');

    RETURN NULL;   
END;
$$;

DROP TRIGGER IF EXISTS trg_versione_crea_bozza ON versione;

CREATE TRIGGER trg_versione_crea_bozza
    AFTER INSERT OR UPDATE OF stato_versione
    ON versione
    FOR EACH ROW
    EXECUTE FUNCTION fn_versione_crea_bozza();


