----------------------------------------------------------------------------
----------------------------------Made By:----------------------------------
-------------------------------guillerp#1928--------------------------------
-------------Don't touch if you don't know what are you doing---------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

ESX = nil
local playerloaded
local coords = false

Citizen.CreateThread(function() 
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 
        Citizen.Wait(0) 
	CreateBlip()		
    end 
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        CreateBlip()
        GetPlayers()
        print("create vehicles")
    end
end)

AddEventHandler('esx:onPlayerSpawn', function()
    Citizen.CreateThread(function()
        while not playerLoaded do
            Citizen.Wait(100)
        end
        GetPlayers()
        CreateBlip()
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    playerLoaded = true
    print("spawn")
end)

function GetPlayers()
    Citizen.Wait(Config.timetospawn * 1000)
    print(GetNumberOfPlayers())
    if GetNumberOfPlayers() == 1 then
        ESX.ShowNotification('Do not restart FiveM, we are loading cars.')
        Citizen.Wait(1000)
        CreateVehicles()
    end

end

function CreateBlip()
    local Blip = AddBlipForCoord(vector3(494.52, -1334.12, 29.32))
    SetBlipSprite (Blip, 635)
    SetBlipDisplay(Blip, 4)
    SetBlipScale  (Blip, 0.9)
    SetBlipColour (Blip, 46)
    SetBlipAsShortRange(Blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Depot")
    EndTextCommandSetBlipName(Blip)
end

function CreateVehicles()
    local player = GetPlayerPed(-1)
    ESX.TriggerServerCallback('guille_getvehicles', function(vehicles)
        local coords = GetEntityCoords(player)
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        for i = 1, #vehicles, 1 do
            Citizen.Wait(30)
            local position = vehicles[i]["position"]
            local vehicleProps = vehicles[i]["vehProps"]
            local mod = GetDisplayNameFromVehicleModel(vehicleProps["model"])
            SetEntityCoords(player, position.x, position.y, position.z, 1, 1, 1, 0)
            LoadModel(vehicleProps["model"])
            local vehicle = CreateVehicle(vehicleProps["model"], position.x, position.y, position.z - 0.975, position.heading, true, true)
            Citizen.Wait(1000)
            ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
			SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleOnGroundProperly(vehicle)
            print("^2 ¡Vehicle ^0" .. mod .. "^2 loaded!")
        end
        SetEntityCoords(player, coords.x, coords.y, coords.z, 1, 1, 1, 0)
        Citizen.Wait(500)
        DoScreenFadeIn(1000)
    end)

end



function LoadModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(5)
	end
end

Citizen.CreateThread(function()   
    while true do
        Citizen.Wait(Config.savetime * 1000)
        local player = GetPlayerPed(-1) 
        if IsPedInAnyVehicle(player) then
            local car = GetVehiclePedIsUsing(player)
            local properties = ESX.Game.GetVehicleProperties(car)
            local plate = properties["plate"]
            print("^2 Saved vehicle ^0" .. plate .. "")
            TriggerServerEvent("guille_storevehicle", plate, properties)
            SetEntityAsMissionEntity(car, true, true)
        end
        
    end

end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)
        dist = GetDistanceBetweenCoords(vector3(494.64, -1333.92, 29.32), GetEntityCoords(PlayerPedId(), true), true)
        if dist < 5 then
            DrawMarker(0, 494.64, -1333.92, 29.32, 0,0,0,0,0,0,0.5,0.5,0.5,255,255,0,165,true,true,0,0)
            ShowFloatingHelpNotification('Press ~g~E~w~ to open the depot', vector3(494.64, -1333.92, 29.32 + 1))
            if IsControlJustPressed(0, 38) then
                ReturnVehicleMenu()
            end
        end
    end
end)

RegisterCommand("getvehicles", function()
    ESX.TriggerServerCallback('getvehiclescommand', function(pos)
        for i = 1, #pos, 1 do
            local position = pos[i]["position"]
            print("^2 Vehicle in property: ^4" .. position.x, position.y, position.z .. "")
        end
    end)
end)

function ShowFloatingHelpNotification(msg, coords)
    AddTextEntry('FloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

function OpenMenuGarage(PointType)
    ESX.UI.Menu.CloseAll()
    local elements = {}


    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'droga', {
        title    = ('Menú de drogas'),
        align    = 'top-right',
        elements = {
            {label = ('Impounded car'), value = 'return_vehicle'},
            }}, function(data, menu)

        if (data.current.value == 'return_vehicle') then
            ReturnVehicleMenu()
        end
            menu.close()
        end, function(data, menu)
            menu.close()
    end)


end

function ReturnVehicleMenu()
    ESX.TriggerServerCallback('guille_nogarages:getOutVehicles', function(vehicles)
        local elements = {}

        for _, v in pairs(vehicles) do
            local hashVehicule = v.model
            local vehicleName = GetDisplayNameFromVehicleModel(hashVehicule)
            local labelvehicle
            labelvehicle = GetLabelText(vehicleName)

            table.insert(elements, {
                label = labelvehicle,
                value = v
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'return_vehicle', {
            title = ('Recuperar vehículos'),
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            ESX.TriggerServerCallback('guille_nogarages:checkMoney', function(hasEnoughMoney)
                if hasEnoughMoney then
                    SpawnPoundedVehicle(data.current.value)
                    menu.close()
                else
                    ESX.ShowNotification('Not enough money')
                end
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end

function SpawnPoundedVehicle(vehicle)
    LoadModel(vehicle.model)
    local car = CreateVehicle(vehicle.model, 489.64, -1333.88, 29.32 - 0.975, 316.84, true, true)
    ESX.Game.SetVehicleProperties(car, vehicle)
    
end
