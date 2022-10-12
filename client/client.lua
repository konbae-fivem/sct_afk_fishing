ESX = nil
InZone = false
InZoneAction = false
InZoneHideStatus = false
InZoneStatus = {}
CacheInventory = {}

RegisterFontFile('font4thai')
fontId = RegisterFontId('font4thai')

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

    for key, value in pairs(ESX.PlayerData.inventory) do
        CacheInventory[value.name] = value.label
    end
    TriggerServerEvent("sct_afk_fishing:getStatus")
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

                MainThreads_DrawTextHead()
                TriggerServerEvent("sct_afk_fishing:updateStatus", nil)

                SendNUIMessage({
                    action = "OPEN_INTERFACE",
                    data = {
                        config = Config.Zones
                    }
                })
            end
        else
            if #(playerCoords - Config.Zones.Pos) > Config.Zones.PosArea then
                InZone = false
                InZoneAction = false
                ClearPedTasksImmediately(playerPed)

                TriggerServerEvent("sct_afk_fishing:updateStatus", nil)

                SendNUIMessage({
                    action = "STOP_ACTION",
                    data = nil
                })

                SendNUIMessage({
                    action = "CLOSE_INTERFACE",
                    data = nil
                })
            end
        end
    end
end)

-- ถ้ากด E ทำงาน --
RegisterCommand("+sct_afk_fishing_start", function()
    if InZone and not InZoneAction then
        local playerPed = PlayerPedId()
        InZoneAction = true
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)
        SendNUIMessage({
            action = "START_ACTION",
            data = nil
        })
    end
end, false)

RegisterCommand("-sct_afk_fishing_start", function()
end, false)

-- ปิดสถานะบนหัว --
RegisterCommand("+sct_afk_fishing_hide_status", function()
    if InZone then
        InZoneHideStatus = not InZoneHideStatus
    end
end, false)

-- ถ้ากด K เปลี่ยนสถานะบนหัว --
RegisterCommand("+sct_afk_fishing_status", function()
    if InZone and InZoneAction then
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "sct_afk_fishing_status", {
            title = "เขียนสถานะ"
        }, function(data, menu)
            local result = tostring(data.value)
            if result == "nil" then

            else
                menu.close()
                TriggerServerEvent("sct_afk_fishing:updateStatus", {
                    ped = PedToNet(playerPed),
                    message = result,
                    coords = playerCoords
                })
            end
        end, function(data, menu)
            menu.close()
        end)
    end
end, false)

RegisterCommand("-sct_afk_fishing_status", function()
end, false)

-- ถ้ากด X ยกเลิกทำงาน --
RegisterCommand("+sct_afk_fishing_cancel", function()
    if InZone and InZoneAction then
        local playerPed = PlayerPedId()
        InZoneAction = false
        ClearPedTasksImmediately(playerPed)
        SendNUIMessage({
            action = "STOP_ACTION",
            data = nil
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

-- อัพเดพ 3dtext --
RegisterNetEvent("sct_afk_fishing:updateStatus", function(data)
    if InZone then
        InZoneStatus = data
    end
end)

-- อัพเดพ Log reward --
RegisterNetEvent("sct_afk_fishing:updateLogRewards", function(name, amount)
    SendNUIMessage({
        action = "UPDATE_LOG_REWARD",
        data = {
            name = name,
            label = CacheInventory[name],
            amount = amount
        }
    })
end)

function MainThreads_DrawTextHead()
    Citizen.CreateThread(function()
        while InZone ~= nil do
            Citizen.Wait(0)
            if not InZoneHideStatus then

                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)

                for key, value in pairs(InZoneStatus) do
                    if #(value.coords - playerCoords) < 20 then
                        local localFPS = 1 / GetFrameTime()
                        local MyCamCoords = GetGameplayCamCoords()
                        local otherPlayerPed = NetToPed(value.ped)
                        local otherPlayerPedHead = GetPedBoneCoords(otherPlayerPed, 1.2844e4, 0, 0, 0) + vector3(0, 0, 1.1) + GetEntityVelocity(otherPlayerPed) / localFPS
                        local distance = math.floor(#(MyCamCoords - otherPlayerPedHead))
                        local sizeOffset = math.max(1 - distance / 10, 0.5)

                        SetDrawOrigin(otherPlayerPedHead, false)
                        SetTextFont(fontId)
                        SetTextScale(0, 0.7 * sizeOffset)
                        SetTextCentre(true)
                        SetTextOutline()
                        SetTextEntry("STRING")
                        AddTextComponentString(value.message)
                        DrawText(0, 0)
                        ClearDrawOrigin()
                    end
                end
            else
                Citizen.Wait(1000)
            end
        end
    end)
end
