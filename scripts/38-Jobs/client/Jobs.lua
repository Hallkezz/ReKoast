class 'PanauDrivers'

function PanauDrivers:DrawShadowedText( pos, text, colour, size, scale )
    if scale == nil then scale = 1.0 end
    if size == nil then size = TextSize.Default end

    Render:DrawText( pos, text, colour, size, scale )
end

function PanauDrivers:__init()
	self.markers = true
	self.flooder = true
	self.isVisible = true
	self.arrowVisible = true
	self.locationsVisible = true
	self.locationsAutoHide = true
	self.locations = {}
	self.availableJob = nil
	availableJobKey = 0
	self.job = nil
	self.jobUpdateTimer = Timer()
	self.jobCompleteTimer = Timer()
	self.opcolor = Color( 251, 184, 41 )
	self.jobcolor = Color( 192, 255, 192 )

	self.configW = Window.Create()
	self.configW:SetSize( Vector2( 400, 115 ) )
	self.configW:SetPosition( (Render.Size - self.configW:GetSize())/2 )
	self.configW:SetTitle( "Настройки работы курьера" )
	self.configW:SetVisible( false )

	local visibleCheck = LabeledCheckBox.Create( self.configW )
	local arrowCheck = LabeledCheckBox.Create( self.configW )
	local locationCheck = LabeledCheckBox.Create( self.configW )
	local locationAutoCheck = LabeledCheckBox.Create( self.configW )

    visibleCheck:SetSize( Vector2( 300, 20 ) )
    visibleCheck:SetDock( GwenPosition.Top )
    visibleCheck:GetLabel():SetText( "Видимый" )
    visibleCheck:GetCheckBox():SetChecked( self.isVisible )
    visibleCheck:GetCheckBox():Subscribe( "CheckChanged", 
        function() self.isVisible = visibleCheck:GetCheckBox():GetChecked() end )

    arrowCheck:SetSize( Vector2( 300, 20 ) )
    arrowCheck:SetDock( GwenPosition.Top )
    arrowCheck:GetLabel():SetText( "Показывают зеленую стрелку" )
    arrowCheck:GetCheckBox():SetChecked( self.arrowVisible )
    arrowCheck:GetCheckBox():Subscribe( "CheckChanged", 
        function() self.arrowVisible = arrowCheck:GetCheckBox():GetChecked() end )

    locationCheck:SetSize( Vector2( 300, 20 ) )
    locationCheck:GetLabel():SetText( "Показать местоположения" )
    locationCheck:SetDock( GwenPosition.Top )
    locationCheck:GetCheckBox():SetChecked( self.locationsVisible )
    locationCheck:GetCheckBox():Subscribe( "CheckChanged", 
        function() self.locationsVisible = locationCheck:GetCheckBox():GetChecked() end )

    locationAutoCheck:SetSize( Vector2( 300, 20 ) )
    locationAutoCheck:SetDock( GwenPosition.Top )
    locationAutoCheck:GetLabel():SetText( "Автоматическое скрытие местоположений при запуске задания" )
    locationAutoCheck:GetCheckBox():SetChecked( self.locationsAutoHide )
    locationAutoCheck:GetCheckBox():Subscribe( "CheckChanged", 
        function() self.locationsAutoHide = locationAutoCheck:GetCheckBox():GetChecked() end )

	self.window = Window.Create()
	self.window:SetSize( Vector2( 300, 110 ))
	self.window:SetPositionRel( Vector2( 0.5, 0.8 ) - self.window:GetSizeRel()/2 )
	self.window:SetTitle("Работа в Панау")
	self.window:SetVisible( false )

	self.windowL1 = Label.Create(self.window, "job description")
	self.windowL2 = Label.Create(self.window, "job money")
	self.windowL3 = Label.Create(self.window, "job vehicle")
	self.windowButton = Button.Create(self.window, "job start")

	self.windowL1:SetText( "-" )
	self.windowL1:SetSize( Vector2( 290, 30 ) )
	self.windowL1:SetPosition( Vector2( 0, 50 ) )
	self.windowL2:SetText( "Награда: Параша" )
	self.windowL2:SetSize( Vector2( 290, 16 ))
	self.windowL2:SetPosition( Vector2( 0, 18 ))
	self.windowL3:SetText( "Транспорт: Вилка" )
	self.windowL3:SetSize( Vector2( 290, 16 ))
	self.windowL3:SetPosition( Vector2( 0, 34 ))
	self.windowButton:SetText( "Нажмите J чтобы начать" )
	self.windowButton:SetSize( Vector2( 290, 16 ) )

	Network:Subscribe( "Locations", self, self.Locations )
	Network:Subscribe( "Jobs", self, self.Jobs )
	Network:Subscribe( "JobStart", self, self.JobStart )
	Network:Subscribe( "JobFinish", self, self.JobFinish )
	Network:Subscribe( "JobsUpdate", self, self.JobsUpdate )
	Network:Subscribe( "JobCancel", self, self.JobCancel )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "Render", self, self.RenderText )
	Events:Subscribe( "GameRender", self, self.GameRender )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Network:Subscribe( "Active", self, self.Active )
