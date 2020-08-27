class 'Settings'

function Settings:__init()
	self.active = false
	self.actv = true
	self.pendclockformat = false
	self.actvDr = true
	self.actvTip = true
	self.actvGod = true
	self.actvSt = true
	self.actvKf = true
	self.actvJes = true
	self.actvBk = false
	self.actvPM = true
	if LocalPlayer:GetMoney() >= 8000 then
		self.actvH = true
	else
		self.actvH = false
	end
	self.actvHu = true
	self.actvMb = true
	self.actvCH = false
	self.actvLHV = false
	self.actvSn = false
	self.gethide = false

	self.aim = true

	self.unit = 0

	if LocalPlayer:GetValue( "Creator" ) or LocalPlayer:GetValue( "GlAdmin" ) or LocalPlayer:GetValue( "Admin" )
		or LocalPlayer:GetValue( "AdminD" ) or LocalPlayer:GetValue( "ModerD" ) or LocalPlayer:GetValue( "Vip" ) then
		self.roll = true
	else
		self.roll = false
	end
	self.spin = false
	self.flip = false

	--Network:Send( "GetDBSettings" )

	self:LoadCategories()

	Events:Subscribe( "Render", self, self.Render )
	--Network:Subscribe( "LoadSettings", self, self.LoadSettings )
	Network:Subscribe( "ResetDone", self, self.ResetDone )
	Network:Subscribe( "UpdateStats", self, self.UpdateStats )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LoadUI", self, self.LoadUI )
	Events:Subscribe( "GameLoad", self, self.GameLoad )
	Events:Subscribe( "OpenSettingsMenu", self, self.OpenSettingsMenu )
	Events:Subscribe( "CloseSettingsMenu", self, self.CloseSettingsMenu )
	Events:Subscribe( "KeyUp", self, self.KeyHide )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "KeyDown", self, self.KeyDown )

	self:GameLoad()
end

function Settings:Lang()
	self.window:SetTitle( "▧ Settings" )
	self.hidetexttip:SetText( "Press F11 to hide/show UI" )
	self.hidetext:SetText( "Use full UI hiding" )
	self.buttonBoost:SetText( "Boost setting (for vehicle)" )
	self.buttonSpeedo:SetText( "Speedometer setting" )
	self.buttonSDS:SetText( "Skydiving settings" )
	self.buttonTags:SetText( "Tags settings" )
	self.texter:SetText( "Saves:" )
	self.buttonSPOff:SetText( "Reset Saved Position" )
end

function Settings:LoadUI()
	self:GameLoad()
end

