-- Needs fixed - Should only load items once when created, then never restock them - Should save the stash after loading & shouldn't restock, you should be able to take items out & put items in - Max cap 125kg

local Bags = {}

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

RegisterNetEvent('kdb:client:deployBag', function(bagType, itemName, slot, metadata, bagId)
    local ped = PlayerPedId()

    loadAnim('anim@heists@money_grab@briefcase')

    TaskPlayAnim(ped, 'anim@heists@money_grab@briefcase', 'put_down_case',
        3.0, 3.0, 1200, 16, 0, false, false, false)

    Wait(900)

    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, -1.0)

    loadModel(Config.BagModel)

    local obj = CreateObject(Config.BagModel, coords.x, coords.y, coords.z, true, true, false)

    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    Bags[bagId] = obj

    TriggerServerEvent('kdb:server:createBag', bagId, bagType, itemName, slot)

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'kdb_open_' .. bagId,
            label = 'Open Duty Bag',
            icon = 'fa-box',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('kdb:server:openBag', bagId)
            end
        },
        {
            name = 'kdb_pickup_' .. bagId,
            label = 'Return Duty Bag',
            icon = 'fa-hand',
            distance = 2.0,
            onSelect = function()
                DeleteEntity(obj)
                TriggerServerEvent('kdb:server:pickupBag', bagId, bagType, itemName, slot)
            end
        }
    })
end)

RegisterNetEvent('kdb:client:openInventory', function(stashId)
    exports.ox_inventory:openInventory('stash', stashId)
end)
