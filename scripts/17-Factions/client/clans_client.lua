class "ClanSystem"

msgColors =
	{
		[ "err" ] = Color.DarkGray,
		[ "info" ] = Color( 0, 255, 0 ),
		[ "warn" ] = Color( 255, 100, 0 )
	}

function ClanSystem:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
end

function ClanSystem:ModuleLoad()
	self.active = false
	self.LastTick = 0
	self.creationdate = "03/08/17 00:00:00"
	self.playerClans = {}

	self.opcolor = Color( 251, 184, 41 )

	self.clanMenu = {}
	self.playerToRow = {}
	self.clansRow = {}

	Network:Send( "Clans:GetClans" )
	self.clanMenu.window = GUI:Window( "✽ Кланы", Vector2( 0.54, 0.4 ) - Vector2( 0.3, 0.45 ) / 2, Vector2( 0.6, 0.70 ) )
	self.clanMenu.tabs = TabControl.Create( self.clanMenu.window )
	self.clanMenu.tabs:SetDock( GwenPosition.Fill )
	self.clanMenu.tabs:SetVisible( true )

	local clanslist = BaseWindow.Create( self.clanMenu.tabs )
	self.clanMenu.tabs:AddPage( "Список кланов", clanslist )

	self.clanMenu.list = SortedList.Create( clanslist )
	self.clanMenu.list:SetDock( GwenPosition.Fill )
	self.clanMenu.list:AddColumn( "Клан" )
	self.clanMenu.list:AddColumn( "Основатель" )
	self.clanMenu.list:AddColumn( "Тип" )
	self.clanMenu.list:Subscribe( "RowSelected", self, self.GetClanInfo )

	self.clanMenu.bkpanelsLabel = Label.Create( clanslist )
	self.clanMenu.bkpanelsLabel:SetDock( GwenPosition.Right )
	self.clanMenu.bkpanelsLabel:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )
	self.clanMenu.bkpanelsLabel:SetSize( Vector2( 250, 20 ) )

	self.clanMenu.cLabel = GroupBox.Create( self.clanMenu.bkpanelsLabel )
	self.clanMenu.cLabel:SetText( "Клан" )
	self.clanMenu.cLabel:SetDock( GwenPosition.Top )
	self.clanMenu.cLabel:SetSize( Vector2( 0, 100 ) )

	self.clanMenu.manageClan = Button.Create( self.clanMenu.cLabel )
	self.clanMenu.manageClan:SetDock( GwenPosition.Top )
	self.clanMenu.manageClan:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.manageClan:SetSize( Vector2( 0, 45 ) )
	self.clanMenu.manageClan:SetTextSize( 15 )
	self.clanMenu.manageClan:SetText( "★ Ваш клан ★" )
	self.clanMenu.manageClan:Subscribe( "Press", self, self.ManageClan )

	self.clanMenu.manageClan = Button.Create( self.clanMenu.cLabel )
	self.clanMenu.manageClan:SetDock( GwenPosition.Top )
	self.clanMenu.manageClan:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.manageClan:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.manageClan:SetTextSize( 15 )
	self.clanMenu.manageClan:SetText( "Список кланов" )
	self.clanMenu.manageClan:Subscribe( "Press", self, self.ClanMenu )

	self.clanMenu.pLabel = GroupBox.Create( self.clanMenu.bkpanelsLabel )
	self.clanMenu.pLabel:SetText( "Игрокам" )
	self.clanMenu.pLabel:SetDock( GwenPosition.Bottom )
	self.clanMenu.pLabel:SetSize( Vector2( 0, 160 ) )

	self.clanMenu.join = Button.Create( self.clanMenu.pLabel )
	self.clanMenu.join:SetDock( GwenPosition.Top )
	self.clanMenu.join:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.join:SetSize( Vector2( 0, 35 ) )
	self.clanMenu.join:SetTextSize( 15 )
	self.clanMenu.join:SetText( "» Присоединиться к клану" )
	self.clanMenu.join:SetTextHoveredColor( Color.SpringGreen )
	self.clanMenu.join:Subscribe( "Press", self, self.JoinClan )

	self.clanMenu.playersList = Button.Create( self.clanMenu.pLabel )
	self.clanMenu.playersList:SetDock( GwenPosition.Top )
	self.clanMenu.playersList:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.playersList:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.playersList:SetTextSize( 15 )
	self.clanMenu.playersList:SetText( "••• Список игроков •••" )
	self.clanMenu.playersList:Subscribe( "Press", self, self.ClanList )

	self.clanMenu.invitations = Button.Create( self.clanMenu.pLabel )
	self.clanMenu.invitations:SetDock( GwenPosition.Top )
	self.clanMenu.invitations:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.invitations:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.invitations:SetTextSize( 15 )
	self.clanMenu.invitations:SetText( "Приглашения" )
	self.clanMenu.invitations:Subscribe( "Press", self, self.Invitations )

	self.clanMenu.create = Button.Create( self.clanMenu.pLabel )
	self.clanMenu.create:SetDock( GwenPosition.Top )
	self.clanMenu.create:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.create:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.create:SetTextSize( 15 )
	self.clanMenu.create:SetText( "Создать клан" )
	self.clanMenu.create:Subscribe( "Press", self, self.ShowCreate )

	self.clanMenu.iLabel = GroupBox.Create( self.clanMenu.bkpanelsLabel )
	self.clanMenu.iLabel:SetText( "Информация" )
	self.clanMenu.iLabel:SetMargin( Vector2( 0, 0 ), Vector2( 0, 20 ) )
	self.clanMenu.iLabel:SetDock( GwenPosition.Bottom )
	self.clanMenu.iLabel:SetSize( Vector2( 0, 160 ) )
	self.clanMenu.iLabel:SetVisible( false )

	self.clanMenu.scrollpanelLabel = ScrollControl.Create( self.clanMenu.iLabel )
	self.clanMenu.scrollpanelLabel:SetDock( GwenPosition.Fill )
	self.clanMenu.scrollpanelLabel:SetScrollable( false, true )

	self.clanMenu.bkpanelsLabel = Label.Create( self.clanMenu.scrollpanelLabel )
	self.clanMenu.bkpanelsLabel:SetText( "Название: Х/З\nОснователь: Х/З\nДата создания: Х/З\nТип: Х/З\nОписание: Х/З" )
	self.clanMenu.bkpanelsLabel:SetWrap( true )
	self.clanMenu.bkpanelsLabel:SetDock( GwenPosition.Fill )

	self.clanMenu.searchClansEdit = TextBox.Create( clanslist )
	self.clanMenu.searchClansEdit:SetDock( GwenPosition.Bottom )
	self.clanMenu.searchClansEdit:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.searchClansEdit:SetMargin( Vector2( 0, 5 ), Vector2( 5, 0 ) )
	self.clanMenu.searchClansEdit:SetToolTip( "Поиск" )
	self.clanMenu.searchClansEdit:Subscribe( "TextChanged", self, self.SearchClans )

	self.createClan = {}
	self.createClan.tabs = TabControl.Create( self.clanMenu.window )
	self.createClan.tabs:SetDock( GwenPosition.Fill )
	self.createClan.tabs:SetVisible( false )

	local clancreate = BaseWindow.Create( self.createClan.tabs )
	self.createClan.tabs:AddPage( "Создание клана", clancreate )

	self.createClan.bkpanelsLabel = Label.Create( clancreate )
	self.createClan.bkpanelsLabel:SetDock( GwenPosition.Right )
	self.createClan.bkpanelsLabel:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )
	self.createClan.bkpanelsLabel:SetSize( Vector2( 250, 20 ) )

	self.createClan.pLabel = GroupBox.Create( self.createClan.bkpanelsLabel )
	self.createClan.pLabel:SetText( "Управление" )
	self.createClan.pLabel:SetDock( GwenPosition.Bottom )
	self.createClan.pLabel:SetSize( Vector2( 0, 100 ) )

	self.createClan.dLabel = Label.Create( self.createClan.pLabel )
	self.createClan.dLabel:SetDock( GwenPosition.Top )
	self.createClan.dLabel:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.createClan.dLabel:SetText( "Требуется $10000, чтобы создать клан" )
	self.createClan.dLabel:SetTextColor( self.opcolor )
	self.createClan.dLabel:SizeToContents()

	self.createClan.create = Button.Create( self.createClan.pLabel )
	self.createClan.create:SetDock( GwenPosition.Top )
	self.createClan.create:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.createClan.create:SetSize( Vector2( 0, 30 ) )
	self.createClan.create:SetTextSize( 15 )
	self.createClan.create:SetText( "Создать клан" )
	self.createClan.create:Subscribe( "Press", self, self.Create )

	self.createClan.back = Button.Create( self.createClan.pLabel )
	self.createClan.back:SetDock( GwenPosition.Top )
	self.createClan.back:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.createClan.back:SetSize( Vector2( 0, 30 ) )
	self.createClan.back:SetTextSize( 15 )
	self.createClan.back:SetText( "< Назад" )
	self.createClan.back:Subscribe( "Press", self, self.ShowCreate )

	self.createClan.nLabel = Label.Create( clancreate )
	self.createClan.nLabel:SetDock( GwenPosition.Top )
	self.createClan.nLabel:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.createClan.nLabel:SetText( "Название клана:" )
	self.createClan.nLabel:SizeToContents()

	self.createClan.nEdit = TextBox.Create( clancreate )
	self.createClan.nEdit:SetDock( GwenPosition.Top )
	self.createClan.nEdit:SetSize( Vector2( 260, 25 ) )
	self.createClan.nEdit:SetToolTip("(макс. 20 символов)")

	self.createClan.tLabel = Label.Create( clancreate )
	self.createClan.tLabel:SetDock( GwenPosition.Top )
	self.createClan.tLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 2 ) )
	self.createClan.tLabel:SetText( "Описание клана:" )
	self.createClan.tLabel:SizeToContents()

	self.createClan.tEdit = TextBoxMultiline.Create( clancreate )
	self.createClan.tEdit:SetDock( GwenPosition.Top )
	self.createClan.tEdit:SetSize( Vector2( 0, 80 ) )

	self.createClan.ttLabel = Label.Create( clancreate )
	self.createClan.ttLabel:SetDock( GwenPosition.Top )
	self.createClan.ttLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 2 ) )
	self.createClan.ttLabel:SetText( "Тип клана:" )
	self.createClan.ttLabel:SizeToContents()

	self.createClan.type = ComboBox.Create( clancreate )
	self.createClan.type:SetDock( GwenPosition.Top )
	self.createClan.type:SetSize( Vector2( 0, 20 ) )
	self.createClan.type:AddItem( "Открытый" )
	self.createClan.type:AddItem( "По приглашению" )

	self.createClan.picker = HSVColorPicker.Create( clancreate )
	self.createClan.picker:SetDock( GwenPosition.Top )
	self.createClan.picker:SetMargin( Vector2( 0, 20 ), Vector2( 0, 0 ) )
	self.createClan.picker:SetSize( Vector2( 0, 250 ) )
	self.createClan.colour = { 255, 255, 255 }

	self.manageClan = {}
	self.manageClan.rows = {}

	self.manageClan.mctabs = TabControl.Create( self.clanMenu.window )
	self.manageClan.mctabs:SetDock( GwenPosition.Fill )
	self.manageClan.mctabs:SetVisible( false )

	local hometab = BaseWindow.Create( self.manageClan.mctabs )
	self.manageClan.mctabs:AddPage( "Мой клан", hometab )

	self.manageClan.mList = SortedList.Create( hometab )
	self.manageClan.mList:SetDock( GwenPosition.Fill )
	self.manageClan.mList:AddColumn( "Игрок" )
	self.manageClan.mList:AddColumn( "Ранг" )
	self.manageClan.mList:AddColumn( "Дата вступления" )

	self.manageClan.mBkpanelsLabel = Label.Create( hometab )
	self.manageClan.mBkpanelsLabel:SetDock( GwenPosition.Right )
	self.manageClan.mBkpanelsLabel:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )
	self.manageClan.mBkpanelsLabel:SetSize( Vector2( 250, 20 ) )

	self.manageClan.mcLabel = GroupBox.Create( self.manageClan.mBkpanelsLabel )
	self.manageClan.mcLabel:SetText( "Клан" )
	self.manageClan.mcLabel:SetDock( GwenPosition.Top )
	self.manageClan.mcLabel:SetSize( Vector2( 0, 100 ) )

	self.manageClan.manageClan = Button.Create( self.manageClan.mcLabel )
	self.manageClan.manageClan:SetDock( GwenPosition.Top )
	self.manageClan.manageClan:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.manageClan:SetSize( Vector2( 0, 45 ) )
	self.manageClan.manageClan:SetTextSize( 15 )
	self.manageClan.manageClan:SetText( "★ Ваш клан ★" )
	self.manageClan.manageClan:Subscribe( "Press", self, self.ManageClan )

	self.manageClan.manageClan = Button.Create( self.manageClan.mcLabel )
	self.manageClan.manageClan:SetDock( GwenPosition.Top )
	self.manageClan.manageClan:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.manageClan:SetSize( Vector2( 0, 30 ) )
	self.manageClan.manageClan:SetTextSize( 15 )
	self.manageClan.manageClan:SetText( "Список кланов" )
	self.manageClan.manageClan:Subscribe( "Press", self, self.ClanMenu )

	self.manageClan.newsLabel = GroupBox.Create( self.manageClan.mBkpanelsLabel )
	self.manageClan.newsLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 10 ) )
	self.manageClan.newsLabel:SetText( "Сообщение дня" )
	self.manageClan.newsLabel:SetDock( GwenPosition.Top )
	self.manageClan.newsLabel:SetSize( Vector2( 0, 100 ) )

	self.manageClan.scrollpanelLabel = ScrollControl.Create( self.manageClan.newsLabel )
	self.manageClan.scrollpanelLabel:SetDock( GwenPosition.Fill )
	self.manageClan.scrollpanelLabel:SetScrollable( false, true )

	self.manageClan.newstbLabel = Label.Create( self.manageClan.scrollpanelLabel )
	self.manageClan.newstbLabel:SetText( "Загрузка..." )
	self.manageClan.newstbLabel:SetWrap( true )
	self.manageClan.newstbLabel:SetDock( GwenPosition.Fill )

	self.manageClan.mpLabel = GroupBox.Create( self.manageClan.mBkpanelsLabel )
	self.manageClan.mpLabel:SetText( "Управление" )
	self.manageClan.mpLabel:SetDock( GwenPosition.Bottom )
	self.manageClan.mpLabel:SetSize( Vector2( 0, 85 ) )

	self.manageClan.playersList = Button.Create( self.manageClan.mpLabel )
	self.manageClan.playersList:SetDock( GwenPosition.Top )
	self.manageClan.playersList:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.playersList:SetSize( Vector2( 0, 30 ) )
	self.manageClan.playersList:SetTextSize( 15 )
	self.manageClan.playersList:SetText( "••• Список игроков •••" )
	self.manageClan.playersList:Subscribe( "Press", self, self.ClanList )

	self.manageClan.leaveClan = Button.Create( self.manageClan.mpLabel )
	self.manageClan.leaveClan:SetDock( GwenPosition.Top )
	self.manageClan.leaveClan:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.leaveClan:SetSize( Vector2( 0, 30 ) )
	self.manageClan.leaveClan:SetTextSize( 15 )
	self.manageClan.leaveClan:SetText( "Покинуть клан" )
	self.manageClan.leaveClan:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.leaveClan:SetTextPressedColor( Color.DarkOrange )
	self.manageClan.leaveClan:Subscribe( "Press", self, self.LeaveClan )

	self.manageClan.mDownpanelsLabel = Label.Create( hometab )
	self.manageClan.mDownpanelsLabel:SetDock( GwenPosition.Bottom )
	self.manageClan.mDownpanelsLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 0 ) )
	self.manageClan.mDownpanelsLabel:SetSize( Vector2( 0, 110 ) )

	self.manageClan.cInfoLabel = GroupBox.Create( self.manageClan.mDownpanelsLabel )
	self.manageClan.cInfoLabel:SetText( "Информация" )
	self.manageClan.cInfoLabel:SetDock( GwenPosition.Left )
	self.manageClan.cInfoLabel:SetSize( Vector2( 280, 0 ) )

	self.manageClan.ciLabel = Label.Create( self.manageClan.cInfoLabel )
	self.manageClan.ciLabel:SetDock( GwenPosition.Bottom )
	self.manageClan.ciLabel:SetText( "Название клана:" )
	self.manageClan.ciLabel:SizeToContents()

	self.manageClan.psettLabel = GroupBox.Create( self.manageClan.mDownpanelsLabel )
	self.manageClan.psettLabel:SetText( "Управление участниками" )
	self.manageClan.psettLabel:SetDock( GwenPosition.Fill )
	self.manageClan.psettLabel:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )

	self.manageClan.ranks = ComboBox.Create( self.manageClan.psettLabel )
	self.manageClan.ranks:SetDock( GwenPosition.Top )
	self.manageClan.ranks:SetMargin( Vector2( 0, 5 ), Vector2( 0, 0 ) )
	self.manageClan.ranks:SetSize( Vector2( 0, 20 ) )
	self.manageClan.ranks:AddItem( "Главный" )
	self.manageClan.ranks:AddItem( "Заместитель" )
	self.manageClan.ranks:AddItem( "Редактор" )
	self.manageClan.ranks:AddItem( "Участник" )

	self.manageClan.kick = Button.Create( self.manageClan.psettLabel )
	self.manageClan.kick:SetDock( GwenPosition.Top )
	self.manageClan.kick:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.kick:SetSize( Vector2( 0, 30 ) )
	self.manageClan.kick:SetTextSize( 15 )
	self.manageClan.kick:SetText( "Установить ранг" )
	self.manageClan.kick:Subscribe( "Press", self, self.SetRank )

	self.manageClan.kick = Button.Create( self.manageClan.psettLabel )
	self.manageClan.kick:SetDock( GwenPosition.Top )
	self.manageClan.kick:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.kick:SetSize( Vector2( 0, 30 ) )
	self.manageClan.kick:SetTextSize( 15 )
	self.manageClan.kick:SetText( "Выгнать" )
	self.manageClan.kick:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.kick:Subscribe( "Press", self, self.Kick )

	local clanlogs = BaseWindow.Create( self.manageClan.mctabs )
	self.manageClan.mctabs:AddPage( "Логи", clanlogs )

	self.log = {}
	self.log.clear = Button.Create( clanlogs )
	self.log.clear:SetDock( GwenPosition.Bottom )
	self.log.clear:SetSize( Vector2( 0, 35 ) )
	self.log.clear:SetTextSize( 15 )
	self.log.clear:SetText( "Очистить логи" )
	self.log.clear:Subscribe( "Press", self, self.ClearLog )

	self.log.list = SortedList.Create( clanlogs )
	self.log.list:SetDock( GwenPosition.Fill )
	self.log.list:AddColumn( "Действие" )
	self.log.list:AddColumn( "Дата", 150 )

	local clansettings = BaseWindow.Create( self.manageClan.mctabs )
	self.manageClan.mctabs:AddPage( "Настройка клана", clansettings )

	self.manageClan.bkpanelsLabel = Label.Create( clansettings )
	self.manageClan.bkpanelsLabel:SetDock( GwenPosition.Right )
	self.manageClan.bkpanelsLabel:SetMargin( Vector2( 5, 0 ), Vector2( 0, 0 ) )
	self.manageClan.bkpanelsLabel:SetSize( Vector2( 250, 20 ) )

	self.manageClan.newsLabel = GroupBox.Create( self.manageClan.bkpanelsLabel )
	self.manageClan.newsLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 10 ) )
	self.manageClan.newsLabel:SetText( "Сообщение дня" )
	self.manageClan.newsLabel:SetDock( GwenPosition.Top )
	self.manageClan.newsLabel:SetSize( Vector2( 0, 140 ) )

	self.manageClan.newsEdit = TextBoxMultiline.Create( self.manageClan.newsLabel )
	self.manageClan.newsEdit:SetDock( GwenPosition.Fill )
	self.manageClan.newsEdit:SetMargin( Vector2( 0, 2 ), Vector2( 0, 4 ) )
	self.manageClan.newsEdit:Subscribe( "TextChanged", self, function() self.manageClan.newsApply:SetEnabled( true ) end )

	self.manageClan.newsApply = Button.Create( self.manageClan.newsLabel )
	self.manageClan.newsApply:SetDock( GwenPosition.Bottom )
	self.manageClan.newsApply:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.newsApply:SetSize( Vector2( 0, 30 ) )
	self.manageClan.newsApply:SetTextSize( 15 )
	self.manageClan.newsApply:SetText( "Применить изменения" )
	self.manageClan.newsApply:Subscribe( "Press", self, self.ChangeClanNews )

	self.manageClan.pLabel = GroupBox.Create( self.manageClan.bkpanelsLabel )
	self.manageClan.pLabel:SetText( "Управление" )
	self.manageClan.pLabel:SetDock( GwenPosition.Bottom )
	self.manageClan.pLabel:SetSize( Vector2( 0, 100 ) )

	self.manageClan.dLabel = Label.Create( self.manageClan.pLabel )
	self.manageClan.dLabel:SetDock( GwenPosition.Top )
	self.manageClan.dLabel:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.dLabel:SetText( "Требуется $1000, чтобы изменить клан" )
	self.manageClan.dLabel:SetTextColor( self.opcolor )
	self.manageClan.dLabel:SizeToContents()

	self.manageClan.create = Button.Create( self.manageClan.pLabel )
	self.manageClan.create:SetDock( GwenPosition.Top )
	self.manageClan.create:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.create:SetSize( Vector2( 0, 30 ) )
	self.manageClan.create:SetTextSize( 15 )
	self.manageClan.create:SetText( "Применить изменения" )
	self.manageClan.create:Subscribe( "Press", self, self.ChangeDescription )

	self.manageClan.remove = Button.Create( self.manageClan.pLabel )
	self.manageClan.remove:SetDock( GwenPosition.Top )
	self.manageClan.remove:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.manageClan.remove:SetSize( Vector2( 0, 30 ) )
	self.manageClan.remove:SetTextSize( 15 )
	self.manageClan.remove:SetText( "Удалить клан" )
	self.manageClan.remove:SetTextHoveredColor( Color.DarkOrange )
	self.manageClan.remove:Subscribe( "Press", self, self.Remove )

	self.manageClan.tLabel = Label.Create( clansettings )
	self.manageClan.tLabel:SetDock( GwenPosition.Top )
	self.manageClan.tLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 2 ) )
	self.manageClan.tLabel:SetText( "Описание клана:" )
	self.manageClan.tLabel:SizeToContents()

	self.manageClan.tEdit = TextBoxMultiline.Create( clansettings )
	self.manageClan.tEdit:SetDock( GwenPosition.Top )
	self.manageClan.tEdit:SetSize( Vector2( 0, 80 ) )

	self.manageClan.ttLabel = Label.Create( clansettings )
	self.manageClan.ttLabel:SetDock( GwenPosition.Top )
	self.manageClan.ttLabel:SetMargin( Vector2( 0, 10 ), Vector2( 0, 2 ) )
	self.manageClan.ttLabel:SetText( "Тип клана:" )
	self.manageClan.ttLabel:SizeToContents()

	self.manageClan.type = ComboBox.Create( clansettings )
	self.manageClan.type:SetDock( GwenPosition.Top )
	self.manageClan.type:SetSize( Vector2( 0, 20 ) )
	self.manageClan.type:AddItem( "Открытый" )
	self.manageClan.type:AddItem( "По приглашению" )

	self.manageClan.picker = HSVColorPicker.Create( clansettings )
	self.manageClan.picker:SetDock( GwenPosition.Top )
	self.manageClan.picker:SetMargin( Vector2( 0, 20 ), Vector2( 0, 0 ) )
	self.manageClan.picker:SetSize( Vector2( 0, 250 ) )
	self.manageClan.colour = { 255, 255, 255 }

	self.confirm = {}
	self.confirm.action = ""
	self.confirm.window = GUI:Window( "Подтвердить действие", Vector2( 0.86, 0.65 ) - Vector2( 0.13, 0.13 ) / 2, Vector2( 0.19, 0.13 ) )
	self.confirm.window:SetVisible( false )
	self.confirm.label = GUI:Label( "Вы уверены, что хотите это сделать?", Vector2( 0.03, 0.1 ), Vector2( 0.90, 0.23 ), self.confirm.window )
	self.confirm.label:SetTextColor( Color.DarkOrange )
	self.confirm.accept = GUI:Button( "Да", Vector2( 0, 0.35 ), Vector2( 0.95, 0.3 ), self.confirm.window )
	self.confirm.accept:SetTextHoveredColor( Color.DarkOrange )
	self.confirm.accept:Subscribe( "Press", self, self.Confirm )

	self.invitations = {}
	self.invitations.rows = {}
	self.invitations.window = GUI:Window( "Приглашения", Vector2( 0.26, 0.4 ) - Vector2( 0.25, 0.45 ) / 2, Vector2( 0.25, 0.7 ) )
	self.invitations.window:SetVisible( false )
	self.invitations.list = SortedList.Create( self.invitations.window )
	self.invitations.list:SetDock( GwenPosition.Fill )
	self.invitations.list:AddColumn( "Клан" )

	self.invitations.join = Button.Create( self.invitations.window )
	self.invitations.join:SetDock( GwenPosition.Bottom )
	self.invitations.join:SetMargin( Vector2( 0, 5 ), Vector2( 0, 0 ) )
	self.invitations.join:SetSize( Vector2( 0, 35 ) )
	self.invitations.join:SetTextSize( 15 )
	self.invitations.join:SetText( "» Присоединиться к клану" )
	self.invitations.join:SetTextHoveredColor( Color.SpringGreen )
	self.invitations.join:Subscribe( "Press", self, self.AcceptInvite )

	self.clanList = {}
	self.clanList.rows = {}
	self.clanList.window = GUI:Window( "••• Список игроков •••", Vector2( 0.26, 0.4 ) - Vector2( 0.25, 0.45 ) / 2, Vector2( 0.25, 0.7 ) )
	self.clanList.window:SetVisible( false )
	self.clanMenu.playersList = SortedList.Create( self.clanList.window )
	self.clanMenu.playersList:SetDock( GwenPosition.Fill )
	self.clanMenu.playersList:SetBackgroundVisible( false )
	self.clanMenu.playersList:AddColumn( "Игроки:" )
	for player in Client:GetPlayers() do
		self:addPlayerToList( player )
	end
	self:addPlayerToList( LocalPlayer )

	self.clanMenu.invitePlayer = Button.Create( self.clanList.window )
	self.clanMenu.invitePlayer:SetDock( GwenPosition.Bottom )
	self.clanMenu.invitePlayer:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
	self.clanMenu.invitePlayer:SetSize( Vector2( 0, 35 ) )
	self.clanMenu.invitePlayer:SetTextSize( 15 )
	self.clanMenu.invitePlayer:SetText( "» Пригласить игрока" )
	self.clanMenu.invitePlayer:SetTextHoveredColor( Color.SpringGreen )
	self.clanMenu.invitePlayer:Subscribe( "Press", self, self.InvitePlayer )

	self.clanMenu.searchEdit = TextBox.Create( self.clanList.window )
	self.clanMenu.searchEdit:SetDock( GwenPosition.Bottom )
	self.clanMenu.searchEdit:SetSize( Vector2( 0, 30 ) )
	self.clanMenu.searchEdit:SetMargin( Vector2( 2, 0 ), Vector2( 2, 2 ) )
	self.clanMenu.searchEdit:SetToolTip( "Поиск" )
	self.clanMenu.searchEdit:Subscribe( "TextChanged", self, self.SearchPlayer )

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