function Settings:LoadCategories()
	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.5 ) )
	self.window:SetMinimumSize( Vector2( 680, 442 ) )
	self.window:SetPositionRel( Vector2( 0.73, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Настройки" )
	self.window:Subscribe( "WindowClosed", self, self.WindowClosed )

	self.tab = TabControl.Create( self.window )
	self.tab:SetDock( GwenPosition.Fill )

	local widgets = BaseWindow.Create( self.window )
	self.tab:AddPage( "Основное", widgets )

	local scroll_control = ScrollControl.Create( widgets )
	scroll_control:SetScrollable( false, true )
	scroll_control:SetSize( Vector2( 328, self.window:GetSize().y - 70 ) )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать часы" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 5 ) )
	button:GetCheckBox():SetChecked( self.actv )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actv = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "12-часовой формат" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 25 ) )
	button:GetCheckBox():SetChecked( self.pendclockformat )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.pendclockformat = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать лучшие рекорды" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 45 ) )
	button:GetCheckBox():SetChecked( self.actvDr )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvDr = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать Мирный" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 85 ) )
	button:GetCheckBox():SetChecked( self.actvGod )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvGod = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать чат убийств" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 105 ) )
	button:GetCheckBox():SetChecked( self.actvSt )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvKf = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать подсказку под чатом" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 145 ) )
	button:GetCheckBox():SetChecked( self.actvTip )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvTip = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать фон чата" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 165 ) )
	button:GetCheckBox():SetChecked( self.actvBk )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvBk = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать маркеры игроков" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 205 ) )
	button:GetCheckBox():SetChecked( self.actvMb )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvMb = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать прицел" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 245 ) )
	button:GetCheckBox():SetChecked( self.aim )
	button:GetCheckBox():Subscribe( "CheckChanged", self, self.ToggleAim )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Серверный прицел" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 265 ) )
	button:GetCheckBox():SetChecked( self.actvCH )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvCH = button:GetCheckBox():GetChecked() self:GameLoad() Game:FireEvent("gui.aim.show") end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Индикатор длинного крюка" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetVisible( false )
	button:SetPosition( Vector2( 5, 285 ) )
	button:GetCheckBox():SetChecked( self.actvLHV )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvLHV = button:GetCheckBox():GetChecked() self:GameLoad() end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Jet HUD (для авиации)" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 285 ) )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() Events:Fire( "JHudActive" ) end )

	local button = LabeledCheckBox.Create( scroll_control )
	button:GetLabel():SetText( "Отображать снег на экране" )
	button:SetSize( Vector2( 300, 20 ) )
	button:GetLabel():SetTextSize( 15 )
	button:SetPosition( Vector2( 5, 325 ) )
	button:GetCheckBox():SetChecked( self.actvSn )
	button:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvSn = button:GetCheckBox():GetChecked() self:GameLoad() end )

	self.JesusVisButton = LabeledCheckBox.Create( scroll_control )
	self.JesusVisButton:GetLabel():SetText( "Отображать Иисус" )
	self.JesusVisButton:SetSize( Vector2( 300, 20 ) )
	self.JesusVisButton:GetLabel():SetTextSize( 15 )
	self.JesusVisButton:SetPosition( Vector2( 5, 345 ) )
	self.JesusVisButton:GetCheckBox():SetChecked( self.actvJes )
	self.JesusVisButton:GetCheckBox():Subscribe( "CheckChanged",
		function() self.actvJes = self.JesusVisButton:GetCheckBox():GetChecked() self:GameLoad() end )

	self.hidetexttip = Label.Create( widgets )
	self.hidetexttip:SetText( "Нажмите F11, чтобы скрыть/показать интерфейс" )
	self.hidetexttip:SetSize( Vector2( 290, 15 ) )
	self.hidetexttip:SetPosition( Vector2( scroll_control:GetSize().x + 10, 340 ) )

	self.hidetext = Label.Create( widgets )
	self.hidetext:SetVisible( false )
	self.hidetext:SetText( "Используется полное скрытие интерфейса" )
	self.hidetext:SetTextColor( Color.Yellow )
	self.hidetext:SetSize( Vector2( 250, 15 ) )
	self.hidetext:SetPosition( Vector2( scroll_control:GetSize().x + 10, 360 ) )

	self.buttonBoost = Button.Create( widgets )
	self.buttonBoost:SetVisible( false )
	self.buttonBoost:SetText( "Настройка ускорения (для ТС)" )
	self.buttonBoost:SetSize( Vector2( 315, 30 ) )
	self.buttonBoost:SetTextSize( 14 )
	if LocalPlayer:GetValue( "BoostEnabled" ) then
		self.buttonBoost:SetPosition( Vector2( scroll_control:GetSize().x + 10, 5 ) )
	else
		self.buttonBoost:SetPosition( Vector2( scroll_control:GetSize().x + 10, -40 ) )
	end
	self.buttonBoost:Subscribe( "Press", self, function() Events:Fire( "BoostSettings" ) end )

	self.buttonSpeedo = Button.Create( widgets )
	self.buttonSpeedo:SetVisible( true )
	self.buttonSpeedo:SetText( "Настройка спидометра" )
	self.buttonSpeedo:SetSize( Vector2( 315, 30 ) )
	self.buttonSpeedo:SetTextSize( 14 )
	self.buttonSpeedo:SetPosition( Vector2( scroll_control:GetSize().x + 10, self.buttonBoost:GetPosition().y + 40 ) )
	self.buttonSpeedo:Subscribe( "Press", self, function() Events:Fire( "OpenSpeedometerMenu" ) end )

	self.buttonSDS = Button.Create( widgets )
	self.buttonSDS:SetVisible( true )
	self.buttonSDS:SetText( "Настройка скайдайвинга" )
	self.buttonSDS:SetSize( Vector2( 315, 30 ) )
	self.buttonSDS:SetTextSize( 14 )
	self.buttonSDS:SetPosition( Vector2( scroll_control:GetSize().x + 10, self.buttonSpeedo:GetPosition().y + 40 ) )
	self.buttonSDS:Subscribe( "Press", self, function() Events:Fire( "OpenSkydivingStatsMenu" ) end )

	self.buttonTags = Button.Create( widgets )
	self.buttonTags:SetVisible( true )
	self.buttonTags:SetText( "Настройка тегов" )
	self.buttonTags:SetSize( Vector2( 315, 30 ) )
	self.buttonTags:SetTextSize( 14 )
	self.buttonTags:SetPosition( Vector2( scroll_control:GetSize().x + 10, self.buttonSDS:GetPosition().y + 40 ) )
	self.buttonTags:Subscribe( "Press", self, function() Events:Fire( "OpenNametagsMenu" ) end )

	self.texter = Label.Create( widgets )
	self.texter:SetText( "Сохранения:" )
	self.texter:SetPosition( Vector2( scroll_control:GetSize().x + 10, self.buttonTags:GetPosition().y + 45 ) )

	self.buttonSPOff = Button.Create( widgets )
	self.buttonSPOff:SetVisible( true )
	self.buttonSPOff:SetText( "Сбросить сохраненную позицию" )
	self.buttonSPOff:SetSize( Vector2( 315, 30 ) )
	self.buttonSPOff:SetTextSize( 14 )
	self.buttonSPOff:SetPosition( Vector2( scroll_control:GetSize().x + 10, self.texter:GetPosition().y + 20 ) )
	self.buttonSPOff:Subscribe( "Press", self, function() Network:Send( "SPOff" ) end )

	local nickcolor = BaseWindow.Create( self.window )
	self.tab:AddPage( "Цвет ника", nickcolor )

	local tab_control = TabControl.Create( nickcolor )
	tab_control:SetDock( GwenPosition.Fill )

	self.pcolorPicker = HSVColorPicker.Create( tab_control )
	self.pcolorPicker:SetDock( GwenPosition.Fill )

	self.pcolorPicker:Subscribe( "ColorChanged", function()
		self.pcolor = self.pcolorPicker:GetColor()
		self.colorChanged = true
	end )

	self.pcolorPicker:SetColor( LocalPlayer:GetColor() )
	self.pcolor = self.pcolorPicker:GetColor()

	local setColorBtn = Button.Create( nickcolor )
	setColorBtn:SetText( "Установить цвет »" )
	setColorBtn:SetTextHoveredColor( Color.GreenYellow )
	setColorBtn:SetTextPressedColor( Color.GreenYellow )
	setColorBtn:SetTextSize( 15 )
	setColorBtn:SetSize( Vector2( 0, 30 ) )
	setColorBtn:SetDock( GwenPosition.Bottom )
	setColorBtn:Subscribe( "Up", function()
		Network:Send( "SetPlyColor", { pcolor = self.pcolor } )
		local sound = ClientSound.Create(AssetLocation.Game, {
				bank_id = 20,
				sound_id = 22,
				position = LocalPlayer:GetPosition(),
				angle = Angle()
		})

		sound:SetParameter(0,1)	
		Game:FireEvent( "bm.savecheckpoint.go" )
	end )

	local skysettings = BaseWindow.Create( self.window )
	self.tab:AddPage( "Статистика", skysettings )

	self.stats = Label.Create( skysettings )
	self.stats:SetText( "Имя: " .. LocalPlayer:GetName() )
	self.stats:SizeToContents()
