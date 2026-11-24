RegisterCommand('evwhoami', function(src)
 if src == 0 then return print('[EV] Commande réservée aux joueurs') end
 local player = EV.GetPlayer(src)
 TriggerClientEvent('chat:addMessage', src, {args = {'EV', player and (player.firstname .. ' ' .. player.lastname .. ' #' .. player.characterId) or 'Aucun personnage sélectionné'}})
end, false)
RegisterCommand('evsetgroup', function(src, args)
 if src ~= 0 and not EV.Permissions.Has(src, 'superadmin') then return end
 local target = tonumber(args[1]); local group = args[2]
 if not target or not group or not EV.Permissions.Set(target, group) then return end
 EV.Logger.Write('warn', 'group_changed', {actor = src, target = target, group = group})
end, false)