function ClanSystem:GetClanInfo()
	local row = self.clanMenu.list:GetSelectedRow()
	if ( row ~= nil ) then
		self.clanMenu.bkpanelsLabel:SetText( "Название: " .. row:GetCellText( 0 ) .. "\nДата создания: " .. row:GetName():sub( 0, 17 ) .. "\nОснователь: " .. row:GetCellText( 1 ) .. "\nТип: " .. row:GetCellText( 2 ) .. "\nОписание: " .. row:GetName():sub( 18 ) )
		self.clanMenu.bkpanelsLabel:SizeToContents()
		self.clanMenu.iLabel:SetVisible( true )
	end
end

function ClanSystem:GetActive()
	return self.active
end

function ClanSystem:SetActive( state )
	self.active = state
	self.clanMenu.window:SetVisible( self.active )
	Mouse:SetVisible( self.active )
	if ( not state ) then
		self.confirm.window:SetVisible( false )
		self.invitations.window:SetVisible( false )
		self.clanList.window:SetVisible( false )
		self.clanMenu.iLabel:SetVisible( false )
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

function ClanSystem:ManageClan()
	Network:Send( "Clans:GetData" )
end

function ClanSystem:ClanMenu()
	self.manageClan.mctabs:SetVisible( false )
	self.clanMenu.tabs:SetVisible( true )
	self.log.clear:SetEnabled( true )
	self.manageClan.create:SetEnabled( true )
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
	self.clanList.window:SetVisible( not self.clanList.window:GetVisible() )
