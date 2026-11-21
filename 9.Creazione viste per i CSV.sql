BEGIN;

CREATE OR REPLACE VIEW v_asset_critici AS
SELECT az.id_azienda,
       az.nome_azienda           AS azienda,
       a.id_asset,
       a.nome_asset,
       a.categoria_asset,
       a.criticita_asset,
       a.descrizione,
       a.stato_asset,
       r.nome || ' ' || r.cognome AS responsabile,
       r.email                    AS email_responsabile
  FROM asset a
  JOIN responsabile r ON r.id_responsabile = a.id_responsabile
  JOIN azienda az     ON az.id_azienda     = r.id_azienda
 WHERE a.criticita_asset = 'alta'
   AND a.stato_asset <> 'dismesso'
 ORDER BY az.id_azienda, a.id_asset;

CREATE OR REPLACE VIEW v_servizi_erogati AS
SELECT az.id_azienda,
       az.nome_azienda           AS azienda,
       s.id_servizio,
       s.nome_servizio,
       s.categoria_servizio,
       s.criticita_servizio,
       s.stato_servizio,
       s.descrizione,
       r.nome || ' ' || r.cognome AS responsabile,
       (SELECT count(*) FROM servizio_asset sa
         WHERE sa.id_servizio = s.id_servizio)      AS n_asset,
       (SELECT count(*) FROM servizio_fornitore sf
         WHERE sf.id_servizio = s.id_servizio)      AS n_fornitori
  FROM servizio s
  JOIN responsabile r ON r.id_responsabile = s.id_responsabile
  JOIN azienda az     ON az.id_azienda     = r.id_azienda
 WHERE s.stato_servizio <> 'dismesso'
 ORDER BY az.id_azienda, s.id_servizio;

CREATE OR REPLACE VIEW v_dipendenze_terze_parti AS
SELECT az.id_azienda,
       az.nome_azienda  AS azienda,
       s.id_servizio,
       s.nome_servizio,
       s.criticita_servizio       AS criticita_del_servizio,
       f.id_fornitore,
       f.nome_fornitore   AS fornitore,
       f.partita_iva     AS partita_iva_fornitore,
       f.categoria_fornitura       AS tipologia_fornitore,
       f.email_fornitore
  FROM servizio s
  JOIN responsabile r         ON r.id_responsabile = s.id_responsabile
  JOIN azienda az             ON az.id_azienda     = r.id_azienda
  JOIN servizio_fornitore sf  ON sf.id_servizio    = s.id_servizio
  JOIN fornitore f            ON f.id_fornitore    = sf.id_fornitore
 WHERE s.stato_servizio <> 'dismesso'
 ORDER BY az.id_azienda, s.id_servizio, f.id_fornitore;

CREATE OR REPLACE VIEW v_punti_di_contatto AS
SELECT az.id_azienda,
       az.nome_azienda           AS azienda,
       'responsabile interno'     AS tipo_contatto,
       r.nome || ' ' || r.cognome AS nominativo,
       r.incarico                    AS ruolo_o_tipologia,
       r.email,
       r.telefono
  FROM responsabile r
  JOIN azienda az ON az.id_azienda = r.id_azienda
UNION ALL
SELECT DISTINCT
       az.id_azienda,
       az.nome_azienda,
       'fornitore',
       f.nome_fornitore,
       f.categoria_fornitura,
       f.email_fornitore,
       NULL
  FROM servizio s
  JOIN responsabile r         ON r.id_responsabile = s.id_responsabile
  JOIN azienda az             ON az.id_azienda     = r.id_azienda
  JOIN servizio_fornitore sf  ON sf.id_servizio    = s.id_servizio
  JOIN fornitore f            ON f.id_fornitore    = sf.id_fornitore
 WHERE s.stato_servizio <> 'dismesso'
 ORDER BY id_azienda, tipo_contatto DESC, nominativo;

COMMIT;
