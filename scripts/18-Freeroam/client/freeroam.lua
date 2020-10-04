class 'Freeroam'

function Freeroam:__init()
	self.hotspots = {}

	if LocalPlayer:GetMoney() == 0 then
		self.spawn = true
	else
		self.spawn = false
	end

	self.wtitle = "ОШБИКА :С"
	self.wtext = "Возможно вы застряли на экране загрузки. \nЖелаете покинуть сервер?"
	self.wbutton = "Покинуть сервер"

	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "LocalPlayerDeath", self, self.LocalPlayerDeath )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Network:Subscribe( "Hotspots", self, self.Hotspots )
	Network:Subscribe( "PlayerKilled", self, self.PlayerKilled )
	Network:Subscribe( "KillerStats", self, self.KillerStats )
	Network:Subscribe( "KillerModeMessage", self, self.KillerModeMessage )
end

function Freeroam:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if args.input == Action.EquipBlackMarketBeacon then
		if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
			Network:Send( "GiveMeWeapon" )
		end
		return false
	end
end

function Freeroam:GameLoad( args )
	if self.spawn then
		Network:Send( "PlayerSpawn" )
		self.spawn = false
	else
		if not LocalPlayer:GetValue( "Passive" ) then
			if LocalPlayer:GetWorld() ~= DefaultWorld then return end
			if not self.PostTickEvent then
				Network:Send( "PlayerSpawnAndPassive", { pvalue = true } )
				self.passiveTimer = Timer()
				self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
			end
		end
	end
end

function Freeroam:PostTick()
	if self.passiveTimer:GetSeconds() >= 10 then
		self.passiveTimer = nil
		Network:Send( "PlayerSpawnAndPassive", { pvalue = false } )
		if self.PostTickEvent then
			Events:Unsubscribe( self.PostTickEvent )
			self.PostTickEvent = nil
		end
	end
end

function Freeroam:LocalPlayerDeath( args )
	if Game:GetState() ~= GUIState.Game then return end
	self.spawn = false
end

function Freeroam:PlayerKilled( args )
	if Game:GetState() ~= GUIState.Game then return end
	self.spawn = true
end

function Freeroam:KillerStats( args )
	Events:Fire( "CastCenterText", { text = args.text, time = 4, color = Color.White } )
end

function Freeroam:Hotspots( args )
	self.hotspots = args
end

function Freeroam:DrawHotspot( v, dist )
	local text = "/tp " .. v[1]
	local text_size = Render:GetTextSize( text, TextSize.VeryLarge )
end


function Freeroam:KillerModeMessage( v, dist )
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

freeroam = Freeroam()
