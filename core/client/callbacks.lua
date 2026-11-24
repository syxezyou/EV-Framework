EV.Callback = {pending = {}, handlers = {}, nextId = 0}
function EV.Callback.Trigger(name, cb, ...)
 assert(type(name) == 'string' and type(cb) == 'function')
 EV.Callback.nextId = EV.Callback.nextId + 1
 local id = EV.Callback.nextId
 EV.Callback.pending[id] = cb
 TriggerServerEvent('ev:server:callback', id, name, ...)
 SetTimeout(EV.Config.CallbackTimeout, function()
  if EV.Callback.pending[id] then EV.Callback.pending[id] = nil; cb(false, 'timeout') end
 end)
end
function EV.Callback.Register(name, fn) EV.Callback.handlers[name] = fn end
RegisterNetEvent('ev:client:callback', function(id, success, ...)
 local cb = EV.Callback.pending[id]; if not cb then return end
 EV.Callback.pending[id] = nil
 cb(success, ...)
end)
RegisterNetEvent('ev:client:request', function(name, ...)
 local fn = EV.Callback.handlers[name]; if fn then fn(...) end
end)
