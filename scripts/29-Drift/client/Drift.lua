class "Drift"

function Drift:__init()
	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	--Events:Subscribe( "LocalPlayerExitVehicle", self, self.LocalPlayerExitVehicle )
	--Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	Network:Subscribe( "03", self, self.onDriftAttempt )

	self.showTimer = Timer()

	self.tWidg = "Лучший Дрифтер:"
	self.tWidgTw = "Лучший "
	self.tDrift = "Дрифтер: "
	self.tDriftTw = "Дрифт: "
	self.tDrift3 = "Продолжай! "
	self.tDrift4 = "Не останавливайся! "
	self.tDrift5 = "Отличный дрифт! "
	self.tDrift6 = "Грациозно! "
	self.tDrift7 = "Мастер! "
	self.tDrift8 = "Повелитель дрифта! "
	self.tDrift9 = "АСТАНАВИСЬ!!! "
	self.tRecord = "Личный дрифт рекорд: "
end

function Drift:GetOption( args )
	self.Display = args.actDr
end

function Drift:Lang( args )
	self.tWidg = "Fantastic Drift:"
	self.tWidgTw = "Fantastic "
	self.tDrift = "Drift: "
	self.tDriftTw = "Drift: "
	self.tDrift3 = "Well done! "
	self.tDrift4 = "Do not stop! "
	self.tDrift5 = "Great drift! "
	self.tDrift6 = "Gracefully! "
	self.tDrift7 = "Drift Master! "
	self.tDrift8 = "Lord of drift! "
	self.tDrift9 = "STOP PLS!!! "
	self.tRecord = "Personal drift record: "
end

function Drift:LocalPlayerExitVehicle()
	if IsValid(LocalPlayer:GetVehicle()) then
		if self.mass then 
			self.mass = false
			Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
		end
	end
end

function Drift:LocalPlayerDeath()
	if IsValid(LocalPlayer:GetVehicle()) then
		if self.mass then 
			self.mass = false
			Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
		end
	end
end

function Drift:PlayerQuit(args)
	if args.player == LocalPlayer then
		if IsValid(LocalPlayer:GetVehicle()) then
			if self.mass then 
				self.mass = false
				Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
			end
		end
	end
end

