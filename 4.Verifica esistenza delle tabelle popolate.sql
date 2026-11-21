SELECT 'azienda' AS tabella, count(*) FROM azienda
UNION ALL SELECT 'responsabile',       count(*) FROM responsabile
UNION ALL SELECT 'fornitore',          count(*) FROM fornitore
UNION ALL SELECT 'asset',              count(*) FROM asset
UNION ALL SELECT 'servizio',           count(*) FROM servizio
UNION ALL SELECT 'servizio_asset',     count(*) FROM servizio_asset
UNION ALL SELECT 'servizio_fornitore', count(*) FROM servizio_fornitore
UNION ALL SELECT 'versione',           count(*) FROM versione;
