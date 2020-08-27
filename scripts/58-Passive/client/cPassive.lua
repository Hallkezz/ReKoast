class 'Passive'

function Passive:__init()
	self.cooldown = 30
	self.tagOffset = 10
	self.textSize = 16
	self.name = "Мирный"
	self.prefix = "[Мирный] "
	self.w = "Подождите "
	self.ws = " секунд, чтобы включить/отключить мирный!"
	self.notusable = "Вы не можете использовать это здесь!"
	self.passiveColor = Color( 255, 255, 255, 55 )

	self.cooltime = 0
	self.actions  = {
		[11] = true, [12] = true, [13] = true, [14] = true,
		[15] = true, [137] = true, [138] = true, [139] = true
		}

	Network:Subscribe( "Text", self, self.Text )

	Events:Subscribe( "PassiveOn", self, self.PassiveOn )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "InputPoll", self, self.InputPoll )
	Events:Subscribe( "LocalPlayerBulletHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "LocalPlayerExplosionHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "LocalPlayerForcePulseHit", self, self.LocalPlayerDamage )
	Events:Subscribe( "NetworkObjectValueChange", self, self.NetworkObjectValueChange )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "LocalPlayerWorldChange", self, self.LocalPlayerWorldChange )
end

function Passive:GetOption( args )
	self.Display = args.actGod
end

function Passive:Lang( args )
	self.name = "Passive"
	self.w = "Wait "
	self.ws = " seconds to enable/disable passive!"
	self.notusable = "You cannot use it here!"
end

function Passive:LocalPlayerWorldChange()
	Network:Send( "Disable" )
end

function Passive:LocalPlayerInput( args )
	if self.actions[args.input] and (LocalPlayer:GetValue("Passive") or LocalPlayer:InVehicle() and LocalPlayer:GetVehicle():GetInvulnerable()) then
		return false
	end
end

function Passive:InputPoll( args )
	if not LocalPlayer:GetValue("Passive") then return end
	Input:SetValue( Action.FireRight, 0 )
	Input:SetValue( Action.FireLeft, 0 )
end

function Passive:Text( message )
	Events:Fire( "CastCenterText", { text = message, time = 3, color = Color( 0, 222, 0, 250 ) } )
end

function Passive:PassiveOn( args )
	if LocalPlayer:GetWorld() ~= DefaultWorld then
		Events:Fire( "CastCenterText", { text = self.notusable, time = 3, color = Color.Red } )
		return
	end
	local time = Client:GetElapsedSeconds()
	if time < self.cooltime then
		Events:Fire( "CastCenterText", { text = self.w .. math.ceil( self.cooltime - time ) .. self.ws, time = 6, color = Color.Red } )
		return false
	end

	Network:Send( "Toggle", not LocalPlayer:GetValue("Passive") )
	self.cooltime = time + self.cooldown
	return false
end

function Passive:LocalPlayerDamage( args )
	if LocalPlayer:GetValue("Passive") or args.attacker and (args.attacker:GetValue("Vbhys")
		or args.attacker:InVehicle() and args.attacker:GetVehicle():GetInvulnerable()) then
	return false
	end
end

function Passive:NetworkObjectValueChange( args )
	if args.key == "Passive" and args.object.__type == "LocalPlayer" then
		if args.value then
			Game:FireEvent( "ply.invulnerable" )
			Events:Fire( "GetGod", {godactive = true} )
			Events:Fire( "AntiCheat", {acActive = false} )
		else
			Game:FireEvent( "ply.vulnerable" )
			Events:Fire( "GetGod", {godactive = false} )
			Events:Fire( "AntiCheat", {acActive = true} )
		end
	end
end

function Passive:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if not self.Display then return end
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end

	--if LocalPlayer:GetValue("Passive") then
	--	if LocalPlayer:GetVehicle() then
	--		if LocalPlayer:GetVehicle():GetLinearVelocity():Length() >= 20 then
	--			Network:Send( "CheckPassive" )
	--		end
	--	end
	--end

	for player in Client:GetStreamedPlayers() do
		if player:GetValue("Passive") then
			if player:GetValue( "TagHide" ) then
				local tagpos    = player:GetBonePosition("ragdoll_Head") + Vector3( 0, 0.4, 0 )
				local distance  = tagpos:Distance(LocalPlayer:GetPosition())
				local pos, onsc = Render:WorldToScreen(tagpos)

				if onsc then
					local scale   = math.clamp(1 - distance / 1000, 0.75, 1)
					local size    = Render:GetTextSize(self.name, self.textSize, scale)
					pos           = pos - Vector2(size.x / 2, size.y + self.tagOffset * scale)
					local sColor  = Color( 0, 0, 0, 180 * scale ^ 2 )
					local color   = Copy( Color.MediumSpringGreen )
					color.a       = 255 * scale

					Render:DrawText( pos + Vector2.One, self.name, sColor, self.textSize, scale )
					Render:DrawText( pos, self.name, color, self.textSize, scale )
				end
			end
		end
	end

    local width = Render:GetTextWidth( self.name )
    local textpos = Vector2( Render.Width/1.52 - width/1.8, 2 )

	Render:FillArea( Vector2( (Render.Width / 1.52 - 38) ,0 ), Vector2( 76, 20 ), Color( 0, 0, 0, 85 ) )

	Render:FillTriangle( Vector2( (Render.Width / 1.52 - 45), 0 ), Vector2( (Render.Width / 1.52 - 38), 0 ), Vector2( (Render.Width / 1.52 - 38), 20 ), Color( 0, 0, 0, 85 ) )
	Render:FillTriangle( Vector2( (Render.Width / 1.52 + 38), 0 ), Vector2( (Render.Width / 1.52 + 45), 0 ), Vector2( (Render.Width / 1.52 + 38), 20 ), Color( 0, 0, 0, 85 ) )
	Render:DrawText( textpos, self.name, self.passiveColor, 18 )

	if LocalPlayer:GetValue("Passive") then
		self.passiveColor = Color.MediumSpringGreen
	else
		self.passiveColor = Color( 255, 255, 255, 55 )
	end
end

passive = Passive()