class "PM"

function PM:__init( player )
	self.dmoode = false

	self.messages = {}
	self.GUI = {}
	self.GUI.window = Window.Create()
	self.GUI.window:SetSize( Vector2( 700, 500 ) )
	self.GUI.window:SetMinimumSize( Vector2( 350, 442 ) )
	self.GUI.window:SetPositionRel( Vector2( 0.7, 0.53 ) - self.GUI.window:GetSizeRel()/2 )
	self.GUI.window:SetTitle( "[▼] Личные Сообщения" )
	self.GUI.window:SetVisible( false )
	self.GUI.list = GUI:SortedList( Vector2( 0.0, 0.0 ), Vector2( 0.4, 0.93 ), self.GUI.window, { { name = "Игрок" } } )
	self.GUI.list:Subscribe( "RowSelected", self, self.loadMessages )

	self.GUI.labelM = Label.Create( self.GUI.window )
	self.GUI.labelM:SetPosition( Vector2( self.GUI.list:GetSize().x + 12, 7 ) )
	self.GUI.labelM:SetSize( Vector2( 0.4, 0.05 ) )
	self.GUI.labelM:SetText( "Переписка:" )
	self.GUI.labelM:SetTextSize( 14 )
	self.GUI.labelM:SizeToContents()

	self.GUI.labelLine = Label.Create( self.GUI.window )
	self.GUI.labelLine:SetPosition( Vector2( self.GUI.list:GetSize().x + 12, 18 ) )
	self.GUI.labelLine:SetSize( Vector2( 0.4, 0.05 ) )
	self.GUI.labelLine:SetText( "_________________________________________________________________" )
	self.GUI.labelLine:SetTextSize( 14 )
	self.GUI.labelLine:SizeToContents()

	self.GUI.labelL = GUI:Label( "0/300", Vector2( 0.42, 0.82 ), Vector2( 0.1, 0.06 ), self.GUI.window )
	self.GUI.messagesScroll = GUI:ScrollControl( Vector2( 0.42, 0.07 ), Vector2( 0.56, 0.74 ), self.GUI.window )
	self.GUI.messagesLabel = GUI:Label( "", Vector2( 0.0, 0.011 ), Vector2( 0.95, 0.3 ), self.GUI.messagesScroll )
	self.GUI.messagesLabel:SetWrap( true )
	self.GUI.message = GUI:TextBox( "", Vector2( 0.42, 0.85 ), Vector2( 0.44, 0.06 ), "text", self.GUI.window )
	self.GUI.message:Subscribe( "ReturnPressed", self, self.sendMessage )
	self.GUI.message:Subscribe( "TextChanged", self, self.ChangelLText )
	self.GUI.send = GUI:Button( ">", Vector2( 0.88, 0.85 ), Vector2( 0.1, 0.06 ), self.GUI.window )
	self.GUI.send:SetTextHoveredColor( Color.Chartreuse )
	self.GUI.send:Subscribe( "Press", self, self.sendMessage )

	self.GUI.clear = Button.Create( self.GUI.window )
	self.GUI.clear:SetPosition( Vector2( self.GUI.window:GetSize().x - 95, 0.01 ) )
	self.GUI.clear:SetSize( Vector2( 80, 25 ) )
	self.GUI.clear:SetText( "Очистить" )
	self.GUI.clear:SetTextHoveredColor( Color.DarkOrange )
	self.GUI.clear:Subscribe( "Press", self, self.clearMessage )

	self.GUI.PMDistrub = Button.Create( self.GUI.window )
	self.GUI.PMDistrub:SetPosition( Vector2( self.GUI.clear:GetPosition().x - 110, 0.01 ) )
	self.GUI.PMDistrub:SetSize( Vector2( 100, 25 ) )
	self.GUI.PMDistrub:SetText( "Не беспокоить" )
	if LocalPlayer:GetValue( "PMDistrub" ) then
		self.GUI.PMDistrub:SetTextNormalColor( Color.DarkOrange )
		self.GUI.PMDistrub:SetTextHoveredColor( Color.DarkOrange )
	else
		self.GUI.PMDistrub:SetTextNormalColor( Color.White )
		self.GUI.PMDistrub:SetTextHoveredColor( Color.White )
	end
	self.GUI.PMDistrub:Subscribe( "Press", self, self.ToggleDistrub )

	self.GUI.window:Subscribe( "WindowClosed", self, self.CloseWindow )
	self.playerToRow = {}
	for player in Client:GetPlayers() do
		self:addPlayerToList ( player )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "PlayerJoin", self, self.playerJoin )
	Events:Subscribe( "PlayerQuit", self, self.playerQuit )
	Events:Subscribe( "OpenGuiPm", self, self.OpenGuiPm )
	Events:Subscribe( "CloseGuiPm", self, self.CloseGuiPm )
	Events:Subscribe( "KeyDown", self, self.KeyDown )
	Events:Subscribe( "LocalPlayerInput", self, self.localPlayerInput )
	Network:Subscribe( "PM.addMessage", self, self.addMessage )
end

function PM:Lang()
	self.GUI.window:SetTitle( "[▼] Private Messages" )
	self.GUI.labelM:SetText( "Messages:" )
	self.GUI.clear:SetText( "Clear" )
	self.GUI.PMDistrub:SetText( "Do not disturb" )
end

