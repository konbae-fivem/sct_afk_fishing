ESX = nil
Status = {}

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    Status[xPlayer.identifier] = nil
end)

RegisterNetEvent("sct_afk_fishing:getStatus", function()
    local _source = source
    TriggerClientEvent("sct_afk_fishing:updateStatus", _source, Status)
end)

RegisterNetEvent("sct_afk_fishing:updateStatus", function(data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    Status[xPlayer.identifier] = data
    TriggerClientEvent("sct_afk_fishing:updateStatus", _source, Status)
end)

RegisterNetEvent("sct_afk_fishing:getRewards", function(token)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if token == "Dj4*L9!KPA7Ku$zNV39a" then
        for key, value in pairs(Config.Zones.ItemsRewards) do
            if math.random(1, 100) <= value.Percent then
                local randomCount = math.random(value.Amount[1], value.Amount[2])
                xPlayer.addInventoryItem(value.Name, randomCount)
                TriggerClientEvent("sct_afk_fishing:updateLogRewards", _source, value.Name, randomCount)
            end
        end
    end
end)
