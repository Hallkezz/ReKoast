class 'Load'

function Load:__init()
	self.name = "СОВЕТ: Нажмите [ B ], чтобы открыть меню сервера."
	self.wtitle = "ОШИБКА :С"
	self.wtext = "Возможно вы застряли на экране загрузки. \nЖелаете покинуть сервер?"
	self.wbutton = "Покинуть сервер"

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath )
	self.PostTick = Events:Subscribe( "PostTick", self, self.PostTick )

	IsJoining = false

	self.border_width = Vector2( Render.Width, 25 )
end

function Load:Lang( args )
	self.name = "TIP: Press [ B ] to open Server Menu."
	self.wtitle = "ERROR :С"
	self.wtext = "You maybe stuck on the loading screen. \nWant to leave the server?"
	self.wbutton = "Leave Server"
end

function Load:ModuleLoad()
	if Game:GetState() ~= GUIState.Loading then
		IsJoining = false
	else
		IsJoining = true
		FadeInTimer = Timer()
	end
end

function Load:GameLoad()
	FadeInTimer = nil
end

function Load:LocalPlayerDeath()
	FadeInTimer = Timer()
end

function Load:PostTick()
	if Game:GetState() == GUIState.Loading then
		if FadeInTimer then
			if FadeInTimer:GetMinutes() >= 1 then
				Events:Unsubscribe( self.PostRender )
				self:ExitWindow()
			end
		end
	end
end

function Load:ExitWindow()
	FadeInTimer = nil
	Mouse:SetVisible( true )
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.2, 0.2 ) )
	self.window:SetMinimumSize( Vector2( 500, 200 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( true )
	self.window:SetTitle( self.wtitle )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.errorText = Label.Create( self.window )
	self.errorText:SetPosition( Vector2( 20, 30 ) )
	self.errorText:SetSize( Vector2( 450, 100 ) )
	self.errorText:SetText( self.wtext )
	self.errorText:SetTextSize( 20 )

	self.leaveButton = Button.Create( self.window )
	self.leaveButton:SetSize( Vector2( 100, 40 ) )
	self.leaveButton:SetDock( GwenPosition.Bottom )
	self.leaveButton:SetText( self.wbutton )
	self.leaveButton:Subscribe( "Press", self, self.Exit )
end

function Load:WindowClosed()
	self.window:Remove()
	Mouse:SetVisible( false )
end

function Load:Exit()
	self.window:Remove()
	Chat:SetEnabled( false )
	Network:Send( "KickPlayer" )
end

Load = Load()