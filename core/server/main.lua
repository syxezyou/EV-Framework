-- Démarrage et sauvegarde périodique, sans boucle par frame.
CreateThread(function()
  MySQL.ready(function()
    EV.Logger.Write('info', 'ready', {version = EV.Version})
    -- On marque ready et on tente de démarrer les modules déjà enregistrés.
    -- Les modules qui arrivent plus tard se démarreront eux-mêmes via Register.
    EV.Modules.StartAll()
    local function saveAll()
      for _, player in pairs(EV.Players) do
        local ok = EV.PlayerSave(player)
        if not ok then
          EV.Logger.Write('error', 'periodic_save_failed', {characterId = player.characterId})
        end
      end
      SetTimeout(EV.Config.SaveInterval, saveAll)
    end
    SetTimeout(EV.Config.SaveInterval, saveAll)
  end)
end)

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() then return end
  for _, player in pairs(EV.Players) do EV.PlayerSave(player) end
end)

-- Bootstrap admin : si la config contient des licenses, on les force en superadmin au load si pas de perso encore
-- (optionnel, pour le premier démarrage)
if EV.Config.BootstrapAdmins then
  CreateThread(function()
    Wait(5000)
    for _, lic in ipairs(EV.Config.BootstrapAdmins) do
      EV.Logger.Write('info', 'bootstrap_admin_note', {license = lic, note = 'Utilise /evsetgroup depuis la console une fois le perso créé'})
    end
  end)
end

exports('GetPlayer', function(src) return EV.GetPlayer(src) end)
exports('RegisterCallback', function(name, fn) EV.Callback.Register(name, fn) end)
exports('RegisterModule', function(name, spec) EV.Modules.Register(name, spec) end)
exports('HasPermission', function(src, group) return EV.Permissions.Has(src, group) end)
exports('GetVersion', function() return EV.Version end)
