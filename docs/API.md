# EV API 0.1.0
## Serveur
`exports.ev:GetPlayer(source)` retourne un objet joueur **côté serveur uniquement** ou `nil`.
`exports.ev:RegisterCallback(name, function(source, ...))` expose un callback distant. **Ne jamais faire confiance aux arguments client.**
`exports.ev:RegisterModule(name, {dependencies={}, init=function(EV) ... end})` enregistre un module.
`exports.ev:HasPermission(source, 'admin')` vérifie le niveau.
En interne : `EV.GetPlayer`, `EV.Callback.Register`, `EV.Events.On/Emit`, `EV.Modules.Register`.
Objet joueur : `:GetAccount(name)`, `:SetAccount(name, amount)`, `:AddAccount(name, amount)`, `:RemoveAccount(name, amount)`, `:Public()`.
## Client
`exports.ev:GetPlayerData()` fournit le snapshot client; `exports.ev:Notify(message, kind)` affiche une notification.
`EV.Callback.Trigger(name, function(success, ...) end, ...)` invoque un callback serveur.
`EV.Callback.Register(name, fn)` répond à une demande serveur (pas de retour RPC).
## Commandes
`/evchars`, `/evwhoami`, `/evsetgroup [id] [groupe]` (console ou superadmin).
## Événements internes
`playerLoaded`, `playerUnloaded`, `accountChanged`, `jobChanged`, `permissionChanged`.
## Installation
1. Importer `sql/install.sql` dans la base configurée pour oxmysql.
2. Installer `oxmysql` et placer `ensure oxmysql` puis `ensure ev` dans `server.cfg`.
3. Les sous-dossiers `modules/*` sont des ressources séparées : les copier dans un répertoire de ressources scanné, puis `ensure ev-accounts`, `ensure ev-jobs` etc. Les noms de dossiers doivent correspondre au nom de ressource souhaité (renommer les dossiers au besoin).
4. Redémarrer le serveur et lancer `/evchars`.
5. La création et la sélection de personnages nécessitent une licence Rockstar valide.
**Important** : le chargement des modules doit être orchestré après leur enregistrement ; voir `update.md` avant toute mise en production.


## Note 0.1.2
`EV.Modules.Register` est réservé aux scripts chargés dans la ressource `ev`. L'export `RegisterModule` est conservé pour compatibilité historique mais n'est pas une interface supportée pour des modules externes à closure. Les opérations financières ne sont pas transactionnelles entre deux joueurs.
