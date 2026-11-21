BEGIN;

INSERT INTO azienda (id_azienda, nome_azienda, partita_iva, soggetto_nis2) VALUES
    (1, 'Ostracon S.p.A.',      '02738473787', 'essenziale'),
    (2, 'Clinica San Giovanni S.p.A.',  '04738452469', 'essenziale'),
    (3, 'Elios S.r.l.',  '09218463578', 'importante');

INSERT INTO responsabile (id_responsabile, id_azienda, nome, cognome, incarico, email, telefono) VALUES
    (1, 1, 'Matteo',   'Morelli', 'Referente sicurezza',                'matteo.morelli@ostracon.it',   '+39 011 8465395'),
    (2, 1, 'Andrea', 'Lamanna', 'Responsabile IT',                    'andrea.lamanna@ostracon.it', '+39 011 1829957'),
    (3, 2, 'Roberta',   'Carli',   'Referente sicurezza',                'roberta.carli@clinicasangiovanni.it',  '+39 02 9264027'),
    (4, 2, 'Paolo',  'Latini',   'Responsabile sistemi informativi',   'paolo.latini@clinicasangiovanni.it', '+39 02 1984280'),
    (5, 3, 'Sandra',   'Pertini',   'Referente sicurezza',                'sandra.pertini@elios.it', '+39 035 1320740'),
    (6, 3, 'Davide', 'Imperato', 'Responsabile produzione',            'davide.imperato@elios.it', '+39 035 8364348');

INSERT INTO fornitore (id_fornitore, nome_fornitore, partita_iva, categoria_fornitura, email_fornitore) VALUES
    (1, 'Robotics Systems S.r.l.', '02745687964', 'manutenzione',      'assistenza@roboticssystem.it'),
    (2, 'Cloud Trinity S.p.A.',    '0273230574', 'cloud e hosting',   'supporto@cloudtrinity.it'),
    (3, 'NetFusion S.r.l.',           '09279175379', 'sicurezza gestita', 'soc@netfusion.it'),
    (4, 'Medsystem S.r.l.',   '02517453689', 'software',          'helpdesk@medsystem.it'),
    (5, 'Telecom Connect S.p.A.',     '04357492432', 'connettivita',      'business@telecomconnect.it'),
    (6, 'Automation S.r.l.',    '09462358365', 'manutenzione',      'service@automation.it');


INSERT INTO asset (id_asset, id_responsabile, nome_asset, categoria_asset, descrizione, criticita_asset, stato_asset) VALUES
    (1,  1, 'Server centrale',          'hardware', 'Server di supervisione e controllo della rete elettrica',        'alta',  'attivo'),
    (2,  1, 'Rete e sottostazioni',          'rete',     'Rete di comunicazione tra centro di controllo e sottostazioni',  'alta',  'attivo'),
    (3,  2, 'Database contatori',      'dati',     'Archivio delle letture dei contatori intelligenti',              'alta',  'attivo'),
    (4,  2, 'Portale clienti',                'software', 'Applicazione web per consultazione consumi e fatture',           'media', 'attivo'),
    (5,  1, 'Firewall perimetrale', 'hardware', 'Firewall sostituito dal nuovo cluster, in attesa di rimozione',   'media', 'dismesso'),
    (6,  4, 'Cartella clinica',   'software', 'Applicativo per la gestione delle cartelle cliniche',            'alta',  'attivo'),
    (7,  4, 'Server diagnostica',                    'hardware', 'Archiviazione e consultazione delle immagini diagnostiche',      'alta',  'attivo'),
    (8,  3, 'wifi reparti',             'rete',     'Rete wireless a uso del personale nei reparti',                  'media', 'attivo'),
    (9,  4, 'Referti',               'dati',     'Archivio digitale dei referti dei pazienti',                     'alta',  'attivo'),
    (10, 3, 'Ambulatorio',         'hardware', 'PC degli ambulatori in corso di sostituzione',                   'bassa', 'in_dismissione'),
    (11, 6, 'PLC',           'hardware', 'Controllori logici della linea di lavorazione',                  'alta',  'attivo'),
    (12, 5, 'Software gestionale',        'software', 'software per ordini, magazzino e contabilita''',                      'media', 'attivo'),
    (13, 6, 'Rete centrale',           'rete',     'Rete di collegamento dei macchinari e degli uffici',             'media', 'attivo'),
    (14, 5, 'NAS',                     'hardware', 'NAS per le copie di sicurezza dei dati aziendali',               'media', 'attivo'),
    (15, 5, 'Sito aziendale',             'software', 'Sito vetrina dell''azienda',                                     'bassa', 'attivo');

INSERT INTO servizio (id_servizio, id_responsabile, nome_servizio, descrizione, categoria_servizio, criticita_servizio, stato_servizio) VALUES
    (1,  1, 'Telecontrollo rete elettrica',            'Supervisione e comando a distanza della rete di distribuzione', 'operativo',      'alta',  'attivo'),
    (2,  2, 'Fatturazione e portale clienti',          'Emissione fatture e accesso clienti ai propri consumi',         'commerciale',    'media', 'attivo'),
    (3,  2, 'Misura consumi (smart metering)',         'Raccolta e gestione delle letture dei contatori',               'operativo',      'alta',  'attivo'),
    (4,  4, 'Gestione cartelle cliniche',              'Creazione e consultazione delle cartelle dei pazienti',         'clinico',        'alta',  'attivo'),
    (5,  4, 'Refertazione e diagnostica per immagini', 'Produzione e archiviazione di referti e immagini',              'clinico',        'alta',  'attivo'),
    (6,  3, 'Prenotazioni online',                     'Prenotazione di visite ed esami tramite web',                   'amministrativo', 'media', 'attivo'),
    (7,  3, 'Centralino telefonico analogico',         'Vecchio centralino sostituito dalla telefonia IP',              'amministrativo', 'bassa', 'dismesso'),
    (8,  6, 'Produzione e controllo linea',            'Gestione e monitoraggio della linea di produzione',             'operativo',      'alta',  'attivo'),
    (9,  5, 'Gestione ordini e magazzino',             'Acquisizione ordini e gestione delle scorte',                   'amministrativo', 'media', 'attivo'),
    (10, 5, 'Presenza online',                         'Sito web e comunicazione verso i clienti',                      'commerciale',    'bassa', 'attivo');

INSERT INTO servizio_asset (id_servizio, id_asset) VALUES
    (1, 1), (1, 2),
    (2, 3), (2, 4),
    (3, 2), (3, 3),
    (4, 6), (4, 9),
    (5, 7), (5, 9),
    (6, 8),
    (7, 10),
    (8, 11), (8, 13),
    (9, 12), (9, 14),
    (10, 15);

INSERT INTO servizio_fornitore (id_servizio, id_fornitore) VALUES
    (1, 1), (1, 3), (1, 5),
    (2, 2),
    (3, 1), (3, 2),
    (4, 2), (4, 4),
    (5, 4),
    (6, 2), (6, 5),
    (7, 5),
    (8, 6),
    (9, 2), (9, 3),
    (10, 2);

INSERT INTO versione (id_versione, id_azienda, numero_versione, stato_versione) VALUES
    (1, 1, 1, 'approvata'),
    (2, 1, 2, 'bozza'),
    (3, 2, 1, 'approvata'),
    (4, 2, 2, 'bozza'),
    (5, 3, 1, 'bozza');

COMMIT;

