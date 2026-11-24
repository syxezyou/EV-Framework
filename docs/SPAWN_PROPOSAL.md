# Proposition spawn EV (après sécurisation et tests bancaires)

## Architecture
- Ajouter `pos_x`, `pos_y`, `pos_z`, `pos_heading` à `ev_characters` via migration SQL versionnée ; valeurs NULL pour les personnages existants.
- `EV.Spawn.GetPosition(src)` lit la position du personnage sélectionné ; position par défaut configurable si aucune position enregistrée.
- `EV.Spawn.SavePosition(src, coords)` n'accepte jamais un `character_id` fourni par le client ; il utilise `EV.GetPlayer(src).characterId`.
- Client : à `ev:client:loaded`, fermeture de la sélection, attente du chargement du monde, demande de position serveur, fade out, `RequestCollisionAtCoord`, placement du ped, heading, fade in.
- Ne jamais utiliser les coordonnées envoyées par le client pour téléporter un autre joueur.
- Pour sauvegarder les coordonnées, valider nombres finis, bornes monde, personnage actif, et limiter la fréquence. Sauvegarde sur intervalle modéré et déconnexion, avec stratégie de reprise si la DB échoue.
- Éviter les doubles spawns avec un état `spawning`/`spawned` par session et nettoyage au unload.
- Prévoir un adaptateur skin ultérieur, sans dépendance ESX/QB.

## Tests attendus
Première connexion, reconnexion, changement de personnage, déconnexion pendant spawn, position invalide, personnage supprimé, restart ressource, collision non chargée, double callback, interruption DB.

Statut : proposition uniquement ; non implémentée dans cette passe, conformément à la priorité donnée aux tests de transfert.
