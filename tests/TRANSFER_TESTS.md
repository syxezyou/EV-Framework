# EV — Plan de tests d'intégration des transferts (0.1.3)

Statut : **NON EXÉCUTÉ**. Nécessite FXServer, oxmysql, MariaDB/MySQL et deux clients connectés.
Ne pas activer les transferts en production avant correction de l'atomicité.

## Préparation
1. Sauvegarder la base et importer `sql/install.sql` sur une base de test vierge.
2. Démarrer `ensure oxmysql`, puis `ensure ev` ; ne pas ensure les sous-modules.
3. Créer deux personnages A et B, sélectionner les personnages et relever leurs `character_id`.
4. Exécuter `tests/ledger_audit.sql` après chaque scénario, en remplaçant les identifiants de personnages si nécessaire dans les requêtes d'inspection.
5. Noter les soldes SQL, les soldes mémoire (API EV.GetPlayer) et le total des soldes bancaires avant et après.

## Scénarios obligatoires
- T1 : transfert 100 de A (1000) vers B (0) ; attendre A=900, B=100, deux écritures ledger (-100,+100).
- T2 : transfert du solde exact ; attendre A=0, B crédité ; deuxième transfert refusé.
- T3 : transfert supérieur au solde ; attendre aucun changement SQL et aucune écriture ledger.
- T4 : montants 0, négatifs, non entiers, très grands ; attendre refus et aucun changement.
- T5 : 10 transferts simultanés de A vers B ; attendre absence de double débit, absence de création monétaire.
- T6 : transfert A->B et B->A simultanés ; vérifier verrouillage et conservation du total.
- T7 : déconnecter A pendant une requête en cours ; vérifier soldes SQL, ledger et absence de perte lors du reconnect.
- T8 : désynchroniser volontairement la mémoire de A (solde mémoire > SQL) puis transférer ; **0 ligne débitée ne doit jamais entraîner un crédit ou une écriture ledger**. La version 0.1.3 ne garantit PAS ce résultat.
- T9 : interrompre la connexion DB au milieu de la transaction ; attendre rollback intégral, pas de succès client.
- T10 : modifier le compte cash pendant un transfert bank ; vérifier que `dirty` reste actif jusqu'à persistance cash.
- T11 : recharger les personnages après chaque transfert et vérifier que les soldes sont identiques aux valeurs SQL.

## Critères de validation
- Aucun crédit sans débit ; somme des deux soldes bancaires conservée.
- Chaque transfert réussi crée exactement deux lignes ledger, opposées, corrélables.
- Chaque transfert échoué ne crée aucune ligne ledger et ne modifie aucun solde.
- Aucun changement mémoire non persisté n'est marqué propre.
- Fournir logs serveur, sorties SQL, versions de FXServer/oxmysql/DB et résultats T1-T11.

## Blocage de release
Le code 0.1.3 peut valider une transaction dont l'UPDATE débiteur affecte zéro ligne. Une procédure stockée (avec `ROW_COUNT()` et `SIGNAL`/rollback) ou une autre transaction vérifiable côté serveur SQL est nécessaire avant certification. Les deux écritures ledger doivent être corrélées par un identifiant unique de transfert.
