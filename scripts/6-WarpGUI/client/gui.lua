class 'WarpGui'

function WarpGui:__init()
	self.cooldown = 15
	timer = Timer()
	self.cooltime = 0

	self.tag = "[Телепорт] "
	self.w = "Подождите "
	self.ws = " секунд, чтобы вновь отправить запрос!"
	self.gonnawarp = " хотел бы телепортироваться к вам. Введите /warp или нажмите 'B', чтобы принять."

	self.textColor = Color( 200, 50, 200 )
	self.rows = {}
	self.acceptButtons = {}
	self.whitelistButtons = {}
	self.whitelist = {}
	self.whitelistAll = false
	self.warpRequests = {}
	self.windowShown = false
	self.warping = true

	self.window = Window.Create()
	self.window:SetVisible( self.windowShown )
	self.window:SetTitle( "▧ Телепорт к игрокам" )
	self.window:SetSizeRel( Vector2( 0.35, 0.7 ) )
	self.window:SetMinimumSize( Vector2( 400, 200 ) )
	self.window:SetPositionRel( Vector2( 0.75, 0.5 ) - self.window:GetSizeRel()/2 )
    self.window:Subscribe( "WindowClosed", self, self.Close )

	self.playerList = SortedList.Create( self.window )
	self.playerList:SetMargin( Vector2.Zero, Vector2( 0, 4 ) )
	self.playerList:SetBackgroundVisible( false )
	self.playerList:AddColumn( "Имя" )
	self.playerList:AddColumn( "Телепорт к", 90 )
	self.playerList:AddColumn( "Запросы", 90 )
	self.playerList:AddColumn( "Авто-ТП", 90 )
	self.playerList:SetButtonsVisible( true )
	self.playerList:SetDock( GwenPosition.Fill )

	self.filter = TextBox.Create( self.window )
	self.filter:SetDock( GwenPosition.Bottom )
	self.filter:SetSize( Vector2( self.window:GetSize().x, 32 ) )
	self.filter:SetToolTip( "Поиск" )
	self.filter:Subscribe( "TextChanged", self, self.TextChanged )

	self.whitelistAllCheckbox = LabeledCheckBox.Create( self.window )
    self.whitelistAllCheckbox:SetDock( GwenPosition.Top )
	self.whitelistAllCheckbox:GetLabel():SetText( "Разрешить Авто-ТП всем" )
	self.whitelistAllCheckbox:GetLabel():SetTextSize( 15 )
	self.whitelistAllCheckbox:GetCheckBox():Subscribe( "CheckChanged", function() self.whitelistAll = self.whitelistAllCheckbox:GetCheckBox():GetChecked() end )

	self.blacklistAllCheckbox = LabeledCheckBox.Create( self.window )
	self.blacklistAllCheckbox:SetDock( GwenPosition.Top )
	self.blacklistAllCheckbox:GetLabel():SetText( "Не беспокоить" )
	self.blacklistAllCheckbox:GetLabel():SetTextSize( 15 )
	self.blacklistAllCheckbox:GetCheckBox():Subscribe( "CheckChanged", function() self.warping = not self.warping end )	

	-- Add players
	for player in Client:GetPlayers() do
		self:AddPlayer( player )
	end
	--self:AddPlayer(LocalPlayer)

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "OpenWarpGUI", self, self.OpenWarpGUI )
	Events:Subscribe( "CloseWarpGUI", self, self.CloseWarpGUI )
	Events:Subscribe( "Render", self, self.Render )
	Network:Subscribe( "WarpRequestToTarget", self, self.WarpRequest )
	Network:Subscribe( "WarpReturnWhitelists", self, self.WarpReturnWhitelists )
	Network:Subscribe( "WarpDoPoof", self, self.WarpDoPoof )

	-- Load whitelists from server
	Network:Send( "WarpGetWhitelists", LocalPlayer )
end

