class 'Menu'

function Menu:__init()
	self.pos = Vector2( 20, 40 )
	self.upgrade = true
	self.freeroam = false
	self.hider = true
	self.god = false
	LocalPlayer:SetValue( "Menu", true )
	self:LoadImages()

	self.cooldown = 3
	self.cooltime = 0

	if LocalPlayer:GetValue( "Tag" ) == "Owner" then
		self.status = "  [Владелец]"
	elseif LocalPlayer:GetValue( "Tag" ) == "GlAdmin" then
		self.status = "  [Гл. Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "Admin" then
		self.status = "  [Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "AdminD" then
		self.status = "  [Админ $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "ModerD" then
		self.status = "  [Модератор $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "VIP" then
		self.status = "  [VIP]"
	elseif LocalPlayer:GetValue( "Tag" ) == "YouTuber" then
		self.status = "  [YouTube Деятель]"
	elseif LocalPlayer:GetValue( "NT_TagName" ) then
		self.status = "  [" .. LocalPlayer:GetValue( "NT_TagName" ) .. "]"
	end

	self.sbar = Color( 251, 184, 41 )
	self.DT_colour = Color.White
	self.DT_colour2 = Color.Orange

	self.winsize = 0.57
	self.winsizeTw = 0.86
	self.buttons = true

	self.active = true

	self.tofreeroamtext = "Добро пожаловать в свободный режим!"

	self.EventRender = Events:Subscribe( "Render", self, self.Render )

	self.rus_image = ImagePanel.Create()
	self.rus_image:SetVisible( false )
	self.rus_image:SetImage( self.rusflag )
	self.rus_image:SetHeight( Render.Size.x / 9 )
	self.rus_image:SetWidth( Render.Size.x / 5.5 )
	self.rus_image:SetPosition( Vector2( Render.Size.x / 3.5, (Render.Height - Render.Size.x / 4 ) ) )

	self.rus_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.rus_button:SetHeight( Render.Size.x / 7 )
	self.rus_button:SetWidth( Render.Size.x / 5.5 )
	self.rus_button:SetPosition( Vector2( Render.Size.x / 3.5, (Render.Height - Render.Size.x / 4 ) ) )
	self.rus_button:SetText( "Русский" )
	self.rus_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
	self.rus_button:SetTextSize( Render.Size.x / 70 )
	if LocalPlayer:GetMoney() <= 0.5 then
		self.rus_button:Subscribe( "Press", self, self.Welcome )
	else
		self.rus_button:Subscribe( "Press", self, self.Rus )
	end

	self.eng_image = ImagePanel.Create()
	self.eng_image:SetVisible( false )
	self.eng_image:SetImage( self.engflag )
	self.eng_image:SetHeight( Render.Size.x / 9 )
	self.eng_image:SetWidth( Render.Size.x / 5.5 )
	self.eng_image:SetPosition( Vector2( Render.Size.x / 2, (Render.Height - Render.Size.x / 4 ) ) )

	self.eng_button = MenuItem.Create()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	self.eng_button:SetHeight( Render.Size.x / 7 )
	self.eng_button:SetWidth( Render.Size.x / 5.5 )
	self.eng_button:SetPosition( Vector2( Render.Size.x / 2, (Render.Height - Render.Size.x / 4 ) ) )
	self.eng_button:SetText( "English" )
	self.eng_button:SetToolTip( "Not full :c" )
	self.eng_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
	self.eng_button:SetTextSize( Render.Size.x / 70 )
	self.eng_button:Subscribe( "Press", self, self.Eng )

	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	if not self.LocalPlayerInputEvent then
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	end

	Network:Subscribe( "BackMe", self, self.BackMe )
	Network:Subscribe( "OpenMenu", self, self.Display )
end

function Menu:ModuleLoad()
	Game:FireEvent( "ply.pause" )
	Mouse:SetVisible( true )
	Chat:SetEnabled( false )
end

function Menu:Display( onjoin )
	if onjoin then return end
	self:Open()
end

function Menu:LocalPlayerInput( args )
	if args.input == Action.GuiPause then
		if self.freeroam then
			self:Close()
		end
	end

	if self.active then
		return false
	end
end

function Menu:GetActive()
	return self.active
end

function Menu:Open()
	local time = Client:GetElapsedSeconds()
	if time < self.cooltime then return end

	LocalPlayer:SetValue( "Menu", true )
	Chat:SetEnabled( false )
	self.buttons = false
	if not self.EventRender then
		self.EventRender = Events:Subscribe( "Render", self, self.Render )
	end
	self.upgrade = false

	if LocalPlayer:GetValue( "Tag" ) == "Owner" then
		self.status = "  [Владелец]"
	elseif LocalPlayer:GetValue( "Tag" ) == "GlAdmin" then
		self.status = "  [Гл. Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "Admin" then
		self.status = "  [Админ]"
	elseif LocalPlayer:GetValue( "Tag" ) == "AdminD" then
		self.status = "  [Админ $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "ModerD" then
		self.status = "  [Модератор $]"
	elseif LocalPlayer:GetValue( "Tag" ) == "VIP" then
		self.status = "  [VIP]"
	elseif LocalPlayer:GetValue( "Tag" ) == "YouTuber" then
		self.status = "  [YouTube Деятель]"
	elseif LocalPlayer:GetValue( "NT_TagName" ) then
		self.status = "  [" .. LocalPlayer:GetValue( "NT_TagName" ) .. "]"
	end

	local result = Physics:Raycast(
		LocalPlayer:GetPosition(),
		LocalPlayer:GetAngle() * Vector3.Forward,
		0,
		100
	)
 
	local spawnArgs = {
		position = result.position + result.normal * 0.5,
		bank_id = 25,
		sound_id = 88,
		variable_id_focus = 0
	}
	sound = ClientSound.Create(AssetLocation.Game, spawnArgs)

	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 13,
			sound_id = 1,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
	self.cooltime = time + self.cooldown
