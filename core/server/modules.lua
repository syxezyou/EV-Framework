EV.Modules = {registry = {}, ready = false}

local function canStart(name)
  local item = EV.Modules.registry[name]
  if not item then return false, 'Dépendance absente: ' .. name end
  if item.started then return true end
  if EV.Config.Modules[name] == false then return false, 'Module désactivé requis: ' .. name end
  return true
end

local visiting = {}

function EV.Modules.Start(name)
  local ok, err = canStart(name)
  if not ok then error(err) end
  local item = EV.Modules.registry[name]
  if item.started then return end
  if visiting[name] then error('Dépendance circulaire: ' .. name) end

  visiting[name] = true
  for _, dep in ipairs(item.spec.dependencies or {}) do
    EV.Modules.Start(dep)
  end
  visiting[name] = nil

  local success, initErr = pcall(item.spec.init, EV)
  if not success then
    EV.Logger.Write('error', 'module_init_failed', {name = name, error = tostring(initErr)})
    error('Init module ' .. name .. ' a échoué: ' .. tostring(initErr))
  end
  item.started = true
  EV.Logger.Write('info', 'module_started', {name = name})
end

function EV.Modules.Register(name, spec)
  assert(type(name) == 'string' and type(spec) == 'table' and type(spec.init) == 'function', 'Spec module invalide')
  if EV.Modules.registry[name] then
    EV.Logger.Write('warn', 'module_reregister', {name = name})
    -- Idempotent : on autorise le re-register pour hot-reload, on reset started
    EV.Modules.registry[name].started = false
  else
    EV.Modules.registry[name] = {spec = spec, started = false}
  end
  EV.Modules.registry[name].spec = spec

  if EV.Modules.ready and EV.Config.Modules[name] ~= false then
    local ok, err = pcall(EV.Modules.Start, name)
    if not ok then
      EV.Logger.Write('error', 'module_late_start_failed', {name = name, error = tostring(err)})
    end
  end
end

function EV.Modules.StartAll()
  EV.Modules.ready = true
  for name in pairs(EV.Modules.registry) do
    if EV.Config.Modules[name] ~= false then
      local ok, err = pcall(EV.Modules.Start, name)
      if not ok then
        EV.Logger.Write('error', 'module_start_failed', {name = name, error = tostring(err)})
      end
    end
  end
end

-- Hot-reload support : si une ressource module redémarre, elle re-register et on tente le start
AddEventHandler('onResourceStart', function(resource)
  -- Les modules appellent RegisterModule eux-mêmes au load, donc on n'a rien à faire de plus ici
  -- mais on peut log
end)
