-- Module EV : inventory-bridge
EV.Modules.Register('inventory-bridge', {dependencies = {}, init = function(core)
 core.InventoryBridge = {provider = 'none'}
end})
