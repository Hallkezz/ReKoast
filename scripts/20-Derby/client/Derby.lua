class 'Derby'

function Derby:__init()
	Network:Subscribe( "SetState", self, self.SetState )

	Network:Subscribe( "TriggerEvent", self, self.TriggerEvent )

	Network:Subscribe( "OutOfArena", self, self.OutOfArena )
	Network:Subscribe( "BackInArena", self, self.BackInArena )
	Network:Subscribe( "enterVehicle", self, self.enterVehicle )
	Network:Subscribe( "exitVehicle", self, self.exitVehicle )

	Network:Subscribe( "PlayerCount", self, self.PlayerCount )
	Network:Subscribe( "CourseName", self, self.CourseName )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )

	Events:Subscribe( "LocalPlayerInput" , self , self.LocalPlayerInput )

	self.handbrake = nil

	self.nameT = "Игроки"
	self.state = "Inactive"
	self.playerCount = nil
	self.courseName = nil
	self.countdownTimer = nil
	self.blockedKeys = { Action.StuntJump, Action.StuntposEnterVehicle, Action.ParachuteOpenClose, Action.ExitVehicle, Action.EnterVehicle, Action.UseItem }

	self.outOfArena = false
	self.inVehicleTimer = nil
	self.vehicleHealthLost = -5
end

function DrawCenteredShadowedText( position, text, color, textsize )
	local textsize = textsize or TextSize.Default
	local bounds = Render:GetTextSize(text, textsize)

	if not IsNaN(position) then
		Render:DrawText( position - (bounds / 2) + (Vector2.One * math.max(textsize / 32, 1)), text, Color( 25, 25, 25, 150 ), textsize )
		Render:DrawText( position - (bounds / 2), text, color, textsize )
	end
end

function Derby:Lang( args )
	self.nameT = "Players"
end

function Derby:SetState( newstate )
	self.state = newstate
	if (newstate == "Inactive") then
		if (IsValid(self.handbrake)) then
			Events:Unsubscribe(self.handbrake)
		end
		self:BackInArena()
	end

	if (newstate == "Lobby") then
		self.state = "Lobby"
		self:BackInArena()
	elseif (newstate == "Setup") then
		self.state = "Setup"
		self.handbrake = Events:Subscribe("InputPoll", function() Input:SetValue(Action.Handbrake, 1) end)
	elseif (newstate == "Countdown") then
		self.state = "Countdown"
		self.countdownTimer = Timer()
	elseif (newstate == "Running") then
		self.state = "Running"
		self.countdownTimer = nil
		Events:Unsubscribe(self.handbrake)
	end
end

function Derby:CourseName( name )
	self.courseName = name
end

function Derby:PlayerCount( amount )
	self.playerCount = amount
end

function Derby:enterVehicle()
	self.inVehicleTimer = nil
end

function Derby:exitVehicle()
	self.inVehicleTimer = Timer()
end

function Derby:OutOfArena()
	self.outOfArena = true
	self.vehicleHealthLost = self.vehicleHealthLost + 5
end

function Derby:BackInArena()
	self.outOfArena = false
	self.vehicleHealthLost = -5
end

function Derby:TriggerEvent( event )
	Game:FireEvent( event )
end

function Derby:LocalPlayerInput( args )
	if (self.state == "Running") then
		if LocalPlayer:InVehicle() then
			for i, action in ipairs(self.blockedKeys) do
				if args.input == action then
					return false
				end
			end
		end
	elseif (self.state == "Setup" or self.state == "Countdown") then
		return false
	end
end
function Derby:TextPos( text, size, offsetx, offsety )
	local text_width = Render:GetTextWidth(text, size)
	local text_height = Render:GetTextHeight(text, size)
	local pos = Vector2( (Render.Width - text_width + offsetx)/2, (Render.Height - text_height + offsety)/2 )

	return pos
