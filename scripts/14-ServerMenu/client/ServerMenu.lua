class 'ServerMenu'

function ServerMenu:__init()
	self.active = false

	self.shopimage = Image.Create( AssetLocation.Resource, "BlackMarketICO" )
	self.tpimage = Image.Create( AssetLocation.Resource, "TeleportICO" )
	self.clansimage = Image.Create( AssetLocation.Resource, "ClansICO" )
	self.pmimage = Image.Create( AssetLocation.Resource, "MessagesICO" )
	self.settimage = Image.Create( AssetLocation.Resource, "SettingsICO" )
	self.mainmenuimage = Image.Create( AssetLocation.Resource, "MainMenuICO" )

	self:LoadCategories()

	Events:Subscribe( "Lang", self, self.Lang )
    Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "KeyDown", self, self.KeyDown )

	Network:Subscribe( "Settings", self, self.Open )
	Network:Subscribe( "Bonus", self, self.Bonus )
	Network:Subscribe( "UpdateTime", self, self.UpdateTime )
end

function ServerMenu:Lang()
	self.window:SetTitle( "▧ Server Menu" )
	self.help_button:SetText( "Open Server Help (FAQ)" )
	self.shop_button:SetText( "Black Market" )
	self.shop_button:SetToolTip( "Vehicles, weapons, appearance and others." )
	self.tp_button:SetText( "Teleportation" )
	self.tp_button:SetToolTip( "Teleport to the players." )
	self.clans_button:SetText( "Clans" )
	self.clans_button:SetToolTip( "Your clan and other clans of players." )
	self.pm_button:SetText( "Messages" )
	self.pm_button:SetToolTip( "Communicate personally with the players." )
	self.sett_button:SetText( "Settings" )
	self.sett_button:SetToolTip( "Server Settings." )
	self.mainmenu_button:SetText( "Disconnect" )
	self.mainmenu_button:SetToolTip( "Disconnect from the server." )
	self.passive:SetText( "Passive mode:" )
	self.jesusmode:SetText( "Jesus mode:" )
	self.passiveon_btn:SetText( "Enable" )
	self.bonus:SetText( "Bonus:" )
	self.bonus_btn:SetText( "NEEDED 9 LEVEL" )
end

