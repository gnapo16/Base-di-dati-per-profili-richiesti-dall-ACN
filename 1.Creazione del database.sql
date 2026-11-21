-- Database: Base di dati per profili richiesti dall'ACN

-- DROP DATABASE IF EXISTS "Base di dati per profili richiesti dall'ACN";

CREATE DATABASE "Base di dati per profili richiesti dall'ACN"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Italian_Italy.1252'
    LC_CTYPE = 'Italian_Italy.1252'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE "Base di dati per profili richiesti dall'ACN"
    IS 'Database che permette l''inserimento degli asset, servizi, dipendenze e responsabilità appartenenti ad un’azienda che opera secondo la normativa NIS2, con la possibilità di generare un documento CSV riepilogativo di tali informazioni.';