function PM:ChangelLText()
	self.GUI.labelL:SetText( self.GUI.message:GetText():len() .. "/300" )
	if self.GUI.message:GetText():len() >= 300 then
		self.GUI.labelL:SetTextColor( Color.Red )
	else
		self.GUI.labelL:SetTextColor( Color.White )
	end
end

function PM:CloseWindow()
	Mouse:SetVisible( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function PM:OpenGuiPm()
	if Game:GetState() ~= GUIState.Game then return end

	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})

	self.GUI.window:SetVisible( not self.GUI.window:GetVisible() )
	if self.GUI.window:GetVisible() == true then
		self:refreshList()
	end
	Mouse:SetVisible( self.GUI.window:GetVisible() )
end

function PM:CloseGuiPm()
	if Game:GetState() ~= GUIState.Game then return end
	if self.GUI.window:GetVisible() == true then
		self.GUI.window:SetVisible( false )
	end
	Mouse:SetVisible( false )
end

function PM:ToggleDistrub()
	self.dmoode = not LocalPlayer:GetValue( "PMDistrub" )
	Network:Send( "ChangePmMode", { dvalue = self.dmoode } )
	if LocalPlayer:GetValue( "PMDistrub" ) then
		self.GUI.PMDistrub:SetTextNormalColor( Color.White )
		self.GUI.PMDistrub:SetTextHoveredColor( Color.White )
	else
		self.GUI.PMDistrub:SetTextNormalColor( Color.DarkOrange )
		self.GUI.PMDistrub:SetTextHoveredColor( Color.DarkOrange )
	end
end

function PM:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self.GUI.window:SetVisible( false )
		Mouse:SetVisible( false )
	end
end

function PM:localPlayerInput( args )
	if ( self.GUI.window:GetVisible() and Game:GetState() == GUIState.Game ) then
		return false
	end
end

function PM:addPlayerToList( player )
	local item = self.GUI.list:AddItem( tostring ( player:GetName() ) )
	local color = player:GetColor()

	if LocalPlayer:IsFriend( player ) then
		item:SetToolTip( "Друг" )
	end

	item:SetTextColor( color )
	item:SetVisible( true )
	item:SetDataObject( "id", player )
	self.playerToRow [ player ] = item
end

function PM:playerJoin( args )
	self:addPlayerToList( args.player )
end

function PM:playerQuit( args )
	if ( self.playerToRow [ args.player ] ) then
		self.GUI.list:RemoveItem( self.playerToRow [ args.player ] )
		self.playerToRow [ args.player ] = nil
	end
end

function PM:loadMessages()
	local row = self.GUI.list:GetSelectedRow()
	if ( row ~= nil ) then
		local player = row:GetDataObject( "id" )
		self.GUI.messagesLabel:SetText( "" )
		if ( self.messages [ tostring( player:GetSteamId() ) ] ) then
			for index, msg in ipairs( self.messages [ tostring ( player:GetSteamId() ) ] ) do
				if ( index > 1 ) then
					self.GUI.messagesLabel:SetText( self.GUI.messagesLabel:GetText() .."\n".. tostring ( msg ) )
				else
					self.GUI.messagesLabel:SetText( tostring ( msg ) )
				end
			end
		end
		self.GUI.messagesLabel:SizeToContents()
	end
end

function PM:addMessage( data )
	if ( data.player ) then
		if ( not self.messages [ tostring ( data.player:GetSteamId() ) ] ) then
			self.messages [ tostring ( data.player:GetSteamId() ) ] = {}
		end
		local row = self.GUI.list:GetSelectedRow()
		if ( row ~= nil ) then
			local player = row:GetDataObject( "id" )
			if ( data.player == player ) then
				if ( #self.messages [ tostring( data.player:GetSteamId() ) ] > 0 ) then
					self.GUI.messagesLabel:SetText( self.GUI.messagesLabel:GetText() .."\n".. tostring ( data.text ) )
				else
					self.GUI.messagesLabel:SetText( tostring ( data.text ) )
				end
				self.GUI.messagesLabel:SizeToContents()
			end
		end
		table.insert ( self.messages [ tostring ( data.player:GetSteamId() ) ], data.text )
	end
end

function PM:sendMessage()
	local row = self.GUI.list:GetSelectedRow()
	if ( row ~= nil ) then
		local player = row:GetDataObject( "id" )
		if ( player ) then
			local text = self.GUI.message:GetText()
			if self.GUI.message:GetText():len() <= 300 then
				if ( text ~= "" ) then
					Network:Send( "PM.send", { player = player, text = text } )
					self.GUI.message:SetText( "" )
					self.GUI.message:Focus()
				end
			else
				Chat:Print( "[Сообщения] ", Color.White, "Вы привысили допустимый лимит!", Color.DarkGray )
			end
		else
			Chat:Print("[Сообщения] ", Color.White, "Игрок не в сети!", Color.DarkGray )
		end
	else
		Chat:Print( "[Сообщения] ", Color.White, "Игрок не выбран!", Color.DarkGray )
	end
end

function PM:clearMessage()
	self.GUI.message:SetText( "" )
end

function PM:refreshList()
	self.GUI.list:Clear()
	self.playerToRow = {}
	for player in Client:GetPlayers() do
		self:addPlayerToList( player )
	end
end

Events:Subscribe( "ModuleLoad",
	function()
		PM()
	end
)