end
function Derby:Render()
	if (self.state == "Inactive") then return end
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	local players = {LocalPlayer}

	for player in Client:GetPlayers() do
		if player:GetWorld() == LocalPlayer:GetWorld() then
			table.insert(players, player)
		end
	end

	if (self.state ~= "Inactive") then
		local pos = Vector2(Render.Width - 367, 0)
	end

	if (self.state == "Lobby") then
		local text = "Игроки: " .. self.playerCount
		local textinfo = self:TextPos( text, TextSize.Large, 0, -Render.Height + 150 )
		local textinfoTw = self:TextPos( text, TextSize.Large, 2, -Render.Height + 152 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), TextSize.Large )   
		Render:DrawText( textinfo, text, Color.White, TextSize.Large )
		
		local text = "Карта: " .. self.courseName
		local textinfo = self:TextPos( text, 25, 0, -Render.Height + 215 )
		local textinfoTw = self:TextPos( text, 25, 2, -Render.Height + 217 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), 25 )
		Render:DrawText( textinfo, text, Color( 165, 165, 165 ), 25 )
	end

	if (self.state == "Setup") then
        local text = "Загрузка"
        local textinfo = self:TextPos( text, TextSize.VeryLarge, 0, -200 )
		local textinfoTw = self:TextPos( text, TextSize.VeryLarge, 1, -198 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), TextSize.VeryLarge )
        Render:DrawText( textinfo, text, Color.White, TextSize.VeryLarge )

        local text = "Пожалуйста, подождите..."
        local textinfo = self:TextPos( text, TextSize.Default, 0, -150 )
		local textinfoTw = self:TextPos( text, TextSize.Default, 1, -148 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), TextSize.Default )
        Render:DrawText( textinfo, text, Color( 165, 165, 165 ), TextSize.Default )
		for k, player in ipairs(players) do
			local color = Color.Black or Color.Gray

			if player:InVehicle() then
				color = player:GetVehicle():GetColors()
			end

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), color )
		end

		DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20) ), self.nameT, Color.White, 20 )
	elseif (self.state == "Countdown") then
		local time = 3 - math.floor(math.clamp(self.countdownTimer:GetSeconds(), 0 , 3))
		local message = {"Го!", "1", "2", "3"}
		local text = message[time + 1]
        local textinfo = self:TextPos( text, TextSize.Huge, 0, -200 )
		local textinfoTw = self:TextPos( text, TextSize.Huge, 2, -197 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), TextSize.Huge ) 
        Render:DrawText( textinfo, text, Color.White, TextSize.Huge )

		for k, player in ipairs(players) do
			local color = Color.Black or Color.Gray

			if player:InVehicle() then
				color = player:GetVehicle():GetColors()
			end

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), color )
		end

		DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20) ), self.nameT, Color.White, 20 )
	elseif (self.state == "Running") then
		local text = "Игроки: " .. self.playerCount
		local textinfo = self:TextPos( text, TextSize.Large, 0, -Render.Height + 215 )
		local textinfoTw = self:TextPos( text, TextSize.Large, 2, -Render.Height + 217 )
		Render:DrawText( textinfoTw, text, Color( 25, 25, 25, 150 ), TextSize.Large )
		Render:DrawText( textinfo, text, Color.White, TextSize.Large )

		for k, player in ipairs(players) do
			local color = Color.Black or Color.Gray

			if player:InVehicle() then
				color = player:GetVehicle():GetColors()
			end

			DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - (k * 20) ), player:GetName(), color )
		end

		DrawCenteredShadowedText( Vector2( Render.Width - 75, Render.Height - 75 - ((#players + 1) * 20) ), self.nameT, Color.White, 20 )
		if (self.outOfArena) then
			local text = "Вы покидаете арену!"
			local text_width = Render:GetTextWidth(text, TextSize.VeryLarge)
			local text_height = Render:GetTextHeight(text, TextSize.VeryLarge)
			local pos = Vector2((Render.Width - text_width)/2, (Render.Height - text_height - 200)/2)
			local posTw = Vector2((Render.Width - text_width)/2, (Render.Height - text_height - 198)/2)
			Render:DrawText(posTw, text, Color( 25, 25, 25, 150 ), TextSize.VeryLarge)
			Render:DrawText(pos, text, Color( 255, 69, 0 ), TextSize.VeryLarge)
			local text = self.vehicleHealthLost .. "% здоровья у транспорта потеряно. Вернитесь на Арену!"
			pos.y = pos.y + 45
			pos.x = (Render.Width - Render:GetTextWidth(text, TextSize.Default))/2
			Render:DrawText( pos, text, Color( 25, 25, 25, 150 ), TextSize.Default )
			Render:DrawText( pos, text, Color.White, TextSize.Default )
		end
		--OUT OF VEHICLE
		if (self.inVehicleTimer ~= nil) then
			Render:FillArea( Vector2(Render.Width - 110, 70), Vector2(Render.Width - 110, 110), Color( 0, 0, 0, 165 ) )
			local time = 20 - math.floor(math.clamp(self.inVehicleTimer:GetSeconds(), 0, 20 ))
			if time <= 0 then return end
            local text = tostring(time)
            local text_width = Render:GetTextWidth( text, TextSize.Huge )
            local text_height = Render:GetTextHeight( text, TextSize.Huge )
            local pos = Vector2( ( ( 110 - text_width )/2 ) + Render.Width - 110, ( text_height ) )
            Render:DrawText( pos, text, Color( 255, 69, 0 ), TextSize.Huge )
            pos.y = pos.y + 70
            pos.x = Render.Width - 98
            Render:DrawText( pos, "     Эй, вернулся!\nИначе проиграешь.", Color.White, 12 )
		end
	end
end

Derby = Derby()