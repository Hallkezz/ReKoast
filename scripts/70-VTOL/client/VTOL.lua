class 'VTOL'

function VTOL:__init()
	self.namept = "Нажмите R чтобы включить автопилот."
	AutoLandActive		=	true	--	Whether or not Auto Land is active by default.		Default: true
	ReverseThrustActive	=	true	--	Whether or not Reverse Thrust is active by default.	Default: true
	self.Display		=	true
	VTOLKey				=	90
	VTOLLandKey			=	162		--	The key to switch VTOL to down instead of up, this is Left Control by default.	Default: 162
	ReverseKey			=	88		--	The key to activate Reverse Thrust, this is X by default.						Default: 88
	NoseKey				=	87		--	The key to pitch the nose, this is W by default.								Default: 87
	TailKey				=	83		--	The key to pitch the tail, this is S by default.								Default: 83
	PlaneVehicles		=	{24, 30, 34, 39, 51, 59, 81, 85}	--	A list of all vehicle IDs of planes.
	PitchSpeedLimit		=	25		--	The max speed in MPS that forced pitching of the nose/tail is allowed. 			Default: 25

	MaxThrust				=	10		--	The maximum thrust speed.						Default: 10
	MinThrust				=	0.1		--	The minimum thrust speed.						Default: 0.1
	CurrentThrust			=	0		--	The starting thrust speed.						Default: 0
	MaxVTOLLandThrust		=	10		--	The maximum VTOL down thrust speed.				Default: 10
	MinVTOLLandThrust		=	0.2 	--	The minimum VTOL down thrust speed.				Default: 0.001
	VTOLLandThrust			=	2		--	The starting VTOL down thrust speed.			Default: 2
	MaxReverseThrust		=	1.5		--	The maximum speed a plane can go in reverse.	Default: 1.5
	ThrustIncreaseFactor	=	1.05	--	How quickly thrust is increased.				Default: 1.05

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "InputPoll", self, self.LandingGear )
	Events:Subscribe( "PreTick", self, self.Thrust )
    Events:Subscribe( "KeyUp", self, self.KeyUp )

	Events:Subscribe( "Render", self, self.Render )
end

function VTOL:Lang( args )
	self.namept = "Press R to enable autopilot panel."
end

function VTOL:LandingGear()
	local vehicle = LocalPlayer:GetVehicle()
	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		LocalVehicleModel	=	vehicle:GetModelId()
		if self:CheckList(PlaneVehicles, LocalVehicleModel) then
			local VehiclePosition	=	vehicle:GetPosition()
			local VehicleAngle		=	vehicle:GetAngle()
			local Direction			=	VehicleAngle * Vector3( 0, -1, 0 )
			local Altitude			=	VehiclePosition.y - 200
			local RayResult			=	Physics:Raycast( VehiclePosition, Direction, 0, Altitude )
			local Distance			=	RayResult.distance
			if Key:IsDown(VTOLKey) then
				if Game:GetState() == GUIState.Game then
					Input:SetValue(Action.PlaneDecTrust, 1)
				end
			elseif Distance <= 35 and AutoLandActive then
				if Game:GetState() == GUIState.Game then
					Input:SetValue(Action.PlaneDecTrust, 1)
				end
			end
		end
	end
end

function VTOL:LocalPlayerEnterVehicle()
	CurrentThrust	=	0
	VTOLLandThrust	=	1
end

function VTOL:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not self.Display then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	local vehicle = LocalPlayer:GetVehicle()
	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		LocalVehicleModel = vehicle:GetModelId()
		if self:CheckList(PlaneVehicles, LocalVehicleModel) then
			local size = Render:GetTextSize( self.namept, 14 )
			local pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 30 )

			Render:DrawText( pos + Vector2.One, self.namept, Color( 0, 0, 0, 180 ), 14 )
			Render:DrawText( pos, self.namept, Color.White, 14 )
		end
	end
end

function VTOL:CheckThrust()
	if Key:IsDown(VTOLLandKey) then return end
	CurrentThrust	=	CurrentThrust * ThrustIncreaseFactor
	if CurrentThrust < MinThrust then
		CurrentThrust	=	MinThrust
	elseif CurrentThrust > MaxThrust then
		CurrentThrust	=	MaxThrust
	end
	ReverseThrust	=	CurrentThrust
	if ReverseThrust > MaxReverseThrust then
		ReverseThrust = MaxReverseThrust
	end
end

function VTOL:Thrust( args )
	if Game:GetState() ~= GUIState.Game then return end
	local vehicle = LocalPlayer:GetVehicle()
	if LocalPlayer:GetState() == PlayerState.InVehicle and IsValid(vehicle) and vehicle:GetDriver() == LocalPlayer then
		LocalVehicleModel = vehicle:GetModelId()
		if self:CheckList(PlaneVehicles, LocalVehicleModel) then
			local VehicleVelocity = vehicle:GetLinearVelocity()
			if IsValid(vehicle) then
				if Key:IsDown(ReverseKey) and ReverseThrustActive then
					self:CheckThrust()
					local VehicleAngle = vehicle:GetAngle()
					local SetThrust	= VehicleVelocity + VehicleAngle * Vector3( 0, 0, ReverseThrust )
					local SendInfo = {}
						SendInfo.Player		=	LocalPlayer
						SendInfo.Vehicle	=	vehicle
						SendInfo.Thrust		=	SetThrust
					Network:Send( "ActivateThrust", SendInfo )
				end
				if VehicleVelocity:Length() <= PitchSpeedLimit then
					if Key:IsDown(NoseKey) then
						local VehicleAngle		=	vehicle:GetAngle()
						local SetThrust			=	VehicleAngle * Vector3( -0.25, 0, 0 )
						local SendInfo	=	{}
							SendInfo.Player		=	LocalPlayer
							SendInfo.Vehicle	=	vehicle
							SendInfo.Thrust		=	SetThrust
						Network:Send("ActivateAngularThrust", SendInfo )
					end
					if Key:IsDown(TailKey) then
						local VehicleAngle		=	vehicle:GetAngle()
						local SetThrust			=	VehicleAngle * Vector3( 0.25, 0, 0 )
						local SendInfo	=	{}
							SendInfo.Player		=	LocalPlayer
							SendInfo.Vehicle	=	vehicle
							SendInfo.Thrust		=	SetThrust
						Network:Send( "ActivateAngularThrust", SendInfo )
					end
				end
			end
		end
	end
end

function VTOL:CheckList( tableList, modelID )
	for k,v in pairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function VTOL:KeyUp( args )
	if args.key == VirtualKey.F11 then
		self.Display = not self.Display
	end
end

vtol = VTOL()