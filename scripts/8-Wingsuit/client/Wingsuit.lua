class 'Wingsuit'

function Wingsuit:__init()
	self.superman = false 
	self.rolls = true
	self.grapple = true
	self.Display = true
	self.score = 0

	self.default_speed = 50
	self.default_vertical_speed = -5

	self.max_speed = 139
	self.min_speed = 0

	self.BrakeText = false

	self.BoostColor = Color( 255, 125, 125, 200 )

	self.tether_length = 150 -- meters
	self.yaw_gain = 1.5
	self.yaw = 0

	self.camera = 1

	self.speed = self.default_speed
	self.vertical_speed = self.default_vertical_speed

	self.blacklist = {
		actions = { -- Actions to block while wingsuit is active
			[Action.LookUp] = true,
			[Action.LookDown] = true,
			[Action.LookLeft] = true,
			[Action.LookRight] = true
		},
		animations = { -- Disallow activation during these base states
			[AnimationState.SDead] = true,
			[AnimationState.SUnfoldParachuteHorizontal] = true,
			[AnimationState.SUnfoldParachuteVertical] = true,
			[AnimationState.SPullOpenParachuteVertical] = true
		}
	}

	self.whitelist = { -- Allow instant activation during these base states
		animations = {
			[AnimationState.SSkydive] = true,
			[AnimationState.SParachute] = true
		}
	}

	self.timers = {
		grapple = Timer()
	}

	self.subs = {}

	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "KeyUp", self, self.Activate )

	Network:Subscribe( "0003", self, self.onFlyingAttempt )

	self.tWidg = "Лучший Полет:"
	self.tWidgTw = "Лучший "
	self.tDrift = "Полет: "
	self.tRecord = "Личный рекорд полета на вингсьюте: "
end

function Wingsuit:onFlyingAttempt( data )
	self.attempt = data
	self.attempt[3] = 4
end

function Wingsuit:GetOption( args )
	self.Display = args.actDr
	self.activ = args.actPM
end

function Wingsuit:Lang( args )
	self.tWidg = "Best Flyihg:"
	self.tWidgTw = "Best "
	self.tDrift = "Flying: "
	self.tRecord = "Personal flying record: "
end

function Wingsuit:Render( args )
	local object = NetworkObject.GetByName("Flying")

	if self.Display and Game:GetState() == GUIState.Game then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		if Game:GetSetting(4) >= 1 then
			if object and LocalPlayer:GetValue("GetWidget") == 3 then
				local record = object:GetValue("S")
				local text = self.tWidg
				local position = Vector2( 20, Render.Height * 0.4 )
				Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position + Vector2( Render:GetTextWidth( self.tWidgTw, 15 ), 0 ), self.tDrift, Color( 255, 165, 0, Game:GetSetting(4) * 2.25 ), 15 )
				local height = Render:GetTextHeight("A") * 1.2
				position.y = position.y + height
				local record = object:GetValue("S")
				if record then
					text = tostring(record) .. " - " .. object:GetValue("N")
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position, text, Color( 0, 150, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position + Vector2( Render:GetTextWidth( text, 16 ), 0 ), " - ", Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record ) .. " - "
					Render:DrawText( position + Vector2( Render:GetTextWidth( text, 16 ), 0 ), object:GetValue("N"), object:GetValue("C") + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), 16 )
					text = ""
					for i = 1, object:GetValue("E") do text = text .. ">" end
					position.y = position.y + height * 0.95
					Render:SetFont( AssetLocation.Disk, "LeagueGothic.ttf" )
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 13 )
					Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 13 )
					if LocalPlayer:GetValue( "SystemFonts" ) then
						Render:SetFont( AssetLocation.SystemFont, "Impact" )
					end
					if self.attempt then
						local player = Player.GetById( self.attempt[2] - 1 )
						if player then
							position.y = position.y + height * 0.6
							local alpha = math.min(self.attempt[3], 1)
							text = tostring( self.attempt[1] ) .. " - " .. player:GetName()
							Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 * alpha ), 16 )
							Render:DrawText( position, text, Color( 255, 255, 255, 255 * alpha ), 16 )
							text = tostring( self.attempt[1] )
							Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, 150 * alpha ), 16 )
							Render:DrawText( position, text, Color( 240, 220, 70, 255 * alpha ), 16 )
							self.attempt[3] = self.attempt[3] - 0.02
							if self.attempt[3] < 0.02 then self.attempt = nil end
						end
					end
				else
					text = "–"
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					Render:DrawText( position, text, Color( 200, 200, 200, Game:GetSetting(4) * 2.25 ), 16 )
				end
			end
		end
	end
