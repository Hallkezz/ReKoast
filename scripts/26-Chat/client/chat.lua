class 'BetterChat'

function BetterChat:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "Render", self, self.Render )

	self.name = "Режим чата: "
	self.nameTw = "  (Нажмите 'H', чтобы сменить)"

	self.toggle = 0
	self.text = "Общий"
	self.tGlobal = "Общий"
	self.tLocal = "Локальный"
	self.tPrefix = "Префикс"
	self.chModeMsg = "Режим чата переключён на "

	Network:Send( "toggle", self.toggle )
end

function BetterChat:Lang()
	self.name = "Chat mode: "
	self.nameTw = "  (Press 'H' to change)"
	self.text = "Global"
	self.tGlobal = "Global"
	self.tLocal = "Local"
	self.tPrefix = "Prefix"
	self.chModeMsg = "Chat mode changed on "
end

function BetterChat:KeyUp( args )
	if string.char(args.key) == "H" then
	if self.toggle <= 1 then
		self.toggle = self.toggle + 1
	else
		self.toggle = 0
	end
		if self.toggle == 1 then
			self.text = self.tLocal
			Chat:Print( self.chModeMsg .. self.text .. "!", Color( 0, 255, 100 ) )
		end
		if self.toggle == 0 then
			self.text = self.tGlobal
			Chat:Print( self.chModeMsg .. self.text .. "!", Color( 0, 255, 100 ) )
		end
		if self.toggle == 2 then
			self.text = self.tPrefix
			Chat:Print( self.chModeMsg .. self.text .. "!", Color( 0, 255, 100 ) )
		end
		Network:Send( "toggle", self.toggle )
	end
end

function BetterChat:Render()
	if Chat:GetActive() then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		Render:DrawText( Chat:GetPosition() - Vector2( -1, 234 ), self.name .. self.text .. self.nameTw, Color( 25, 25, 25, 150 ), 13 +1 )
		Render:DrawText( Chat:GetPosition() - Vector2( 0, 235 ), self.name .. self.text .. self.nameTw, Color( 200, 200, 200 ), 13 +1 )
	end
end

betterchat = BetterChat()