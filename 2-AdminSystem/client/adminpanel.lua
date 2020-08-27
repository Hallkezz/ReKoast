class "AdminPanel"

function AdminPanel:__init()
    self.players = {}
    self.active = false

    self.numberValue = 0

    self.reasons =
    {
        "Без причины",
        "Спам/Флуд",
        "Оскорбления/Агрессия",
        "Читы/Взлом",
        "Использование багов",
        "Реклама",
        "Нарушение правил",
        "Троллинг",
        "Использование недопустимого имени"
    }

    Events:Subscribe( "KeyUp", self, self.KeyUp )
    Events:Subscribe( "KeyDown", self, self.KeyDown )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

    Network:Subscribe( "ToChat", self, self.ToChat )
    Network:Subscribe( "ToLogs", self, self.ToLogs )
    Network:Subscribe( "DisplayInformation", self, self.DisplayInformation )

	self.mainwindow = Window.Create()
	self.mainwindow:SetSizeRel( Vector2( 0.55, 0.7 ) )
	self.mainwindow:SetMinimumSize( Vector2( 680, 442 ) )
	self.mainwindow:SetPositionRel( Vector2( 0.7, 0.5 ) - self.mainwindow:GetSizeRel()/2 )
	self.mainwindow:SetVisible( self.active )
	self.mainwindow:SetTitle( "▧ Управление сервером (BETA)" )
    self.mainwindow:Subscribe( "WindowClosed", self, self.MainWindowClosed )

    self.tab = TabControl.Create( self.mainwindow )
    self.tab:SetDock( GwenPosition.Fill )

    local main = BaseWindow.Create( self.mainwindow )
    self.tab:AddPage( "Основное", main )

    self.mainlist = SortedList.Create( main )
    self.mainlist:AddColumn( "Имя" )
	self.mainlist:SetPositionRel( Vector2( 0, 0 ) )
    self.mainlist:SetSize( Vector2( 200, self.mainwindow:GetSize().y ) )
    self.mainlist:Subscribe( "RowSelected", self, self.getInformation )

	self.pname = Label.Create( main )
    self.pname:SetText( "Имя: N/A" )
    self.pname:SetPosition( Vector2( self.mainlist:GetSize().x + 10, 10 ) )
    self.pname:SizeToContents()

    self.psteamid = Label.Create( main )
    self.psteamid:SetText( "SteamID: N/A" )
    self.psteamid:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pname:GetPosition().y + 12 ) )
    self.psteamid:SizeToContents()

    self.pip = Label.Create( main )
    self.pip:SetText( "IP: N/A" )
    self.pip:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.psteamid:GetPosition().y + 12 ) )
    self.pip:SizeToContents()

    self.prole = Label.Create( main )
    self.prole:SetText( "Роль: N/A" )
    self.prole:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pip:GetPosition().y + 12 ) )
    self.prole:SizeToContents()

    self.pping = Label.Create( main )
    self.pping:SetText( "Пинг: N/A" )
    self.pping:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.prole:GetPosition().y + 12 ) )
    self.pping:SizeToContents()

    self.phealth = Label.Create( main )
    self.phealth:SetText( "Здоровье: N/A" )
    self.phealth:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pping:GetPosition().y + 12 ) )
    self.phealth:SizeToContents()

    self.pmoney = Label.Create( main )
    self.pmoney:SetText( "Деньги: N/A" )
    self.pmoney:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.phealth:GetPosition().y + 12 ) )
    self.pmoney:SizeToContents()

    self.ppos = Label.Create( main )
    self.ppos:SetText( "Позиция: N/A" )
    self.ppos:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pmoney:GetPosition().y + 12 ) )
    self.ppos:SizeToContents()

    self.pangle = Label.Create( main )
    self.pangle:SetText( "Угол: N/A" )
    self.pangle:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.ppos:GetPosition().y + 12 ) )
    self.pangle:SizeToContents()

    self.pworldid = Label.Create( main )
    self.pworldid:SetText( "ID мира: N/A" )
    self.pworldid:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pangle:GetPosition().y + 12 ) )
    self.pworldid:SizeToContents()

    self.pchart = Label.Create( main )
    self.pchart:SetText( "ID персонажа: N/A" )
    self.pchart:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pworldid:GetPosition().y + 12 ) )
    self.pchart:SizeToContents()

    self.pweap = Label.Create( main )
    self.pweap:SetText( "Оружие: N/A" )
    self.pweap:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pchart:GetPosition().y + 12 ) )
    self.pweap:SizeToContents()

    self.pammo = Label.Create( main )
    self.pammo:SetText( "Патроны: N/A" )
    self.pammo:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pweap:GetPosition().y + 12 ) )
    self.pammo:SizeToContents()

    self.pvehicle = Label.Create( main )
    self.pvehicle:SetText( "Транспорт: N/A" )
    self.pvehicle:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pammo:GetPosition().y + 12 ) )
    self.pvehicle:SizeToContents()

    self.pvhealth = Label.Create( main )
    self.pvhealth:SetText( "Здоровье ТС: N/A" )
    self.pvhealth:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pvehicle:GetPosition().y + 12 ) )
    self.pvhealth:SizeToContents()

    self.plang = Label.Create( main )
    self.plang:SetText( "Язык: N/A" )
    self.plang:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pvhealth:GetPosition().y + 12 ) )
    self.plang:SizeToContents()

    self.pgamemode = Label.Create( main )
    self.pgamemode:SetText( "Режим: N/A" )
    self.pgamemode:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.plang:GetPosition().y + 12 ) )
    self.pgamemode:SizeToContents()

    self.pkills = Label.Create( main )
    self.pkills:SetText( "Убийств: N/A" )
    self.pkills:SetPosition( Vector2( self.mainlist:GetSize().x + 10, self.pgamemode:GetPosition().y + 12 ) )
    self.pkills:SizeToContents()

	self.warnbtn = Button.Create( main )
	self.warnbtn:SetVisible( true )
	self.warnbtn:SetText( "Дать предупрждение" )
	self.warnbtn:SetSize( Vector2( 200, 30 ) )
	self.warnbtn:SetTextSize( 14 )
	self.warnbtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, 10 ) )
    self.warnbtn:Subscribe( "Press", self, self.AddWarnWindow )

    self.sethealthbtn = Button.Create( main )
	self.sethealthbtn:SetVisible( true )
	self.sethealthbtn:SetText( "Установить здоровье" )
	self.sethealthbtn:SetSize( Vector2( 200, 30 ) )
	self.sethealthbtn:SetTextSize( 14 )
	self.sethealthbtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.warnbtn:GetPosition().y + 40 ) )
    self.sethealthbtn:Subscribe( "Press", self, self.SetHealthWindow )

    self.kickbtn = Button.Create( main )
	self.kickbtn:SetVisible( true )
	self.kickbtn:SetText( "Выгнать игрока" )
	self.kickbtn:SetSize( Vector2( 200, 30 ) )
	self.kickbtn:SetTextSize( 14 )
	self.kickbtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.sethealthbtn:GetPosition().y + 40 ) )
    self.kickbtn:Subscribe( "Press", self, self.KickPlayerWindow )

    self.addmoneybtn = Button.Create( main )
	self.addmoneybtn:SetVisible( true )
	self.addmoneybtn:SetText( "Дать денег" )
	self.addmoneybtn:SetSize( Vector2( 200, 30 ) )
	self.addmoneybtn:SetTextSize( 14 )
	self.addmoneybtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.kickbtn:GetPosition().y + 40 ) )
    self.addmoneybtn:Subscribe( "Press", self, self.AddMoneyWindow )

    self.tpbtn = Button.Create( main )
	self.tpbtn:SetVisible( true )
	self.tpbtn:SetText( "Телепортироваться" )
	self.tpbtn:SetSize( Vector2( 200, 30 ) )
	self.tpbtn:SetTextSize( 14 )
	self.tpbtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.addmoneybtn:GetPosition().y + 40 ) )
    self.tpbtn:Subscribe( "Press", self, self.Teleport )

    self.tptomebtn = Button.Create( main )
	self.tptomebtn:SetVisible( true )
	self.tptomebtn:SetText( "Телепортировать к себе" )
	self.tptomebtn:SetSize( Vector2( 200, 30 ) )
	self.tptomebtn:SetTextSize( 14 )
	self.tptomebtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.tpbtn:GetPosition().y + 40 ) )
    self.tptomebtn:Subscribe( "Press", self, self.TeleportToMe )

    self.watchbtn = Button.Create( main )
	self.watchbtn:SetVisible( true )
	self.watchbtn:SetText( "Наблюдать" )
	self.watchbtn:SetSize( Vector2( 200, 30 ) )
	self.watchbtn:SetTextSize( 14 )
	self.watchbtn:SetPosition( Vector2( self.mainwindow:GetSize().x - 230, self.tptomebtn:GetPosition().y + 40 ) )
	self.watchbtn:Subscribe( "Press", self, self.StartWatch )

    local admchat = BaseWindow.Create( self.mainwindow )
    self.tab:AddPage( "Чат избранных", admchat )

    local text = ""
	local scroll_control = ScrollControl.Create( admchat )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
    scroll_control:SetScrollable( false, true )
    scroll_control:SetDock( GwenPosition.Fill )
    scroll_control:SetSize( Vector2( 500, 250 ) )

	self.admchatlabel = Label.Create( scroll_control )
	self.admchatlabel:SetPadding( Vector2.Zero, Vector2( 14, 0 ) )
	self.admchatlabel:SetText( text )
	self.admchatlabel:SetTextSize( 13 )
	self.admchatlabel:SetTextColor( Color.White )
    self.admchatlabel:SetWrap( true )
    self.admchatlabel:SetDock( GwenPosition.Fill )

    self.textB = TextBox.Create( admchat )
    self.textB:SetDock( GwenPosition.Bottom )
    self.textB:SetSize( Vector2( 500, 30 ) )
    self.textB:Subscribe( "ReturnPressed", self, self.GetText )

    local admlogs = BaseWindow.Create( self.mainwindow )
    self.tab:AddPage( "Состояние сервера", admlogs )

    local text = ""
	local scroll_control = ScrollControl.Create( admlogs )
	scroll_control:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )
    scroll_control:SetScrollable( false, true )
    scroll_control:SetDock( GwenPosition.Fill )
    scroll_control:SetSize( Vector2( 500, 250 ) )

	self.admlogslabel = Label.Create( scroll_control )
	self.admlogslabel:SetPadding( Vector2.Zero, Vector2( 14, 0 ) )
	self.admlogslabel:SetText( text )
	self.admlogslabel:SetTextSize( 13 )
	self.admlogslabel:SetTextColor( Color.White )
    self.admlogslabel:SetWrap( true )
    self.admlogslabel:SetDock( GwenPosition.Fill )

    for player in Client:GetPlayers() do
		self:AddPlayer( player )
    end
    self:AddPlayer( LocalPlayer )

    Network:Send( "LoadMessages" )
