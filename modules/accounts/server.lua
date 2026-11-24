-- Module EV : accounts
EV.Modules.Register('accounts', {
  dependencies = {},
  init = function(core)
    core.Accounts = core.Accounts or {}

    local function generateTransferId()
      return ('%s-%s'):format(os.time(), math.random(100000, 999999))
    end

    function core.Accounts.Transfer(src, target, amount)
      local a = core.GetPlayer(src)
      local b = core.GetPlayer(target)
      if not a or not b or a == b or not core.Utils.IsInteger(amount) or amount <= 0 then return false end

      if a.transferring or b.transferring then
        core.Logger.Write('warn', 'transfer_contention', {from = src, to = target})
        return false
      end
      a.transferring = true
      b.transferring = true

      local transferId = generateTransferId()
      local success = false
      local ok, err = pcall(function()
        -- Appel de la procédure stockée qui fait le contrôle ROW_COUNT et rollback
        local result = core.Database.Query('CALL ev_transfer_bank(?, ?, ?, ?)', {a.characterId, b.characterId, amount, transferId})
        -- Si la procédure a SIGNAL, oxmysql lève une erreur → pcall échoue
        success = true
      end)

      a.transferring = false
      b.transferring = false

      if not ok or not success then
        core.Logger.Write('error', 'bank_transfer_failed', {from = src, to = target, amount = amount, transferId = transferId, error = tostring(err)})
        return false
      end

      -- Sync mémoire après succès réel de la procédure
      -- On ne force PAS dirty=false pour ne pas effacer d'autres modifications concurrentes
      local oldA = a:GetAccount('bank') or 0
      local oldB = b:GetAccount('bank') or 0
      a:SetAccount('bank', oldA - amount)
      b:SetAccount('bank', oldB + amount)
      -- Le SetAccount a déjà incrémenté revision et mis dirty=true
      -- C'est correct : le prochain save réécrira la même valeur (idempotent)

      core.Logger.Write('info', 'bank_transfer_sp', {from = src, to = target, amount = amount, transferId = transferId})
      return true
    end
  end
})
