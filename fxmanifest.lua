fx_version 'adamant'

author 'guillerp#1928'

description 'A garage, with no garages.'

game 'gta5'

client_scripts {
    "client/client.lua",
    "config.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua",
    "config.lua"
}

