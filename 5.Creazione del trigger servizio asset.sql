CREATE OR REPLACE FUNCTION fn_servizio_asset_stessa_azienda()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_azienda_servizio INTEGER;
    v_azienda_asset    INTEGER;
BEGIN
    SELECT r.id_azienda
      INTO v_azienda_servizio
      FROM servizio s
      JOIN responsabile r ON r.id_responsabile = s.id_responsabile
     WHERE s.id_servizio = NEW.id_servizio;

    SELECT r.id_azienda
      INTO v_azienda_asset
      FROM asset a
      JOIN responsabile r ON r.id_responsabile = a.id_responsabile
     WHERE a.id_asset = NEW.id_asset;


    IF v_azienda_servizio IS NULL OR v_azienda_asset IS NULL THEN
        RETURN NEW;
    END IF;

    IF v_azienda_servizio <> v_azienda_asset THEN
        RAISE EXCEPTION
            'servizio_asset: il servizio % (azienda %) e l''asset % (azienda %) appartengono ad aziende diverse',
            NEW.id_servizio, v_azienda_servizio, NEW.id_asset, v_azienda_asset
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_servizio_asset_stessa_azienda ON servizio_asset;

CREATE TRIGGER trg_servizio_asset_stessa_azienda
    BEFORE INSERT OR UPDATE OF id_servizio, id_asset
    ON servizio_asset
    FOR EACH ROW
    EXECUTE FUNCTION fn_servizio_asset_stessa_azienda();