end

function Wingsuit:LocalPlayerInput( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.activ then
		if Input:GetValue(Action.EquipLeftSlot) > 0 and not self.subs.camera and not LocalPlayer:GetVehicle() then
			if Game:GetSetting(GameSetting.GamepadInUse) == 1 then
				local bs = LocalPlayer:GetBaseState()
				if self.blacklist.animations[bs] then return end

				if not self.timers.activate or self.timers.activate:GetMilliseconds() > 300 then
					self.timers.activate = Timer()
				elseif self.timers.activate:GetMilliseconds() < 500 then
					self.timers.activate = nil

					if self.whitelist.animations[bs] then
						self.timers.camera_start = Timer()
						self.speed = self.default_speed
						-- self.camera = 1
						LocalPlayer:SetBaseState(AnimationState.SSkydive)
						LocalPlayer:SetValue( "Wingsuit", true )
						self.subs.wings = Events:Subscribe( "GameRenderOpaque", self, self.DrawWings )
						self.subs.velocity = Events:Subscribe( "Render", self, self.SetVelocity )
						self.subs.camera = Events:Subscribe( "CalcView", self, self.Camera )
						self.subs.glide = Events:Subscribe( "InputPoll", self, self.Glide )
						self.subs.input = Events:Subscribe( "LocalPlayerInput", self, self.Input )
					elseif self.superman then
						local timer = Timer()
						self.timers.camera_start = Timer()
						self.speed = self.default_speed
						-- self.camera = 1
						self.subs.camera = Events:Subscribe( "CalcView", self, self.Camera )
						self.subs.input = Events:Subscribe( "LocalPlayerInput", self, self.Input )
						self.subs.wings = Events:Subscribe( "GameRenderOpaque", self, self.DrawWings )
						self.subs.delay = Events:Subscribe( "PreTick", function()
							local dt = timer:GetMilliseconds()
							LocalPlayer:SetBaseState(AnimationState.SSkydive)
							LocalPlayer:SetLinearVelocity( LocalPlayer:GetAngle() * math.lerp( Vector3( 0, self.speed, 0 ), Vector3( 0, 0, -self.speed ), dt / 1000) )
							if dt > 1000 then
								Events:Unsubscribe( self.subs.delay )
								self.subs.delay = nil
								self.subs.velocity = Events:Subscribe( "Render", self, self.SetVelocity )
							end
						end )
					end
				end
			end
		end
	end
end

function Wingsuit:Activate( args )
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.activ then
		if args.key == VirtualKey.Shift and not self.subs.camera and not LocalPlayer:GetVehicle() then
			local bs = LocalPlayer:GetBaseState()
			if self.blacklist.animations[bs] then return end

			if not self.timers.activate or self.timers.activate:GetMilliseconds() > 300 then
				self.timers.activate = Timer()
			elseif self.timers.activate:GetMilliseconds() < 500 then
				self.timers.activate = nil

				if self.whitelist.animations[bs] then
					if not self.RCtimer then
						self.RCtimer = Timer()
					end
					self.timers.camera_start = Timer()
					self.speed = self.default_speed
					-- self.camera = 1
					LocalPlayer:SetBaseState(AnimationState.SSkydive)
					LocalPlayer:SetValue( "Wingsuit", true )
					self.subs.wings = Events:Subscribe( "GameRenderOpaque", self, self.DrawWings )
					self.subs.velocity = Events:Subscribe( "Render", self, self.SetVelocity )
					self.subs.camera = Events:Subscribe( "CalcView", self, self.Camera )
					self.subs.glide = Events:Subscribe( "InputPoll", self, self.Glide )
					self.subs.input = Events:Subscribe( "LocalPlayerInput", self, self.Input )
				elseif self.superman then
					local timer = Timer()
					self.timers.camera_start = Timer()
					self.speed = self.default_speed
					-- self.camera = 1
					self.subs.camera = Events:Subscribe( "CalcView", self, self.Camera )
					self.subs.input = Events:Subscribe( "LocalPlayerInput", self, self.Input )
					self.subs.wings = Events:Subscribe( "GameRenderOpaque", self, self.DrawWings )
					self.subs.delay = Events:Subscribe( "PreTick", function()
						local dt = timer:GetMilliseconds()
						LocalPlayer:SetBaseState(AnimationState.SSkydive)
						LocalPlayer:SetLinearVelocity( LocalPlayer:GetAngle() * math.lerp( Vector3( 0, self.speed, 0 ), Vector3( 0, 0, -self.speed ), dt / 1000) )
						if dt > 1000 then
							Events:Unsubscribe( self.subs.delay )
							self.subs.delay = nil
							self.subs.velocity = Events:Subscribe( "Render", self, self.SetVelocity )
						end
					end )
				end
			end
		elseif args.key == VirtualKey.Control and self.subs.camera and not self.timers.camera_start and not self.timers.camera_stop then
			if not self.timers.activate or self.timers.activate:GetMilliseconds() > 300 then
				self.timers.activate = Timer()
			elseif self.timers.activate:GetMilliseconds() < 500 then
				local ray = Physics:Raycast( LocalPlayer:GetPosition(), LocalPlayer:GetAngle() * Vector3( 0, -1, -1 ), 0, 50 )
				if ray.distance < 50 then
					LocalPlayer:SetBaseState(AnimationState.SFall)
				else
					LocalPlayer:SetBaseState(AnimationState.SSkydive)
				end
				self.timers.camera_stop = Timer()
			end
		elseif args.key == string.byte("C") and self.subs.camera then
			if self.camera < 5 then
				self.camera = self.camera + 1
			else
				self.camera = 1
			end
		end
	end
end

function Wingsuit:DrawWings()
	self.dt = math.abs((Game:GetTime() + 12) % 24 - 12) / 12

	local bones = LocalPlayer:GetBones()
	local color = LocalPlayer:GetColor()

	local r = math.lerp( 0.1 * color.r, color.r, self.dt )
	local g = math.lerp( 0.1 * color.g, color.g, self.dt )
	local b = math.lerp( 0.1 * color.b, color.b, self.dt )

	color = Color( r, g, b )

	Render:FillTriangle(
		bones.ragdoll_RightArm.position, 
		bones.ragdoll_RightForeArm.position,
		bones.ragdoll_RightUpLeg.position, 
		color
	)

	Render:FillTriangle(
		bones.ragdoll_LeftArm.position, 
		bones.ragdoll_LeftForeArm.position,
		bones.ragdoll_LeftUpLeg.position, 
		color
	)

	Render:DrawLine(
		bones.ragdoll_RightForeArm.position,
		bones.ragdoll_RightUpLeg.position,
		Color.Black
	)

	Render:DrawLine(
		bones.ragdoll_LeftForeArm.position,
		bones.ragdoll_LeftUpLeg.position,
		Color.Black
	)
end

function Wingsuit:SetVelocity()
	local bs = LocalPlayer:GetBaseState()

	if bs ~= AnimationState.SSkydive and bs ~= AnimationState.SSkydiveDash then
		self:Abort()
		return
	end

	if self.superman then
		if Input:GetValue(Action.Dash) > 0 and self.speed < self.max_speed then
			self.speed = self.speed + 0.5
		elseif Key:IsDown(VirtualKey.Control) and self.speed > self.min_speed then
			self.speed = self.speed - 1
		end
		local speed = self.speed - math.sin(LocalPlayer:GetAngle().pitch) * 20
		LocalPlayer:SetLinearVelocity( LocalPlayer:GetAngle() * Vector3( 0, 0, -speed ) )
	else
		self.score =math.ceil(self.RCtimer:GetSeconds() )
		local speed = self.speed - math.sin(LocalPlayer:GetAngle().pitch) * 20
		LocalPlayer:SetLinearVelocity( LocalPlayer:GetAngle() * Vector3( 0, 0, -speed ) + Vector3( 0, self.vertical_speed, 0 ) )
	end

	if not self.rolls or self.subs.grapple then return end

	if Input:GetValue(Action.MoveLeft) > 0 then
		if not self.roll_left then
			self.roll_left = true
			if not self.timers.roll_left then
				self.timers.roll_left = Timer()
			elseif self.timers.roll_left:GetMilliseconds() < 500 then
				if not self.subs.roll_left then
					local timer = Timer()
					LocalPlayer:SetBaseState(AnimationState.SSkydiveDash)
					self.subs.roll_left = Events:Subscribe( "PreTick", function()
						if timer:GetMilliseconds() > 750 then
							LocalPlayer:SetBaseState(AnimationState.SSkydive)
							Events:Unsubscribe( self.subs.roll_left )
							self.subs.roll_left = nil
						end
					end )
				end
				self.timers.roll_left = nil
			else
				self.timers.roll_left = nil
			end
		end
	else
		self.roll_left = nil
	end

	if Input:GetValue(Action.MoveRight) > 0 then
		if not self.roll_right then
			self.roll_right = true
			if not self.timers.roll_right then
				self.timers.roll_right = Timer()
			elseif self.timers.roll_right:GetMilliseconds() < 500 then
				if not self.subs.roll_right then
					local timer = Timer()
					LocalPlayer:SetBaseState( AnimationState.SSkydiveDash )
					self.subs.roll_right = Events:Subscribe( "PreTick", function()
						if timer:GetMilliseconds() > 750 then
							LocalPlayer:SetBaseState( AnimationState.SSkydive )
							Events:Unsubscribe( self.subs.roll_right )
							self.subs.roll_right = nil
						end
					end )
				end
				self.timers.roll_right = nil
			else
				self.timers.roll_right = nil
			end
		end
	else
		self.roll_right = nil
	end
end

function Wingsuit:Glide()
	if self.superman then return end

	if not self.hit then
		if Input:GetValue(Action.MoveBackward) > 0 and LocalPlayer:GetAngle().pitch > 0 then
			Input:SetValue(Action.MoveBackward, 0)
		end
	else
		Input:SetValue(Action.MoveBackward, 0.9)

		if self.yaw < 0 then
			Input:SetValue(Action.MoveLeft, -self.yaw_gain * self.yaw)
		elseif self.yaw > 0 then
			Input:SetValue(Action.MoveRight, self.yaw_gain * self.yaw)
		end
	end
end

function Wingsuit:Input( args )
	if Game:GetState() ~= GUIState.Game then return end
	
	if not self.superman and self.grapple and args.input == Action.FireGrapple then
		if self.subs.grapple or self.subs.roll_left or self.subs.roll_right or self.timers.grapple:GetMilliseconds() < 500 then return false end

		local angle = LocalPlayer:GetAngle()

		if angle.pitch < -0.2 * math.pi then return false end

		LocalPlayer:SetLeftArmState( 399 )

		self.timers.grapple = Timer()
		local direction = Angle(angle.yaw, 0, 0) * Vector3( -angle.roll, -0.3, -1 )

		self.effect = ClientEffect.Create(AssetLocation.Game, {
			effect_id = 11,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
		})

		self.subs.grapple = Events:Subscribe( "GameRenderOpaque", function()

			local dt = self.timers.grapple:GetMilliseconds()
			local bone_pos = LocalPlayer:GetBonePosition("ragdoll_LeftForeArm")

			local color = Color( 100, 100, 100 )
			local r = math.lerp( 0.5 * color.r, color.r, self.dt )
			local g = math.lerp( 0.5 * color.g, color.g, self.dt )
			local b = math.lerp( 0.5 * color.b, color.b, self.dt )

			if not self.hit then
				local distance = self.tether_length * dt / 500
				local ray = Physics:Raycast( bone_pos, direction, 0, distance )

				Render:DrawLine( bone_pos, ray.position, Color( r, g, b, 192 ) )

				if ray.distance < distance - 0.1 and ray.position.y > 199  then
					self.hit = ray.position
					self.speed = self.speed + 4
					self.vertical_speed = -self.vertical_speed
				end

				if dt > 500 then self:EndGrapple() end
			else
				Render:DrawLine( bone_pos, self.hit, Color( r, g, b, 192 ) )

				local yaw1 = math.atan2(bone_pos.x - self.hit.x, bone_pos.z - self.hit.z)
				local yaw2 = angle.yaw
				self.yaw = (yaw2 - yaw1 + math.pi) % (2 * math.pi) - math.pi

				if dt > 1500 or math.abs(self.yaw) > 0.2 * math.pi or Vector3.DistanceSqr(bone_pos, self.hit) > self.tether_length^2 then
					self:EndGrapple()
				end
			end
		end )
		return false
	end
	if self.blacklist.actions[args.input] then return false end
end

function Wingsuit:EndGrapple()
	self.timers.grapple:Restart()
	self.effect:Remove()
	LocalPlayer:SetLeftArmState( 384 )
	Events:Unsubscribe( self.subs.grapple )
	self.subs.grapple = nil
	self.hit = nil
	self.yaw = 0
	self.vertical_speed = self.default_vertical_speed
	self.speed = self.default_speed
end

function Wingsuit:Abort()
	local object = NetworkObject.GetByName("Flying")
	if not object or self.score > (object:GetValue("S") or 0) then
		Network:Send("0001", self.score)
	elseif self.score > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~= LocalPlayer:GetName() then
		Network:Send("0002", self.score)
	end

	local shared = SharedObject.Create("Flying")
	if self.score > (shared:GetValue("Record") or 0) then
		shared:SetValue( "Record", self.score )
		Game:ShowPopup( self.tRecord .. self.score, true )
	end
	self.RCtimer = nil
	self.score = 0
	LocalPlayer:SetValue( "Wingsuit", nil )
	if self.subs.wings then
		Events:Unsubscribe( self.subs.wings )
		self.subs.wings = nil
	end
	if self.subs.velocity then
		Events:Unsubscribe ( self.subs.velocity )
		self.subs.velocity = nil
	end
	if self.subs.glide then
		Events:Unsubscribe( self.subs.glide )
		self.subs.glide = nil
	end
	if self.subs.input then
		Events:Unsubscribe( self.subs.input )
		self.subs.input = nil
	end
	if self.subs.camera then
		Events:Unsubscribe( self.subs.camera )
		self.subs.camera = nil
	end
end

function Wingsuit:Camera()
	local player_pos = LocalPlayer:GetPosition()
	local player_angle = LocalPlayer:GetAngle()
	local vector

	if self.camera == 1 then
		vector = Vector3( 0, 2, 7 )
	elseif self.camera == 2 then
		vector = Vector3( 0, 1, 1 )
	elseif self.camera == 3 then
		vector = Vector3( 0, 0.5, -1 )
	elseif self.camera == 4 then
		vector = Vector3( 0, 1, 10 )
	end

	if self.timers.camera_start then
		local dt = self.timers.camera_start:GetMilliseconds()

		if self.camera < 5 then
			Camera:SetPosition( math.lerp( Camera:GetPosition(), player_pos + player_angle * vector, dt / 1000 ) )
			Camera:SetAngle( Angle.Slerp( Camera:GetAngle(), player_angle, 0.9 * dt / 1000 ) )
		end

		if dt >= 1000 then
			self.timers.camera_start = nil
		end
	elseif self.timers.camera_stop then
		local dt = self.timers.camera_stop:GetMilliseconds()

		if self.camera < 5 then
			Camera:SetPosition( math.lerp( player_pos + player_angle * vector, Camera:GetPosition(), dt / 1000 ) )
			Camera:SetAngle( Angle.Slerp( Camera:GetAngle(), player_angle, 0.9 - 0.9 * dt / 1000 ) )
		end

		if dt >= 1000 then
			self.timers.camera_stop = nil
			self:Abort()
		end
	else
		if self.camera < 5 then
			Camera:SetPosition (player_pos + player_angle * vector )
			Camera:SetAngle (Angle.Slerp( Camera:GetAngle(), player_angle, 0.9 ) )
		end
	end
end

wingsuit = Wingsuit()