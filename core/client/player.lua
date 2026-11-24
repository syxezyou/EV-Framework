EV.Player = nil
RegisterNetEvent('ev:client:loaded', function(data)
 EV.Player = data
 EV.ClientUtils.Notify(('Bienvenue %s %s'):format(data.firstname, data.lastname), 'success')
end)
