# Diagnostic réel du CALL oxmysql — EV 0.1.6

**Statut : non exécuté.** Aucun FXServer, serveur MariaDB/MySQL ni connexion oxmysql opérationnels dans l'environnement de revue.

## Vérifier dans cet ordre

1. Installer le schéma sur une base de test et vérifier `SHOW CREATE PROCEDURE ev_transfer_bank;`.
2. Exécuter `tests/CALL_SMOKE_TEST.sql` avec deux personnages de test valides, après avoir remplacé 101/102. Capturer les résultats SQL et le message d'erreur éventuel.
3. Depuis une ressource FiveM de test, appeler `MySQL.query.await('CALL ev_transfer_bank(?, ?, ?, ?)', {fromId, toId, 1, uniqueId})` dans `pcall`; journaliser `ok`, l'erreur et le résultat retourné (sans secrets).
4. Vérifier SQL après l'appel : débit exact, crédit exact, deux écritures opposées, même transfer_id. Tester aussi un échec de solde insuffisant et vérifier l'absence d'effet.
5. Si le CALL direct SQL fonctionne mais pas le wrapper, capturer version oxmysql, erreur complète et forme du résultat. Essayer `exports.oxmysql:query_async('CALL ev_transfer_bank(?, ?, ?, ?)', params)` seulement si la version installée expose cet export. Ne pas présumer qu'un autre wrapper corrige un problème de procédure ou de transactions.

## Problèmes statiques bloquants indépendants du wrapper

- `pcall` ne garantit pas qu'une réponse `nil`/`false` corresponde à un succès ; vérifier explicitement le retour selon le contrat observé de la version oxmysql.
- La procédure ne rejette pas elle-même `p_amount <= 0`, `p_from = p_to`, ni les dépassements numériques : ces gardes doivent être imposées en SQL aussi.
- `generateTransferId` combine seconde et random à six chiffres, sans unicité garantie ; prévoir UUID et contrainte d'unicité/idempotence.
- La synchronisation post-COMMIT se fonde sur les soldes mémoire précédents, pas sur les soldes SQL autoritaires.
- `PlayerSave` peut écraser les soldes bancaires transférés avec un cache obsolète ; synchroniser/verrouiller save et transfert, ou adopter une persistance SQL atomique par opération.
- L'installation de `install.sql` via un outil ne prenant pas en charge `DELIMITER` doit être adaptée : `DELIMITER` est une directive de client SQL, pas du SQL serveur.

## Résultats T1–T11

Tous **NON EXÉCUTÉS**. Aucun résultat de test réel, journal ou version de serveur n'a été fourni. Ne pas annoncer une validation de production.

## Handoff

Faire tourner T1–T11 sur FXServer + oxmysql + MariaDB/MySQL avec deux joueurs, joindre logs anonymisés et dumps de soldes/ledger avant-après. Corriger la procédure et la concurrence save/transfer avant de commencer le spawn.
