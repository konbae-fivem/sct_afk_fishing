ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterUsableItem(Config.Zones.ItemRequires.ItemUse, function(source)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    TriggerClientEvent("sct_afk_fishing:onUseItem", _source)
end)

RegisterNetEvent("sct_afk_fishing:getRewards", function(token)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if token == "Dj4*L9!KPA7Ku$zNV39a" then
        local xItem = xPlayer.getInventoryItem(Config.Zones.ItemRequires.ItemRemove)
        if xItem.count > 0 then
            xPlayer.removeInventoryItem(Config.Zones.ItemRequires.ItemRemove, 1)
            for key, value in pairs(Config.Zones.ItemsRewards) do
                if math.random(1, 100) <= value.Percent then
                    local randomCount = math.random(value.Amount[1], value.Amount[2])
                    xPlayer.addInventoryItem(value.Name, randomCount)
                    TriggerClientEvent("sct_afk_fishing:updateLogRewards", _source, value.Name, value.Label, randomCount)
                end
            end
        else
            exports.nc_notify:PushNotification(_source, {
                title = "แจ้งเตือน: ปลาไม่กินเบ็ด",
                description = "ปลาไม่กินเบ็ด เป็นเพราะเหยื่อไม่พอ หรือเพราะเธอไม่มีใจ;---;",
                icon = "cross",
                type = "error",
                duration = 4000
            })
        end
    end
end)