end

function ClanSystem:Invitations()
	self.invitations.window:SetVisible( not self.invitations.window:GetVisible() )
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
		local colour = ( data.colour:split ( "," ) or { 255, 255, 255 } )
		local r, g, b = table.unpack ( colour )
		local item = self.clanMenu.list:AddItem( tostring ( name ) )
		item:SetCellText( 1, data.creator )
		item:SetCellText( 2, ( data.type == "Открытый" and "Публичный" or "По приглашению" ) )
		item:SetName( tostring( data.creationDate ) .. tostring( data.description ) )
		item:SetTextColor( Color( tonumber( r ), tonumber( g ), tonumber( b ) ) )
		table.insert( self.clanList.rows, item )
		self.clansRow[ tostring( name ) ] = item
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
	self.clanMenu.tabs:SetVisible( not self.clanMenu.tabs:GetVisible() )
	self.createClan.tabs:SetVisible( not self.createClan.tabs:GetVisible() )
end

function ClanSystem:Create()
	local args = {}
	local color = self.createClan.picker:GetColor()
	self.createClan.colour = { color.r, color.g, color.b }
	args.name = self.createClan.nEdit:GetText():sub( 0, 20 )
	if self.createClan.nEdit:GetText():len() <= 20 then
		if ( args.name ~= "" ) then
			if self.createClan.tEdit:GetText() ~= "" then
				args.description = self.createClan.tEdit:GetText():sub( 0, 5000 )
			else
				args.description = "Описание отсутствует."
			end
			args.colour = table.concat( self.createClan.colour, ", " )
			args.type = self.createClan.type:GetText()
			Network:Send( "Clans:Create", args )
			self:ShowCreate()
		else
			LocalPlayer:Message( "Напишите название клана!", "err" )
		end
	else
		LocalPlayer:Message( "В названии кланы больше 20-ти символов!", "err" )
	end