end

function AdminPanel:DisplayInformation( data )
	if ( type ( data ) == "table" ) then
        self.pname:SetText ( "Имя: " .. tostring( data.name ) )
        self.pname:SizeToContents()

        self.psteamid:SetText( "SteamID: " .. tostring( data.steamID ) )
        self.psteamid:SizeToContents()
    
        self.pip:SetText( "IP: " .. tostring( data.ip ) )
        self.pip:SizeToContents()

        self.prole:SetText( "Роль: " .. tostring( data.groups ) )
        self.prole:SizeToContents()
    
        self.pping:SetText( "Пинг: " .. tostring( data.ping ) )
        self.pping:SizeToContents()

        self.phealth:SetText( "Здоровье: " .. tostring( data.health ) )
        self.phealth:SizeToContents()

        self.pmoney:SetText( "Деньги: " .. tostring( data.money ) )
        self.pmoney:SizeToContents()

        self.ppos:SetText( "Позиция: " .. tostring( data.position ) )
        self.ppos:SizeToContents()

        self.pangle:SetText( "Угол: " .. tostring( data.angle ) )
        self.pangle:SizeToContents()

        self.pworldid:SetText( "ID мира: " .. tostring( data.worldid ) )
        self.pworldid:SizeToContents()

        self.pchart:SetText( "ID персонажа: " .. tostring( data.model ) )
        self.pchart:SizeToContents()

        self.pweap:SetText( "Оружие: " .. tostring( data.weapon ) )
        self.pweap:SizeToContents()

        self.pammo:SetText( "Патроны: " .. tostring( data.weaponAmmo ) )
        self.pammo:SizeToContents()

        self.pvehicle:SetText( "Транспорт: " .. tostring( data.vehicle ) )
        self.pvehicle:SizeToContents()

        self.pvhealth:SetText( "Здоровье ТС: " .. tostring( data.vehicleHealth ) )
        self.pvhealth:SizeToContents()

        self.plang:SetText( "Язык: " .. tostring( data.lang ) )
        self.plang:SizeToContents()

        self.pgamemode:SetText( "Режим: " .. tostring( data.gamemode ) )
        self.pgamemode:SizeToContents()

        self.pkills:SetText( "Убийств: " .. tostring( data.kills ) )
        self.pkills:SizeToContents()
	end
