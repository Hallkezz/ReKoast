class "ClanSystem"

msgColors =
	{
		[ "err" ] = Color( 255, 0, 0 ),
		[ "info" ] = Color( 0, 255, 0 ),
		[ "warn" ] = Color( 255, 100, 0 )
	}

function ClanSystem:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
end

function ClanSystem:ModuleLoad()
	self.active = false
	self.LastTick = 0
	self.playerClans = {}

	self.opcolor = Color( 251, 184, 41 )

	self.clanMenu = {}
	self.playerToRow = {}
	Network:Send( "Clans:GetClans" )
	self.clanMenu.window = GUI:Window( "✽ Кланы", Vector2( 0.54, 0.4 ) - Vector2( 0.3, 0.45 ) / 2, Vector2( 0.6, 0.70 ) )
	self.clanMenu.list = GUI:SortedList( Vector2( 0.0, 0.0 ), Vector2( 0.63, 0.85 ), self.clanMenu.window, { { name = "Клан" }, { name = "Тип" } } )
	self.clanMenu.join = GUI:Button( "» Присоединиться к клану", Vector2( 0.0, 0.865 ), Vector2( 0.63, 0.07 ), self.clanMenu.window )
	self.clanMenu.join:SetTextHoveredColor( Color.SpringGreen )
	self.clanMenu.join:Subscribe( "Press", self, self.JoinClan )

	self.clanMenu.cLabel = GUI:Label( "Клан:", Vector2( 0.66, 0.04 ), Vector2( 0.20, 0.1 ), self.clanMenu.window )
	self.clanMenu.manageClan = GUI:Button( "★ Ваш клан ★", Vector2( 0.66, 0.08 ), Vector2( 0.30, 0.09 ), self.clanMenu.window )
	self.clanMenu.manageClan:Subscribe( "Press", self, self.ManageClan )

	self.clanMenu.manageClan = GUI:Button( "Список кланов", Vector2( 0.66, 0.18 ), Vector2( 0.30, 0.07 ), self.clanMenu.window )
	self.clanMenu.manageClan:Subscribe( "Press", self, self.ClanMenu )

	self.clanMenu.pLabel = GUI:Label( "Игрокам:", Vector2( 0.66, 0.57 ), Vector2( 0.20, 0.1 ), self.clanMenu.window )
	self.clanMenu.clanList = GUI:Button( "••• Список игроков •••", Vector2( 0.66, 0.61 ), Vector2( 0.30, 0.07 ), self.clanMenu.window )
	self.clanMenu.clanList:Subscribe( "Press", self, self.ClanList )

	self.clanMenu.invitations = GUI:Button( "Приглашения", Vector2( 0.66, 0.7 ), Vector2( 0.30, 0.07 ), self.clanMenu.window )
	self.clanMenu.invitations:Subscribe( "Press", self, self.Invitations )

	self.clanMenu.create = GUI:Button( "Создать клан", Vector2( 0.66, 0.79 ), Vector2( 0.30, 0.07 ), self.clanMenu.window )
	self.clanMenu.create:Subscribe( "Press", self, self.ShowCreate )

	self.createClan = {}
	self.createClan.window = GUI:Window( "Создать клан", Vector2( 0.28, 0.34 ) - Vector2( 0.2, 0.33 ) / 2, Vector2( 0.2, 0.36 ) )
	self.createClan.window:SetVisible( false )
	self.createClan.nLabel = GUI:Label( "Название клана:", Vector2( 0.0, 0.01 ), Vector2( 0.0, 0.0 ), self.createClan.window )
	self.createClan.nLabel:SizeToContents()
	self.createClan.nEdit = GUI:TextBox( "", Vector2( 0.0, 0.08 ), Vector2( 0.96, 0.08 ), "text", self.createClan.window )
	self.createClan.nEdit:SetToolTip("(макс. 20 символов)")
	self.createClan.tLabel = GUI:Label( "Тег клана:", Vector2( 0.0, 0.20 ), Vector2( 0.0, 0.0 ), self.createClan.window )
	self.createClan.tLabel:SizeToContents()
	self.createClan.tEdit = GUI:TextBox( "", Vector2( 0.0, 0.27 ), Vector2( 0.96, 0.08 ), "text", self.createClan.window )
	self.createClan.tEdit:SetToolTip("(макс. 20 символов)")
	self.createClan.ttLabel = GUI:Label( "Тип клана:", Vector2( 0.0, 0.38 ), Vector2( 0.0, 0.0 ), self.createClan.window )
	self.createClan.ttLabel:SizeToContents()
	self.createClan.type = GUI:ComboBox( Vector2( 0.0, 0.46 ), Vector2( 0.96, 0.08 ), self.createClan.window, { "Открытый", "Только по приглашению" } )
	self.createClan.cPick = GUI:Button( "Цвет клана", Vector2( 0.0, 0.65 ), Vector2( 0.96, 0.10 ), self.createClan.window )
	self.createClan.cPick:Subscribe( "Press", self, self.Colour )
	self.createClan.tttLabel = GUI:Label( "Вам нужно: $10000", Vector2( 0.0, 0.57 ), Vector2( 0.96, 0.10 ), self.createClan.window )
	self.createClan.tttLabel:SetTextColor( self.opcolor )
	self.createClan.create = GUI:Button( "Создать клан", Vector2( 0.0, 0.75 ), Vector2( 0.96, 0.10 ), self.createClan.window )
	self.createClan.create:Subscribe( "Press", self, self.Create )

	self.colorPicker = {}
	self.colorPicker.window = GUI:Window( "▨ Цвет", Vector2( 0.28, 0.74 ) - Vector2( 0.2, 0.42 ) / 2, Vector2( 0.2, 0.42 ) )
	self.colorPicker.window:SetVisible( false )
	self.colorPicker.picker = HSVColorPicker.Create()
	self.colorPicker.picker:SetParent( self.colorPicker.window )
	self.colorPicker.picker:SetSizeRel( Vector2( 1.06, 0.8 ) )
	self.colorPicker.set = GUI:Button( "Установить цвет >", Vector2( 0.0, 0.82 ), Vector2( 0.76, 0.070 ), self.colorPicker.window )
	self.colorPicker.set:SetTextHoveredColor( Color.Yellow )
	self.colorPicker.set:SetTextPressedColor( Color.Yellow )
	self.colorPicker.set:Subscribe( "Press", self, self.SetColour )
	self.colorPicker.colour = { 255, 255, 255 }

	self.manageClan = {}
	self.manageClan.rows = {}
	self.manageClan.mList = GUI:SortedList( Vector2.Zero, Vector2( 0.63, 0.62 ), self.clanMenu.window, { { name = "Имя" }, { name = "Ранг" }, { name = "Дата вступления" } } )
	self.manageClan.mList:SetButtonsVisible( true )
	self.manageClan.mList:SetVisible( false )
	self.manageClan.dLabel = GUI:Label( "Название клана:", Vector2( 0, 0.72 ), Vector2.Zero, self.clanMenu.window )
	self.manageClan.dLabel:SizeToContents()
	self.manageClan.dLabel:SetVisible( false )
	self.manageClan.mLabel = GUI:Label( "Настройки участников:", Vector2( 0.33, 0.73 ), Vector2.Zero, self.clanMenu.window )
	self.manageClan.mLabel:SizeToContents()
	self.manageClan.mLabel:SetVisible( false )
	self.manageClan.ranks = GUI:ComboBox( Vector2( 0.33, 0.77 ), Vector2( 0.16, 0.06 ), self.clanMenu.window, { "Главный", "Заместитель", "Участник", "Петух" } )
	self.manageClan.ranks:SetVisible( false )
	self.manageClan.kick = GUI:Button( "Выгнать", Vector2( 0.33, 0.85 ), Vector2( 0.3, 0.068 ), self.clanMenu.window )
	self.manageClan.kick:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.kick:Subscribe( "Press", self, self.Kick )
	self.manageClan.kick:SetVisible( false )
	self.manageClan.sRank = GUI:Button( "Уст. ранг", Vector2( 0.50, 0.77 ), Vector2( 0.13, 0.065 ), self.clanMenu.window )
	self.manageClan.sRank:Subscribe( "Press", self, self.SetRank )
	self.manageClan.sRank:SetVisible( false )
	self.manageClan.leaveClan = GUI:Button( "Покинуть", Vector2( 0.33, 0.63 ), Vector2( 0.16, 0.068 ), self.clanMenu.window )
	self.manageClan.leaveClan:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.leaveClan:SetTextPressedColor( Color.DarkOrange )
	self.manageClan.leaveClan:Subscribe( "Press", self, self.LeaveClan )
	self.manageClan.leaveClan:SetVisible( false )
	self.manageClan.delete = GUI:Button( "Удалить", Vector2( 0.5, 0.63 ), Vector2( 0.13, 0.068 ), self.clanMenu.window )
	self.manageClan.delete:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.delete:Subscribe( "Press", self, self.Remove )
	self.manageClan.delete:SetVisible( false )
	self.manageClan.log = GUI:Button( "Логи", Vector2( 0, 0.63 ), Vector2( 0.13, 0.068 ), self.clanMenu.window )
	self.manageClan.log:Subscribe( "Press", self, self.ShowLog )
	self.manageClan.log:SetVisible( false )
	self.manageClan.motd = GUI:Button( "Информация", Vector2( 0.14, 0.63 ), Vector2( 0.16, 0.068 ), self.clanMenu.window )
	self.manageClan.motd:Subscribe( "Press", self, self.ShowMotd )
	self.manageClan.motd:SetVisible( false )

	self.confirm = {}
	self.confirm.action = ""
	self.confirm.window = GUI:Window( "Подтвердить действие", Vector2( 0.85, 0.5 ) - Vector2( 0.13, 0.13 ) / 2, Vector2( 0.19, 0.13 ) )
	self.confirm.window:SetVisible( false )
	self.confirm.label = GUI:Label( "Вы уверены, что хотите это сделать?", Vector2( 0.03, 0.1 ), Vector2( 0.90, 0.23 ), self.confirm.window )
	self.confirm.label:SetWrap( true )
	self.confirm.label:SetTextColor( Color.DarkOrange )
	self.confirm.accept = GUI:Button( "Да", Vector2( 0, 0.35 ), Vector2( 0.95, 0.3 ), self.confirm.window )
	self.confirm.accept:SetTextHoveredColor( Color.DarkOrange )
	self.confirm.accept:Subscribe( "Press", self, self.Confirm )

	self.invitations = {}
	self.invitations.rows = {}
	self.invitations.window = GUI:Window( "Приглашения", Vector2( 0.26, 0.4 ) - Vector2( 0.25, 0.45 ) / 2, Vector2( 0.25, 0.7 ) )
	self.invitations.window:SetVisible( false )
	self.invitations.list = GUI:SortedList( Vector2.Zero, Vector2( 0.97, 0.85 ), self.invitations.window, { { name = "Клан" } } )
	self.invitations.join = GUI:Button( "» Присоединиться к клану", Vector2( 0, 0.86 ), Vector2( 0.97, 0.07 ), self.invitations.window )
	self.invitations.join:SetTextHoveredColor( Color.SpringGreen )
	self.invitations.join:Subscribe( "Press", self, self.AcceptInvite )

	self.clanList = {}
	self.clanList.rows = {}
	self.clanList.window = GUI:Window( "••• Список игроков •••", Vector2( 0.26, 0.4 ) - Vector2( 0.25, 0.45 ) / 2, Vector2( 0.25, 0.7 ) )
	self.clanList.window:SetVisible( false )
	self.clanMenu.playersList = GUI:SortedList( Vector2.Zero, Vector2( 0.97, 0.75 ), self.clanList.window, { { name = "Игроки:" } } )
	self.clanMenu.playersList:SetBackgroundVisible( false )
	for player in Client:GetPlayers() do
		self:addPlayerToList( player )
	end
	self:addPlayerToList( LocalPlayer )

	self.clanMenu.invitePlayer = GUI:Button( "» Пригл. игрока", Vector2( 0, 0.86 ), Vector2( 0.97, 0.07 ), self.clanList.window )
	self.clanMenu.invitePlayer:SetTextHoveredColor( Color.SpringGreen )
	self.clanMenu.invitePlayer:Subscribe( "Press", self, self.InvitePlayer )

	self.clanMenu.searchEdit = GUI:TextBox( "", Vector2( 0, 0.79 ), Vector2( 0.97, 0.06 ), "text", self.clanList.window )
	self.clanMenu.searchEdit:SetToolTip( "Поиск" )
	self.clanMenu.searchEdit:Subscribe( "TextChanged", self, self.SearchPlayer )

	self.motd = {}
	self.motd.window = GUI:Window( "Информация", Vector2( 0.25, 0.35 ) - Vector2( 0.27, 0.35 ) / 2, Vector2( 0.27, 0.7 ) )
	self.motd.window:SetVisible( false )
	self.motd.content = GUI:TextBox( "\n\n\n\n\n\n\n\n\n\n\n\n\n\nЧат клана - /f <текст>\nP.s Своих убивать вы не можете!", Vector2.Zero, Vector2( 0.96, 0.85 ), "multiline", self.motd.window )
	self.motd.content:SetEnabled( false )
	self.motd.update = GUI:Button( "Обновить информацию", Vector2( 0, 0.86 ), Vector2( 0.97, 0.07 ), self.motd.window )
	self.motd.update:Subscribe( "Press", self, self.UpdateMotd )

	self.log = {}
	self.log.window = GUI:Window( "Логи", Vector2( 0.25, 0.35 ) - Vector2( 0.27, 0.35 ) / 2, Vector2( 0.27, 0.7 ) )
	self.log.window:SetVisible( false )
	self.log.list = GUI:SortedList( Vector2.Zero, Vector2( 0.97, 0.85 ), self.log.window, { { name = "Действия" } } )
	self.log.clear = GUI:Button( "Очистить логи", Vector2( 0, 0.86 ), Vector2( 0.97, 0.07 ), self.log.window )
	self.log.clear:SetTextHoveredColor( Color.DarkOrange )
	self.log.clear:SetTextPressedColor( Color.DarkOrange )
	self.log.clear:Subscribe( "Press", self, self.ClearLog )

	Network:Send( "Clans:RequestSyncList", LocalPlayer )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Network:Subscribe( "Clans:SyncPlayers", self, self.SyncPlayerClans )
	Network:Subscribe( "Clans:ReceiveData", self, self.ReceiveData )
	Network:Subscribe( "Clans:ReceiveInvitations", self, self.ReceiveInvitations )
	Network:Subscribe( "Clans:ReceiveClans", self, self.ReceiveClans )
	Events:Subscribe( "OpenClansMenu", self, self.OpenClansMenu )
	Events:Subscribe( "CloseClansMenu", self, self.CloseClansMenu )
	Events:Subscribe( "KeyDown", self, self.KeyDown )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "Render", self, self.Render )
	self.clanMenu.window:Subscribe( "WindowClosed", self, self.WindowClosed )
