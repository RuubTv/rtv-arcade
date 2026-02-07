local QBCore = exports['qb-core']:GetCoreObject()

local function Notify(msg, nType)
    lib.notify({
        description = msg,
        type = nType or 'info'
    })
end

-- Check if table is array (numeric keys only)
local function IsArray(t)
    if type(t) ~= 'table' then return false end
    local hasNumberKey = false
    for k, _ in pairs(t) do
        if type(k) ~= 'number' then
            return false
        end
        hasNumberKey = true
    end
    return hasNumberKey
end

-- =========================
-- Minigame Runners
-- =========================

local function RunExportMinigame(mg, done)
    if not mg.resource or not mg.export then
        Notify('Minigame config missing resource/export.', 'error')
        done(false)
        return
    end

    local exp = exports[mg.resource]
    if not exp or type(exp[mg.export]) ~= 'function' then
        Notify(('Export not found: %s:%s'):format(mg.resource, mg.export), 'error')
        done(false)
        return
    end

    local style = mg.style or 'return'
    local args = mg.args

    if style == 'callback' then
        local cb = function(success)
            done(success == true)
        end

        if args == nil then
            exp[mg.export](cb)
        else
            if IsArray(args) then
                exp[mg.export](cb, table.unpack(args))
            else
                exp[mg.export](cb, args)
            end
        end

        return
    end

    -- return style
    local success
    if args == nil then
        success = exp[mg.export]()
    else
        if IsArray(args) then
            success = exp[mg.export](table.unpack(args))
        else
            success = exp[mg.export](args)
        end
    end

    done(success == true)
end

local function RunEventMinigame(mg, done)
    if not mg.startEvent or not mg.resultEvent then
        Notify('Event minigame config missing startEvent/resultEvent.', 'error')
        done(false)
        return
    end

    local finished = false
    local handler
    local timeoutMs = (mg.timeout or 60) * 1000

    handler = AddEventHandler(mg.resultEvent, function(success)
        if finished then return end
        finished = true
        RemoveEventHandler(handler)
        done(success == true)
    end)

    -- start minigame
    if mg.args ~= nil then
        TriggerEvent(mg.startEvent, mg.args)
    else
        TriggerEvent(mg.startEvent)
    end

    -- fail-safe timeout
    CreateThread(function()
        Wait(timeoutMs)
        if finished then return end
        finished = true
        RemoveEventHandler(handler)
        done(false)
    end)
end

local function StartMachineMinigame(machineId)
    local machine = Config.ArcadeMachines[machineId]
    if not machine then
        Notify('Unknown arcade machine.', 'error')
        return
    end

    local function Finish(success)
        TriggerServerEvent('rtv-arcade:server:FinishGame', machineId, success == true)
    end

    local mg = machine.Minigame

    -- fallback
    if not mg then
        local ok = lib.skillCheck({ 'easy', 'medium', 'hard' }, { 'w', 'a', 's', 'd' })
        Finish(ok)
        return
    end

    if mg.type == 'event' then
        RunEventMinigame(mg, Finish)
        return
    end

    RunExportMinigame(mg, Finish)
end

RegisterNetEvent('rtv-arcade:client:StartMinigame', function(machineId)
    StartMachineMinigame(machineId)
end)

-- =========================
-- Arcade Machine Targets (Boxzones)
-- =========================
CreateThread(function()
    for id, machine in pairs(Config.ArcadeMachines) do
        if machine.coords then
            local size = machine.zoneSize or vec3(0.8, 0.8, 1.2)
            local rot = machine.coords.w or 0.0
            local dist = machine.distance or Config.TargetDistance or 2.0

            exports.ox_target:addBoxZone({
                coords = vec3(machine.coords.x, machine.coords.y, machine.coords.z),
                size = size,
                rotation = rot,
                debug = false,
                options = {
                    {
                        name = ('rtv-arcade-machine-%s'):format(id),
                        icon = machine.icon or 'fa-solid fa-gamepad',
                        label = machine.label or 'Arcade Machine',
                        distance = dist,
                        onSelect = function()
                            TriggerServerEvent('rtv-arcade:server:TryStartGame', id)
                        end
                    }
                }
            })
        else
            Notify(('Machine %s has no coords configured.'):format(id), 'error')
        end
    end
end)

-- =========================
-- Prize Counter / Exchange Shop
-- =========================

local function OpenPrizeCounter()
    local shop = Config.ExchangeShop
    if not shop or not shop.enabled then return end

    local options = {}
    for i, v in ipairs(shop.items or {}) do
        options[#options + 1] = {
            title = v.label or v.item,
            description = ('Costs %d tickets | You receive x%d'):format(v.tickets or 0, v.amount or 1),
            icon = 'fa-solid fa-ticket',
            onSelect = function()
                TriggerServerEvent('rtv-arcade:server:ExchangeTickets', i)
            end
        }
    end

    if #options == 0 then
        Notify('No prizes configured.', 'error')
        return
    end

    lib.registerContext({
        id = 'rtv-arcade-prizecounter',
        title = 'RTV Prize Counter',
        options = options
    })

    lib.showContext('rtv-arcade-prizecounter')
end

CreateThread(function()
    local shop = Config.ExchangeShop
    if not shop or not shop.enabled then return end

    local pedModel = shop.ped and shop.ped.model
    local pedCoords = shop.ped and shop.ped.coords
    if not pedModel or not pedCoords then return end

    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    local ped = CreatePed(0, pedModel, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedCoords.w, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    exports.ox_target:addBoxZone({
        coords = vec3(pedCoords.x, pedCoords.y, pedCoords.z),
        size = shop.target.size or vec3(1.5, 1.5, 2.0),
        rotation = pedCoords.w,
        debug = false,
        options = {
            {
                name = 'rtv-arcade-prizecounter',
                icon = shop.target.icon or 'fa-solid fa-ticket',
                label = shop.target.label or 'Prize Counter',
                distance = shop.target.distance or 2.0,
                onSelect = function()
                    OpenPrizeCounter()
                end
            }
        }
    })
end)