end

function Settings:GameLoad()
	Events:Fire( "GetOption", {
		act = self.actv,
		pendclockformat = self.pendclockformat,
		actDr = self.actvDr,
		actGod = self.actvGod,
		actJes = self.actvJes,
		actSt = self.actvSt,
		actKf = self.actvKf,
		actTip = self.actvTip,
		actBk = self.actvBk,
		actPM = self.actvPM,
		actH = self.actvH,
		actHu = self.actvHu,
		actMb = self.actvMb,
		actCH = self.actvCH,
		actLHV = self.actvLHV,
		actSn = self.actvSn,
		roll = self.roll,
		spin = self.spin,
		flip = self.flip
	} )
end

function Settings:ToSQL()
	local value = 1
	if self.actv then
		value = 1
	else
		value = 0
	end

	Network:Send( "SaveSettings", {
		clockbol = value
	} )
end

function Settings:LoadSettings( args )
	if args.clockdb then
		if args.clockdb == 1 then
			self.actv = true
		else
			self.actv = false
		end
	end
end

function Settings:UpdateStats( args )
	self.stats:SetText( args.stats )
	self.stats:SizeToContents()
end

function Settings:Open()
	self:SetWindowVisible( not self.active )
	if LocalPlayer:GetValue( "JesusModeEnabled" ) then
		self.JesusVisButton:SetVisible( true )
	else
		self.JesusVisButton:SetVisible( false )
	end

	if LocalPlayer:GetValue( "BoostEnabled" ) then
		self.buttonBoost:SetVisible( true )
	else
		self.buttonBoost:SetVisible( false )
	end

	Network:Send( "GetStats" )

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