function ServerMenu:LoadCategories()
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.55, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 500, 442 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Меню сервера" )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.help_button = Button.Create( self.window )
	self.help_button:SetVisible( true )
	self.help_button:SetText( "Открыть помощь / правила сервера (FAQ)" )
	self.help_button:SetDock( GwenPosition.Top )
	self.help_button:SetTextSize( 14 )
	self.help_button:SetSize( Vector2( 0, 30 ) )
	self.help_button:Subscribe( "Press", self, self.CastHelpMenu )

	self.scroll_control = ScrollControl.Create( self.window )
	self.scroll_control:SetScrollable( true, false )
	self.scroll_control:SetSize( Vector2( self.window:GetSize().x - 15, 215 ) )
	self.scroll_control:SetDock( GwenPosition.Top )

	self.shop_image = ImagePanel.Create( self.scroll_control )
	self.shop_image:SetImage( self.shopimage )
	self.shop_image:SetPosition( Vector2( 5, 20 ) )
	self.shop_image:SetHeight( 135 )
	self.shop_image:SetWidth( 135 )

	self.shop_button = MenuItem.Create( self.scroll_control )
	self.shop_button:SetPosition( self.shop_image:GetPosition() )
	self.shop_button:SetHeight( 170 )
	self.shop_button:SetWidth( self.shop_image:GetSize().x )
	self.shop_button:SetText( "Черный рынок" )
	self.shop_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.shop_button:SetTextSize( 19 )
	self.shop_button:SetToolTip( "Транспорт, оружие, внешность и прочие." )
	self.shop_button:Subscribe( "Press", self, self.CastShop )

	self.tp_image = ImagePanel.Create( self.scroll_control )
	self.tp_image:SetImage( self.tpimage )
	self.tp_image:SetPosition( Vector2( self.shop_image:GetPosition().x + 150, 20 ) )
	self.tp_image:SetHeight( 135 )
	self.tp_image:SetWidth( 135 )

	self.tp_button = MenuItem.Create( self.scroll_control )
	self.tp_button:SetPosition( self.tp_image:GetPosition() )
	self.tp_button:SetHeight( 170 )
	self.tp_button:SetWidth( self.tp_image:GetSize().x )
	self.tp_button:SetText( "Телепортация" )
	self.tp_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.tp_button:SetTextSize( 19 )
	self.tp_button:SetToolTip( "Телепортация к игрокам." )
	self.tp_button:Subscribe( "Press", self, self.CastWarpGUI )

	self.clans_image = ImagePanel.Create( self.scroll_control )
	self.clans_image:SetImage( self.clansimage )
	self.clans_image:SetPosition( Vector2( self.tp_image:GetPosition().x + 150, 20 ) )
	self.clans_image:SetHeight( 135 )
	self.clans_image:SetWidth( 135 )

	self.clans_button = MenuItem.Create( self.scroll_control )
	self.clans_button:SetPosition( self.clans_image:GetPosition() )
	self.clans_button:SetHeight( 170 )
	self.clans_button:SetWidth( self.clans_image:GetSize().x )
	self.clans_button:SetText( "Кланы" )
	self.clans_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.clans_button:SetTextSize( 19 )
	self.clans_button:SetToolTip( "Управление кланом и другие кланы игроков." )
	self.clans_button:Subscribe( "Press", self, self.CastClansMenu )

	self.pm_image = ImagePanel.Create( self.scroll_control )
	self.pm_image:SetImage( self.pmimage )
	self.pm_image:SetPosition( Vector2( self.clans_image:GetPosition().x + 150, 20 ) )
	self.pm_image:SetHeight( 135 )
	self.pm_image:SetWidth( 135 )

	self.pm_button = MenuItem.Create( self.scroll_control )
	self.pm_button:SetPosition( self.pm_image:GetPosition() )
	self.pm_button:SetHeight( 170 )
	self.pm_button:SetWidth( self.pm_image:GetSize().x )
	self.pm_button:SetText( "Сообщения" )
	self.pm_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.pm_button:SetTextSize( 19 )
	self.pm_button:SetToolTip( "Общайтесь лично с игроками." )
	self.pm_button:Subscribe( "Press", self, self.CastGuiPm )

	self.sett_image = ImagePanel.Create( self.scroll_control )
	self.sett_image:SetImage( self.settimage )
	self.sett_image:SetPosition( Vector2( self.pm_image:GetPosition().x + 150, 20 ) )
	self.sett_image:SetHeight( 135 )
	self.sett_image:SetWidth( 135 )

	self.sett_button = MenuItem.Create( self.scroll_control )
	self.sett_button:SetPosition( self.sett_image:GetPosition() )
	self.sett_button:SetHeight( 170 )
	self.sett_button:SetWidth( self.sett_image:GetSize().x )
	self.sett_button:SetText( "Настройки" )
	self.sett_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.sett_button:SetTextSize( 19 )
	self.sett_button:SetToolTip( "Настройки сервера." )
	self.sett_button:Subscribe( "Press", self, self.CastSettingsMenu )

	self.mainmenu_image = ImagePanel.Create( self.scroll_control )
	self.mainmenu_image:SetImage( self.mainmenuimage )
	self.mainmenu_image:SetPosition( Vector2( self.sett_image:GetPosition().x + 150, 20 ) )
	self.mainmenu_image:SetHeight( 135 )
	self.mainmenu_image:SetWidth( 135 )

	self.mainmenu_button = MenuItem.Create( self.scroll_control )
	self.mainmenu_button:SetPosition( self.mainmenu_image:GetPosition() )
	self.mainmenu_button:SetHeight( 170 )
	self.mainmenu_button:SetWidth( self.mainmenu_image:GetSize().x )
	self.mainmenu_button:SetText( "Покинуть" )
	self.mainmenu_button:SetTextPadding( Vector2( 0, 135 ), Vector2.Zero )
	self.mainmenu_button:SetTextSize( 19 )
	self.mainmenu_button:SetToolTip( "Покинуть сервер." )
	self.mainmenu_button:Subscribe( "Press", self, self.CastMainMenu )

	self.leftlabel = Label.Create( self.window )
	self.leftlabel:SetDock( GwenPosition.Left )
	self.leftlabel:SetMargin( Vector2( 0, 15 ), Vector2( 5, 5 ) )
	self.leftlabel:SetSize( Vector2( 250, 0 ) )

	self.passive = Label.Create( self.leftlabel )
	self.passive:SetTextColor( Color.MediumSpringGreen )
	self.passive:SetText( "Мирный режим:" )
	self.passive:SetPosition( Vector2( 5, 0 ) )
	self.passive:SizeToContents()

	self.passiveon_btn = Button.Create( self.leftlabel )
	self.passiveon_btn:SetVisible( true )
	self.passiveon_btn:SetText( "Включить" )
	self.passiveon_btn:SetSize( Vector2( 100, 30 ) )
	self.passiveon_btn:SetTextSize( 14 )
	self.passiveon_btn:SetPosition( Vector2( 5, 20 ) )
	self.passiveon_btn:Subscribe( "Press", self, self.CastPassive )

	self.jesusmode = Label.Create( self.leftlabel )
	self.jesusmode:SetTextColor( Color.LightBlue )
	self.jesusmode:SetText( "Иисус мод:" )
	self.jesusmode:SetPosition( Vector2( self.passive:GetPosition().x + 116, 0 ) )
	self.jesusmode:SizeToContents()

	self.jesusmode_btn = Button.Create( self.leftlabel )
	self.jesusmode_btn:SetText( "Включить" )
	self.jesusmode_btn:SetSize( Vector2( 100, 30 ) )
	self.jesusmode_btn:SetTextSize( 14 )
	self.jesusmode_btn:SetPosition( Vector2( self.passiveon_btn:GetSize().x + 20, 20 ) )
	self.jesusmode_btn:Subscribe( "Press", self, self.CastJesusMode )

	self.rightlabel = Label.Create( self.window )
	self.rightlabel:SetDock( GwenPosition.Right )
	self.rightlabel:SetMargin( Vector2( 0, 15 ), Vector2( 5, 5 ) )
	self.rightlabel:SetSize( Vector2( 230, 0 ) )

	self.bonus = Label.Create( self.rightlabel )
	self.bonus:SetText( "Награды:" )
	self.bonus:SetDock( GwenPosition.Top )
	self.bonus:SetMargin( Vector2( 0, 0 ), Vector2( 0, 6 ) )
	self.bonus:SizeToContents()

	self.bonus_btn = Button.Create( self.rightlabel )
	self.bonus_btn:SetEnabled( false )
	self.bonus_btn:SetText( "Достигните 9-го уровня" )
	self.bonus_btn:SetSize( Vector2( 215, 30 ) )
	self.bonus_btn:SetTextHoveredColor( Color.Yellow )
	self.bonus_btn:SetTextPressedColor( Color.Yellow )
	self.bonus_btn:SetTextSize( 15 )
	self.bonus_btn:SetDock( GwenPosition.Top )
	self.bonus_btn:Subscribe( "Press", self, self.Cash )

	self.tetris_btn = Button.Create( self.rightlabel )
	self.tetris_btn:SetText( "□□□" )
	self.tetris_btn:SetSize( Vector2( 0, 20 ) )
	self.tetris_btn:SetTextSize( 15 )
	self.tetris_btn:SetDock( GwenPosition.Bottom )
	self.tetris_btn:SetMargin( Vector2( 190, 5 ), Vector2( 0, 0 ) )
	self.tetris_btn:Subscribe( "Press", self, function() self:WindowClosed() Events:Fire( "TetrisToggle" ) end )

	self.time = Label.Create( self.leftlabel )
	self.time:SetTextColor( Color.White )
	self.time:SetText( "Игровое время: 00:00" )
	self.time:SetTextSize( 15 )
	self.time:SizeToContents()
	self.time:SetMargin( Vector2( 10, 5 ), Vector2( 0, 15 ) )
	self.time:SetDock( GwenPosition.Bottom )

	self.money = Label.Create( self.leftlabel )
	self.money:SetTextColor( Color( 251, 184, 41 ) )
	self.money:SetText( "Баланс: $" .. LocalPlayer:GetMoney() )
	self.money:SetTextSize( 20 )
	self.money:SizeToContents()
	self.money:SetMargin( Vector2( 10, 5 ), Vector2( 0, 0 ) )
	self.money:SetDock( GwenPosition.Bottom )
