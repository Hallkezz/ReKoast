class 'HijackBlocker'

function HijackBlocker:__init()
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )

	self.cooldown = 2
	self.cooltime = 0
end

local actions = { 37, 38, 45, 82, 121, 147, 148, 150 }
local always_drop_states = { 207, 208, 324, 221, 222, 270, 272, 273, 440, 50 }

invalid_vehicles = {}
function AddVehicle(id)
	invalid_vehicles[id] = true
end
AddVehicle(1)
AddVehicle(3)
AddVehicle(9)
AddVehicle(11)
AddVehicle(21)
AddVehicle(22)
AddVehicle(32)
AddVehicle(36)
AddVehicle(43)
AddVehicle(47)
AddVehicle(56)
AddVehicle(61)
AddVehicle(74)
AddVehicle(83)
AddVehicle(89)
AddVehicle(90)
AddVehicle(19)
AddVehicle(25)
AddVehicle(28)
AddVehicle(38)
AddVehicle(45)
AddVehicle(50)
AddVehicle(69)
AddVehicle(80)
AddVehicle(88)
AddVehicle(39)
AddVehicle(85)
AddVehicle(14)
AddVehicle(57)
AddVehicle(67)
AddVehicle(64)
AddVehicle(62)
AddVehicle(9)

function CheckVehicle( target )
	return target == nil or not IsValid( target ) or not IsValid( target:GetDriver() )
end

function HijackBlocker:LocalPlayerInput( args )
	if table.find( actions, args.input ) == nil then return true end

	local base_state = LocalPlayer:GetBaseState()

	if table.find( always_drop_states, base_state ) ~= nil then return false end

	local state = LocalPlayer:GetState()

	local vehicle = LocalPlayer:GetVehicle()
	local target = LocalPlayer:GetAimTarget().vehicle

	if CheckVehicle( vehicle ) and CheckVehicle( target ) then return true end

	if LocalPlayer:GetState() == PlayerState.StuntPos or
		(base_state >= 84 and base_state <= 110) or
		(base_state >= 318 and base_state <= 327) or
		(base_state == 88 or base_state == 327) or
		(base_state == 270 or base_state == 273) or
		(base_state == 207 or base_state == 208) or
		(base_state == 272 or base_state == 222) or 
		(base_state == 273 or base_state == 221) then

		if (not invalid_vehicles[vehicle:GetModelId()] and #vehicle:GetOccupants() == 1) then
			local time = Client:GetElapsedSeconds()
			if time > self.cooltime then
				local args = {}
				args.vehicle = vehicle
				Network:Send( "EnterPassenger", args )
			end
			self.cooltime = time + self.cooldown
		else
			return false
		end
	end
end

hijackblocker = HijackBlocker()