class "PDA"

PDA.ToggleDelay = 0.25

function PDA:__init()
	circletime = 0
	oldsize = Render.Height * 0.007

	InitTimer = Timer()
	CircleTimer = nil

	self.actions = {
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		[17] = true,
		[18] = true,
		[105] = true,
		[137] = true,
		[138] = true,
		[139] = true,
		[16] = true
	}

	extraction_enabled = true
	extraction_speed = 5000 -- meters per second

	world_fadeout_delay = 1000 -- milliseconds
	map_fadeout_delay = 1000 -- milliseconds
	world_fadein_delay = 1000 -- milliseconds

	ramka = true
	rendermap = true

	self.active            = false
	self.mouseDown         = false
	self.dragging          = false
	self.lastMousePosition = Mouse:GetPosition()
	
	MTSetWp = "[СКМ] / [1] - поставить точку назначения"
	MTPToggle = "[ПКМ] - показать/скрыть имена игроков"
	MTExtract = "[R] - запросить перемещение"

	labels = 0
	players = {}

	if not self.KeyUpEvent then
		self.KeyUpEvent = Events:Subscribe( "KeyUp", self, self.KeyUp )
	end

	Events:Subscribe( "Lang", self, self.Lang )
	Network:Subscribe( "PlayerUpdate", self, self.PlayerUpdate )
end

function PDA:Lang( args )
	MTSetWp = "[Middle Click] / [1] - Set Waypoint"
	MTPToggle = "[Right Click] - Show/Hide players names"
	MTExtract = "[R] - Request Travel"
end

function PDA:PlayerUpdate( args )
	players = args
end

function PDA:IsUsingGamepad()
	return Game:GetSetting(GameSetting.GamepadInUse) ~= 0
end

function PDA:Toggle()
	self.active = not self.active
	Mouse:SetVisible( not PDA:IsUsingGamepad() and self.active )
	if self.active then
		LocalPlayer:SetValue( "ServerMap", 1 )
		if not self.EventPostRender then
			self.EventPostRender = Events:Subscribe( "PostRender", self, self.PostRender )
		end
		if not self.LocalPlayerInputEvent then
			self.MouseDownEvent = Events:Subscribe( "MouseDown", self, self.MouseDown )
			self.MouseMoveEvent = Events:Subscribe( "MouseMove", self, self.MouseMove )
			self.MouseUpEvent = Events:Subscribe( "MouseUp", self, self.MouseUp )
			self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		end
		Events:Fire( "ToggleCamZoom", { zoomcam = false } )
		Network:Send( "MapShown" )
		border = false
		CircleTimer = Timer()
		timerF = Timer()
		FadeInTimer = Timer()
	else
		LocalPlayer:SetValue( "ServerMap", nil )
		if self.EventPostRender then
			Events:Unsubscribe( self.EventPostRender )
			self.EventPostRender = nil
		end
		if not world_fadein_timer then
			if self.LocalPlayerInputEvent then
				Events:Unsubscribe( self.MouseDownEvent )
				Events:Unsubscribe( self.MouseMoveEvent )
				Events:Unsubscribe( self.MouseUpEvent )
				Events:Unsubscribe( self.LocalPlayerInputEvent )
				self.MouseDownEvent = nil
				self.MouseMoveEvent = nil
				self.MouseUpEvent = nil
				self.LocalPlayerInputEvent = nil
			end
		end
		Events:Fire( "ToggleCamZoom", { zoomcam = true } )
		Network:Send( "MapHide" )
		timerF = nil
		CircleTimer = nil
		FadeOutTimer = nil
		DelayTimer = nil
		FadeInTimer = nil
		circletime = 0
		oldsize = 0
	end
end