end

function PanauDrivers:Active()
	if self.configW:GetVisible() == true then
		self.configW:SetVisible( false )
	else 
		self.configW:SetVisible( true )
	end
	return false
end

function PanauDrivers:Locations( args )
	self.locations = args
end

function PanauDrivers:Jobs( args )
	self.jobsTable = args
end

function PanauDrivers:JobsUpdate( args )
	self.jobsTable[args[1]] = args[2]
end

function PanauDrivers:JobStart( args )
	self.job = args
	Waypoint:SetPosition(self.locations[self.job.destination].position)
	if self.locationsAutoHide == true then
		timerF = Timer()
		textF = "Задание начато!"
		self.sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 25,
			sound_id = 47,
			position = Camera:GetPosition(),
			angle = Camera:GetAngle()
		})

		self.sound:SetParameter(0,1)
		JobsColor = Color( 0, 255, 0 )
		self.locationsVisible = false
	end
end

function PanauDrivers:JobFinish( args )
	if self.job != nil then
		self.markers = true
		timerF = Timer()
		textF = "Задание выполнено!"
		self.sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 25,
			sound_id = 45,
			position = Camera:GetPosition(),
			angle = Camera:GetAngle()
		})
		self.sound:SetParameter(0,1)
		self.flooder = true
		JobsColor = Color( 0, 255, 0 )
		Waypoint:Remove()
		self.job = nil
		Game:FireEvent( "msy.factionmission.completed" )
	end
	if self.locationsAutoHide == true then
		self.locationsVisible = true
	end
end

function PanauDrivers:JobCancel( args )
	if self.job != nil then
		self.markers = true
		timerF = Timer()
		textF = "Задание провалено!"
		self.sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 25,
			sound_id = 46,
			position = Camera:GetPosition(),
			angle = Camera:GetAngle()
		})
		self.sound:SetParameter(0,1)
		self.flooder = true
		JobsColor = Color.Red
		Waypoint:Remove()
		self.job = nil
	end
	if self.locationsAutoHide == true then
		self.locationsVisible = true
	end
end

function PanauDrivers:PreTick( args )
	if self.jobCompleteTimer:GetSeconds() > 1 and self.job != nil and LocalPlayer:GetVehicle() != nil then
		self.jobCompleteTimer:Restart()
		pVehicle = LocalPlayer:GetVehicle()
		jDist = self.locations[self.job.destination].position:Distance( pVehicle:GetPosition() )
		if jDist < 20 then
			Network:Send( "CompleteJob", nil )
		end
	end
end

function PanauDrivers:KeyUp( a )
	if Game:GetState() ~= GUIState.Game then return end
	local args = {}
	args.job = self.availableJobKey
	if a.key == string.byte("J") and args.job != 0 then
		Network:Send( "TakeJob", args )
		self.windowButton:SetTextColor( Color( 255, 0, 0 ) )
	else
		self.windowButton:SetTextColor( Color( 255, 255, 255 ) )
		self.flooder = true
	end
end

function PanauDrivers:LocalPlayerInput( a )
	if Game:GetState() ~= GUIState.Game then return end
	local args = {}
	args.job = self.availableJobKey
	if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
		if self.flooder then
			if a.input == Action.EquipBlackMarketBeacon and args.job != 0 then
				Network:Send( "TakeJob", args )
				self.windowButton:SetTextColor( Color( 255, 0, 0 ) )
				self.flooder = false
			else
				self.windowButton:SetTextColor( Color( 255, 255, 255 ) )
			end
		end
	end
end

function PanauDrivers:DrawLocation(k, v, dist, dir, jobDistance)
	if self.locationsVisible == true and dist <= 100 and self.job == nil then
		t2 = Transform3()
		local upAngle = Angle(0, math.pi/2, 0)
		t2:Translate(v.position):Rotate(upAngle)
		Render:SetTransform(t2)
		Render:FillCircle( Vector3( 0, 0, 0 ), 2, Color( 255, 255, 255, 10 ) )
	end
end	

