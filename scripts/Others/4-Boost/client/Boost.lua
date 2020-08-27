class 'Boost'

function Boost:__init()
	self.multiplier = 3
	self.boosting = true
	self.defaultLandBoost = true
	self.defaultBoatBoost = true
	self.defaultHeliBoost = true
	self.defaultPlaneBoost = true
	self.defaultTextEnabled = true
	self.defaultPadEnabled = true
	self.defaultBrakeEnabled = true
	self.display = true

	self.landBoost    = self.defaultLandBoost
	self.boatBoost    = self.defaultBoatBoost
	self.heliBoost    = self.defaultHeliBoost
	self.planeBoost   = self.defaultPlaneBoost
	self.textEnabled  = self.defaultTextEnabled
	self.padEnabled   = self.defaultPadEnabled
	self.brake   	  = self.defaultBrakeEnabled
	self.timer        = Timer()
	self.interval     = 50 -- ms
	self.windowOpen   = false

	self.name = "Нажмите "
	self.nameTw = "или LB "
	self.nameTh = "чтобы ускориться. "
	self.nameFo = "Нажмите F чтобы затормозить."
	self.nameFi = "ТОРМОЗ"

	self.boats = {
		[5] = true, [6] = true, [16] = true, [19] = true,
		[25] = true, [27] = true, [28] = true, [38] = true,
		[45] = true, [50] = true, [53] = true, [69] = true,
		[80] = true, [88] = true
		}
	self.helis = {
		[3] = true, [14] = true, [37] = true, [57] = true,
		[62] = true, [64] = true, [65] = true, [67] = true
		}
	self.planes = {
		[24] = true, [30] = true, [34] = true, [39] = true,
		[51] = true, [59] = true, [81] = true, [85] = true
		}

	self.settingSub = Network:Subscribe( "UpdateSettings", self, self.UpdateSettings )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "KeyUp", self, self.KeyHide )
	Events:Subscribe( "KeyDown", self, self.KeyBrake )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
end

function Boost:Lang( args )
	self.name = "Press "
	self.nameTw = "or LB "
	self.nameTh = "to boost. "
	self.nameFo = "Press F to brake."
	self.nameFi = "BRAKE"
end

function Boost:UpdateSettings( args )
	Network:Unsubscribe(self.settingSub)
	self.settingSub = nil

	if args.landBoost then self.landBoost = args.landBoost == 1 end
	if args.boatBoost then self.boatBoost = args.boatBoost == 1 end
	if args.heliBoost then self.heliBoost = args.heliBoost == 1 end
	if args.planeBoost then self.planeBoost = args.planeBoost == 1 end
	if args.textEnabled then self.textEnabled = args.textEnabled == 1 end
	if args.padEnabled then self.padEnabled = args.padEnabled == 1 end
	if args.brake then self.brake = args.brake == 1 end

	self.window = Window.Create()
	self.window:SetSize( Vector2( 190, 175 ) )
	self.window:SetTitle( "Настройки ускорения" )
	self.window:SetVisible( false )
	self.window:Subscribe( "WindowClosed", function() self:SetWindowOpen( false ) end )
	self:ResolutionChange()

	self:AddSetting( "Ускорение для машин", "landBoost", self.landBoost, self.defaultLandBoost )
	self:AddSetting( "Ускорение для лодок", "boatBoost", self.boatBoost, self.defaultBoatBoost )
	self:AddSetting( "Ускорение для вертолётов", "heliBoost", self.heliBoost, self.defaultHeliBoost )
	self:AddSetting( "Ускорение для самолётов", "planeBoost", self.planeBoost, self.defaultPlaneBoost )
	self:AddSetting( "Текст", "textEnabled", self.textEnabled, self.defaultTextEnabled )
	self:AddSetting( "Контроллер", "padEnabled", self.padEnabled, self.defaultPadEnabled )
	self:AddSetting( "Резкий тормоз", "brake", self.brake, self.defaultBrakeEnabled )

	Events:Subscribe( "BoostSettings", self, self.BoostSettings )
	Events:Subscribe( "ResolutionChange", self, self.ResolutionChange )
end

function Boost:GetWindowOpen()
	return self.windowOpen
end

function Boost:SetWindowOpen( state )
	self.windowOpen = state
	self.window:SetVisible( state )
	Mouse:SetVisible( state )
end

function Boost:BoostSettings()
	self:SetWindowOpen( not self:GetWindowOpen() )
	return false
end

function Boost:LocalPlayerInput( args )
	if self.windowOpen then return false end
		if self.padEnabled then
			if args.input == Action.VehicleFireLeft then
			if LocalPlayer:GetWorld() == DefaultWorld and self:IsDriver() and
				Game:GetSetting(GameSetting.GamepadInUse) == 1 then
				local v = LocalPlayer:GetVehicle()
				if self:LandCheck(v) or self:BoatCheck(v) or self:HeliCheck(v) or self:PlaneCheck(v) then
					self:Boost()
				end
			end
		end
	end
