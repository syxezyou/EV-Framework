EV.Logger = {}
function EV.Logger.Write(level, action, data)
 local payload = {version = EV.Version, level = level, action = action, data = data or {}, timestamp = os.time()}
 print('[EV] ' .. json.encode(payload))
end
