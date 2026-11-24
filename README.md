<div align="center">

<img src="https://raw.githubusercontent.com/syxezyou/syxezyou/main/assets/syx-galaxy.svg" width="100%" alt="SYX Galaxy"/>

# EV Framework

**Un framework RP modulaire pour FiveM — par SYX**

![Version](https://img.shields.io/badge/Archive-0.1.6-9333EA?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.4-000000?style=for-the-badge&logo=lua&logoColor=c084fc)
![FiveM](https://img.shields.io/badge/FiveM-Framework-000000?style=for-the-badge&logo=fivem&logoColor=c084fc)
![Statut](https://img.shields.io/badge/Statut-Expérimental-4c1d95?style=for-the-badge)

</div>

## Présentation

EV est un projet de framework RP autonome pour FiveM, organisé autour d'un noyau Lua, de modules internes, de données SQL et d'une interface NUI. Il vise une architecture lisible et extensible.

**État actuel :** archive 0.1.6 expérimentale, runtime déclaré 0.1.5. Cette publication de documentation précède l'importation des fichiers sources. Ne pas utiliser en production sans validation.

## Fonctionnalités de l'archive

- Gestion des personnages et des sessions joueur.
- Comptes cash, bank et black ; persistance et journalisation.
- Gestion des métiers, permissions et callbacks.
- Interface NUI de sélection des personnages.
- Localisation française et anglaise.
- Registre de modules internes avec dépendances.
- Modules comptes et métiers activés par défaut ; inventaire, véhicules et sociétés à l'état de squelettes désactivés.
- Schéma SQL et scripts de diagnostic des transferts.

## Prérequis

- FXServer / FiveM et Lua 5.4.
- MySQL ou MariaDB avec prise en charge des procédures stockées.
- oxmysql installé et configuré.
- Une base de test dédiée avant tout déploiement.

## Installation (après importation des sources)

1. Placer le dossier `ev` dans les ressources FiveM.
2. Créer une base de données dédiée et importer `ev/sql/install.sql`.
3. Configurer la connexion oxmysql dans `server.cfg`, sans partager les identifiants.
4. Charger les ressources dans cet ordre :

```cfg
set mysql_connection_string "mysql://USER:PASSWORD@127.0.0.1/ev"
ensure oxmysql
ensure ev
```

5. Configurer `ev/config/config.lua` et redémarrer le serveur de test.

Les modules font partie de la ressource `ev` : ne pas démarrer leurs manifests individuellement.

## Configuration

| Paramètre | Défaut |
| --- | --- |
| Locale | fr |
| Debug | false |
| SaveInterval | 300000 ms |
| MaxCharacters | 3 |
| DefaultGroup | user |
| StartingAccounts | cash=500, bank=2500, black=0 |
| Modules actifs | accounts, jobs |
| CallbackTimeout | 15000 ms |

## Commandes

| Commande | Fonction |
| --- | --- |
| /evchars | Sélection de personnage |
| /evwhoami | Informations sur le personnage |
| /evsetgroup ID GROUPE | Modification du groupe, console ou superadmin |

## API serveur

```lua
local player = exports.ev:GetPlayer(source)
if player then
    local balance = player:GetAccount('bank')
    print(balance)
end
```

Les exports documentés comprennent GetPlayer, RegisterCallback, HasPermission et GetVersion. L'enregistrement de modules par closure reste interne à la ressource. Valider les données client et les permissions côté serveur.

## Structure de l'archive

```text
ev/
├── fxmanifest.lua
├── config/
│   ├── config.lua
│   └── locales/
├── core/
│   ├── client/
│   ├── server/
│   └── shared/
├── modules/
│   ├── accounts/
│   ├── jobs/
│   ├── inventory-bridge/
│   ├── vehicles/
│   └── society/
├── sql/install.sql
├── web/
├── docs/
├── tests/
└── update.md
```

## Limites et feuille de route

- Valider l'appel de procédure stockée avec FXServer et oxmysql.
- Exécuter les scénarios de transfert T1 à T11 sur une base de test.
- Renforcer l'idempotence, les contrôles SQL et la cohérence entre cache et sauvegarde.
- Implémenter et tester le spawn.
- Compléter les modules désactivés.

Les tests d'intégration n'ont pas été exécutés dans l'environnement de préparation. La documentation historique comporte des indications devenues obsolètes ; privilégier l'ordre de démarrage ci-dessus.

## Licence et contributions

Aucune nouvelle licence n'est attribuée par cette publication. Les droits et conditions des composants tiers restent applicables. Signaler les problèmes via les issues, sans divulguer de secrets.

---

<div align="center">

**Projet SYX — [@syxezyou](https://github.com/syxezyou)**

Développer · Expérimenter · Améliorer

</div>