end

function AdminPanel:getInformation()
	local player = self:getListSelectedPlayer ( self.mainlist )
	if ( player ) then
		if IsValid ( player, false ) then
			Network:Send( "RequestInformation", player )
		end
	end
end

function AdminPanel:AddPlayer( player )
    local item = self.mainlist:AddItem( player:GetName() )
	local playerColor = player:GetColor()

	if LocalPlayer:IsFriend( player ) then
		item:SetToolTip( "Друг" )
	end

    item:SetDataObject ( "id", player )
	self.players[ tostring ( player:GetSteamId() ) ] = item
end

function AdminPanel:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.mainwindow:GetVisible() ~= is_visible then
		self.mainwindow:SetVisible( is_visible )
	end
end

function AdminPanel:KeyUp( args )
    if args.key == string.byte("P") then
        if LocalPlayer:GetValue( "Tag" ) == "Owner" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "AdminD" or LocalPlayer:GetValue( "Tag" ) == "ModerD" then
            self:SetWindowVisible( not self.active )

            if self.active then
                ClientEffect.Play(AssetLocation.Game, {
                    effect_id = 382,
        
                    position = Camera:GetPosition(),
                    angle = Angle()
                })
            else
                ClientEffect.Play(AssetLocation.Game, {
                    effect_id = 383,
        
                    position = Camera:GetPosition(),
                    angle = Angle()
                })
            end
        end
    end