function WarpGui:Lang()
	self.tag = "[Teleport] "
	self.w = "Wait "
	self.ws = " seconds to send the request again!"
	self.gonnawarp = " sent you a teleport request. Type /warp or press 'B', to accept."
	self.window:SetTitle( "▧ Teleport to players" )
	self.whitelistAllCheckbox:GetLabel():SetText( "Allow Auto-TP for all" )
	self.blacklistAllCheckbox:GetLabel():SetText( "Do not disturb" )
end

--  Player adding
function WarpGui:CreateListButton( text, enabled, listItem )
    local buttonBackground = Rectangle.Create( listItem )
    buttonBackground:SetSizeRel( Vector2( 0.5, 1.0 ) )
    buttonBackground:SetDock( GwenPosition.Fill )
    buttonBackground:SetColor( Color( 0, 0, 0, 100 ) )

	local button = Button.Create( listItem )
	button:SetText( text )
	button:SetTextSize( 13 )
	button:SetDock( GwenPosition.Fill )
	button:SetEnabled( enabled )

	return button
end

function WarpGui:AddPlayer( player )
	local playerId = tostring(player:GetSteamId().id)
	local playerName = player:GetName()
	local playerColor = player:GetColor()

	local item = self.playerList:AddItem( playerId )

	if LocalPlayer:IsFriend( player ) then
		item:SetToolTip( "Друг" )
	end

	local warpToButton = self:CreateListButton( "Телепорт ≫", true, item )
	warpToButton:Subscribe( "Press", function() self:WarpToPlayerClick(player) end )

	local acceptButton = self:CreateListButton( "Принять √", false, item )
	acceptButton:Subscribe( "Press", function() self:AcceptWarpClick(player) end )
	self.acceptButtons[playerId] = acceptButton

	local whitelist = self.whitelist[playerId]
	local whitelistButtonText = "-"
	if whitelist ~= nil then
		if whitelist == 1 then whitelistButtonText = "Вкл"
		elseif whitelist == 2 then whitelistButtonText = "Заблок."
		end
	end
	local whitelistButton = self:CreateListButton( whitelistButtonText, true, item )
	whitelistButton:Subscribe( "Press", function() self:WhitelistClick(playerId, whitelistButton) end )
	self.whitelistButtons[playerId] = whitelistButton

	item:SetCellText( 0, playerName )
	item:SetCellContents( 1, warpToButton )
	item:SetCellContents( 2, acceptButton )
	item:SetCellContents( 3, whitelistButton )
	item:SetTextColor( playerColor )

	self.rows[playerId] = item

	-- Add is serch filter matches
	local filter = self.filter:GetText():lower()
	if filter:len() > 0 then
		item:SetVisible( true )
	end
end

--  Player search
function WarpGui:TextChanged()
	local filter = self.filter:GetText()

	if filter:len() > 0 then
		for k, v in pairs( self.rows ) do
			v:SetVisible( self:PlayerNameContains(v:GetCellText( 0 ), filter) )
		end
	else
		for k, v in pairs( self.rows ) do
			v:SetVisible( true )
		end
	end
end

function WarpGui:PlayerNameContains( name, filter )
	return string.match(name:lower(), filter:lower()) ~= nil
end

function WarpGui:WarpToPlayerClick( player )
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
	local time = Client:GetElapsedSeconds()
	if time < self.cooltime then
		self:SetWindowVisible( false )
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		Events:Fire( "CastCenterText", { text = self.w .. math.ceil(self.cooltime - time) .. self.ws, time = 6, color = Color.Red } )
		return
	end
	Network:Send( "WarpRequestToServer", {requester = LocalPlayer, target = player} )
	Events:Unsubscribe( self.KeyDownEvent )
	Events:Unsubscribe( self.LocalPlayerInputEvent )
	timer:Restart()
	self:SetWindowVisible( false )

	self.cooltime = time + self.cooldown
	return false
end

