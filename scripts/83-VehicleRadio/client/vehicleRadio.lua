class 'VehicleRadio'

function VehicleRadio:__init()
	self.radio = nil
	self.refresh = nil
	self.radioname = "Магнитола: "
	self.offname = "Выключено"

	self.check = 0
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "LocalPlayerEnterVehicle", self, self.LocalPlayerEnterVehicle )
	Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function VehicleRadio:Lang( args )
	self.radioname = "Radio: "
	self.offname = "Disabled"
end

function VehicleRadio:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if LocalPlayer:InVehicle() then
		if args.key == VirtualKey.OemPeriod then
			if self.check <= 4 then
				self.check = self.check + 1
			end

			if self.check == 1 then
				if self.refresh then
					self:ModuleUnload()
				end
				self.refresh = true
				self.radio = true
				Sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 25,
						sound_id = 86,
						position = Camera:GetPosition(),
						angle = Angle()
				})

				Sound:SetParameter(0,1)
				Game:ShowPopup( self.radioname .. "Tom Main Theme", false )
			end

			if self.check == 2 then
				if self.refresh then
					self:ModuleUnload()
				end
				self.radio = true
				Sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 25,
						sound_id = 155,
						position = Camera:GetPosition(),
						angle = Angle()
				})

				Sound:SetParameter(0,1)
				Game:ShowPopup( self.radioname .. "Fighting 01", false )
			end

			if self.check == 3 then
				if self.refresh then
					self:ModuleUnload()
				end
				self.radio = true
				Sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 25,
						sound_id = 154,
						position = Camera:GetPosition(),
						angle = Angle()
				})

				Sound:SetParameter(0,1)
				Game:ShowPopup( self.radioname .. "Fighting 02", false )
			end

			if self.check == 4 then
				if self.refresh then
					self:ModuleUnload()
				end
				self.refresh = nil
				self.radio = nil
				self.check = 0
				Game:ShowPopup( self.radioname .. self.offname, false )
			end
		end
	end
end

function VehicleRadio:PreTick( args )
	if self.radio then
		if LocalPlayer:InVehicle() then
			Sound:SetPosition( Camera:GetPosition() )
		end
	end
end

function VehicleRadio:LocalPlayerEnterVehicle( args )
	Game:ShowPopup( self.radioname .. self.offname, false )
	self.check = 0
end

function VehicleRadio:LocalPlayerExitVehicle( args )
	if self.radio then
		self:ModuleUnload()
		self.radio = nil
	end
end

function VehicleRadio:ModuleUnload()
	if self.radio then
		Sound:Remove()
		Sound = nil
	end
end

vehicleradio = VehicleRadio()