ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) 

RegisterServerEvent("guille_storevehicle")
AddEventHandler("guille_storevehicle", function(plate, properties)
    local xPlayer = ESX.GetPlayerFromId(source)

    local pos = json.encode(xPlayer.getCoords())
    local plate = plate
    local vehprop = json.encode(properties)
    print(plate)
    print(properties)

    MySQL.Async.execute("UPDATE owned_vehicles SET position=@position WHERE plate=@plate", {
        ['@position'] = pos,
        ['@plate'] = plate,
    })
    MySQL.Async.execute("UPDATE owned_vehicles SET vehicle=@vehicle WHERE plate=@plate", {
        ['@vehicle'] = vehprop,
        ['@plate'] = plate,
    })

end)

ESX.RegisterServerCallback('guille_getvehicles', function(source,cb) 

    MySQL.Async.fetchAll("SELECT vehicle, position FROM owned_vehicles", {}, function(result)
        local vehicles = {}
        if result[1] ~= nil then
            for i = 1, #result, 1 do
                print("test")
                table.insert(vehicles, { ["position"] = json.decode(result[i]["position"]), ["vehProps"] = json.decode(result[i]["vehicle"]) })
            end
        end
        cb(vehicles)
    end)

end)

ESX.RegisterServerCallback('getvehiclescommand', function(source,cb)

	local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll("SELECT position FROM owned_vehicles", {}, function(result)
        local pos = {}
        for i = 1, #result, 1 do
            table.insert(pos, { ["position"] = json.decode(result[i]["position"]) })
        end
        cb(pos)
    end)
end)

ESX.RegisterServerCallback('guille_nogarages:getOutVehicles', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local vehicules = {}

    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner=@identifier', {
        ['@identifier'] = xPlayer.getIdentifier()
    }, function(data)
        for _, v in pairs(data) do
            local vehicle = json.decode(v.vehicle)
            table.insert(vehicules, vehicle)
        end

        cb(vehicules)
    end)
end)

ESX.RegisterServerCallback('guille_nogarages:checkMoney', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if(xPlayer.getMoney() >= Config.moneytoretrieve) then
        xPlayer.removeMoney(100)
        cb(true)
    else
        cb(false)
    end
end)