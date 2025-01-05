ESX = exports["es_extended"]:getSharedObject()
-- Donne la récompense finale
RegisterNetEvent('cleaning:rewardPlayer')
AddEventHandler('cleaning:rewardPlayer', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(Config.RewardItem, Config.RewardAmount)
    end
end)