function Settings:LocalPlayerInput( args )
    return not (self.active and Game:GetState() == GUIState.Game)
end

function Settings:OpenSettingsMenu( args )
	if Game:GetState() ~= GUIState.Game then return end
	self:Open()
end

function Settings:CloseSettingsMenu( args )
	if Game:GetState() ~= GUIState.Game then return end
	if self.window:GetVisible() == true then
		self:SetWindowVisible( false )
	end
end

function Settings:WindowClosed( args )
	self:SetWindowVisible( false )
	ClientEffect.Create(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function Settings:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetWindowVisible( false )
	end
end

function Settings:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end
end

function Settings:SetWindowVisible( visible )
    if self.active ~= visible then
		self.active = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )
	end
end

function Settings:ToggleAim()
	self.aim = not self.aim
	if self.aim then
		if self.RenderEvent then
			Events:Unsubscribe( self.RenderEvent )
			self.RenderEvent = nil
		end
		Game:FireEvent("gui.aim.show")
		self.actvCH = self.before
		self.before = nil
		self:GameLoad()
	else
		if not self.RenderEvent then
			self.RenderEvent = Events:Subscribe( "Render", self, self.Aim )
		end
		if self.actvCH then
			self.actvCH = false
			self.before = true
			self:GameLoad()
		end
	end
end

function Settings:Aim()
	Game:FireEvent("gui.aim.hide")
end

function Settings:GetJetpack()
	Events:Fire( "UseJetpack" )
end

function Settings:ResetDone()
	self.buttonSPOff:SetEnabled( false )
	self.buttonSPOff:SetText( "Позиция сброшена. Перезайдите в игру." )
end

function Settings:KeyHide( args )
	if args.key == VirtualKey.F11 then
		if self.gethide then
			self.hidetext:SetVisible( false )
		else
			self.hidetext:SetVisible( true )
		end
		self.actv = not self.actv
		self.actvDr = not self.actvDr
		self.actvGod = not self.actvGod
		self.actvJes = not self.actvJes
		self.actvSt = not self.actvSt
		self.actvKf = not self.actvKf
		self.actvMb = not self.actvMb
		self.actvLHV = not self.actvLHV
		self.gethide = not self.gethide
		self:GameLoad()
	end
end

settings = Settings()