end

function ServerMenu:LocalPlayerMoneyChange()
	Network:Send( "GetTime" )
end

function ServerMenu:Open()
	self:SetWindowVisible( not self.active )
	if self.active then
		if not self.RenderEvent then
			self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
		end
		if not self.LocalPlayerInputEvent then
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end

		if not self.LocalPlayerMoneyChangeEvent then
			self.LocalPlayerMoneyChangeEvent = Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )
		end
		ClientEffect.Play(AssetLocation.Game, {
			effect_id = 382,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	else
		if self.RenderEvent then
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
		end
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
		if self.LocalPlayerMoneyChangeEvent then
			Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
			self.LocalPlayerMoneyChangeEvent = nil
		end
		ClientEffect.Play(AssetLocation.Game, {
			effect_id = 383,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	end
end

function ServerMenu:LocalPlayerInput( args )
    return false
end

function ServerMenu:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if args.key == string.byte('B') then
		self:Open()
		Events:Fire( "CloseHelpMenu" )
		Events:Fire( "CloseShop" )
		Events:Fire( "CloseWarpGUI" )
		Events:Fire( "CloseClansMenu" )
		Events:Fire( "CloseGuiPm" )
		Events:Fire( "CloseSettingsMenu" )
    end
end

function ServerMenu:WindowClosed( args )
	self:SetWindowVisible( false )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function ServerMenu:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetWindowVisible( false )
		if self.RenderEvent then
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
		end
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
		if self.LocalPlayerMoneyChangeEvent then
			Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
			self.LocalPlayerMoneyChangeEvent = nil
		end
	end
end

function ServerMenu:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end
end

function ServerMenu:UpdateTime( args )
	if LocalPlayer:GetValue( "Lang" ) == "РУС" then
		self.money:SetText( "Баланс: $" .. LocalPlayer:GetMoney() )
		self.time:SetText( "Игровое время: " .. args.time )
	else
		self.money:SetText( "Money: " .. LocalPlayer:GetMoney() )
		self.time:SetText( "Game time: " .. args.time )
	end

	self.money:SizeToContents()
	self.time:SizeToContents()
end

function ServerMenu:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )

		Network:Send( "GetTime" )

		self.scroll_control:SetSize( Vector2( self.window:GetSize().x - 15, 215 ) )
		self.bonus:SetPosition( Vector2( self.window:GetSize().x - 235, 250 ) )
		self.bonus_btn:SetPosition( Vector2( self.window:GetSize().x - 235, 270 ) )

		self.money:SizeToContents()
		self.time:SizeToContents()

		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.shop_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.tp_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.clans_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.pm_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.sett_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.mainmenu_button:SetFont( AssetLocation.SystemFont, "Impact" )
			self.money:SetFont( AssetLocation.SystemFont, "Impact" )
			self.time:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		if LocalPlayer:GetValue( "Lang" ) then
			if LocalPlayer:GetValue( "Lang" ) == "РУС" then
				self.money:SetText( "Баланс: $" .. LocalPlayer:GetMoney() )
			else
				self.money:SetText( "Money: " .. LocalPlayer:GetMoney() )
			end

			if LocalPlayer:GetValue( "Passive" ) then
				if LocalPlayer:GetValue( "Lang" ) == "РУС" then
					self.passiveon_btn:SetText( "Выключить" )
				else
					self.passiveon_btn:SetText( "Disable" )
				end
			else
				if LocalPlayer:GetValue( "Lang" ) == "РУС" then
					self.passiveon_btn:SetText( "Включить" )
				else
					self.passiveon_btn:SetText( "Enable" )
				end
			end
			if LocalPlayer:GetValue( "WaterWalk" ) then
				if LocalPlayer:GetValue( "Lang" ) == "РУС" then
					self.jesusmode_btn:SetText( "Выключить" )
				else
					self.jesusmode_btn:SetText( "Disable" )
				end
			else
				if LocalPlayer:GetValue( "Lang" ) == "РУС" then
					self.jesusmode_btn:SetText( "Включить" )
				else
					self.jesusmode_btn:SetText( "Enable" )
				end
			end
			if LocalPlayer:GetValue( "Lang" ) == "РУС" then
				self.bonus_btn:SetText( "$$ Денежный бонус $$" )
			else
				self.bonus_btn:SetText( "$$ Money bonus $$" )
			end
		end

		if LocalPlayer:GetValue( "JesusModeEnabled" ) then
			self.jesusmode:SetVisible( true )
			self.jesusmode_btn:SetVisible( true )
		else
			self.jesusmode:SetVisible( false )
			self.jesusmode_btn:SetVisible( false )
		end
		if LocalPlayer:GetWorld() == DefaultWorld then
			self.shop_button:SetEnabled( true )
			self.tp_button:SetEnabled( true )
			self.passiveon_btn:SetEnabled( true )
			self.jesusmode_btn:SetEnabled( true )
		else
			self.shop_button:SetEnabled( false )
			self.tp_button:SetEnabled( false )
			self.passiveon_btn:SetEnabled( false )
			self.jesusmode_btn:SetEnabled( false )
		end
	end
end

function ServerMenu:CastHelpMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenHelpMenu" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastShop()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenShop" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastWarpGUI()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenWarpGUI" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastClansMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenClansMenu" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastGuiPm()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenGuiPm" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastSettingsMenu()
	self:SetWindowVisible( not self.active )
	Events:Fire( "OpenSettingsMenu" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastMainMenu()
	self:SetWindowVisible( not self.active )
	Network:Send( "PlayerKick" )
    Game:FireEvent( "bm.loadcheckpoint.go" )
	Chat:SetEnabled( false )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastPassive()
	self:SetWindowVisible( not self.active )
	Events:Fire( "PassiveOn" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:CastJesusMode()
	self:SetWindowVisible( not self.active )
	Events:Fire( "JesusToggle" )
	if self.RenderEvent then
		Events:Unsubscribe( self.RenderEvent )
		self.RenderEvent = nil
	end
	if self.LocalPlayerInputEvent then
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		self.LocalPlayerInputEvent = nil
	end
	if self.LocalPlayerMoneyChangeEvent then
		Events:Unsubscribe( self.LocalPlayerMoneyChangeEvent )
		self.LocalPlayerMoneyChangeEvent = nil
	end
end

function ServerMenu:Cash()
	Network:Send( "Cash" )
	self.bonus_btn:SetEnabled( false )
	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 20,
			sound_id = 20,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
end

function ServerMenu:Bonus()
	if LocalPlayer:GetMoney() >= 12000 then
		self.bonus_btn:SetEnabled( true )
		if LocalPlayer:GetValue( "Lang" ) == "ENG" then
			Chat:Print( "[Bonus] ", Color.White, "Money bonus is available! Open the server menu to get it!", Color.GreenYellow )
		else
			Chat:Print( "[Бонус] ", Color.White, "Доступен денежный бонус! Откройте меню сервера, чтобы получить его.", Color.GreenYellow )
		end
	end
end

servermenu = ServerMenu()