function PDA:ExtractionSequence()
	if not extraction_sequence then return end
	if world_fadeout_timer then
		if world_fadeout_timer:GetMilliseconds() > world_fadeout_delay then
			Network:Send( "InitialTeleport", {position = next_position} )
			world_fadeout_timer = nil
			extraction_timer = Timer()
			teleporting = true
		end
	elseif teleporting then
		if LocalPlayer:GetPosition() ~= previous_position then
			teleporting = false
			loading = true
			border = false
			ramka = false
			rendermap = false
			if self.MouseDownEvent then
				Events:Unsubscribe( self.MouseDownEvent )
				Events:Unsubscribe( self.MouseUpEvent )
				self.MouseDownEvent = nil
				self.MouseUpEvent = nil
			end
		end
	elseif loading then
		if LocalPlayer:GetLinearVelocity() ~= Vector3.Zero then
			loading = false
		end
	end

	if extraction_timer then
		if extraction_timer:GetSeconds() > extraction_delay then
			extraction_timer = nil
			map_fadeout_timer = Timer()
		end
	elseif map_fadeout_timer then
		local dt = map_fadeout_timer:GetMilliseconds()
		local delay = map_fadeout_delay
		local alpha = math.clamp(1 - dt / delay, 0, 1)
		Map.Image:SetAlpha( alpha )
		Location.Icon.Sheet:SetAlpha( alpha )
		if dt > delay then map_fadeout_timer = nil end
	end

	if not world_fadeout_timer and not world_fadein_timer and not teleporting and not loading and not extraction_timer and not map_fadeout_timer then
		world_fadein_timer = Timer()
		local ray = Physics:Raycast( Vector3( next_position.x, 2100, next_position.z ), Vector3.Down, 0, 2100 )
		Network:Send( "CorrectedTeleport", {position = ray.position} )
	end

	if world_fadein_timer then
		if world_fadein_timer:GetMilliseconds() > world_fadein_delay then
			Events:Unsubscribe( extraction_sequence )
			Game:FireEvent( "ply.makevulnerable" )
			Map.Image:SetAlpha( 1 )
			Location.Icon.Sheet:SetAlpha( 1 )
			rendermap = true
			PDA:Toggle()
			border = true
			ramka = true
			world_fadein_timer = nil
			extraction_sequence = nil
			extraction_render = nil
			previous_position = nil
			next_position = nil
			if not self.KeyUpEvent then
				self.KeyUpEvent = Events:Subscribe( "KeyUp", self, self.KeyUp )
			end
		end
	end
end

function PDA:MouseDown( args )
	if self.active then
		self.mouseDown = args.button
	end

	self.lastMousePosition = Mouse:GetPosition()
end

function PDA:MouseMove( args )
	if self.active and self.mouseDown then
		Map.Offset = Map.Offset + ( (args.position - self.lastMousePosition) / Map.Zoom )
		self.dragging = true
	end

	self.lastMousePosition = args.position
end

function PDA:MouseUp( args )
	if self.mouseDown == args.button then
		if args.button == 2 then
			labels = labels < 1 and labels + 1 or 0
		end

		if args.button == 3 then
			Map:ToggleWaypoint( Map.ActiveLocation and Map.ActiveLocation.position or Map:ScreenToWorld( Mouse:GetPosition() ) )
		end

		self.mouseDown = false
		self.dragging = false
	end

	self.lastMousePosition = Mouse:GetPosition()
end

function PDA:KeyUp( args )
	if (args.key) == VirtualKey.F2 or string.char(args.key) == "M" and Game:GetState() == GUIState.Game then
		PDA:Toggle()

		if self.active then
			Map.Zoom = 1.5

			Map.Image:SetSize( Vector2.One * Render.Height * Map.Zoom )

			Map.Offset = Vector2( LocalPlayer:GetPosition().x, LocalPlayer:GetPosition().z ) / 16384
			Map.Offset = -Vector2( Map.Offset.x * (Map.Image:GetSize().x / 2), Map.Offset.y * (Map.Image:GetSize().y / 2) ) / Map.Zoom
		end
	end

	if self.active and Map.ActiveLocation and string.char(args.key) == "R" then
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		PDA:Toggle()
		--and Map.ActiveLocation
		Events:Fire( "CastCenterText", { text = "Вы не можете использовать это здесь!", time = 3, color = Color.Red } )
		return
	end
		local position = Map:ScreenToWorld(Mouse:GetPosition())
		if position.x >= -16384 and position.x <= 16383 and position.z >= -16384 and position.z <= 16383 then
			previous_position = LocalPlayer:GetPosition()
			next_position = position
			extraction_delay = Vector3.Distance( previous_position, next_position ) / extraction_speed
			extraction_sequence = Events:Subscribe( "PreTick", self, self.ExtractionSequence )
			world_fadeout_timer = Timer()
			Game:FireEvent( "ply.makeinvulnerable" )
			CircleTimer = nil
			FadeOutTimer = nil
			DelayTimer = nil
			FadeInTimer = nil
			circletime = 0
			oldsize = 0
			Map.Zoom = 1
			Map.Offset = Vector2.Zero
			Mouse:SetVisible( false )
			if self.LocalPlayerInputEvent then
				Events:Unsubscribe( self.LocalPlayerInputEvent )
				Events:Unsubscribe( self.MouseMoveEvent )
				Events:Unsubscribe( self.KeyUpEvent )
				self.LocalPlayerInputEvent = nil
				self.MouseMoveEvent = nil
				self.KeyUpEvent = nil
			end
		end
	end

	if self.active and string.char(args.key) == "1" then
		Map:ToggleWaypoint( Map.ActiveLocation and Map.ActiveLocation.position or Map:ScreenToWorld( Mouse:GetPosition() ) )
	end
