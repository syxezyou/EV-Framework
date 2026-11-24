EV.ClientUtils = {}
function EV.ClientUtils.Notify(message, kind)
 SendNUIMessage({action = 'notify', message = tostring(message), kind = kind or 'info'})
end