end

function Boost:Render()
	if not self:IsDriver() then return end
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end

	if self.braked then
		if LocalPlayer:InVehicle() then
		local veh = LocalPlayer:GetVehicle()
		if veh:GetDriver() == LocalPlayer then
				local veh = LocalPlayer:GetVehicle()
				veh:SetLinearVelocity( Vector3.Zero )
				veh:SetPosition( self.vpos )
			end
		end
	end

	local v     = LocalPlayer:GetVehicle()
	local land  = self:LandCheck(v)
	local boat  = self:BoatCheck(v)
	local heli  = self:HeliCheck(v)
	local plane = self:PlaneCheck(v)

	local v = LocalPlayer:GetVehicle()
	if self.boosting then
		if land or boat then
			if Key:IsDown(160) then -- LShift
				self:Boost()
			end
		elseif heli or plane then
			if Key:IsDown(81) then -- Q
				self:Boost()
			end
		end
	end

	if Game:GetState() ~= GUIState.Game then return end
	if not self.display then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	if self.textEnabled and (land or boat or heli or plane) then
		local text = self.name
		if land or boat then
			text = text .. "Shift "
		elseif heli or plane then
			text = text .. "Q "
		end
		if self.padEnabled then
			text = text .. self.nameTw
		end
		text = text .. self.nameTh
		if self.brake then
			text = text .. self.nameFo
		end
		if self.BrakeText then
			text = self.nameFi
		end

		local size = Render:GetTextSize( text, 15 )
		local pos = Vector2( ( Render.Width - size.x ) / 2, Render.Height - size.y - 10 )

		Render:DrawText( pos + Vector2.One, text, Color( 0, 0, 0, 180 ), 15 )
		Render:DrawText( pos, text, Color.White, 15 )
	end
end

function Boost:ResolutionChange()
	self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel() / 2 )
end

function Boost:AddSetting( text, setting, value, default )
	local checkBox = LabeledCheckBox.Create(self.window)
	checkBox:SetSize( Vector2( 200, 20 ) )
	checkBox:SetDock( GwenPosition.Top )
	checkBox:GetLabel():SetText( text )
	checkBox:GetCheckBox():SetChecked( value )
	checkBox:GetCheckBox():Subscribe( "CheckChanged", function(box)
		self:UpdateSetting(setting, box:GetChecked(), default) end )
end

function Boost:UpdateSetting( setting, value, default )
	self[setting] = value

	-- Translate for DB
	if value == default then
		value = nil
	else
		value = value and 1 or 0
	end

	Network:Send( "ChangeSetting", {setting = setting, value = value} )
end

function Boost:Boost()
	if self.timer:GetMilliseconds() > self.interval then
		local v = LocalPlayer:GetVehicle()
		if IsValid(v) then
			local forward = v:GetAngle() * Vector3( 0, 0, -1 * self.multiplier )
			v:SetLinearVelocity( v:GetLinearVelocity() + forward )
		end
		self.timer:Restart()
	end
end

function Boost:IsDriver()
	return LocalPlayer:InVehicle() and LocalPlayer == LocalPlayer:GetVehicle():GetDriver()
end

function Boost:LandCheck( vehicle )
	local id = vehicle:GetModelId()
	return self.landBoost and not self.boats[id] and not self.helis[id] and not self.planes[id]
end

function Boost:BoatCheck( vehicle )
	return self.boatBoost and self.boats[vehicle:GetModelId()]
end

function Boost:HeliCheck( vehicle )
	return self.heliBoost and self.helis[vehicle:GetModelId()]
end

function Boost:PlaneCheck( vehicle )
	return self.planeBoost and self.planes[vehicle:GetModelId()]
end

function Boost:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.brake then
		if string.char(args.key) == "F" then
			self.boosting = true
			self.BrakeText = nil
			self.braked = nil
			self.vpos = nil
		end
	end
end

function Boost:KeyBrake( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.brake then
		if LocalPlayer:InVehicle() then
			local veh = LocalPlayer:GetVehicle()
			if veh:GetDriver() == LocalPlayer then
				if string.char(args.key) == "F" then
					local veh = LocalPlayer:GetVehicle()
					self.boosting = false
					self.BrakeText = true
					self.braked = true
					veh:SetLinearVelocity( Vector3.Zero )
					if not self.vpos then
						self.vpos = veh:GetPosition()
					end
				end
			end
		end
	end
end

function Boost:LocalPlayerExitVehicle()
	self.boosting = true
	self.BrakeText = false
	self.braked = false
end

function Boost:KeyHide( args )
	if args.key == VirtualKey.F11 then
		self.display = not self.display
	end
end

boost = Boost()