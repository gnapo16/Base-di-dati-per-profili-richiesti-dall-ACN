CREATE TABLE azienda (
    id_azienda     INTEGER      NOT NULL,
    nome_azienda  VARCHAR(50) NOT NULL,
    partita_iva    VARCHAR(11)  NOT NULL,
    soggetto_nis2    VARCHAR(10)  NOT NULL,
    CONSTRAINT pk_azienda PRIMARY KEY (id_azienda),
    CONSTRAINT uk_azienda_partita_iva UNIQUE (partita_iva),
    CONSTRAINT ck_azienda_denominazione CHECK (length(trim(nome_azienda)) > 0),
    CONSTRAINT ck_azienda_partita_iva   CHECK (partita_iva ~ '^[0-9]{11}$'),
    CONSTRAINT ck_azienda_ambito_nis2   CHECK (soggetto_nis2 IN ('essenziale', 'importante'))
);

CREATE TABLE responsabile (
    id_responsabile INTEGER      NOT NULL,
    id_azienda      INTEGER      NOT NULL,
    nome            VARCHAR(50) NOT NULL,
    cognome         VARCHAR(50) NOT NULL,
    incarico        VARCHAR(100) NOT NULL,
    email           VARCHAR(50) NOT NULL,
    telefono        VARCHAR(30)  NOT NULL,
    CONSTRAINT pk_responsabile PRIMARY KEY (id_responsabile),
    CONSTRAINT uk_responsabile_email UNIQUE (email),
    CONSTRAINT fk_responsabile_azienda FOREIGN KEY (id_azienda)
        REFERENCES azienda (id_azienda) ON DELETE RESTRICT,
    CONSTRAINT ck_responsabile_nome    CHECK (length(trim(nome)) > 0),
    CONSTRAINT ck_responsabile_cognome CHECK (length(trim(cognome)) > 0),
    CONSTRAINT ck_responsabile_incarico   CHECK (length(trim(incarico)) > 0)
);


CREATE TABLE asset (
    id_asset        INTEGER      NOT NULL,
    id_responsabile INTEGER      NOT NULL,
    nome_asset      VARCHAR(50) NOT NULL,
    categoria_asset VARCHAR(10)  NOT NULL,
    descrizione     TEXT         NOT NULL,
    criticita_asset VARCHAR(10)  NOT NULL,
    stato_asset     VARCHAR(15)  NOT NULL,
    CONSTRAINT pk_asset PRIMARY KEY (id_asset),
    CONSTRAINT fk_asset_responsabile FOREIGN KEY (id_responsabile)
        REFERENCES responsabile (id_responsabile) ON DELETE RESTRICT,
    CONSTRAINT ck_asset_nome_asset       CHECK (length(trim(nome_asset)) > 0),
    CONSTRAINT ck_asset_categoria_asset   CHECK (categoria_asset IN ('hardware', 'software', 'rete', 'dati', 'altro')),
    CONSTRAINT ck_asset_descrizione CHECK (length(trim(descrizione)) > 0),
    CONSTRAINT ck_asset_criticita_asset   CHECK (criticita_asset IN ('bassa', 'media', 'alta')),
    CONSTRAINT ck_asset_stato_asset       CHECK (stato_asset IN ('attivo', 'in_dismissione', 'dismesso'))
);


CREATE TABLE servizio (
    id_servizio     INTEGER      NOT NULL,
    id_responsabile INTEGER      NOT NULL,
    nome_servizio   VARCHAR(50) NOT NULL,
    descrizione     TEXT         NOT NULL,
    categoria_servizio       VARCHAR(50)  NOT NULL,
    criticita_servizio       VARCHAR(10)  NOT NULL,
    stato_servizio           VARCHAR(15)  NOT NULL,
    CONSTRAINT pk_servizio PRIMARY KEY (id_servizio),
    CONSTRAINT fk_servizio_responsabile FOREIGN KEY (id_responsabile)
        REFERENCES responsabile (id_responsabile) ON DELETE RESTRICT,
    CONSTRAINT ck_servizio_nome        CHECK (length(trim(nome_servizio)) > 0),
    CONSTRAINT ck_servizio_descrizione CHECK (length(trim(descrizione)) > 0),
    CONSTRAINT ck_servizio_criticita_servizio   CHECK (criticita_servizio IN ('bassa', 'media', 'alta')),
    CONSTRAINT ck_servizio_stato_servizio       CHECK (stato_servizio IN ('attivo', 'in_dismissione', 'dismesso'))
);


