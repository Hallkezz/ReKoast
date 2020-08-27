class 'Help'

function Help:__init()
	self.HelpActive = false

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.58, 0.7 ) )
	self.window:SetPositionRel( Vector2( 0.69, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetTitle( "ⓘ Помощь" )
	self.window:SetVisible( self.HelpActive )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )
	self.tab_control:SetTabStripPosition( GwenPosition.Top )

	self.tabs = {}

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "OpenHelpMenu", self, self.OpenHelpMenu )
	Events:Subscribe( "CloseHelpMenu", self, self.CloseHelpMenu )
	Events:Subscribe( "KeyDown", self, self.KeyDown )
	Events:Subscribe( "LocalPlayerInput", self,	self.LocalHelpInput )
	Events:Subscribe( "HelpAddItem", self, self.AddItem )
	Events:Subscribe( "HelpRemoveItem", self, self.RemoveItem )

	Console:Subscribe( "help", self, self.GetConsoleHelp )
end

function Help:Lang()
	self.window:SetTitle( "ⓘ Help" )
end

function Help:GetActive()
	return self.HelpActive
end

function Help:SetActive( state )
	self.HelpActive = state
	self.window:SetVisible( self.HelpActive )
	Mouse:SetVisible( self.HelpActive )
end

function Help:OpenHelpMenu()
	if Game:GetState() ~= GUIState.Game then return end

	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})

	self:SetActive( not self:GetActive() )
	Events:Fire( "LoadAdminsTab" )
end

function Help:CloseHelpMenu()
	if Game:GetState() ~= GUIState.Game then return end
	if self:GetActive() then
		self:SetActive( false )
	end
end

function Help:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetActive( false )
	end
end

function Help:LocalHelpInput( args )
	if self:GetActive() and Game:GetState() == GUIState.Game then
		return false
	end
end

function Help:WindowClosed( args )
	self:SetActive( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
	Events:Fire( "UnloadAdminsTab" )
end

function Help:AddItem( args )
	if self.tabs[args.name] ~= nil then
		self:RemoveItem( args )
	end

	local tab_button = self.tab_control:AddPage( args.name )

	local page = tab_button:GetPage()

	local scroll_control = ScrollControl.Create( page )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetDock( GwenPosition.Fill )

	local label = Label.Create( scroll_control )

	label:SetPadding( Vector2.Zero, Vector2( 14, 0 ) )
	label:SetText( args.text )
	label:SetTextSize( 15 )
	label:SizeToContents()
	label:SetTextColor( Color.LightSkyBlue )
	label:SetWrap( true )
	
	label:Subscribe( "Render" , function(label)
		label:SetWidth( label:GetParent():GetWidth() )
	end)

	self.tabs[args.name] = tab_button
end

function Help:RemoveItem( args )
	if self.tabs[args.name] == nil then return end

	self.tabs[args.name]:GetPage():Remove()
	self.tab_control:RemovePage( self.tabs[args.name] )
	self.tabs[args.name] = nil
end

function Help:GetConsoleHelp()
	print( "Console commands: \n" ..
	"reconnect - reconnect to the server \n" ..
	"disconnect - disconnect to the server \n" ..
	"quit - quit game \n" ..
	"font <default/server> - Enable/Disable server font \n" ..
	"profiler_sample (seconds) - Get server modules consumption" )
end

help = Help()