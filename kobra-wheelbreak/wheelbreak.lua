local wheelBreakSpeedMph = 100
local minSpeedDropMph = 40 -- how hard the crash must be

local excludedClasses = {
    [8] = true,
    [9] = true,
    [14] = true,
    [15] = true,
    [16] = true
}

---@param class number
---@return boolean
local function isVehicleClassValid(class)
    return not excludedClasses[class]
end

CreateThread(function()
    local lastSpeedMph = 0

    while true do
        local waitLoop = 500
        local playerPed = PlayerPedId()

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if GetPedInVehicleSeat(vehicle, -1) == playerPed and isVehicleClassValid(GetVehicleClass(vehicle)) then
                waitLoop = 10

                local currentSpeedMph = GetEntitySpeed(vehicle) * 2.236936
                local speedDrop = lastSpeedMph - currentSpeedMph

                if lastSpeedMph >= wheelBreakSpeedMph
                and speedDrop >= minSpeedDropMph
                and HasEntityCollidedWithAnything(vehicle) then

                    local randomWheelIndex = math.random(0, 3)
                    BreakOffVehicleWheel(vehicle, randomWheelIndex, true, false, true, false)

                    Wait(1000) -- prevent multiple triggers instantly
                end

                lastSpeedMph = currentSpeedMph
            end
        end

        Wait(waitLoop)
    end
end)