end	

function ClanSystem:GetActive()
	return self.active
end

function ClanSystem:SetActive( state )
	self.active = state
	self.clanMenu.window:SetVisible( self.active )
	Mouse:SetVisible( self.active )
	if ( not state ) then
		self.createClan.window:SetVisible( false )
		self.colorPicker.window:SetVisible( false )
		self.confirm.window:SetVisible( false )
		self.invitations.window:SetVisible( false )
		self.clanList.window:SetVisible( false )
		self.log.window:SetVisible( false )
		self.motd.window:SetVisible( false )
	end
end

function ClanSystem:OpenClansMenu()
	if Game:GetState() ~= GUIState.Game then return end

	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})

	if not (LocalPlayer:GetMoney() >= 10000) then
		self.createClan.create:SetTextHoveredColor( Color.Coral )
		self.createClan.create:SetTextNormalColor( Color.Coral )
		self.createClan.create:SetTextPressedColor( Color.Coral )
	else
		self.createClan.create:SetTextHoveredColor( Color.SpringGreen )
		self.createClan.create:SetTextNormalColor( Color.SpringGreen )
		self.createClan.create:SetTextPressedColor( Color.SpringGreen )
	end
		self:SetActive( not self:GetActive() )
		Network:Send( "Clans:GetClans" )