end

function PDA:LocalPlayerInput(args)
	if self.active then
		if self.actions[args.input] then
			return false
		end
		if ( args.input == Action.GuiPDAZoomIn or args.input == Action.GuiPDAZoomOut ) and args.state > 0.15 then
			local oldZoom = Map.Zoom

			Map.Zoom = math.max(math.min(Map.Zoom - (0.1 * args.state * (PDA:IsUsingGamepad() and -1 or 1) * (args.input == Action.GuiPDAZoomIn and 1 or -1)), 3), 1)

			local zoomFactor  = Map.Zoom - oldZoom
			local zoomProduct = oldZoom * oldZoom + oldZoom * zoomFactor
			local zoomTarget  = ((PDA:IsUsingGamepad() and (Render.Size / 2) or Mouse:GetPosition()) - (Render.Size / 2))

			Map.Offset = Map.Offset - ((zoomTarget * zoomFactor) / zoomProduct)
		elseif args.input == Action.GuiAnalogDown and args.state > 0.15 then
			Map.Offset = Map.Offset - (Vector2.Down * 5 * math.pow(args.state, 2) / Map.Zoom)
		elseif args.input == Action.GuiAnalogUp and args.state > 0.15 then
			Map.Offset = Map.Offset - (Vector2.Up * 5 * math.pow(args.state, 2) / Map.Zoom)
		elseif args.input == Action.GuiAnalogLeft and args.state > 0.15 then
			Map.Offset = Map.Offset - (Vector2.Left * 5 * math.pow(args.state, 2) / Map.Zoom)
		elseif args.input == Action.GuiAnalogRight and args.state > 0.15 then
			Map.Offset = Map.Offset - (Vector2.Right * 5 * math.pow(args.state, 2) / Map.Zoom)
		end
	end
end

function PDA:PostRender()
	if Game:GetState() ~= GUIState.Game then
		if self.active then
			PDA:Toggle()
		end

		return
	end

	if extraction_sequence then
		if world_fadeout_timer then
			local dt = world_fadeout_timer:GetMilliseconds()
			local delay = world_fadeout_delay
			if dt < delay then
				Render:FillArea( Vector2.Zero, Render.Size, self:ColorA( Color.Black, 255 * ( dt / delay ) ) )
			end
		end

		if teleporting or loading or extraction_timer or map_fadeout_timer then
			Render:FillArea( Vector2.Zero, Render.Size, Color.Black )
		end

		if world_fadein_timer then
			local dt = world_fadein_timer:GetMilliseconds()
			local delay = world_fadein_delay
			if dt < delay then
				Render:FillArea( Vector2.Zero, Render.Size, self:ColorA( Color.Black, 255 * ( 1 - dt / delay ) ) )
			end
		end
	end

	if self.active then
		if self.sound then
			self.sound:SetPosition( Camera:GetPosition() )
		end
		Map:Draw()
	end
end

function PDA:ColorA( color, alpha )
	color.a = alpha
	return color
end

PDA = PDA()