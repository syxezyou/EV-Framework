EV.Utils = {}
function EV.Utils.Trim(s) if type(s) ~= 'string' then return '' end return (s:gsub('^%s+', ''):gsub('%s+$', '')) end
function EV.Utils.IsInteger(n) return type(n) == 'number' and n % 1 == 0 end
function EV.Utils.Copy(t) if type(t) ~= 'table' then return t end local r = {}; for k,v in pairs(t) do r[k] = EV.Utils.Copy(v) end return r end
