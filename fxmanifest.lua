fx_version 'cerulean'
game 'gta5'

name 'rtv-arcade'
author 'RuubTv | RTV Scripts'
description 'Arcade machines with generic minigame support, entry fees, ticket rewards, and prize counter'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    '@ox_target/init.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}
