fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'ev'
author 'ChatGPT'
version '0.1.5'
description 'EV Framework'
dependency 'oxmysql'
shared_scripts {'config/config.lua','config/locales/fr.lua','config/locales/en.lua','core/shared/version.lua','core/shared/enums.lua','core/shared/utils.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','core/server/database.lua','core/server/logger.lua','core/server/events.lua','core/server/permissions.lua','core/server/player.lua','core/server/callbacks.lua','core/server/characters.lua','core/server/modules.lua','modules/accounts/server.lua','modules/jobs/server.lua','modules/inventory-bridge/server.lua','modules/vehicles/server.lua','modules/society/server.lua','core/server/commands.lua','core/server/main.lua'}
client_scripts {'core/client/utils.lua','core/client/callbacks.lua','core/client/player.lua','core/client/main.lua'}
ui_page 'web/index.html'
files {'web/index.html','web/style.css','web/app.js'}
