

-----------------------------------------------------------------------------------------------------------------------------------------
-- Config
-----------------------------------------------------------------------------------------------------------------------------------------
local hour = 0
local minute = 0
local segundos = 0
local month = ""
local dayOfMonth = 0
local voice = 2
local voiceDisplay = "<span style='color:white'><img class='microfone' src='img/mic.png'> Normal</span>"
local proximity = 3.0
local CintoSeguranca = false
local ExNoCarro = false
local sBuffer = {}
local vBuffer = {}
local displayValue = false
local gasolina = 0
local started = true


local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- Date/Hour
-----------------------------------------------------------------------------------------------------------------------------------------
function CalculateTimeToDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = "0" .. hour
	end
	if minute <= 9 then
		minute = "0" .. minute
	end
end
function CalculateDateToDisplay()
	month = GetClockMonth()
	dayOfMonth = GetClockDayOfMonth()
	if month == 0 then
		month = "Janeiro"
	elseif month == 1 then
		month = "Fevereiro"
	elseif month == 2 then
		month = "Março"
	elseif month == 3 then
		month = "Abril"
	elseif month == 4 then
		month = "Maio"
	elseif month == 5 then
		month = "Junho"
	elseif month == 6 then
		month = "Julho"
	elseif month == 7 then
		month = "Agosto"
	elseif month == 8 then
		month = "Setembro"
	elseif month == 9 then
		month = "Outubro"
	elseif month == 10 then
		month = "Novembro"
	elseif month == 11 then
		month = "Dezembro"
	end
end


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)	
		CalculateTimeToDisplay()
		CalculateDateToDisplay()
	end
end)

AddEventHandler("playerSpawned",function()
	NetworkSetTalkerProximity(proximity)
	started = true
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		setVoice()
	end
end)
function setVoice()
	NetworkSetTalkerProximity(proximity)
	NetworkClearVoiceChannel()
end
Citizen.CreateThread(function()
    local currSpeed = 0.0
    local cruiseSpeed = 999.0
    local cruiseIsOn = false
    local seatbeltIsOn = false
	while true do
		-- P
		Citizen.Wait(10)
		ped = PlayerPedId()
		health = (GetEntityHealth(ped)-100)/300*100
		armor = GetPedArmour(ped)
		local x,y,z = table.unpack(GetEntityCoords(ped,false))
		local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
		

		-- print(NetworkGetTalkerProximity())
		HideHudComponentThisFrame( 1 ) -- Wanted Stars
		HideHudComponentThisFrame( 2 ) -- Weapon Icon
		HideHudComponentThisFrame( 3 ) -- Cash
		HideHudComponentThisFrame( 4 ) -- MP Cash
		HideHudComponentThisFrame( 6 ) -- Vehicle Name
		HideHudComponentThisFrame( 7 ) -- Area Name
		HideHudComponentThisFrame( 8 ) -- Vehicle Class
		HideHudComponentThisFrame( 9 ) -- Street Name
		HideHudComponentThisFrame( 13 ) -- Cash Change
		HideHudComponentThisFrame( 17 ) -- Save Game
		HideHudComponentThisFrame( 20 ) -- Weapon Stats

		HideHudComponentThisFrame( 5 ) -- Weapon Stats-- P
		

		if IsPedInAnyVehicle(ped) then
			DisplayRadar(true)
			inCar  = true
			PedCar = GetVehiclePedIsIn(ped)
			speed = math.ceil(GetEntitySpeed(PedCar) * 2.236936)
			rpm = GetVehicleCurrentRpm(PedCar)
			nsei,baixo,alto = GetVehicleLightsState(PedCar)
			if baixo == 1 and alto == 0 then
				farol = 1
			elseif  alto == 1 then
				farol = 2
			else
				farol = 0
			end
			-- print(penis)
			if GetEntitySpeed(PedCar) == 0 and GetVehicleCurrentGear(PedCar) == 0  then
				marcha = "P"
			elseif GetEntitySpeed(PedCar) ~= 0 and GetVehicleCurrentGear(PedCar) == 0  then
				marcha = "R"
			else
				marcha = GetVehicleCurrentGear(PedCar)
			end
		 	gasolina = GetVehicleFuelLevel(PedCar)
			VehIndicatorLight = GetVehicleIndicatorLights(PedCar)
			if(VehIndicatorLight == 0) then
				piscaEsquerdo = false
				piscaDireito = false
			elseif(VehIndicatorLight == 1) then
				piscaEsquerdo = true
				piscaDireito = false
			elseif(VehIndicatorLight == 2) then
				piscaEsquerdo = false
				piscaDireito = true
			elseif(VehIndicatorLight == 3) then
				piscaEsquerdo = true
				piscaDireito = true
			end

			-- cruise?
	        if (GetPedInVehicleSeat(PedCar, -1) == ped) then
	            if IsControlJustReleased(0, 137) then
	                cruiseIsOn = not cruiseIsOn
	                cruiseSpeed = GetEntitySpeed(PedCar)
	            end
	            local maxSpeed = cruiseIsOn and cruiseSpeed or GetVehicleHandlingFloat(PedCar,"CHandlingData","fInitialDriveMaxFlatVel")
	            SetEntityMaxSpeed(PedCar, maxSpeed)
	        else
	            cruiseIsOn = false
	        end			
		else	
			inCar  = false
			PedCar = 0
			speed = 0
			rpm = 0
			marcha = 0
			cruiseIsOn = false
			VehIndicatorLight = 0
			if menu_celular then
				DisplayRadar(true)
			else
				DisplayRadar(false)
			end
		end
		SendNUIMessage({
			show = show,
			incar = inCar,
			speed = speed,
			rpm = rpm,
			gear = marcha,
			heal = health,
			armor = armor,
			dia = dayOfMonth,
			mes = month,
			hora = hour,
			minuto = minute,
			voz = voiceDisplay,
			piscaEsquerdo = piscaEsquerdo,
			piscaDireito = piscaDireito,
			gas = gasolina,
			cinto = CintoSeguranca,
			farol = farol,
			cruise = cruiseIsOn,
		 	display = displayValue,
		 	rua = street
		});
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Seatbelt
-----------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	
Fwv = function (entity)
	local hr = GetEntityHeading(entity) + 90.0
	if hr < 0.0 then
		hr = 360.0 + hr
	end
	hr = hr * 0.0174533
	return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Remove hud on pause
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
  while true do
      Citizen.Wait(100)
      	if started then 
	      if IsPauseMenuActive() or menu_celular then
	         displayValue = false
	      else
	         displayValue = true
	      end
	  	end
  end
end)

