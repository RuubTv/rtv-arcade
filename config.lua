Config = {}

Config.Tag = 'rtv'

-- Ticket item
Config.TicketItem = 'arcade_ticket'
Config.DefaultTicketReward = 5

-- Allowed payment accounts
Config.AllowedAccounts = {
    cash = true,
    bank = true,
}

-- Target defaults
Config.TargetDistance = 2.0

-- Anti-spam
Config.StartCooldownSeconds = 2

-- =========================
-- Arcade Machines
-- Each machine has coords + zone size + rotation (heading).
-- =========================
Config.ArcadeMachines = {
    -- =========================================
    -- tgg-minigames examples (return style)
    -- =========================================
    [1] = {
        label = 'Masher',
        icon = 'fa-solid fa-hand-fist',

        coords = vec4(-1652.10, -1077.20, 13.15, 150.0),
        zoneSize = vec3(0.8, 0.8, 1.2),
        distance = 2.0,

        entryFee = 200,
        account = 'cash',

        reward = { minTickets = 3, maxTickets = 6 },

        Minigame = {
            type = 'export',      -- export | event
            resource = 'tgg-minigames',
            export = 'Masher',
            style = 'return',     -- return | callback
            args = {
                requiredPresses = 20,
                timeLimit = 5
            }
        }
    },
    -- =========================================
    -- Example: export callback style (generic)
    -- =========================================
    --[[ [2] = {
        label = 'Callback Example',
        icon = 'fa-solid fa-bolt',

        coords = vec4(-1656.90, -1073.60, 13.15, 150.0),
        zoneSize = vec3(0.8, 0.8, 1.2),

        entryFee = 150,
        account = 'cash',

        reward = { minTickets = 2, maxTickets = 5 },

        Minigame = {
            type = 'export',
            resource = 'my-callback-minigame',
            export = 'StartGame',
            style = 'callback',
            -- args can be array (varargs) OR object (single table)
            args = { 'medium', 30 }
        }
    },
    -- =========================================
    -- Example: event based minigame (generic)
    -- =========================================
    [3] = {
        label = 'Event Based Example',
        icon = 'fa-solid fa-code',

        coords = vec4(-1657.70, -1073.00, 13.15, 150.0),
        zoneSize = vec3(0.8, 0.8, 1.2),

        entryFee = 150,
        account = 'bank',

        reward = { minTickets = 2, maxTickets = 5 },

        Minigame = {
            type = 'event',
            startEvent = 'somegame:client:start',
            resultEvent = 'somegame:client:result',
            timeout = 60,
            args = { difficulty = 'hard' }
        }
    },
    -- ============================================
    -- Fallback: ox_lib skillcheck if Minigame=nil
    -- ============================================
    [4] = {
        label = 'Skillcheck (Fallback)',
        icon = 'fa-solid fa-gamepad',

        coords = vec4(-1658.50, -1072.40, 13.15, 150.0),
        zoneSize = vec3(0.8, 0.8, 1.2),

        entryFee = 100,
        account = 'cash',

        reward = { minTickets = 1, maxTickets = 3 },

        Minigame = nil
    }, ]]--
}

-- =========================
-- Prize Counter / Exchange Shop
-- =========================
Config.ExchangeShop = {
    enabled = true,

    ped = {
        model = `csb_anita`,
        coords = vector4(-1658.55, -1074.21, 13.15, 150.0)
    },

    target = {
        size = vec3(1.5, 1.5, 2.0),
        icon = 'fa-solid fa-ticket',
        label = 'RTV Prize Counter',
        distance = 2.0
    },

    items = {
        { item = 'sandwich', tickets = 5, amount = 1, label = 'Sandwich' },
        { item = 'water_bottle', tickets = 5, amount = 1, label = 'Water' },
        { item = 'repairkit', tickets = 20, amount = 1, label = 'Repair Kit' },
    }
}
