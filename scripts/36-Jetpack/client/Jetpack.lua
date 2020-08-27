class "Jetpack"

function Jetpack:__init()
	self:initVars()
	Events:Subscribe( "UseJetpack", self, self.UseJetpack )
	Events:Subscribe( "Render", self, self.onRender )
	Events:Subscribe( "LocalPlayerInput", self, self.onLocalPlayerInput )
	Events:Subscribe( "InputPoll", self, self.onInputPoll )
	Events:Subscribe( "ModuleUnload", self, self.onModuleUnload )
end

function Jetpack:UseJetpack()
	Network:Send( "EnableJetpack" )
end

function Jetpack:initVars()
	self.jetpacksBottom = {}
	self.jetpacksTop = {}
	self.timer = Timer()
	self.impulse = Vector3.Zero
end

function Jetpack:onRender()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	local checked = {}
	local players = {LocalPlayer}

	for player in Client:GetStreamedPlayers() do
		table.insert(players, player)
	end

	for _, player in pairs( players ) do
		if IsValid(player) then
			local playerId = player:GetId() + 1
			if player:GetValue("JP") then
				if self.jetpacksBottom[playerId] then
					local angle = player:GetBoneAngle("ragdoll_Spine1")
					self.jetpacksBottom[playerId]:SetPosition( player:GetBonePosition("ragdoll_Spine1") + angle * Vector3( 0.001, 0.4, 0.2 ) )
					self.jetpacksBottom[playerId]:SetAngle(angle * Angle(0, 0, math.pi))
					self.jetpacksTop[playerId]:SetPosition( player:GetBonePosition("ragdoll_Spine1") + angle * Vector3( 0, -0.4, 0.2 ) )
					self.jetpacksTop[playerId]:SetAngle( angle )
					local velocity = player:GetLinearVelocity()
					ClientEffect.Play(AssetLocation.Game,
					{
						effect_id = (velocity.y > 1) and 41 or 42,
						position = player:GetBonePosition("ragdoll_Spine1") + angle * Vector3( 0, -0.5, 0.2 ) + velocity * 0.11,
						angle = angle * Angle( 0, 1.57, 0 ),
						timeout = 0.001
					})
				else
					self.jetpacksBottom[playerId] = ClientStaticObject.Create({
						model = "general.bl/rotor1-axelsmall.lod",
						collision = "",
						position = player:GetPosition(),
						angle = Angle(),
						fixed = true
					})
					self.jetpacksTop[playerId] = ClientStaticObject.Create({
						model = "general.bl/rotor1-axelsmall.lod",
						collision = "",
						position = player:GetPosition(),
						angle = Angle(),
						fixed = true
					})
				end
				checked[playerId] = true
			end
		end
    end

	for playerId, _ in pairs( self.jetpacksBottom ) do
		if not checked[playerId] then
			if IsValid(self.jetpacksBottom[playerId], false) then self.jetpacksBottom[playerId]:Remove() end
			if IsValid(self.jetpacksTop[playerId], false) then self.jetpacksTop[playerId]:Remove() end
			self.jetpacksBottom[playerId] = nil
			self.jetpacksTop[playerId] = nil
		end
	end

	if not LocalPlayer:GetValue("JP") then return end
	if self.impulse == Vector3.Zero then return end
	LocalPlayer:SetBaseState(AnimationState.SUprightIdle)
	LocalPlayer:SetAngle( Angle.Slerp( LocalPlayer:GetAngle(), Angle( Camera:GetAngle().yaw, 0, 0), 0.1 ) )
	self.impulse = self.impulse + Vector3( 0, math.sin(self.timer:GetSeconds()) * 0.02, 0 )
end

function Jetpack:onLocalPlayerInput( args )
	if not LocalPlayer:GetValue("JP") then return end
	if args.input == Action.UseItem then return false end
end

function Jetpack:onInputPoll()
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not LocalPlayer:GetValue("JP") then return end
	local velocity = Vector3.Zero
	local raycast = Physics:Raycast( LocalPlayer:GetPosition() + Vector3( 0, 0.1, 0 ), Vector3.Down, 0, 3, true )

	if self.impulse:Length() < 20 then
		if Input:GetValue(Action.HeliDecAltitude) > 0 then
			self.impulse = self.impulse + 0.6 * Vector3.Down
		end
		if Input:GetValue(Action.HeliIncAltitude) > 0 then
			self.impulse = self.impulse + 0.3 * Vector3.Up
		end
		if raycast.distance > 2 then
			if Input:GetValue(Action.MoveForward) > 0 then
				self.impulse = self.impulse + Angle(Camera:GetAngle().yaw, 0, 0) * (0.8 * Vector3.Forward)
			end
			if Input:GetValue(Action.MoveBackward) > 0 then
				self.impulse = self.impulse + Angle(Camera:GetAngle().yaw, 0, 0) * (0.8 * Vector3.Backward)
			end
			if Input:GetValue(Action.MoveLeft) > 0 then
				self.impulse = self.impulse + Angle(Camera:GetAngle().yaw, 0, 0) * (0.8 * Vector3.Left)
			end
			if Input:GetValue(Action.MoveRight) > 0 then
				self.impulse = self.impulse + Angle(Camera:GetAngle().yaw, 0, 0) * (0.8 * Vector3.Right)
			end
		end
	end

	self.impulse = self.impulse * 0.98
	velocity = velocity + self.impulse

	if Input:GetValue(Action.HeliIncAltitude) < 1 and raycast.distance < 2 then
		self.impulse = Vector3.Zero
		return
	end

	LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
	LocalPlayer:SetLinearVelocity( velocity )
end

function Jetpack:onModuleUnload()
	for playerId, _ in pairs( self.jetpacksBottom ) do
		if IsValid(self.jetpacksBottom[playerId], false) then self.jetpacksBottom[playerId]:Remove() end
		if IsValid(self.jetpacksTop[playerId], false) then self.jetpacksTop[playerId]:Remove() end
		self.jetpacksBottom[playerId] = nil
		self.jetpacksTop[playerId] = nil
	end
end

jetpack = Jetpack()