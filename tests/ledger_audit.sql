-- Requêtes de diagnostic lecture seule, à lancer sur la base de test.
-- Un ledger sans identifiant de transfert ne permet PAS de reconstituer
-- de manière fiable des paires de transferts concurrents.
SELECT character_id, name, balance FROM ev_accounts WHERE name = 'bank' ORDER BY character_id;
SELECT id, character_id, amount, reason, related_character_id, created_at
FROM ev_account_ledger WHERE account_name = 'bank' ORDER BY id DESC LIMIT 100;
SELECT SUM(balance) AS total_bank FROM ev_accounts WHERE name = 'bank';
SELECT SUM(amount) AS net_ledger FROM ev_account_ledger WHERE account_name = 'bank';
SELECT character_id, SUM(amount) AS ledger_net FROM ev_account_ledger
WHERE account_name = 'bank' GROUP BY character_id ORDER BY character_id;
