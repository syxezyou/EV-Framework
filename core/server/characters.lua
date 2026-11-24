EV.Characters = {}
local locks = {} -- protection contre les races sur création/sélection (Lua single-thread + yields)

local function identifier(src)
  for _, value in ipairs(GetPlayerIdentifiers(src)) do
    if value:sub(1, 8) == 'license:' then return value end
  end
  return nil
end

local function withLicenseLock(license, fn)
  if locks[license] then
    EV.Logger.Write('warn', 'character_lock_contention', {license = license})
    return nil, 'busy'
  end
  locks[license] = true
  local ok, result = pcall(fn)
  locks[license] = nil
  if not ok then
    EV.Logger.Write('error', 'character_lock_error', {error = tostring(result)})
    return nil, 'error'
  end
  return result
end

function EV.Characters.List(src)
  local license = identifier(src)
  if not license then return {} end
  return EV.Database.Query('SELECT id, firstname, lastname, job, job_grade FROM ev_characters WHERE license = ? ORDER BY id LIMIT ?', {license, EV.Config.MaxCharacters}) or {}
end

local function validName(s)
  return type(s) == 'string' and #s >= 2 and #s <= 32 and s:match('^[%a%s%-]+$') ~= nil
end

function EV.Characters.Create(src, first, last)
  local license = identifier(src)
  if not license or EV.GetPlayer(src) then return nil end

  local rule = EV.Config.RateLimits.character or {count = 5, window = 10000}
  if not EV.Events.Allow(src, 'character:create', rule.count, rule.window) then
    EV.Logger.Write('warn', 'character_create_ratelimit', {source = src})
    return nil
  end

  first, last = EV.Utils.Trim(first), EV.Utils.Trim(last)
  if not validName(first) or not validName(last) then return nil end

  return withLicenseLock(license, function()
    if not GetPlayerName(src) or identifier(src) ~= license then return nil end
    local rows = EV.Database.Query('SELECT id FROM ev_characters WHERE license = ? LIMIT ?', {license, EV.Config.MaxCharacters + 1})
    if not rows or #rows >= EV.Config.MaxCharacters then return nil end

    local id = EV.Database.Insert('INSERT INTO ev_characters (license, firstname, lastname, permission_group, job, job_grade) VALUES (?, ?, ?, ?, ?, ?)', {license, first, last, EV.Config.DefaultGroup, 'unemployed', 0})
    if not id then return nil end

    local queries = {}
    for name, balance in pairs(EV.Config.StartingAccounts) do
      queries[#queries + 1] = {query = 'INSERT INTO ev_accounts (character_id, name, balance) VALUES (?, ?, ?)', values = {id, name, balance}}
    end
    local ok, committed = pcall(EV.Database.Transaction, queries)
    if not ok or committed ~= true then
      -- Rollback best-effort
      EV.Database.Update('DELETE FROM ev_characters WHERE id = ?', {id})
      EV.Logger.Write('error', 'character_accounts_failed', {characterId = id, source = src})
      return nil
    end

    EV.Logger.Write('info', 'character_created', {characterId = id, source = src})
    return id
  end)
end

function EV.Characters.Select(src, id)
  local license = identifier(src)
  if not license or not EV.Utils.IsInteger(id) or EV.GetPlayer(src) then return false end

  local rule = EV.Config.RateLimits.character or {count = 5, window = 10000}
  if not EV.Events.Allow(src, 'character:select', rule.count, rule.window) then return false end

  local result = withLicenseLock(license, function()
    local row = EV.Database.Single('SELECT * FROM ev_characters WHERE id = ? AND license = ?', {id, license})
    if not row or not GetPlayerName(src) or identifier(src) ~= license or EV.GetPlayer(src) then return false end

    local accountRows = EV.Database.Query('SELECT name, balance FROM ev_accounts WHERE character_id = ?', {id}) or {}
    local accounts = EV.Utils.Copy(EV.Config.StartingAccounts)
    for name in pairs(accounts) do accounts[name] = 0 end
    for _, account in ipairs(accountRows) do
      if accounts[account.name] ~= nil then accounts[account.name] = account.balance end
    end

    if not GetPlayerName(src) or identifier(src) ~= license or EV.GetPlayer(src) then return false end
    local player = EV.PlayerCreate(src, row, accounts)
    TriggerClientEvent('ev:client:loaded', src, player:Public())
    EV.Events.Emit('playerLoaded', src, player)
    return true
  end)
  return result == true
end

EV.Callback = EV.Callback or {}
EV.Callback.Register('characters:list', function(src) return EV.Characters.List(src) end)
EV.Callback.Register('characters:create', function(src, first, last) return EV.Characters.Create(src, first, last) end)
EV.Callback.Register('characters:select', function(src, id) return EV.Characters.Select(src, id) end)