CREATE TABLE fornitore (
    id_fornitore    INTEGER      NOT NULL,
    nome_fornitore   VARCHAR(50) NOT NULL,
    partita_iva     VARCHAR(11)  NOT NULL,
    categoria_fornitura       VARCHAR(50)  NOT NULL,
    email_fornitore VARCHAR(50) NOT NULL,
    CONSTRAINT pk_fornitore PRIMARY KEY (id_fornitore),
    CONSTRAINT uk_fornitore_partita_iva UNIQUE (partita_iva),
    CONSTRAINT ck_fornitore_nome_fornitore CHECK (length(trim(nome_fornitore)) > 0),
    CONSTRAINT ck_fornitore_partita_iva   CHECK (partita_iva ~ '^[0-9]{11}$')
);


CREATE TABLE servizio_asset (
    id_servizio INTEGER NOT NULL,
    id_asset    INTEGER NOT NULL,
    CONSTRAINT pk_servizio_asset PRIMARY KEY (id_servizio, id_asset),
    CONSTRAINT fk_servizio_asset_servizio FOREIGN KEY (id_servizio)
        REFERENCES servizio (id_servizio) ON DELETE CASCADE,
    CONSTRAINT fk_servizio_asset_asset FOREIGN KEY (id_asset)
        REFERENCES asset (id_asset) ON DELETE CASCADE
);


CREATE TABLE servizio_fornitore (
    id_servizio  INTEGER NOT NULL,
    id_fornitore INTEGER NOT NULL,
    CONSTRAINT pk_servizio_fornitore PRIMARY KEY (id_servizio, id_fornitore),
    CONSTRAINT fk_servizio_fornitore_servizio FOREIGN KEY (id_servizio)
        REFERENCES servizio (id_servizio) ON DELETE CASCADE,
    CONSTRAINT fk_servizio_fornitore_fornitore FOREIGN KEY (id_fornitore)
        REFERENCES fornitore (id_fornitore) ON DELETE CASCADE
);


CREATE TABLE versione (
    id_versione     INTEGER     NOT NULL,
    id_azienda      INTEGER     NOT NULL,
    numero_versione INTEGER     NOT NULL,
    stato_versione  VARCHAR(10) NOT NULL,
    CONSTRAINT pk_versione PRIMARY KEY (id_versione),
    CONSTRAINT uk_versione_azienda_numero UNIQUE (id_azienda, numero_versione),
    CONSTRAINT fk_versione_azienda FOREIGN KEY (id_azienda)
        REFERENCES azienda (id_azienda) ON DELETE RESTRICT,
    CONSTRAINT ck_versione_numero CHECK (numero_versione > 0),
    CONSTRAINT ck_versione_stato  CHECK (stato_versione IN ('bozza', 'approvata', 'archiviata'))
);


CREATE UNIQUE INDEX uq_versione_approvata_per_azienda
    ON versione (id_azienda)
    WHERE stato_versione = 'approvata';


CREATE TABLE storico (
    id_storico           BIGINT      NOT NULL,
    id_versione          INTEGER     NOT NULL,
    id_responsabile      INTEGER     NOT NULL,
    entita_modificata    VARCHAR(50) NOT NULL,
    id_record_modificato VARCHAR(50) NOT NULL,
    modifica        VARCHAR(20) NOT NULL,
    descrizione          TEXT        NOT NULL,
    CONSTRAINT pk_storico PRIMARY KEY (id_storico),
    CONSTRAINT fk_storico_versione FOREIGN KEY (id_versione)
        REFERENCES versione (id_versione) ON DELETE RESTRICT,
    CONSTRAINT fk_storico_responsabile FOREIGN KEY (id_responsabile)
        REFERENCES responsabile (id_responsabile) ON DELETE RESTRICT,
    CONSTRAINT ck_storico_entita CHECK (entita_modificata IN (
        'azienda', 'responsabile', 'asset', 'servizio',
        'fornitore', 'servizio_asset', 'servizio_fornitore', 'versione')),
    CONSTRAINT ck_storico_modifica CHECK (modifica IN ('inserimento', 'aggiornamento', 'eliminazione'))
);


CREATE INDEX idx_responsabile_azienda      ON responsabile (id_azienda);
CREATE INDEX idx_asset_responsabile        ON asset (id_responsabile);
CREATE INDEX idx_servizio_responsabile     ON servizio (id_responsabile);
CREATE INDEX idx_servizio_asset_asset      ON servizio_asset (id_asset);
CREATE INDEX idx_servizio_fornitore_forn   ON servizio_fornitore (id_fornitore);
CREATE INDEX idx_storico_versione          ON storico (id_versione);
CREATE INDEX idx_storico_responsabile      ON storico (id_responsabile);
CREATE INDEX idx_storico_record            ON storico (entita_modificata, id_record_modificato);
