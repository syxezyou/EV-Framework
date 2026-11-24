# Conventions EV
- Lua 5.4, variables locales par défaut, namespace `EV` partagé uniquement dans une ressource.
- Aucune confiance dans les arguments du client ; `source` serveur fait autorité.
- SQL paramétré via `?`, jamais de concaténation de données utilisateur.
- Un événement réseau sensible doit être limité en fréquence et vérifier son autorisation.
- Pas de boucle par frame en idle ; sauvegardes via `SetTimeout`.
- Les évolutions d'API publiques demandent une entrée dans `update.md` et un incrément SemVer.
- Les modules ne partagent pas automatiquement le namespace Lua de la ressource `ev` ; passer par des exports ou des événements sécurisés.


## 0.1.2 — Exécution des modules
Les scripts de modules s'exécutent dans la ressource `ev` uniquement. Aucun export inter-ressource ne doit accepter une table `EV` ou un callback d'initialisation transportant des closures. Les extensions externes utiliseront des exports granulaires.