end

function Menu:Render()
	local message1 = os.date ( "%X" )
	local time1 = os.date("%d/%m/%Y")

	LocalPlayer:SetValue( "GetFreeroam", self.freeroam )

	local pos8 = Vector2( (Render.Width - 60), (Render.Height - 40) )

	if self.active then
		Game:FireEvent( "gui.hud.hide" )
		Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, 200 ) )
	end

	if self.hider then
		if Game:GetState() ~= GUIState.Loading then
			self.rus_image:SetVisible( true )
			self.rus_button:SetVisible( true )
			self.eng_image:SetVisible( true )
			self.eng_button:SetVisible( true )
			if LocalPlayer:GetValue( "SystemFonts" ) then
				self.rus_button:SetFont( AssetLocation.SystemFont, "Impact" )
			end
			if LocalPlayer:GetValue( "SystemFonts" ) then
				self.eng_button:SetFont( AssetLocation.SystemFont, "Impact" )
			end
		else
			self.rus_image:SetVisible( false )
			self.rus_button:SetVisible( false )
			self.eng_image:SetVisible( false )
			self.eng_button:SetVisible( false )
		end
	end

	if self.active then
		if self.upgrade then
			Game:FireEvent( "ply.health.upgrade" )
		end
		if LocalPlayer:GetValue( "KoastBuild" ) then
			Render:DrawText( pos8, LocalPlayer:GetValue( "KoastBuild" ), Color.White, 15 )
		end
		local position = Vector2( 20, Render.Height * 0.40 )
		local text = tostring(message1)
		local pos_1 = Vector2( (20)/1, (Render.Height/3) + 5)
		local text1 = tostring(time1)

		Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )
		Render:DrawText( position, text, self.DT_colour, 24 )

		local pos7 = Vector2( 60, (Render.Height - 40) )
		local height = Render:GetTextHeight("A") * 1.5
		position.y = position.y + height
		Render:DrawText( position, text1, self.DT_colour2, 16 )	
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		Render:DrawText( pos7, LocalPlayer:GetName(), Color.White, 17 )
		if self.status then
			Render:DrawText( pos7 + Vector2( Render:GetTextWidth( LocalPlayer:GetName(), 17 ), 0 ), self.status, Color.DarkGray, 17 )
		end
		LocalPlayer:GetAvatar(1):Draw( Vector2( 20, (Render.Height - 50) ), Vector2( 30, 30 ), Vector2.Zero, Vector2.One )
	end
end

function Menu:Close()
	self.freeroam = true
	self.buttons = true
	if self.EventRender then
		Events:Unsubscribe( self.EventRender )
		self.EventRender = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	Game:FireEvent( "ply.unpause" )
	Game:FireEvent( "gui.hud.show" )
	Events:Fire( "CastCenterText", { text = self.tofreeroamtext, time = 2, color = Color( 255, 255, 255 ) } )
	Network:Send( "SetFreeroam" )
	LocalPlayer:SetValue( "Menu", false )
	Mouse:SetVisible( false )
	Chat:SetEnabled( true )
end

function Menu:Welcome()
    Network:Send( "SetRus" )
	self:BackMe()
	--Welcome.Start = true
	self.hider = false
	self.rus_image:Remove()
	self.rus_button:Remove()
	self.eng_image:Remove()
	self.eng_button:Remove()
	self:Close()
	self.buttons = true

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:BackMe()
	Welcome.Start = false
	self:Close()

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 0,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Selected()
	Network:Send( "JoinMessage" )
	self.buttons = true
	self.hider = false
	self.rus_image:Remove()
	self.rus_button:Remove()
	self.eng_image:Remove()
	self.eng_button:Remove()
	self:Close()

	local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 18,
				sound_id = 1,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Menu:Rus()
	Network:Send( "SetRus" )
	self:Selected()
end

function Menu:Eng()
	Events:Fire( "SetEng" )
	Network:Send( "SetEng" )

	self.tofreeroamtext = "Welcome to freeroam mode!"

	Events:Fire( "EngHelp" )
	Events:Fire( "Lang" )

	self:Selected()
end

function Menu:LoadImages()
	self.rusflag = Image.Create( AssetLocation.Resource, "RusFlag" )
	self.engflag = Image.Create( AssetLocation.Resource, "EngFlag" )
end

menu = Menu()