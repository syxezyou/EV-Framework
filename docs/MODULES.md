# Modules EV — 0.1.2

Les modules sont des dossiers internes au runtime `ev` et sont chargés via `ev/fxmanifest.lua`, dans un ordre déterministe. Leurs manifests locaux décrivent le module, mais **ne doivent pas être démarrés séparément** dans `server.cfg`. Cette décision supprime le passage de closures, tables et métatables Lua entre ressources FiveM et garantit l'accès au même namespace EV.

## Démarrage

`ensure oxmysql`, puis `ensure ev`. Ne pas ajouter `ensure ev-accounts` ou `ensure ev-jobs` : ces ressources n'existent pas en tant que ressources séparées dans cette version. Le chargement des scripts enregistre les modules, puis `EV.Modules.StartAll()` initialise ceux qui sont activés dans `EV.Config.Modules`.

## API

`EV.Modules.Register(name, {dependencies = {'accounts'}, init = function(core) ... end})` est une API **interne** (même runtime). Le registre est idempotent ; les dépendances désactivées bloquent le module dépendant. Ajouter un module en créant `modules/<nom>/server.lua` et en l'insérant dans `server_scripts` après `core/server/modules.lua`.

## État

`accounts` et `jobs` ont des opérations serveur. `inventory-bridge`, `vehicles` et `society` sont des squelettes désactivés par défaut. Le transfert `accounts` n'est PAS atomique entre joueurs : il ne doit pas être exposé aux clients ni utilisé pour une économie de production. Une transaction SQL avec ledger est requise.

## Compatibilité

Les exports `GetPlayer`, `RegisterCallback`, `RegisterModule`, `HasPermission`, `GetVersion` sont conservés. `RegisterModule` via export externe avec `spec.init` n'est plus supporté : l'initialisation de modules par closure doit rester dans le runtime EV. Prévoir des exports granulaires pour les extensions externes.
