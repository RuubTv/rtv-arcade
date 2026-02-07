local QBCore = exports['qb-core']:GetCoreObject()

local ActiveGames = {} -- src -> machineId
local LastStart = {}   -- src -> os.time()

local function Notify(src, msg, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        description = msg,
        type = nType or 'info'
    })
end

local function GetTicketReward(machine)
    local r = machine.reward
    if r and r.minTickets and r.maxTickets then
        local minT = tonumber(r.minTickets) or Config.DefaultTicketReward
        local maxT = tonumber(r.maxTickets) or minT
        if maxT < minT then maxT = minT end
        return math.random(minT, maxT)
    end
    return Config.DefaultTicketReward
end

local function GetItemCount(src, itemName)
    -- ox_inventory Search returns either table results or count depending on type,
    -- but "count" is the easiest for this use case.
    return exports.ox_inventory:Search(src, 'count', itemName) or 0
end

local function AddItem(src, itemName, amount)
    return exports.ox_inventory:AddItem(src, itemName, amount)
end

local function RemoveItem(src, itemName, amount)
    return exports.ox_inventory:RemoveItem(src, itemName, amount)
end

RegisterNetEvent('rtv-arcade:server:TryStartGame', function(machineId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local machine = Config.ArcadeMachines[machineId]
    if not machine then
        Notify(src, 'This arcade machine is not configured.', 'error')
        return
    end

    -- Cooldown
    local now = os.time()
    if LastStart[src] and (now - LastStart[src]) < (Config.StartCooldownSeconds or 2) then
        Notify(src, 'Please wait a moment...', 'error')
        return
    end
    LastStart[src] = now

    -- Prevent double-start
    if ActiveGames[src] then
        Notify(src, 'You are already in a minigame.', 'error')
        return
    end

    -- Payment via QBCore money
    local account = machine.account or 'cash'
    if not Config.AllowedAccounts[account] then
        Notify(src, 'Invalid payment account.', 'error')
        return
    end

    local fee = tonumber(machine.entryFee) or 0
    if fee > 0 then
        local balance = Player.Functions.GetMoney(account)
        if balance < fee then
            Notify(src, ('Not enough %s.'):format(account == 'cash' and 'cash' or 'bank funds'), 'error')
            return
        end

        Player.Functions.RemoveMoney(account, fee, 'rtv-arcade-entryfee')
        Notify(src, ('Entry fee paid: %d'):format(fee), 'success')
    end

    ActiveGames[src] = machineId
    TriggerClientEvent('rtv-arcade:client:StartMinigame', src, machineId)
end)

RegisterNetEvent('rtv-arcade:server:FinishGame', function(machineId, won)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not ActiveGames[src] or ActiveGames[src] ~= machineId then
        return
    end
    ActiveGames[src] = nil

    if not won then
        Notify(src, 'You lost. Better luck next time!', 'error')
        return
    end

    local machine = Config.ArcadeMachines[machineId]
    if not machine then return end

    local tickets = GetTicketReward(machine)
    if tickets <= 0 then tickets = 1 end

    local ok = AddItem(src, Config.TicketItem, tickets)
    if not ok then
        Notify(src, 'Inventory full. Could not give tickets.', 'error')
        return
    end

    Notify(src, ('You won! You received %d ticket(s).'):format(tickets), 'success')
end)

RegisterNetEvent('rtv-arcade:server:ExchangeTickets', function(index)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local shop = Config.ExchangeShop
    if not shop or not shop.enabled then return end

    local prize = shop.items and shop.items[index]
    if not prize then
        Notify(src, 'Invalid prize selection.', 'error')
        return
    end

    local needed = tonumber(prize.tickets) or 0
    local amount = tonumber(prize.amount) or 1
    if needed <= 0 then
        Notify(src, 'Prize config error: invalid ticket cost.', 'error')
        return
    end

    local current = GetItemCount(src, Config.TicketItem)
    if current < needed then
        Notify(src, ('Not enough tickets. Need %d, you have %d.'):format(needed, current), 'error')
        return
    end

    -- Remove tickets
    local removed = RemoveItem(src, Config.TicketItem, needed)
    if not removed then
        Notify(src, 'Could not remove tickets.', 'error')
        return
    end

    -- Give prize
    local ok = AddItem(src, prize.item, amount)
    if not ok then
        -- refund tickets if prize fails
        AddItem(src, Config.TicketItem, needed)
        Notify(src, 'Inventory full. Could not give prize (tickets refunded).', 'error')
        return
    end

    Notify(src, ('Exchanged %d tickets for %dx %s.'):format(needed, amount, prize.label or prize.item), 'success')
end)

AddEventHandler('playerDropped', function()
    local src = source
    ActiveGames[src] = nil
    LastStart[src] = nil
end)
