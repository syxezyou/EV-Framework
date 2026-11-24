EV.Permissions = {}
function EV.Permissions.Has(src, group)
 local player = EV.GetPlayer(src)
 if not player then return false end
 return (EV.Config.Groups[player.group] or 0) >= (EV.Config.Groups[group] or math.huge)
end
function EV.Permissions.Set(src, group)
 if not EV.Config.Groups[group] then return false end
 local player = EV.GetPlayer(src); if not player then return false end
 local updated = EV.Database.Update('UPDATE ev_characters SET permission_group = ? WHERE id = ?', {group, player.characterId})
 if updated ~= 1 then return false end
 player.group = group
 EV.Events.Emit('permissionChanged', src, group)
 return true
end
