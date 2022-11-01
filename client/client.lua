ESX = nil
InZone = false
InZoneAction = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer

end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

-- ตรวจสอบเข้า zone --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if not InZone then
            if #(playerCoords - Config.Zones.Pos) < Config.Zones.PosArea then
                InZone = true
                InZoneAction = false
            end
        else
            if #(playerCoords - Config.Zones.Pos) > Config.Zones.PosArea then
                InZone = false
                InZoneAction = false
                ClearPedTasksImmediately(playerPed)

                SendNUIMessage({
                    action = "ACTION_INTERFACE",
                    data = false
                })

                SendNUIMessage({
                    action = "CLOSE_INTERFACE",
                    data = nil
                })
            end
        end
    end
end)

-- ถ้ากดใช้ไอเทมทำงาน --
RegisterNetEvent("sct_afk_fishing:onUseItem", function()
    if InZone and not InZoneAction then
        local playerPed = PlayerPedId()
        InZoneAction = true
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)

        SendNUIMessage({
            action = "OPEN_INTERFACE",
            data = {
                config = Config.Zones
            }
        })

        SendNUIMessage({
            action = "ACTION_INTERFACE",
            data = true
        })
    end
end)

-- ถ้ากด X ยกเลิกทำงาน --
RegisterKeyMapping("+sct_afk_fishing_cancel", "Cancle of sct_afk_fishing", "keyboard", "X")
RegisterCommand("+sct_afk_fishing_cancel", function()
    if InZone and InZoneAction then
        local playerPed = PlayerPedId()
        InZoneAction = false
        ClearPedTasksImmediately(playerPed)

        SendNUIMessage({
            action = "CLOSE_INTERFACE",
            data = nil
        })

        SendNUIMessage({
            action = "ACTION_INTERFACE",
            data = false
        })
    end
end, false)

RegisterCommand("-sct_afk_fishing_cancel", function()
end, false)

RegisterNUICallback("ActionFinished", function(data, cb)
    if InZone and InZoneAction then
        TriggerServerEvent("sct_afk_fishing:getRewards", "Dj4*L9!KPA7Ku$zNV39a")
    end
    cb("OK")
end)

-- อัพเดพ Log reward --
RegisterNetEvent("sct_afk_fishing:updateLogRewards", function(name, label, amount)
    SendNUIMessage({
        action = "UPDATE_LOG_INTERFACE",
        data = {
            name = name,
            label = label,
            amount = amount
        }
    })
end)