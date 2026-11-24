EV.Players = {}
function EV.GetPlayer(src) return EV.Players[tonumber(src)] end
local Player = {}; Player.__index = Player
function Player:GetAccount(name) return self.accounts[name] end
function Player:SetAccount(name, amount)
 if not EV.Config.StartingAccounts[name] or not EV.Utils.IsInteger(amount) or amount < 0 or amount > 2147483647 then return false end
 self.accounts[name] = amount; self.dirty = true; self.revision = (self.revision or 0) + 1
 EV.Events.Emit('accountChanged', self.source, name, amount)
 return true
end
function Player:AddAccount(name, amount)
 if not EV.Utils.IsInteger(amount) or amount < 0 then return false end
 local old = self:GetAccount(name); if not old then return false end
 return self:SetAccount(name, old + amount)
end
function Player:RemoveAccount(name, amount)
 if not EV.Utils.IsInteger(amount) or amount < 0 then return false end
 local old = self:GetAccount(name); if not old or old < amount then return false end
 return self:SetAccount(name, old - amount)
end
function Player:Public()
 return {source = self.source, characterId = self.characterId, firstname = self.firstname, lastname = self.lastname, group = self.group, job = self.job, grade = self.grade, accounts = EV.Utils.Copy(self.accounts)}
end
function EV.PlayerCreate(src, row, accounts)
 local player = setmetatable({source = src, characterId = row.id, firstname = row.firstname, lastname = row.lastname, group = row.permission_group, job = row.job, grade = row.job_grade, accounts = accounts, dirty = false, revision = 0, saving = false}, Player)
 EV.Players[src] = player
 return player
end
function EV.PlayerSave(player)
 if not player then return false end
 if player.saving then return false end
 if not player.dirty then return true end
 player.saving = true
 local revision = player.revision
 local queries = {}
 for name, amount in pairs(player.accounts) do
  queries[#queries+1] = {query = 'INSERT INTO ev_accounts (character_id, name, balance) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE balance = VALUES(balance)', values = {player.characterId, name, amount}}
 end
 local ok, result = pcall(EV.Database.Transaction, queries)
 player.saving = false
 if not ok or result ~= true then
  EV.Logger.Write('error', 'save_failed', {characterId = player.characterId})
  return false
 end
 if player.revision == revision then player.dirty = false end
 return true
end
function EV.PlayerUnload(src)
 local player = EV.GetPlayer(src)
 if not player then return end
 if not EV.PlayerSave(player) then
  EV.Logger.Write('error', 'unload_unsaved', {characterId = player.characterId})
 end
 EV.Players[src] = nil
 EV.Events.Emit('playerUnloaded', src)
end
AddEventHandler('playerDropped', function() EV.PlayerUnload(source) end)