end

function AdminPanel:KeyDown( args )
    if args.key == VirtualKey.Escape then
        if LocalPlayer:GetValue( "Tag" ) == "Owner" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "AdminD" or LocalPlayer:GetValue( "Tag" ) == "ModerD" then
            if self.active then
                self:SetWindowVisible( false )
            end
        end
	end
end

function AdminPanel:LocalPlayerInput( args )
	if self.active then
		return false
	end
end

function AdminPanel:PlayerJoin( args )
	local player = args.player

	self:AddPlayer( player )
end

function AdminPanel:PlayerQuit( args )
	local steamID = tostring( args.player:GetSteamId() )
	if ( self.players[ steamID ] ) then
		self.mainlist:RemoveItem( self.players[ steamID ] )
		self.players[ steamID ] = nil
	end
end

function AdminPanel:MainWindowClosed( args )
	self:SetWindowVisible( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
    })
    if self.window then
        self.window:Remove()
        self.window = nil
    end
end

function AdminPanel:WindowClosed( args )
    if self.window then
        self.window:Remove()
        self.window = nil
        self.acceptbtn:Remove()
    end
end

function AdminPanel:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.mainwindow:SetVisible( visible )
		Mouse:SetVisible( visible )
    end
end

function AdminPanel:getListSelectedPlayer( item )
	if ( item ) then
		local row = item:GetSelectedRow()
		if ( row ) then
			return row:GetDataObject ( "id" )
		end
	else
		return false
	end
end

