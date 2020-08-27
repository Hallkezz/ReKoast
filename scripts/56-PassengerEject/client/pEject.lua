class 'Eject'

function Eject:__init()
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
end

invalid_vehicles = {}
function AddVehicle(id)
	invalid_vehicles[id] = true
end
AddVehicle(3)
AddVehicle(14)
AddVehicle(67)

function Eject:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	if args.input == Action.StuntJump then
		-- This runs every time you press the stunt jump button
		if (LocalPlayer:InVehicle()) then
			localVehicle = LocalPlayer:GetVehicle()
			if (localVehicle:GetDriver() ~= LocalPlayer and not invalid_vehicles[localVehicle:GetModelId()]) then
				local args = {}
				args.vehicle = localVehicle
				Network:Send( "EjectPassenger", args )
			end
		end
	end
	if args.input == Action.ParachuteOpenClose then
		-- This runs every time you press the Parachute Open button
		if (LocalPlayer:InVehicle()) then
			localVehicle = LocalPlayer:GetVehicle()
			if (localVehicle:GetDriver() ~= LocalPlayer and not invalid_vehicles[localVehicle:GetModelId()]) then
				local args = {}
				args.vehicle = localVehicle
				Network:Send( "EjectPassenger", args )
			end
		end
	end
end

eject = Eject()