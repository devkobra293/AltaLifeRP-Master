local lastSpawnTimes = {}

local function Notify(src, msg)
    TriggerClientEvent('prop_menu:notify', src, msg)
end


RegisterCommand(Config.OpenCommand, function(source)
    if source == 0 then
        print(('^1[prop_menu]^7 /%s can only be used by players.'):format(Config.OpenCommand))
        return
    end

    TriggerClientEvent('prop_menu:openMenu', source)
end, false)

RegisterNetEvent('prop_menu:requestSpawn', function(objectName)
    local src = source

    if type(objectName) ~= 'string' or objectName == '' then
        return
    end


    local now = os.time()
    local lastSpawn = lastSpawnTimes[src] or 0
    local cooldown = tonumber(Config.SpawnCooldownSeconds) or 5
    local remaining = cooldown - (now - lastSpawn)

    if remaining > 0 then
        Notify(src, ('~r~Please wait %s more second(s) before spawning another prop.'):format(remaining))
        return
    end

    lastSpawnTimes[src] = now
    TriggerClientEvent('prop_menu:spawnApproved', src, objectName)
end)

AddEventHandler('playerDropped', function()
    lastSpawnTimes[source] = nil
end)
