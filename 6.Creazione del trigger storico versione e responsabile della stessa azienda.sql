CREATE OR REPLACE FUNCTION fn_storico_stessa_azienda()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_azienda_responsabile INTEGER;
    v_azienda_versione     INTEGER;
BEGIN
    SELECT id_azienda
      INTO v_azienda_responsabile
      FROM responsabile
     WHERE id_responsabile = NEW.id_responsabile;

    SELECT id_azienda
      INTO v_azienda_versione
      FROM versione
     WHERE id_versione = NEW.id_versione;

    IF v_azienda_responsabile IS NULL OR v_azienda_versione IS NULL THEN
        RETURN NEW;
    END IF;

    IF v_azienda_responsabile <> v_azienda_versione THEN
        RAISE EXCEPTION
            'storico: il responsabile % (azienda %) e la versione % (azienda %) appartengono ad aziende diverse',
            NEW.id_responsabile, v_azienda_responsabile,
            NEW.id_versione,     v_azienda_versione
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_storico_stessa_azienda ON storico;

CREATE TRIGGER trg_storico_stessa_azienda
    BEFORE INSERT OR UPDATE OF id_responsabile, id_versione
    ON storico
    FOR EACH ROW
    EXECUTE FUNCTION fn_storico_stessa_azienda();
