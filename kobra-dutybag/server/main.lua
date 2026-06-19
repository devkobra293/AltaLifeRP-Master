local Bags = {}

local function getStashId(bagId)
    return ('kdb_dutybag_%s'):format(bagId)
end

local function generateBagId()
    return tostring(os.time() .. math.random(1000, 9999))
end

---------------------------------------------------------------------
-- DB ONLY STORES BAG META (NOT ITEMS)
---------------------------------------------------------------------
local function saveBagMeta(bagId, bagType, owner)
    exports.oxmysql:execute([[
        INSERT INTO kdb_dutybags (bag_id, bag_type, owner, items)
        VALUES (?, ?, ?, NULL)
        ON DUPLICATE KEY UPDATE bag_type = VALUES(bag_type)
    ]], {
        bagId,
        bagType,
        owner
    })
end

---------------------------------------------------------------------
-- USE ITEM
---------------------------------------------------------------------
exports('useDutyBag', function(event, item, inventory)
    if event ~= 'usingItem' then return end

    local bagType =
        item.name == 'gear_bag' and 'gear' or
        item.name == 'weapons_bag' and 'weapons' or
        nil

    if not bagType then return end

    local bagId = item.metadata and item.metadata.bagId or generateBagId()

    TriggerClientEvent('kdb:client:deployBag',
        inventory.id,
        bagType,
        item.name,
        item.slot,
        item.metadata or {},
        bagId
    )
end)

---------------------------------------------------------------------
-- CREATE BAG (NO POPULATION, NO DB ITEMS)
---------------------------------------------------------------------
RegisterNetEvent('kdb:server:createBag', function(bagId, bagType, itemName, slot)
    local src = source
    local stashId = getStashId(bagId)

    Bags[bagId] = {
        stash = stashId,
        type = bagType
    }

    exports.ox_inventory:RemoveItem(src, itemName, 1, nil, slot)

    exports.ox_inventory:RegisterStash(
        stashId,
        ('Duty Bag (%s)'):format(bagType),
        50,
        Config.StashWeight,
        false
    )

    -- only metadata saved
    saveBagMeta(bagId, bagType, src)
end)

---------------------------------------------------------------------
-- OPEN BAG (DO NOTHING EXCEPT OPEN)
---------------------------------------------------------------------
RegisterNetEvent('kdb:server:openBag', function(bagId)
    local src = source
    local bag = Bags[bagId]
    if not bag then return end

    TriggerClientEvent('kdb:client:openInventory', src, bag.stash)
end)

---------------------------------------------------------------------
-- PICKUP (JUST RETURN ITEM)
---------------------------------------------------------------------
RegisterNetEvent('kdb:server:pickupBag', function(bagId, bagType, itemName, slot)
    local src = source
    local bag = Bags[bagId]
    if not bag then return end

    exports.ox_inventory:AddItem(src, itemName, 1, {
        bagId = bagId
    })

    Bags[bagId] = nil
end)