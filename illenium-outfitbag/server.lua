local Bags = {}
local NextId = 1

-- spam prevention
local lastPlace = {}

-------------------------------------------------------
-- PLACE BAG (WITH ITEM CONSUMPTION)
-------------------------------------------------------
RegisterNetEvent('snk_outfitbag:server:placeBag', function(coords, heading)
    local src = source

    -- spam prevention (2 sec cooldown)
    local now = os.time()
    if lastPlace[src] and (now - lastPlace[src]) < 2 then
        return
    end
    lastPlace[src] = now

    -- remove item FIRST
    local removed = exports.ox_inventory:RemoveItem(src, 'outfit_bag', 1)

    if not removed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Outfit Bag',
            description = 'You do not have an outfit bag.',
            type = 'error'
        })
        return
    end

    local id = NextId
    NextId += 1

    Bags[id] = {
        id = id,
        owner = src,
        coords = coords,
        heading = heading
    }

    TriggerClientEvent('snk_outfitbag:client:spawnBag', -1, Bags[id])
end)

-------------------------------------------------------
-- PICKUP BAG
-------------------------------------------------------
RegisterNetEvent('snk_outfitbag:server:pickupBag', function(id)
    local src = source
    local bag = Bags[id]

    if not bag then return end

    if bag.owner ~= src then return end

    Bags[id] = nil

    exports.ox_inventory:AddItem(src, 'outfit_bag', 1)

    TriggerClientEvent('snk_outfitbag:client:removeBag', -1, id)
end)

-------------------------------------------------------
-- SYNC ON JOIN
-------------------------------------------------------
RegisterNetEvent('playerJoining', function()
    TriggerClientEvent('snk_outfitbag:client:syncBags', source, Bags)
end)