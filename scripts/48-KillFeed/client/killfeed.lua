class 'Killfeed'

function Killfeed:__init()
	self.list = {}
	self.removal_time = 18

	self:CreateKillStrings()

	Network:Subscribe( "PlayerDeath", self, self.PlayerDeath )

	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "Render", self, self.Render )
end

function Killfeed:PlayerDeath( args )
	if not IsValid( args.player ) then return end
	local reason = args.reason

	if args.killer then
		if not self.killer_msg[reason] then
			reason = DamageEntity.None
		end
	else
		if not self.no_killer_msg[reason] then
			reason = DamageEntity.None
		end
	end

	if args.killer then
		args.message = string.format( self.killer_msg[reason][args.id], args.player:GetName(), "     " .. args.killer:GetName() )

		args.killer_name   = args.killer:GetName()
		args.killer_colour = args.killer:GetColor()
	else
		args.message = string.format( self.no_killer_msg[reason][args.id], args.player:GetName() )
	end

	args.player_name   = args.player:GetName()
	args.player_colour = args.player:GetColor()

	args.time = os.clock()

	table.insert( self.list, args )
end

function Killfeed:CreateKillStrings()
	self.no_killer_msg = {
		[DamageEntity.None] = { 
			"%s умер!",
			"%s скончался!"
		},

		[DamageEntity.Physics] = { 
			"%s умер!",
			"%s скончался!"
		},

		[DamageEntity.Bullet] = { 
			"%s застрелен!",
			"%s смертельно ранен!"
		},

		[DamageEntity.Explosion] = { 
			"%s взорвался!",
			"%s был взрывоопасным!"
		},

		[DamageEntity.Vehicle] = {
			"%s был сбит!",
			"%s попал под машину!"
		}
	}

	self.killer_msg = {
		[DamageEntity.None] = { 
			"%s каким-то образом убит %s!",
			"%s тронут магией %s!"
		},

		[DamageEntity.Physics] = { 
			"%s уничтожен силой %s!",
			"%s умер благодаря %s!"
		},

		[DamageEntity.Bullet] = { 
			"%s убит %s!",
			"%s застрелен %s!"
		},

		[DamageEntity.Explosion] = { 
			"%s взорван %s!",
			"%s оснащен взрывами  %s!"
		},

		[DamageEntity.Vehicle] = {
			"%s попал в ярость дороги %s!",
			"%s сбит %s!"
		}
	}
end

function Killfeed:CalculateAlpha( time )
	local difftime = os.clock() - time
	local removal_time_gap = self.removal_time - 1

	if difftime < removal_time_gap then
		return 255
	elseif difftime >= removal_time_gap and difftime < self.removal_time then
		local interval = difftime - removal_time_gap
		return 255 * (1 - interval)
	else
		return 1
	end
end

function Killfeed:GetOption( args )
	self.active = args.actKf
end

function Killfeed:Render( args )
	if Game:GetState() ~= GUIState.Game then return end
	if not self.active then return end

	local center_hint = Vector2( Render.Width - 5, Render.Height / 4.8 )
	local height_offset = 0

	for i,v in ipairs( self.list ) do
		if os.clock() - v.time < self.removal_time then
			local text_width = Render:GetTextWidth( v.message )
			local text_height = Render:GetTextHeight( v.message )

			local pos = center_hint + Vector2( -text_width, height_offset )
			local alpha = self:CalculateAlpha( v.time )

			local shadow_colour = Color( 20, 20, 20, alpha * 0.5 )

			Render:DrawText( pos + Vector2.One, v.message, shadow_colour )
			Render:DrawText( pos, v.message, Color( 255, 255, 255, alpha ) )

			local player_colour = v.player_colour
			player_colour.a = alpha

			local img_width = text_height

			Render:DrawText( pos, v.player_name, player_colour )

			if IsValid( v.player, false ) then
				Render:FillArea( pos - Vector2( img_width + 2, 0 ), Vector2( img_width - 1, img_width - 1 ), shadow_colour )
				v.player:GetAvatar():SetAlpha( 255 * player_colour.a )
				v.player:GetAvatar():Draw( pos - Vector2( img_width + 3, 1 ), Vector2( img_width, img_width ), Vector2.Zero, Vector2.One )
			end

			if v.killer_name ~= nil then
				local killer_colour = v.killer_colour
				killer_colour.a = alpha
				local name_text = v.killer_name .. "!"
				local name_width = Render:GetTextWidth( name_text )

				Render:DrawText( center_hint + Vector2( -name_width, height_offset ), v.killer_name, killer_colour )

				if IsValid( v.killer, false ) then
					pos = center_hint + Vector2( -name_width, height_offset )
					Render:FillArea( pos - Vector2( img_width + 2, 0 ), Vector2( img_width - 1, img_width - 1 ), shadow_colour )
					v.killer:GetAvatar():SetAlpha( 255 * player_colour.a )
					v.killer:GetAvatar():Draw( pos - Vector2( img_width + 3, 1 ), Vector2( img_width, img_width ), Vector2.Zero, Vector2.One )
				end
			end

			height_offset = height_offset + text_height + 4
		else
			table.remove( self.list, i )
			if IsValid( v.player, false ) then
				v.player:GetAvatar():SetAlpha( 1 )
			end
			if v.killer_name ~= nil then
				v.killer:GetAvatar():SetAlpha( 1 )
			end
		end
	end
end

killfeed = Killfeed()