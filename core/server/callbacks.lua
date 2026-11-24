EV.Callback = {handlers = {}}
function EV.Callback.Register(name, fn)
 assert(type(name) == 'string' and type(fn) == 'function')
 EV.Callback.handlers[name] = fn
end
RegisterNetEvent('ev:server:callback', function(requestId, name, ...)
 local src = source
 local rule = EV.Config.RateLimits.callback
 if not EV.Events.Allow(src, 'callback', rule.count, rule.window) then return end
 if not EV.Utils.IsInteger(requestId) or requestId < 1 or type(name) ~= 'string' or #name > 80 then return end
 local handler = EV.Callback.handlers[name]
 if not handler then return TriggerClientEvent('ev:client:callback', src, requestId, false, 'unknown_callback') end
 local args = {...}
 local ok, result = pcall(function() return table.pack(handler(src, table.unpack(args))) end)
 if not ok then
  EV.Logger.Write('error', 'callback_failed', {name = name, source = src, error = tostring(result)})
  return TriggerClientEvent('ev:client:callback', src, requestId, false, 'internal_error')
 end
 TriggerClientEvent('ev:client:callback', src, requestId, true, table.unpack(result, 1, result.n))
end)
function EV.Callback.Trigger(src, name, ...)
 TriggerClientEvent('ev:client:request', src, name, ...)
end
