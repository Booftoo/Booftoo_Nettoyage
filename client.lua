
ESX = exports["es_extended"]:getSharedObject()

local isCleaning = false
local currentPointIndex = 0
local activeMarkers = {}
local broomObject = nil 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local distance = #(playerCoords - Config.BroomPickup)

        if distance < 3.0 then
            ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour récupérer un balai.")
            if IsControlJustReleased(0, 38) then -- Touche [E]
                TriggerEvent('cleaning:startCleaning')
            end
        end
    end
end)

RegisterNetEvent('cleaning:startCleaning')
AddEventHandler('cleaning:startCleaning', function()
    if not isCleaning then
        isCleaning = true
        currentPointIndex = 1
        spawnMarkers()
        playAnimation('missfbi4prepp1', 'idle', 'prop_cs_mop_s')
        ESX.ShowNotification("Commencez à nettoyer les points marqués.")
    end
end)

function spawnMarkers()
    for i, point in ipairs(Config.CleaningPoints) do
        local groundZ = getGroundZ(point.x, point.y)
        activeMarkers[i] = {
            coords = vector3(point.x, point.y, groundZ + 0.5), 
            cleaned = false
        }
    end

    Citizen.CreateThread(function()
        while isCleaning do
            Citizen.Wait(0)
            drawMarkers()
        end
    end)
end

function getGroundZ(x, y)
    local foundGround, z = GetGroundZFor_3dCoord(x, y, 1000.0, false)
    return foundGround and z or 0.0
end

function drawMarkers()
    for i, marker in ipairs(activeMarkers) do
        if not marker.cleaned then
            DrawMarker(0, marker.coords.x, marker.coords.y, marker.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, false, 2, nil, nil, false)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - marker.coords)

            if distance < 2.0 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour nettoyer ce point.")
                if IsControlJustReleased(0, 38) then -- Touche [E]
                    cleanPoint(i)
                end
            end
        end
    end
end
function cleanPoint(index)
    local marker = activeMarkers[index]
    if marker and not marker.cleaned then
        FreezeEntityPosition(PlayerPedId(), true)

        local broom = playAnimation('move_mop', 'idle_scrub_small_player', 'prop_cs_mop_s')

        Citizen.Wait(Config.CleaningTime * 1000)
        ESX.ShowNotification("Tu as nettoyé cet endroit. Passe au suivant !")

        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasksImmediately(PlayerPedId())
        DeleteObject(broom)

        activeMarkers[index].cleaned = true
        currentPointIndex = currentPointIndex + 1

        if currentPointIndex > #Config.CleaningPoints then
            endCleaning()
        end
    end
end

function endCleaning()
    isCleaning = false
    ClearPedTasksImmediately(PlayerPedId())
    activeMarkers = {}
    TriggerServerEvent('cleaning:rewardPlayer')
    ESX.ShowNotification("Ta fini de laver c'est bien bon toutou maintenant bouge ton cul et va dehors !")
end

function playAnimation(dict, anim, prop)
    local playerPed = PlayerPedId()

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, dict, anim, 8.0, -8.0, -1, 49, 0, false, false, false)

    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local boneIndex = GetPedBoneIndex(playerPed, 28422)

    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Citizen.Wait(100)
    end

    local propObject = CreateObject(GetHashKey(prop), x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(propObject, playerPed, boneIndex, -0.02, -0.06, -0.2, -13.37, 10.35, 17.96, true, true, false, true, 1, true)
end
