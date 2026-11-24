EV.Events = {handlers = {}, limits = {}}
function EV.Events.Allow(src, key, count, window)
 if type(src) ~= 'number' or src <= 0 then return false end
 local now = GetGameTimer(); local id = tostring(src) .. ':' .. key
 local item = EV.Events.limits[id]
 if not item or now - item.start >= window then item = {start = now, count = 0}; EV.Events.limits[id] = item end
 item.count = item.count + 1
 return item.count <= count
end
function EV.Events.On(name, handler)
 assert(type(name) == 'string' and type(handler) == 'function')
 EV.Events.handlers[name] = EV.Events.handlers[name] or {}
 table.insert(EV.Events.handlers[name], handler)
end
function EV.Events.Emit(name, ...)
 for _, handler in ipairs(EV.Events.handlers[name] or {}) do
  local ok, err = pcall(handler, ...)
  if not ok then EV.Logger.Write('error', 'event_handler', {event = name, error = tostring(err)}) end
 end
end
AddEventHandler('playerDropped', function()
 local prefix = tostring(source) .. ':'
 for key in pairs(EV.Events.limits) do if key:sub(1, #prefix) == prefix then EV.Events.limits[key] = nil end end
end)