function WarpGui:AcceptWarpClick( player )
	local playerId = tostring(player:GetSteamId().id)

	if self.warpRequests[playerId] == nil then
		Chat:Print( self.tag, Color.White, player:GetName() .. " не просил вас телепортироваться.", self.textColor )
		return
	else
		local acceptButton = self.acceptButtons[playerId]
		if acceptButton == nil then return end
		self.warpRequests[playerId] = nil
		acceptButton:SetEnabled( false )
		
		Network:Send( "WarpTo", {requester = player, target = LocalPlayer} )
		self:SetWindowVisible( false )
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

--  Warp request
function WarpGui:WarpRequest( args )
	if self.warping then
		local requestingPlayer = args
		local playerId = tostring(requestingPlayer:GetSteamId().id)
		local whitelist = self.whitelist[playerId]

		if whitelist == 1 or self.whitelistAll then
			Network:Send( "WarpTo", {requester = requestingPlayer, target = LocalPlayer} )
		elseif whitelist == 0 or whitelist == nil then -- Not in whitelist
			local acceptButton = self.acceptButtons[playerId]
			if acceptButton == nil then return end

			acceptButton:SetEnabled( true )
			self.warpRequests[playerId] = true
			if LocalPlayer:GetWorld() ~= DefaultWorld then
				Network:Send( "WarpMessageTo", {target = requestingPlayer, message = "Игрок " .. LocalPlayer:GetName() .. " сейчас в мини-игре, но сможет принять запрос на телепортацию позже."} )
				Chat:Print( self.tag, Color.White, requestingPlayer:GetName() .. " хотел бы телепортироваться к вам, вы можете принять запрос на телепортацию позже, нажав B.", self.textColor )
				return
			end
			Network:Send( "WarpMessageTo", {target = requestingPlayer, message = "Запрос на телепортацию отправлен к " .. LocalPlayer:GetName() .. ". Ожидайте принятия запроса."} )
			Chat:Print( self.tag, Color.White, requestingPlayer:GetName() .. self.gonnawarp, self.textColor )

			if not self.PostTickEvent then
				self.PostTickEvent = Events:Subscribe( "PostTick", self, self.PostTick )
				self.RefreshTimer = Timer()
			else
				self.RefreshTimer:Restart()
			end
		end
	else
		Chat:Print( self.tag, Color.White, "Игрок в режиме не беспокоить.", self.textColor )
	end
end

function WarpGui:PostTick()
	if self.RefreshTimer:GetSeconds() <= 30 then return end
	self:refreshList()
	self.RefreshTimer = nil
	if self.PostTickEvent then
		Events:Unsubscribe( self.PostTickEvent )
		self.PostTickEvent = nil
	end
end

--  White/black -list click
function WarpGui:WhitelistClick( playerId, button )
	local currentWhiteList = self.whitelist[playerId]

	if currentWhiteList == 0 or currentWhiteList == nil then -- Currently none, set whitelisted
		self:SetWhitelist( playerId, 1, true )
	elseif currentWhiteList == 1 then -- Currently whitelisted, blacklisted
		self:SetWhitelist( playerId, 2, true )
	elseif currentWhiteList == 2 then -- Currently blacklisted, set none
		self:SetWhitelist( playerId, 0, true )
	end
end

function WarpGui:SetWhitelist( playerId, whitelisted, sendToServer )
	if self.whitelist[playerId] ~= whitelisted then self.whitelist[playerId] = whitelisted end

	local whitelistButton = self.whitelistButtons[playerId]
	if whitelistButton == nil then return end

	if whitelisted == 0 then
		whitelistButton:SetText( "-" )
		whitelistButton:SetTextSize( 13 )
	elseif whitelisted == 1 then
		whitelistButton:SetText( "Вкл" )
		whitelistButton:SetTextSize( 13 )
	elseif whitelisted == 2 then
		whitelistButton:SetText( "Заблок." )
		whitelistButton:SetTextSize( 13 )
	end

	if sendToServer then
		Network:Send( "WarpSetWhitelist", {playerSteamId = LocalPlayer:GetSteamId().id, targetSteamId = playerId, whitelist = whitelisted} )
	end