end

function ClanSystem:CloseClansMenu()
	if Game:GetState() ~= GUIState.Game then return end
	if self.clanMenu.window:GetVisible() == true then
		self:SetActive( false )
	end
end

function ClanSystem:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetActive( false )
	end
end

function ClanSystem:LocalPlayerInput( args )
	if ( self:GetActive() and Game:GetState() == GUIState.Game ) then
		return false
	end
end

function ClanSystem:WindowClosed()
	self:SetActive ( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function ClanSystem:SetColour()
	local color = self.colorPicker.picker:GetColor()
	self.colorPicker.colour = { color.r, color.g, color.b }
	self.colorPicker.window:SetVisible( false )
end

function ClanSystem:Colour()
	self.colorPicker.window:SetVisible( not self.colorPicker.window:GetVisible() )
end

function ClanSystem:ManageClan()
	Network:Send( "Clans:GetData" )
end

function ClanSystem:ClanMenu()
	self.clanMenu.list:SetVisible( true )
	self.clanMenu.join:SetVisible( true )

	self.manageClan.mList:SetVisible( false )
	self.manageClan.dLabel:SetVisible( false )
	self.manageClan.mLabel:SetVisible( false )
	self.manageClan.ranks:SetVisible( false )
	self.manageClan.kick:SetVisible( false )
	self.manageClan.sRank:SetVisible( false )
	self.manageClan.leaveClan:SetVisible( false )
	self.manageClan.delete:SetVisible( false )
	self.manageClan.log:SetVisible( false )
	self.manageClan.motd:SetVisible( false )
end

function ClanSystem:LeaveClan()
	self.confirm.window:SetVisible( true )
	self.confirm.action = "leave"
end

function ClanSystem:InvitePlayer()
	local row = self.clanMenu.playersList:GetSelectedRow()
	if ( row ~= nil ) then
		local player = row:GetDataObject ( "id" )
		Network:Send( "Clans:Invite", player )
	end
end

function ClanSystem:ClanList()	
	self.clanList.window:SetVisible( true )
end

function ClanSystem:Invitations()
	self.invitations.window:SetVisible( true )
	Network:Send( "Clans:Invitations" )
end

function ClanSystem:ReceiveInvitations( invitations )
	self.invitations.list:Clear()
	if ( type ( invitations ) == "table" ) then
		for index, clan in ipairs ( invitations ) do
			self.invitations.rows [ clan ] = self.invitations.list:AddItem ( tostring ( clan ) )
			self.invitations.rows [ clan ]:SetDataNumber ( "id", index )
		end
	end
end

function ClanSystem:AcceptInvite()
	local row = self.invitations.list:GetSelectedRow()
	if ( row ~= nil ) then
		local clan = row:GetCellText( 0 )
		local index = row:GetDataNumber( "id" )
		Network:Send( "Clans:AcceptInvite", { clan = clan, index = index } )
		self.invitations.window:SetVisible( false )
	end
end

function ClanSystem:ReceiveClans( clans )
	self.clanMenu.list:Clear()
	for name, data in pairs ( clans ) do
		local item = self.clanMenu.list:AddItem( tostring ( name ) )
		item:SetCellText( 1, ( data.type == "Открытый" and "Публичный" or "Только по приглашению" ) )
		table.insert( self.clanList.rows, item )
	end
end

function ClanSystem:JoinClan()
	local row = self.clanMenu.list:GetSelectedRow()
	if ( row ~= nil ) then
		local clan = row:GetCellText( 0 )
		Network:Send( "Clans:JoinClan", clan )
	end
end

function ClanSystem:ShowCreate()
	self.createClan.window:SetVisible( true )
end

function ClanSystem:Create()
	local args = {}
	args.name = self.createClan.nEdit:GetText():sub( 0, 20 )
	if self.createClan.nEdit:GetText():len() <= 20 then
		if ( args.name ~= "" ) then
			args.tag = self.createClan.tEdit:GetText():sub( 0, 20 )
			args.colour = table.concat( self.colorPicker.colour, ", " )
			args.type = self.createClan.type:GetText()
			Network:Send( "Clans:Create", args )
			self.createClan.window:SetVisible( false )
		else
			LocalPlayer:Message( "[Клан] Напишите название клана!", "err" )
		end
	else
		LocalPlayer:Message( "[Клан] В названии кланы больше 20-ти символов!", "err" )
	end
end

function ClanSystem:ReceiveData( args )
	self.clanMenu.list:SetVisible( false )
	self.clanMenu.join:SetVisible( false )

	self.manageClan.mList:SetVisible( true )
	self.manageClan.dLabel:SetVisible( true )
	self.manageClan.mLabel:SetVisible( true )
	self.manageClan.ranks:SetVisible( true )
	self.manageClan.kick:SetVisible( true )
	self.manageClan.sRank:SetVisible( true )
	self.manageClan.leaveClan:SetVisible( true )
	self.manageClan.delete:SetVisible( true )
	self.manageClan.log:SetVisible( true )
	self.manageClan.motd:SetVisible( true )
	self.manageClan.dLabel:SetText(
		"> Название клана: " .. tostring ( args.clanData.name ) ..
		"\n\n> Тег клана: " .. tostring ( args.clanData.tag ) ..
		"\n\n★ Тип клана: " .. ( args.clanData.type == "Открытый" and "Публичный" or "Только по приглашению" ) ..
		"\n\nツ Всего участников: " .. tostring ( #args.members ) ..
		"\n\n● Дата создания: ".. tostring ( args.clanData.creationDate ) )
	self.manageClan.dLabel:SizeToContents()
	self.manageClan.mList:Clear()
	for _, member in ipairs( args.members ) do
		local item = self.manageClan.mList:AddItem( tostring( member.name ) )
		item:SetCellText( 1, tostring ( member.rank ) )
		item:SetCellText( 2, tostring ( member.joinDate ) )
		item:SetDataString( "id", member.steamID )
		table.insert( self.manageClan.rows, item )
	end
	self.log.list:Clear()
	if ( type ( args.messages ) == "table" ) then
		for _, msg in ipairs( args.messages ) do
			if ( msg.type == "log" ) then
				self.log.list:AddItem( tostring( msg.message ) )
			end
		end
	end
end

function ClanSystem:Kick()
	local row = self.manageClan.mList:GetSelectedRow()
	if ( row ~= nil ) then
		local steamID = row:GetDataString( "id" )
		local name = row:GetCellText( 0 )
		local rank = row:GetCellText( 1 )
		Network:Send( "Clans:Kick", { name = name, steamID = steamID, rank = rank } )
	end
end

function ClanSystem:SetRank()
	local row = self.manageClan.mList:GetSelectedRow()
	if ( row ~= nil ) then
		local steamID = row:GetDataString ( "id" )
		local name = row:GetCellText( 0 )
		local rank = self.manageClan.ranks:GetText()
		local curRank = row:GetCellText( 1 )
		Network:Send( "Clans:SetRank", { name = name, steamID = steamID, curRank = curRank, rank = rank } )
	end
end

function ClanSystem:ShowLog()
	self.log.window:SetVisible( true )
end

function ClanSystem:ShowMotd()
	self.motd.window:SetVisible( true )
end

function ClanSystem:Remove()
	self.confirm.window:SetVisible( true )
	self.confirm.action = "remove"
end

function ClanSystem:Chat()
end

function ClanSystem:Confirm()
	if ( self.confirm.action == "remove" ) then
		Network:Send( "Clans:Remove" )
	elseif ( self.confirm.action == "leave" ) then
		Network:Send( "Clans:Leave" )
	end
	self:ClanMenu()
	self:SetActive( false )
end

function ClanSystem:addPlayerToList( player )
	local item = self.clanMenu.playersList:AddItem( tostring ( player:GetName() ) )
	local playerColor = player:GetColor()
	
	if LocalPlayer:IsFriend( player ) then
		item:SetToolTip( "Друг" )
	end
	
	item:SetVisible( true )
	item:SetDataObject( "id", player )
	item:SetTextColor( playerColor )
	self.playerToRow [ player:GetId() ] = item
end

function ClanSystem:PlayerJoin( args )
	self:addPlayerToList( args.player )
end

function ClanSystem:PlayerQuit( args )
	if ( self.playerToRow [ args.player:GetId() ] ) then
		self.clanMenu.playersList:RemoveItem( self.playerToRow [ args.player:GetId() ] )
	end
end

function ClanSystem:SearchPlayer()
	local text = self.clanMenu.searchEdit:GetText():lower()
	if ( text ~= "" and text:len() > 0 ) then
		for _, item in pairs ( self.playerToRow ) do
			if ( type ( item ) == "userdata" ) then
				item:SetVisible( false )
				if item:GetCellText( 0 ):lower():find( text, 1, true ) then
					item:SetVisible( true )
				end
			end
		end
	else
		for _, item in pairs ( self.playerToRow ) do
			if ( type ( item ) == "userdata" ) then
				item:SetVisible( true )
			end
		end
	end
end

function ClanSystem:SyncPlayerClans( players )
	self.playerClans = players
end

function ClanSystem:PostTick()
	if ( Client:GetElapsedSeconds() - self.LastTick >= 5 ) then
		Network:Send( "Clans:RequestSyncList", LocalPlayer )
		self.LastTick = Client:GetElapsedSeconds()
	end
end

function ClanSystem:GetPlayerClan( player )
	if ( type ( player ) == "userdata" ) then
		if ( self.playerClans [ player:GetId() ] ) then
			return self.playerClans [ player:GetId() ]
		else
			return false
		end
	else
		return false
	end
end

function ClanSystem:UpdateMotd()
	local text = self.motd.content:GetText()
	Network:Send( "Clans:UpdateMOTD", text )
end

function ClanSystem:ClearLog()
	Network:Send( "Clans:ClearLog" )
	self.log.window:SetVisible( false )
	self.log.list:Clear()
end

function ClanSystem:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.clanMenu.window:GetVisible() ~= is_visible then
		self.clanMenu.window:SetVisible( is_visible )
	end

	if self.active then
		Mouse:SetVisible( true )
	end
end

clanSystem = ClanSystem()

function LocalPlayer:Message( msg, color )
	Chat:Print( msg, msgColors [ color ] )
end

function convertNumberToString( value )
	if ( value and tonumber( value ) ) then
		local value = tostring( value )
		if string.sub ( value, 1, 1 ) == "-" then
			return "-".. setCommasInNumber( string.sub( value, 2, #value ) )
		else
			return setCommasInNumber( value )
		end
	end

	return false
end

function setCommasInNumber( value )
	if ( #value > 3 ) then
		return setCommasInNumber( string.sub ( value, 1, #value - 3 ) ) ..",".. string.sub ( value, #value - 2, #value )
	else
		return value
	end
end