function PanauDrivers:DrawLocation2(k, v, dist, dir, jobDistance)
	local pos = v.position + Vector3( 0, 3, 0 )
	local angle = Angle( Camera:GetAngle().yaw, 0, math.pi ) * Angle( math.pi, 0, 0 )
	
	local textSize = 20
	local textScale = 0.04
	local textAlpha = 255
	if dist <= 50 then
		textAlpha = 255
		textScale = 0.02
	elseif dist <= 60 then
		textScale = 0.03
	elseif dist <= 70 then
		textScale = 0.04
	else
		textAlpha = 255
	end

	local text = v.name
	local textBoxScale = Render:GetTextSize( text, textSize )

	local t = Transform3()
	t:Translate( pos )
	t:Scale( textScale )
    t:Rotate( angle )
    t:Translate( -Vector3( textBoxScale.x, textBoxScale.y, 0 )/2 )

    Render:SetTransform( t )

	if dist <= 100 and self.job == nil then
		if self.locationsVisible == true then
			self:DrawShadowedText( Vector3( 0, 0, 0 ), text, Color( 67, 254, 255, textAlpha ), textSize ) end

		if self.locationsVisible == true then
			if self.job == nil then
				local arrowColor = Color( 0, 0, 0 , 128 )
				if jobDistance < 1000 then
					arrowColor = Color( 64, 255, 128, 58 )
				elseif jobDistance < 2000 then
					arrowColor = Color( 128, 255, 196, 58 )
				elseif jobDistance < 4000 then
					arrowColor = Color( 128, 255, 0, 58 )
				elseif jobDistance < 6000 then
					arrowColor = Color( 255, 255, 0, 58 )
				elseif jobDistance < 8000 then
					arrowColor = Color( 255, 128, 0, 58 )
				elseif jobDistance < 10000 then
					arrowColor = Color( 255, 128, 0, 58 )
				elseif jobDistance < 14000 then
					arrowColor = Color( 255, 0, 0, 58 )
				else
					arrowColor = Color( 128, 0, 255, 58 )
				end
				Render:ResetTransform()
			end
		end
	end

	Render:ResetTransform()

	if dist <= 4 and self.job == nil then
		local theJob = self.jobsTable[k]
		if self.jobUpdateTimer:GetSeconds() > 1 then
			self.windowL1:SetText( theJob.description )
			self.windowL1:SetTextColor( self.jobcolor )
			self.windowL2:SetText( "Награда: $" .. tostring(theJob.reward) )
			self.windowL2:SetTextColor( self.opcolor )
			self.windowL3:SetText( "Транспорт: " .. Vehicle.GetNameByModelId(theJob.vehicle) )
			self.jobUpdateTimer:Restart()
		end
		self.window:SetVisible( true )
		self.availableJobKey = k
		self.availableJob = theJob
	end
end

function PanauDrivers:RenderText()
	if Game:GetState() ~= GUIState.Game then return end

	if timerF and textF then
		alpha = 4

	if timerF:GetSeconds() > 5 and timerF:GetSeconds() < 6 then
		alpha = 5 - (timerF:GetSeconds() - 1)
	elseif timerF:GetSeconds() >= 6 then
		timerF = nil
		textF = nil
		return
	end
		text_width = Render:GetTextWidth( textF, 48 )
		pos_0 = Vector2(
		( Render.Width - text_width)/2,
		( Render.Height)/2.5 )
		col = Copy( JobsColor )
		col.a = col.a * alpha

		colS = Copy( Color( 0, 0, 0, 80 ) )
		colS.a = colS.a * alpha	

		Render:SetFont( AssetLocation.SystemFont, "Impact" )
		Render:DrawText( pos_0 + Vector2.One, textF, colS, 48 )
		Render:DrawText( pos_0, textF, col, 48 )
	end
end