end

function ClanSystem:ReceiveData( args )
	self.manageClan.mctabs:SetVisible( true )
	self.clanMenu.tabs:SetVisible( false )
	self.manageClan.newstbLabel:SetText( args.newstext )
	self.manageClan.newstbLabel:SizeToContents()

	self.manageClan.ciLabel:SetText(
		"> Название клана: " .. tostring ( args.clanData.name ) ..
		"\n\n★ Тип клана: " .. ( args.clanData.type == "Открытый" and "Публичный" or "По приглашению" ) ..
		"\n\nツ Всего участников: " .. tostring ( #args.members ) ..
		"\n\n● Дата создания: ".. tostring ( args.clanData.creationDate ) )
	self.manageClan.ciLabel:SizeToContents()
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
				local item = self.log.list:AddItem( tostring( msg.message ) )
				item:SetCellText( 1, tostring( msg.date ) )
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

function ClanSystem:SearchClans()
	local text = self.clanMenu.searchClansEdit:GetText():lower()
	if ( text ~= "" and text:len() > 0 ) then
		for _, item in pairs ( self.clansRow ) do
			if ( type ( item ) == "userdata" ) then
				item:SetVisible( false )
				if item:GetCellText( 0 ):lower():find( text, 1, true ) then
					item:SetVisible( true )
				end
			end
		end
	else
		for _, item in pairs ( self.clansRow ) do
			if ( type ( item ) == "userdata" ) then
				item:SetVisible( true )
			end
		end
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

function ClanSystem:ChangeDescription()
	local args = {}
	local color = self.manageClan.picker:GetColor()
	self.manageClan.colour = { color.r, color.g, color.b }
	if self.manageClan.tEdit:GetText() ~= "" then
		args.description = self.manageClan.tEdit:GetText():sub( 0, 5000 )
		args.colour = table.concat( self.manageClan.colour, ", " )
		args.type = self.manageClan.type:GetText()
		Network:Send( "Clans:UpdateClanSettings", args )
		self.manageClan.create:SetEnabled( false )
	else
		LocalPlayer:Message( "Описание клана отсутствует! Как так-то?", "err" )
	end
end

function ClanSystem:ChangeClanNews()
	local args = {}
	if self.manageClan.newsEdit:GetText() ~= "" then
		args.clannews = self.manageClan.newsEdit:GetText():sub( 0, 5000 )
	else
		args.clannews = "Сообщение дня отсутствует."
	end
	Network:Send( "Clans:UpdateClanNews", args )
	self.manageClan.newsApply:SetEnabled( false )
end

function ClanSystem:ClearLog()
	Network:Send( "Clans:ClearLog" )
	self.log.clear:SetEnabled( false )
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
	Chat:Print( "[Клан] ", Color.White, msg, msgColors [ color ] )
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
