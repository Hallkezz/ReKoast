class 'Welcome'

function Welcome:__init()
	Events:Subscribe( "Render", self, self.Render )
	self.fireworks = Image.Create( AssetLocation.Resource, "Rico" )
	self.offline = false

	self.Menu_button = Button.Create()
	self.Menu_button:SetVisible( false )
	self.Menu_button:SetPosition( Vector2( Render.Size.x / 2.5, Render.Size.x / 2.7 ) )
	self.Menu_button:SetHeight( Render.Size.x / 30 )
	self.Menu_button:SetWidth( Render.Size.x / 5 )
	self.Menu_button:SetText( "Продолжить ( ͡° ͜ʖ ͡°)" )
	self.Menu_button:SetTextSize( 15 )
	self.Menu_button:Subscribe( "Press", self, self.Menu )
end

function Welcome:Render()
	if Welcome.Start then
		self.offline = true
		Game:FireEvent( "ply.pause" )
		Game:FireEvent( "gui.hud.hide" )
		Mouse:SetVisible( true )
		Chat:SetEnabled( false )
		self.Menu_button:SetVisible( true )
		Render:FillArea( Vector2.Zero, Render.Size, Color( 10, 10, 10, 200 ) )

		self.fireworks:SetPosition( Vector2( (Render.Width - 350), (Render.Height - 520) ) )
		self.fireworks:SetSize( Vector2( 350, 700 ) )
		self.fireworks:Draw()

		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		Render:DrawText( Vector2( Render.Size.x / 3.4, Render.Size.x / 7 ), "Добро пожаловать!", Color.White, Render.Size.x / 40 )
		Render:DrawText( Vector2( Render.Size.x / 5, Render.Size.x / 5 ), ".\n\n" ..
		"> Официальная группа проекта в VK - \n" ..
		"> Официальная группа проекта в Steam - \n" ..
		"> Официальный канал проекта в Discord - \n \n" ..
		"Желаем вам приятной игры, наслаждайтесь :)", Color.White, Render.Size.x / 70 )
		Render:DrawText( Vector2( 20, (Render.Height - 40) ), "© JCGTeam 2020", Color.White, 15 )
	else
		if self.offline then
			self.Menu_button:SetVisible( false )
		end
	end
end

function Welcome:Menu()
	Network:Send( "GoMenu" )
end

welcome = Welcome()