end

function WarpGui:WarpReturnWhitelists( whitelists )
	for i = 1, #whitelists do
		local targetSteamId = whitelists[i].target_steam_id
		local whitelisted = whitelists[i].whitelist
		self:SetWhitelist( targetSteamId, tonumber(whitelisted), false )
	end
end

function WarpGui:LocalPlayerChat( args )
	local message = args.text

	local commands = {}
	for command in string.gmatch(message, "[^%s]+") do
		table.insert(commands, command)
	end

	if commands[1] ~= "/warp" then return true end

	if #commands == 1 then -- No extra commands, show window and return
		if LocalPlayer:GetWorld() ~= DefaultWorld then return end
		self:SetWindowVisible( not self.windowShown )
		if self.windowShown then
			self.KeyDownEvent = Events:Subscribe( "KeyDown", self, self.KeyDown )
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
			ClientEffect.Play(AssetLocation.Game, {
				effect_id = 382,

				position = Camera:GetPosition(),
				angle = Angle()
			})
		else
			Events:Unsubscribe( self.KeyDownEvent )
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			ClientEffect.Play(AssetLocation.Game, {
				effect_id = 383,

				position = Camera:GetPosition(),
				angle = Angle()
			})
		end
		return false
	end

	local warpNameSearch = table.concat(commands, " ", 2)

	for player in Client:GetPlayers() do
		if (self:PlayerNameContains( player:GetName(), warpNameSearch) ) then
			self:WarpToPlayerClick( player )
			return false
		end
	end

	return false
end

function WarpGui:WarpDoPoof( position )
    ClientEffect.Play( AssetLocation.Game, {effect_id = 250, position = position, angle = Angle()} )
end

--  Window management
function WarpGui:LocalPlayerInput( args )
    return false
end

function WarpGui:OpenWarpGUI()
	if Game:GetState() ~= GUIState.Game then return end

	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})

	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	self:SetWindowVisible( not self.windowShown )
	if self.windowShown then
		self.KeyDownEvent = Events:Subscribe( "KeyDown", self, self.KeyDown )
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	else
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

function WarpGui:CloseWarpGUI()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.window:GetVisible() == true then
		self:SetWindowVisible( false )
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

function WarpGui:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetWindowVisible( false )
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

function WarpGui:PlayerJoin( args )
	local player = args.player

	self:AddPlayer( player )
end

function WarpGui:PlayerQuit( args )
	local player = args.player
	local playerId = tostring(player:GetSteamId().id)

	if self.rows[playerId] == nil then return end

	self.playerList:RemoveItem(self.rows[playerId])
	self.rows[playerId] = nil
end

function WarpGui:Render()
	local is_visible = self.windowShown and (Game:GetState() == GUIState.Game)

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	if self.active then
		Mouse:SetVisible( true )
	end
end

function WarpGui:SetWindowVisible( visible )
    if self.windowShown ~= visible then
		self.windowShown = visible
		self.window:SetVisible( visible )
		Mouse:SetVisible( visible )
		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.whitelistAllCheckbox:GetLabel():SetFont( AssetLocation.SystemFont, "Impact" )
			self.blacklistAllCheckbox:GetLabel():SetFont( AssetLocation.SystemFont, "Impact" )
		end
	end
end

function WarpGui:Close()
	self:SetWindowVisible( false )
	Events:Unsubscribe( self.KeyDownEvent )
	Events:Unsubscribe( self.LocalPlayerInputEvent )
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function WarpGui:refreshList()
	self.playerList:Clear()
	self.playerToRow = {}
	for player in Client:GetPlayers() do
		self:AddPlayer( player )
	end
	--self:AddPlayer(LocalPlayer)
end

warpGui = WarpGui()