function Drift:Render()
	local object = NetworkObject.GetByName("Drift")

	if self.Display and Game:GetState() == GUIState.Game then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		if Game:GetSetting(4) >= 1 then
			if object and LocalPlayer:GetValue("GetWidget") == 2 then
				local record = object:GetValue("S")
				local text = self.tWidg
				local position = Vector2( 20, Render.Height * 0.4 )
				Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position + Vector2( Render:GetTextWidth( self.tWidgTw, 15 ), 0 ), self.tDrift, Color( 255, 165, 0, Game:GetSetting(4) * 2.25 ), 15 )
				local height = Render:GetTextHeight("A") * 1.2
				position.y = position.y + height
				local record = object:GetValue("S")
				if record then
					text = tostring(record) .. " - " .. object:GetValue("N")
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position, text, Color( 0, 150, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position + Vector2( Render:GetTextWidth( text, 16 ), 0 ), " - ", Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record ) .. " - "
					Render:DrawText( position + Vector2( Render:GetTextWidth( text, 16 ), 0 ), object:GetValue("N"), object:GetValue("C") + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), 16 )
					text = ""
					for i = 1, object:GetValue("E") do text = text .. ">" end
					position.y = position.y + height * 0.95
					Render:SetFont( AssetLocation.Disk, "LeagueGothic.ttf" )
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 13 )
					Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 13 )
					if LocalPlayer:GetValue( "SystemFonts" ) then
						Render:SetFont( AssetLocation.SystemFont, "Impact" )
					end
					if self.attempt then
						local player = Player.GetById( self.attempt[2] - 1 )
						if player then
							position.y = position.y + height * 0.6
							local alpha = math.min(self.attempt[3], 1)
							text = tostring( self.attempt[1] ) .. " - " .. player:GetName()
							Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 * alpha ), 16 )
							Render:DrawText( position, text, Color( 255, 255, 255, 255 * alpha ), 16 )
							text = tostring( self.attempt[1] )
							Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 * alpha ), 16 )
							Render:DrawText( position, text, Color( 240, 220, 70, 255 * alpha ), 16 )
							self.attempt[3] = self.attempt[3] - 0.02
							if self.attempt[3] < 0.02 then self.attempt = nil end
						end
					end
				else
					text = "–"
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					Render:DrawText( position, text, Color( 200, 200, 200, Game:GetSetting(4) * 2.25 ), 16 )
				end
			end
		end
	end

	if self.slide then
		if self.slide == 0 then
			if not self.mass then
				self.mass = true
				Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
			end
		else
			if self.mass then
				self.mass = false
				Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
			end
		end
	else
		if self.mass then
			self.mass = false
			Network:Send("setmas", {veh = LocalPlayer:GetVehicle(), bool = self.mass})
		end
	end

	if self.score and not self.timer and self.score >= 100 then
		self.slide = self.slide + (1 * self.multipler)
		self.anim_tick = self.anim_tick + 1
		self.sscore = self.score
		local btext = self.tDriftTw
		local text = self.tDriftTw .. tostring( math.ceil(self.score*self.multipler) )
		local text_mult = "x" .. tostring( self.multipler )

		if self.anim_tick < 30 then
			self.size = 122 - self.anim_tick * 2
		elseif self.anim_tick > 29 then
			self.size = 62
		end

		if math.ceil(self.score * self.multipler) > 5000 then
			btext = self.tDrift3
			text = self.tDrift3 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 10000 then
			btext = self.tDrift4
			text = self.tDrift4 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 50000 then
			btext = self.tDrift5
			text = self.tDrift5 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 100000 then
			btext = self.tDrift6
			text = self.tDrift6 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 500000 then
			btext = self.tDrift7
			text = self.tDrift7 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 1000000 then
			btext = self.tDrift8
			text = self.tDrift8 .. math.ceil(self.score*self.multipler)
		end
		if math.ceil(self.score * self.multipler) > 10000000 then
			btext = self.tDrift9
			text = self.tDrift9 .. math.ceil(self.score*self.multipler)
		end

		if self.Display and Game:GetState() == GUIState.Game then
			local textSize = Render:GetTextSize(text, 36)
			local textSize_mult = Render:GetTextSize(text_mult, 36)
			local alpha = 1 - self.slide / 265

			local position = Vector2(Render.Width / 2, Render.Height * 0.3 * alpha) - textSize / 2
			local position_mult = position + Vector2(textSize.x / 2,textSize.y*1.6) - textSize_mult/2

			Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 * alpha ), 36 )

			Render:DrawText( position_mult + Vector2.One, text_mult, Color( 25, 25, 25, 150 * alpha), 36 )
			Render:DrawText( position_mult, text_mult, Color( 255, 150, 0, 255 * alpha ), 36 )
			if(math.ceil(self.score * self.multipler) > (object:GetValue("S") or 0)) then
				Render:DrawText( position, text, Color( 255, 0, 0, 255 * alpha ), 36 )
			else
				Render:DrawText( position, text, Color( 255, 150, 0, 255 * alpha ), 36 )
			end

			Render:DrawText( position + Vector2( Render:GetTextWidth(btext, 36), 0 ), tostring( math.ceil(self.score * self.multipler) ), Color( 255, 255, 255, 255 * alpha ), 36 )
		end

		if self.slide >= 255 then
			local object = NetworkObject.GetByName("Drift")
			if not object or math.ceil(self.score * self.multipler) > (object:GetValue("S") or 0) then
				Network:Send( "01", math.ceil(self.score * self.multipler) )
			elseif math.ceil(self.score * self.multipler) > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~= LocalPlayer:GetName() then
				Network:Send( "02", math.ceil(self.score * self.multipler) )
			end
			local shared = SharedObject.Create("Drift")
			if math.ceil(self.score * self.multipler) > (shared:GetValue("Record") or 0) then
				shared:SetValue( "Record", math.ceil(self.score * self.multipler) )
				Game:ShowPopup( self.tRecord .. math.ceil(self.score * self.multipler), true )
			end
			self.slide = nil
			self.score = nil
			self.sscore = nil
			self.multipler = 1
		end
	end

	if LocalPlayer:GetState() ~= PlayerState.InVehicle then self.timer = nil; return end
	local vehicle = LocalPlayer:GetVehicle()
	if not IsValid(vehicle) then self.timer = nil; return end
	if vehicle:GetClass() ~= VehicleClass.Land then self.timer = nil; return end
	local velocity = vehicle:GetLinearVelocity()
	if velocity:Length() < 3 then self.timer = nil; return end
	local dot = Angle.Dot(Angle(Angle.FromVectors(velocity, Vector3.Forward).yaw, 0, 0), Angle(-vehicle:GetAngle().yaw, 0, 0))
	if dot < 0.1 or dot > 0.99 then self.timer = nil; return end
	local raycast = Physics:Raycast(vehicle:GetPosition() + Vector3(0, 0.5, 0), Vector3.Down, 0, 10, true)
	if raycast.distance > 1 then self.timer = nil; return end
	if not self.timer then
		self.timer = Timer()
		self.quality = 0
		if self.sscore ~= nil then
			self.multipler = self.multipler + 0.1
		end
		self.anim_tick = 1
	end
	self.quality = math.max(math.lerp(self.quality, -45 * math.pow(dot - 0.85, 2) + 1, 0.1), self.quality)
	if self.sscore ~= nil then
		score = self.sscore + math.ceil(self.timer:GetMilliseconds() * self.quality)
	else
		self.multipler = 1
		score = math.ceil(self.timer:GetMilliseconds() * self.quality)
	end

	if score < 100 then return end

	self.score = score
	self.slide = 0
	self.anim_tick = self.anim_tick + 1
	local btext = self.tDriftTw
	local text = self.tDriftTw .. tostring( math.ceil(self.score*self.multipler) )
	local text_mult = "x" .. tostring( self.multipler )

	self.angular = vehicle:GetAngularVelocity()

	if self.anim_tick < 30 then
		self.size = 1.9 - self.anim_tick * 0.01
	elseif self.anim_tick > 29 then
		self.size = 1.6
	end

	if math.ceil( self.multipler ) > 10 then
		self.multipler = 10
	end
	if math.ceil(self.score * self.multipler) > 5000 then
		btext = self.tDrift3
		text = self.tDrift3 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 10000 then
		btext = self.tDrift4
		text = self.tDrift4 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 50000 then
		btext = self.tDrift5
		text = self.tDrift5 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 100000 then
		btext = self.tDrift6
		text = self.tDrift6 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 500000 then
		btext = self.tDrift7
		text = self.tDrift7 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 1000000 then
		btext = self.tDrift8
		text = self.tDrift8 .. math.ceil(self.score*self.multipler)
	end
	if math.ceil(self.score * self.multipler) > 10000000 then
		btext = self.tDrift9
		text = self.tDrift9 .. math.ceil(self.score*self.multipler)
	end

	if self.Display and Game:GetState() == GUIState.Game then
		local textSize = Render:GetTextSize( text, 36 )
		local textSize_mult = Render:GetTextSize(text_mult, 36)

		local position = Vector2( Render.Width / 2, Render.Height * 0.3 ) - textSize / 2
		local position_mult = position + Vector2(textSize.x / 2,textSize.y*self.size) - textSize_mult/2

		Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 ), 36 )
		if(math.ceil(self.score * self.multipler) > (object:GetValue("S") or 0)) then
			Render:DrawText( position, text, Color( 255, 0, 0 ), 36 )
		else 
			Render:DrawText( position, text, Color( 255, 150, 0 ), 36 )
		end
		Render:DrawText( position + Vector2( Render:GetTextWidth(btext,36), 0 ), tostring( math.ceil(self.score*self.multipler) ), Color( 255, 255, 255 ), 36 )
		Render:DrawText( position_mult + Vector2.One, text_mult, Color( 25, 25, 25, 150 ), 36 )
		Render:DrawText( position_mult, text_mult, Color( 255, 150, 0, 255 ), 36 )
	end
end

function Drift:onDriftAttempt( data )
	self.attempt = data
	self.attempt[3] = 4
end

drift = Drift()