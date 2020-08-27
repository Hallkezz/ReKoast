class "Grenades"

local blacklist = {64, 37, 57, 30, 34, 20, 53, 24}

function Grenades:__init()
	if LocalPlayer:GetValue("exp") ~= 0 then
		self.TossTimer = Timer()
	end

	self.C4Max = "10"

	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "Render", self, self.Render )

	self.grenadeIMG = Image.Create( AssetLocation.Resource, "Grenade" )
	self.grenade1 = Image.Create( AssetLocation.Resource, "Grenade1" )
	self.c4 = Image.Create( AssetLocation.Resource, "C4" )
	self.clay = Image.Create( AssetLocation.Resource, "Clay" )
	self.background = Image.Create( AssetLocation.Resource, "Back" )

	self.textb = Image.Create( AssetLocation.Resource, "TextBa" )

	self.stars = Image.Create( AssetLocation.Resource, "Stars0" )
	self.stars1 = Image.Create( AssetLocation.Resource, "Stars1" )
	self.stars2 = Image.Create( AssetLocation.Resource, "Stars2" )
	self.stars3 = Image.Create( AssetLocation.Resource, "Stars3" )
	self.stars4 = Image.Create( AssetLocation.Resource, "Stars4" )
	self.stars5 = Image.Create( AssetLocation.Resource, "Stars5" )
end

function Grenades:CheckList( tableList, modelID )
	for k,v in pairs(tableList) do
		if v == modelID then return true end
	end
	return false
end

function Grenades:KeyUp( args )
	if args.key == string.byte('G') then
		if not self.TossTimer then
			self.TossTimer = Timer()
		else
			self.TossTimer:Restart()
		end
		if LocalPlayer:GetValue("exp") == nil then
			LocalPlayer:SetValue("exp", 1)
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		elseif LocalPlayer:GetValue("exp") == 0 then
			LocalPlayer:SetValue("exp", 1)
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		elseif LocalPlayer:GetValue("exp") == 1 then
			LocalPlayer:SetValue("exp", 2)
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		elseif LocalPlayer:GetValue("exp") == 2 then
			LocalPlayer:SetValue("exp", 3)

			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		elseif LocalPlayer:GetValue("exp") == 3 then
			LocalPlayer:SetValue("exp", 0)
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		else
			LocalPlayer:SetValue("exp", 0)
			self.TossTimer = nil
		end
	end

	if args.key == string.byte('2') then
		LocalPlayer:SetValue("l_exp", LocalPlayer:GetValue("exp"))
		LocalPlayer:SetValue("exp", 0)
		self.FadeOutTimer = nil
	elseif args.key == string.byte('1') then
		if LocalPlayer:GetValue("l_exp") then
			LocalPlayer:SetValue("exp", LocalPlayer:GetValue("l_exp"))
			LocalPlayer:SetValue("l_exp", nil)
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		end
	end
end

function Grenades:LocalPlayerInput( args )
	local input = args.input
	if input == Action.ThrowGrenade then
		if Game:GetState() ~= GUIState.Game then return end
		if LocalPlayer:GetValue( "Passive" ) then return end
		if LocalPlayer:GetValue( "ServerMap" ) then return end
	
		if LocalPlayer:GetVehicle() then
			local vehicle = LocalPlayer:GetVehicle()
			if vehicle:GetModelId() == 7 or vehicle:GetModelId() == 77 or vehicle:GetModelId() == 56 or vehicle:GetModelId() == 18 then
				if vehicle:GetTemplate() == "Armed" or vehicle:GetTemplate() == "FullyUpgraded" or vehicle:GetTemplate() == "" or vehicle:GetTemplate() == "Cannon" then return end
			else
				if vehicle:GetTemplate() == "Armed" or vehicle:GetTemplate() == "FullyUpgraded" or vehicle:GetTemplate() == "Dome" then return end
			end
			local LocalVehicleModel	= vehicle:GetModelId()
			if self:CheckList( blacklist, LocalVehicleModel ) then return end
		end

		if LocalPlayer:GetValue("exp") == 1 and self.grenade then
			Events:Fire("FireGrenade", { type = "Frag" } )
			self.grenade = nil
			self.TossTimer = Timer()
		elseif LocalPlayer:GetValue("exp") == 2 then
			Events:Fire( "FireC4" )
		elseif LocalPlayer:GetValue("exp") == 4 and self.grenade then
			self.grenade = nil
			Events:Fire("FireGrenade", { type = "Smoke" } )
			self.TossTimer = Timer()
		end

		if LocalPlayer:GetValue("exp") ~= 0 and LocalPlayer:GetValue("exp") then
			if self.FadeOutTimer then
				self.FadeOutTimer:Restart()
			else
				self.FadeOutTimer = Timer()
			end
		end
	end
end

