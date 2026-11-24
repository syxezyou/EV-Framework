-- À exécuter UNIQUEMENT sur une base de test jetable, après install.sql.
-- Remplacer 101 et 102 par deux character_id existants ayant chacun un compte bank.
-- Sauvegarder les soldes et compter le ledger avant et après.
SELECT character_id, balance FROM ev_accounts WHERE name='bank' AND character_id IN (101,102);
SELECT transfer_id, character_id, amount FROM ev_account_ledger WHERE transfer_id='ev-smoke-001';
CALL ev_transfer_bank(101,102,1,'ev-smoke-001');
SELECT character_id, balance FROM ev_accounts WHERE name='bank' AND character_id IN (101,102);
SELECT transfer_id, character_id, amount FROM ev_account_ledger WHERE transfer_id='ev-smoke-001';
-- Le CALL direct ne prouve PAS que le wrapper oxmysql fonctionne.
-- Exécuter séparément via la ressource FiveM et comparer les mêmes requêtes.
