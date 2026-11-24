EV = EV or {}
EV.Config = {
  Locale = 'fr',
  Debug = false,
  SaveInterval = 300000,
  MaxCharacters = 3,
  DefaultGroup = 'user',
  Groups = {user = 0, mod = 10, admin = 20, superadmin = 30},
  StartingAccounts = {cash = 500, bank = 2500, black = 0},
  Modules = {accounts = true, jobs = true, ['inventory-bridge'] = false, vehicles = false, society = false},
  RateLimits = {
    callback = {count = 15, window = 10000},
    character = {count = 5, window = 10000}
  },
  CallbackTimeout = 15000,
  -- Licenses Rockstar à promouvoir manuellement en superadmin via console au premier boot
  -- Exemple: BootstrapAdmins = {'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'}
  BootstrapAdmins = {},
}