function AdminPanel:AddWarnWindow( player )
    local reasonsItems = {}

    if not self.window then
        self.window = Window.Create()
        self.window:SetSize( Vector2( 400, 250 ) )
        self.window:SetMinimumSize( Vector2( 400, 250 ) )
        self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
        self.window:SetTitle( "Выдать предупреждение" )
        self.window:Subscribe( "WindowClosed", self, function() self.reasonsCb:Remove() self:WindowClosed() end )

        self.reasonsCb = ComboBox.Create( self.window )
        self.reasonsCb:SetPosition( Vector2( 10, 10 ) )
        self.reasonsCb:SetSize( Vector2( 250, 30 ) )
        for _, reason in ipairs ( self.reasons ) do
            reasonsItems [ reason ] = self.reasonsCb:AddItem ( reason )
        end

        self.numberNum = Numeric.Create( self.window )
        self.numberNum:SetPosition( Vector2( 10, 50 ) )
        self.numberNum:SetSize( Vector2( 30, 20 ) )
        self.numberNum:SetRange( 0, 3 )
        self.numberNum:SetValue( self.numberValue )
        self.numberNum:Subscribe( "Changed", 
		function() 
			self.numberValue = self.numberNum:GetValue() 
		end )
    
        self.acceptbtn = Button.Create( self.window )
        self.acceptbtn:SetText( "Выдать предупрждение" )
        self.acceptbtn:SetSize( Vector2( 200, 30 ) )
        self.acceptbtn:SetTextSize( 14 )
        self.acceptbtn:SetPosition( Vector2( 10, self.window:GetSize().y - 80 ) )
        self.acceptbtn:Subscribe( "Press", self, function() self.reason = self.reasonsCb:GetSelectedItem():GetText() self:AddWarn() self:WindowClosed() end )
    else
        self.window:Remove()
        self.window = nil
        if self.reasonsCb then
            self.reasonsCb:Remove()
            self.reasonsCb = nil
        end
        if self.numberNum then
            self.numberNum:Remove()
            self.numberNum = nil
        end
        if self.acceptbtn then
            self.acceptbtn:Remove()
            self.acceptbtn = nil
        end
    end
end

function AdminPanel:SetHealthWindow( player )
    if not self.window then
        self.window = Window.Create()
        self.window:SetSize( Vector2( 400, 250 ) )
        self.window:SetMinimumSize( Vector2( 400, 250 ) )
        self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
        self.window:SetTitle( "Установить здоровье" )
        self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

        self.numberNum = Numeric.Create( self.window )
        self.numberNum:SetPosition( Vector2( 10, 50 ) )
        self.numberNum:SetSize( Vector2( 40, 20 ) )
        self.numberNum:SetRange( 0, 100 )
        self.numberNum:SetValue( 100 )
    
        self.acceptbtn = Button.Create( self.window )
        self.acceptbtn:SetText( "Установить здоровье" )
        self.acceptbtn:SetSize( Vector2( 200, 30 ) )
        self.acceptbtn:SetTextSize( 14 )
        self.acceptbtn:SetPosition( Vector2( 10, self.window:GetSize().y - 80 ) )
        self.acceptbtn:Subscribe( "Press", self, function() self:SetHealth() self:WindowClosed() end )
    else
        self.window:Remove()
        self.window = nil
        if self.reasonsCb then
            self.reasonsCb:Remove()
            self.reasonsCb = nil
        end
        if self.numberNum then
            self.numberNum:Remove()
            self.numberNum = nil
        end
        if self.acceptbtn then
            self.acceptbtn:Remove()
            self.acceptbtn = nil
        end
    end
end

function AdminPanel:KickPlayerWindow( player )
    local reasonsItems = {}

    if not self.window then
        self.window = Window.Create()
        self.window:SetSize( Vector2( 400, 250 ) )
        self.window:SetMinimumSize( Vector2( 400, 250 ) )
        self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
        self.window:SetTitle( "Выгнать игрока" )
        self.window:Subscribe( "WindowClosed", self, function() self.reasonsCb:Remove() self:WindowClosed() end )

        self.reasonsCb = ComboBox.Create( self.window )
        self.reasonsCb:SetPosition( Vector2( 10, 10 ) )
        self.reasonsCb:SetSize( Vector2( 250, 30 ) )
        for _, reason in ipairs ( self.reasons ) do
            reasonsItems [ reason ] = self.reasonsCb:AddItem ( reason )
        end
    
        self.acceptbtn = Button.Create( self.window )
        self.acceptbtn:SetText( "Выдать предупрждение" )
        self.acceptbtn:SetSize( Vector2( 200, 30 ) )
        self.acceptbtn:SetTextSize( 14 )
        self.acceptbtn:SetPosition( Vector2( 10, self.window:GetSize().y - 80 ) )
        self.acceptbtn:Subscribe( "Press", self, function() self.reason = self.reasonsCb:GetSelectedItem():GetText() self:KickPlayer() self:WindowClosed() end )
    else
        self.window:Remove()
        self.window = nil
        if self.reasonsCb then
            self.reasonsCb:Remove()
            self.reasonsCb = nil
        end
        if self.numberNum then
            self.numberNum:Remove()
            self.numberNum = nil
        end
        if self.acceptbtn then
            self.acceptbtn:Remove()
            self.acceptbtn = nil
        end
    end