function PanauDrivers:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.isVisible == false then return end
	Render:SetFont(AssetLocation.SystemFont, "Impact")

	if self.sound then
		self.sound:SetPosition( Camera:GetPosition() )
	end

	if self.jobsTable != nil then
		for k, v in ipairs(self.locations) do
			local camPos = Camera:GetPosition()
			local jobToRender = self.jobsTable[k]
			if v.position.x > camPos.x - 1028 and v.position.x < camPos.x + 1028 and v.position.z > camPos.z - 1028 and 	v.position.z < camPos.z + 1028 and jobToRender.direction != nil then
				self:DrawLocation( k, v, v.position:Distance2D( Camera:GetPosition()), jobToRender.direction, jobToRender.distance )
				local mapPos    = Render:WorldToMinimap( Vector3( v.position.x, v.position.y, v.position.z ) )
				if self.markers then
					Render:FillCircle( mapPos, 3, Color( 30, 144, 022, Game:GetSetting(4) * 2.25 ) )
					Render:FillCircle( mapPos, 2,  Color( 175, 238, 238, Game:GetSetting(4) * 2.25 ) )
				end
			end
		end
	end

	if self.job != nil then
		self.markers = false
		local textPos = Vector2( Render.Width / 2, Render.Height * 0.08 )
		local text = "● Цель: " .. self.job.description
		textPos = textPos - Vector2( Render:GetTextWidth(text) / 2, 0 )
		Render:DrawText( textPos + Vector2.One, text, Color( 0, 0, 0, 80 ) )
		Render:DrawText( textPos, text, Color( 192, 255, 192 ))
		--draw destination circle
		destPos = self.locations[self.job.destination].position
		destDist = Vector3.Distance(destPos, LocalPlayer:GetPosition())
		if destDist < 500 then
			t2 = Transform3()
			local upAngle = Angle(0, math.pi/2, 0)
			t2:Translate(destPos):Rotate(upAngle)
			Render:SetTransform(t2)
			Render:FillCircle( Vector3( 0, 0 ,0 ), 10, Color( 64, 255, 64, 64 ) )
		end

	pVehicle = LocalPlayer:GetVehicle()
		if pVehicle != nil and self.arrowVisible == true then
			local multiArrow = 1
			while (multiArrow > 0) do
				arrowDir = pVehicle:GetPosition() - destPos
				arrowDir:Normalize()
				arrowDir = arrowDir + Vector3( 0, .1, 0 )
				arrowDir.y = -arrowDir.y
				arrowDir.z = -arrowDir.z
				arrowDir.x = -arrowDir.x
				local arrowAxis = Vector3( 0, 1, 0 )
				if (multiArrow == 3) then
					arrowAxis = Vector3( 0, 0, 1 )
				end
				if (multiArrow == 2) then
					arrowAxis = Vector3( 1, 0, 0 )
				end
				dirCp = arrowDir:Cross( arrowAxis )
				dirCn = arrowAxis:Cross( arrowDir )
				Render:ResetTransform()
				--make the arrow segments
				arrowScale = Render.Height * .05
				arrow1 = dirCp * arrowScale * 2
				arrow2 = dirCn * arrowScale * 2
				arrow3 = Vector3( 0, 0, 0 ) - ( arrowDir * arrowScale * 2 )
				shaft1 = dirCp * arrowScale
				shaft2 = dirCn * arrowScale
				shaft3 = shaft1 + ( arrowDir * arrowScale * 2 )
				shaft4 = shaft2 + ( arrowDir * arrowScale * 2 )
				--multiply by camera angle to flatten everything relative to the camera
				local ang = Camera:GetAngle():Inverse()
				arrow1 = ang * arrow1
				arrow2 = ang * arrow2
				arrow3 = ang * arrow3
				shaft1 = ang * shaft1
				shaft2 = ang * shaft2
				shaft3 = ang * shaft3
				shaft4 = ang * shaft4
				--turn 3d in to 2d
				center = Vector2( Render.Width / 2, Render.Height / 3 )
				arrow1 = Vector2( -arrow1.x, arrow1.y) + center
				arrow2 = Vector2( -arrow2.x, arrow2.y) + center
				arrow3 = Vector2( -arrow3.x, arrow3.y) + center
				shaft1 = Vector2( -shaft1.x, shaft1.y ) + center
				shaft2 = Vector2( -shaft2.x, shaft2.y ) + center
				shaft3 = Vector2( -shaft3.x, shaft3.y ) + center
				shaft4 = Vector2( -shaft4.x, shaft4.y ) + center
				
				local arrowColor = Color( 5, 255, 64, 128 )
				Render:FillTriangle( arrow1, arrow2, arrow3, arrowColor )
				Render:FillTriangle( shaft1, shaft2, shaft3, arrowColor )
				Render:FillTriangle( shaft2, shaft3, shaft4, arrowColor )
				
				multiArrow = multiArrow - 1
			end
		end
	end
end

function PanauDrivers:GameRender()
	Render:SetFont( AssetLocation.SystemFont, "Impact" )
	Mouse:SetVisible( self.configW:GetVisible() )
	availableJob = nil
	self.window:SetVisible( false )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.isVisible == false then return end

	if self.jobsTable != nil then
		for k, v in ipairs(self.locations) do
			local camPos = Camera:GetPosition()
			local jobToRender = self.jobsTable[k]
			if v.position.x > camPos.x - 1028 and v.position.x < camPos.x + 1028 and v.position.z > camPos.z - 1028 and 	v.position.z < camPos.z + 1028 and jobToRender.direction != nil then
				self:DrawLocation2( k, v, v.position:Distance2D( Camera:GetPosition()), jobToRender.direction, jobToRender.distance )
			end
		end
	end	
end

panaudrivers = PanauDrivers()