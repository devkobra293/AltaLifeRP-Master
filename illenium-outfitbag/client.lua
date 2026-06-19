local Bags = {}

local function notify(msg, type)
    lib.notify({
        title = 'Outfit Bag',
        description = msg,
        type = type or 'inform'
    })
end

local function canUse()
    local ped = cache.ped

    if IsPedDeadOrDying(ped, true) then
        notify('You are dead.')
        return false
    end

    if IsPedInAnyVehicle(ped, false) then
        notify('Exit the vehicle first.')
        return false
    end

    return true
end

-------------------------------------------------------
-- PLACE BAG REQUEST
-------------------------------------------------------
RegisterNetEvent('snk_outfitbag:client:placeBag', function()
    if not canUse() then return end

    local ped = cache.ped
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
    local heading = GetEntityHeading(ped)

    TriggerServerEvent('snk_outfitbag:server:placeBag', coords, heading)
end)

-------------------------------------------------------
-- SPAWN BAG
-------------------------------------------------------
local function spawnBag(data)
    if Bags[data.id] then return end

    local obj = CreateObject(
        `prop_cs_heist_bag_02`,
        data.coords.x,
        data.coords.y,
        data.coords.z - 1.0,
        false,
        false,
        false
    )

    SetEntityHeading(obj, data.heading)
    FreezeEntityPosition(obj, true)

    Bags[data.id] = obj

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'outfitbag_open_' .. data.id,
            label = 'Open Outfit Bag',
            icon = 'fa-solid fa-shirt',
            distance = 2.0,
            onSelect = function()
                if not canUse() then return end

                lib.callback('illenium-appearance:server:getOutfits', false, function(outfits)
                    if not outfits or #outfits == 0 then
                        notify('No outfits found.', 'error')
                        return
                    end

                    local options = {}

                    for _, outfit in ipairs(outfits) do
                        options[#options + 1] = {
                            title = outfit.name,
                            icon = 'shirt',
                            onSelect = function()
                                TriggerEvent('illenium-appearance:client:changeOutfit', outfit)
                            end
                        }
                    end

                    lib.registerContext({
                        id = 'outfitbag_menu',
                        title = 'Outfit Bag',
                        options = options
                    })

                    lib.showContext('outfitbag_menu')
                end)
            end
        },
        {
            name = 'outfitbag_pickup_' .. data.id,
            label = 'Pick Up Bag',
            icon = 'fa-solid fa-hand',
            distance = 2.0,
            onSelect = function()
                TriggerServerEvent('snk_outfitbag:server:pickupBag', data.id)
            end
        }
    })
end

-------------------------------------------------------
-- SYNC
-------------------------------------------------------
RegisterNetEvent('snk_outfitbag:client:spawnBag', spawnBag)

RegisterNetEvent('snk_outfitbag:client:removeBag', function(id)
    local obj = Bags[id]

    if obj and DoesEntityExist(obj) then
        exports.ox_target:removeLocalEntity(obj)
        DeleteEntity(obj)
    end

    Bags[id] = nil
end)

RegisterNetEvent('snk_outfitbag:client:syncBags', function(bags)
    for _, bag in pairs(bags) do
        spawnBag(bag)
    end
end)