end

function AdminPanel:AddMoneyWindow( player )
    if not self.window then
        self.window = Window.Create()
        self.window:SetSize( Vector2( 400, 250 ) )
        self.window:SetMinimumSize( Vector2( 400, 250 ) )
        self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
        self.window:SetTitle( "Дать денег" )
        self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

        self.numberNum = Numeric.Create( self.window )
        self.numberNum:SetPosition( Vector2( 10, 50 ) )
        self.numberNum:SetSize( Vector2( 150, 20 ) )
        self.numberNum:SetRange( 0, 2147483647 )
        self.numberNum:SetValue( 500 )

        self.acceptbtn = Button.Create( self.window )
        self.acceptbtn:SetText( "Дать денег" )
        self.acceptbtn:SetSize( Vector2( 200, 30 ) )
        self.acceptbtn:SetTextSize( 14 )
        self.acceptbtn:SetPosition( Vector2( 10, self.window:GetSize().y - 80 ) )
        self.acceptbtn:Subscribe( "Press", self, function() self:AddMoney() self:WindowClosed() end )
    else
        self.window:Remove()
        self.window = nil
        if self.reasonsCb then
            self.reasonsCb:Remove()
            self.reasonsCb = nil
        end
        if self.numberNum then
            self.numberNum:Remove()
            self.numberNum = nil
        end
        if self.acceptbtn then
            self.acceptbtn:Remove()
            self.acceptbtn = nil
        end
    end
end

function AdminPanel:Teleport( player )
    local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "Teleport", { pname = player } )
        if self.active then
            self:SetWindowVisible( false )
        end
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:TeleportToMe( player )
    local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "TeleportToMe", { pname = player } )
        if self.active then
            self:SetWindowVisible( false )
        end
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:StartWatch( player )
    if not self.CalcViewEvent then
        self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.spectateCamera )
        if self.active then
            self:SetWindowVisible( false )
        end
    else
        Events:Unsubscribe( self.CalcViewEvent )
        self.CalcViewEvent = nil
    end
end

function AdminPanel:spectateCamera()
    local player = self:getListSelectedPlayer ( self.mainlist )
	if IsValid ( player, false ) then
        local position = player:GetPosition()
        local angle = player:GetAngle()
		Camera:SetPosition( position + angle * Vector3 ( 0, 2.5, 10 ) )
	end
	return false
end

function AdminPanel:AddWarn( player )
	local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "AddWarn", { number = self.numberValue, pname = player, text = self.reason } )
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:SetHealth( player )
	local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "SetHealth", { number = self.numberNum:GetValue(), pname = player } )
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:KickPlayer( player )
	local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "KickPlayer", { pname = player, text = self.reason } )
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:AddMoney( player )
	local player = self:getListSelectedPlayer ( self.mainlist )
    if ( player ) then
        Network:Send( "AddMoney", { number = self.numberNum:GetValue(), pname = player } )
	else
		Chat:Print( "[Сервер] ", Color.White, "Игрок не выбран.", Color.DarkGray )
	end
end

function AdminPanel:GetText()
    if self.textB:GetText() ~= "" then
        Network:Send( "SendMessage", { msg = self.textB:GetText() } )
    end
    self.textB:SetText("")
end

function AdminPanel:ToChat( args )
	self.text = self.admchatlabel:GetText()
	if ( text == "" ) then
        self.admchatlabel:SetText( args.text )
        self.admchatlabel:SetTextColor( Color.White )
	else
        self.admchatlabel:SetText( self.text .. "\n" .. args.text )
	end
    self.admchatlabel:SizeToContents()
    Network:Send( "SaveMessages", { gettext = self.admchatlabel:GetText() } )
end

function AdminPanel:ToLogs( args )
	self.text = self.admlogslabel:GetText()
	if ( text == "" ) then
        self.admlogslabel:SetText( args.text )
        self.admlogslabel:SetTextColor( Color.White )
	else
        self.admlogslabel:SetText( self.text .. "\n" .. args.text )
	end
	self.admlogslabel:SizeToContents()
end

adminpanel = AdminPanel()