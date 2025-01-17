local playerData -- Player stats Massive
local pickupsData -- Coords and Models massive
local entities = {} -- Entities massive

-- Load model
-- Model hash
local function ModelRequest(mhash)
  local i = 0
  while not HasModelLoaded(mhash) and i < 10000 do
    RequestModel(mhash)
    Citizen.Wait(10)
    i = i+1
  end
  if HasModelLoaded(mhash) then
    return true
  else
    return false
  end
end

local function Notify(text) 
  SetNotificationTextEntry('STRING')
  AddTextComponentString(text)
  DrawNotification(true, false)
end

Citizen.CreateThread(function()
  while true do
    Wait(5000)

    if pickupsData then
      local pc = GetEntityCoords(PlayerPedId())

      for k,v in pairs(pickupsData) do
        Wait(10)
        if not playerData.pickups[tostring(k)] and entities[k] then
          if HasPickupBeenCollected(entities[k]) then
            playerData.pickups[tostring(k)] = true
            TriggerServerEvent('halloween-quest:takePuckup', tostring(k))
            RemovePickup(entities[k])
            entities[k] = nil
          end
        end

        if not playerData.pickups[tostring(k)] and (not entities[k] or not DoesEntityExist(Citizen.InvokeNative('0x5099BC55630B25AE ', entities[k]))) then
          if GetDistanceBetweenCoords(pc, v[2][1], v[2][2], v[2][3], true) < 100.0 and ModelRequest(v[1]) then
            local pickup = CreatePickupRotate(79909481, v[2][1], v[2][2], v[2][3], v[3][1], v[3][2], v[3][3], 0, 1, 2, 0,v[1])
            entities[k] = pickup
          end
        end
      end
    end
    
  end
end)

RegisterNetEvent('halloween-quest:receiveData')
AddEventHandler('halloween-quest:receiveData', function(receivePlayerData, receivePickupsData)
  playerData = receivePlayerData
  pickupsData = receivePickupsData
end)

RegisterNetEvent('halloween-quest:notify')
AddEventHandler('halloween-quest:notify', function(text)
  Notify(text)
end)

TriggerServerEvent('halloween-quest:requestData')