function Grenades:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue("exp") ~= 0 and LocalPlayer:GetValue("exp") ~= nil and self.FadeOutTimer then
		local timer_text = ""
		local max_text = ""
		local tpos = 0.985

		self.background:SetSize( Vector2( Render.Height * 0.18, Render.Height * 0.09 ) )
		self.textb:SetSize( Vector2( Render.Height * 0.2, Render.Height * 0.03 ) )

		local imga = self.grenadeIMG
		local text = "Осколочная граната"

		if LocalPlayer:GetValue("exp") == 1 then
			imga = self.grenadeIMG
			tpos = 0.985

			if LocalPlayer:GetValue( "Lang" ) == "РУС" then
				text = "Осколочная граната"
			else
				text = "Fragmentation Grenade"
			end
			timer_text = "∞"

			if self.TossTimer then
				local rem = 2 - self.TossTimer:GetSeconds()
				if rem - (rem % 1) > 0 then
					timer_text = tostring(rem - (rem % 1))
				else
					self.TossTimer = nil
					self.grenade = true
				end
			end
		elseif LocalPlayer:GetValue("exp") == 2 then
			imga = self.c4
			tpos = 0.99

			if LocalPlayer:GetValue( "Lang" ) == "РУС" then
				text = "Бомбы-липучки"
			else
				text = "Triggered Explosive"
			end
			max_text = self.C4Max
			if LocalPlayer:GetValue("C4Count") == nil then
				timer_text = "0"
				self.c4actv = true
			else
				timer_text = tostring( LocalPlayer:GetValue("C4Count") )
				self.c4actv = true
			end
		elseif LocalPlayer:GetValue("exp") == 3 then
			imga = self.clay
			tpos = 0.99

			if LocalPlayer:GetValue( "Lang" ) == "РУС" then
				text = "Мины Клеймор"
			else
				text = "Claymore Mine"
			end
			timer_text = "∞"
			self.c4actv = false
		end
		
		if self.FadeOutTimer:GetSeconds() >= 11 then
			self.FadeOutTimer = nil
			return
		end

		imga:SetSize( Vector2( Render.Height * 0.09, Render.Height * 0.045 ) )

		local timerwidth = (Render:GetTextSize( timer_text, imga:GetSize().y/1.8).x / 2 )
		local c4maxwidth = (Render:GetTextSize( max_text, imga:GetSize().y/1.8).x / 2 )

		local pos_2d = Vector2( Render.Size.x / 0.995 - self.background:GetSize().x, (Render.Height - Render.Height * 0.23) - imga:GetSize().y/2 )
		local pos_2d_a = Vector2( Render.Size.x / 1.009 - self.background:GetSize().x, (Render.Height - Render.Height * 0.230) - self.background:GetSize().y/2 )
		local pos_2d_t = Vector2( Render.Size.x / 1.015 - self.textb:GetSize().x, (Render.Height - Render.Height * 0.185) - self.textb:GetSize().y/2 )
		local pos_2d_timer = Vector2( Render.Size.x / 1.01 - timerwidth/2 - imga:GetSize().x/2, (Render.Height - Render.Height * 0.227) - self.textb:GetSize().y/2 )
		if self.c4actv then
			pos_2d_timer = Vector2( Render.Size.x / 1.009 - timerwidth/2 - imga:GetSize().x/2, (Render.Height - Render.Height * 0.232) - self.textb:GetSize().y/2 )
		end
		local pos_2d_c4max = Vector2( Render.Size.x / 1.008 - c4maxwidth/2 - imga:GetSize().x/2, (Render.Height - Render.Height * 0.212) - self.textb:GetSize().y/2 )
		local pos_2d_text = Vector2( Render.Size.x / tpos - (Render:GetTextWidth(text, self.textb:GetSize().y/1.5)) - imga:GetSize().x/2, (Render.Height - Render.Height * 0.18) - self.textb:GetSize().y/2 )

		if Game:GetSetting(4) >= 1 then
			imga:SetPosition( pos_2d )
			imga:SetAlpha( 201 - Game:GetSetting(4) * 2 )
			self.background:SetPosition( pos_2d_a )
			self.background:SetAlpha( 201 - Game:GetSetting(4) * 2 )
			self.textb:SetPosition( pos_2d_t )
			self.textb:SetAlpha( 201 - Game:GetSetting(4) * 2 )

			self.textb:Draw()
			self.background:Draw()
			imga:Draw()

			Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
			Render:DrawText( pos_2d_text + Vector2.One, text, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), self.textb:GetSize().y/1.5 )
			Render:DrawText( pos_2d_text, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), self.textb:GetSize().y/1.5 )

			Render:DrawText( pos_2d_timer, timer_text, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), imga:GetSize().y/1.8 )
			Render:DrawText( pos_2d_timer, timer_text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), imga:GetSize().y/1.8 )

			Render:DrawText( pos_2d_c4max, max_text, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), imga:GetSize().y/2.5 )
			Render:DrawText( pos_2d_c4max, max_text, Color( 169, 169, 169, Game:GetSetting(4) * 2.25 ), imga:GetSize().y/2.5 )
		end
	end
end

grenades = Grenades()