class 'Pong'

function Pong:__init()
	Events:Subscribe( "MouseMove", self, self.MouseMove )
	Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "PreTick", self, self.ClientTick )
	Events:Subscribe( "LocalPlayerChat", self, self.PlayerChat )
end

function Pong:LocalPlayerInput( args )
	if active and args.state ~= 0 then
		if args.input == Action.LookUp or args.input == Action.LookDown or args.input == Action.LookLeft or args.input == Action.LookRight then
			return false
		end
	end
end

function Pong:ClientTick( args )
	if active and not paused then
		HandleBallData(args)
		HandleCPU(args)
	end
end

function Pong:MouseMove( args )
	if active then
		if args.position.y >= mouse_last.y and (ping_pos + ping_height) < pong_table_height then
			ping_pos = ping_pos + (args.position.y - mouse_last.y)

			if (ping_pos + ping_height) + (args.position.y - mouse_last.y) > pong_table_height then ping_pos = (pong_table_height - ping_height) end
		elseif args.position.y <= mouse_last.y and ping_pos > 0 then
			ping_pos = ping_pos - (mouse_last.y - args.position.y)

			if ping_pos - (mouse_last.y - args.position.y) < 0 then ping_pos = 0 end
		end
		mouse_last.y = args.position.y
	end
end

function Pong:Render( args )
	if active then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		Render:FillArea( pong_draw_start, Vector2( pong_table_width, pong_table_height ), Color( 0, 0, 0, 100 ) )	
		Render:FillArea( pong_draw_start + Vector2( 10, ping_pos ), Vector2( ping_width, ping_height ), Color( 255, 255, 255 ) )
		Render:FillArea( pong_draw_start + Vector2( pong_table_width - ping_width - 10, ping_pos_opp ), Vector2( ping_width, ping_height ), Color( 255, 255, 255 ) )
		Render:FillArea( pong_draw_start + ball_pos, Vector2( ball_width, ball_height ), Color( 255, 255, 255 ) )

		Render:DrawText( pong_draw_start + Vector2( 1, pong_table_height + 1 ), "Вы: "..scores[1], Color( 25, 25, 25, 150 ) )
		Render:DrawText( pong_draw_start + Vector2( pong_table_width - 64, pong_table_height + 1 ), "Гопник: "..scores[2], Color( 25, 25, 25, 150 ) )
		Render:DrawText( pong_draw_start + Vector2( pong_table_width / 2 - 54, pong_table_height + 1 ), "Макс. лимит: "..score_limit, Color( 25, 25, 25, 150 ) )
		Render:DrawText( pong_draw_start + Vector2( 0, pong_table_height ), "Вы: "..scores[1], Color( 255, 255, 255 ) )
		Render:DrawText( pong_draw_start + Vector2( pong_table_width - 65, pong_table_height ), "Гопник: "..scores[2], Color( 255, 255, 255 ) )
		Render:DrawText( pong_draw_start + Vector2( pong_table_width / 2 - 55, pong_table_height ), "Макс. лимит: "..score_limit, Color( 255, 255, 255 ) )

		Render:DrawText( pong_draw_start + Vector2( pong_table_width / 2 - 399, pong_table_height + 51 ), "Инструкция: Используйте мышь, чтобы переместить платформу, введите \"/pong exit\" чтобы выйти.", Color( 25, 25, 25, 150 ), 18 )
		Render:DrawText( pong_draw_start + Vector2( pong_table_width / 2 - 400, pong_table_height + 50 ), "Инструкция: Используйте мышь, чтобы переместить платформу, введите \"/pong exit\" чтобы выйти.", Color( 0, 255, 0 ), 18 )

		if paused then
			Render:DrawText( pong_draw_start + pong_table_center + Vector2( Render:GetTextWidth( status_text, TextSize.Huge ) * -0.5, Render:GetTextHeight( status_text, TextSize.Huge) * -0.5 ), status_text, status_colour, TextSize.Huge )
		end
	end
end

function Pong:PlayerChat( args )
	local player = LocalPlayer
    local msg = args.text

	if string.sub(msg , 1 , 1) ~= "/" then
		return true
	end

	local params = {}
    for param in string.gmatch(msg, "[^%s]+") do
        table.insert(params, param)
    end

	if params[1] == "/pong" then
		if params[2] and params[2] == "exit" or params[2] and params[2] == "leave" then
		    Mouse:SetVisible( false )
			active = false
			return false
		end

		if not params[2] then
			Chat:Print( "[Понг] ", Color.White, "Используйте /pong <сложность>", Color.Yellow )
			Chat:Print( "[Понг] ", Color.White, "Сложности: Noob, Easy, Medium, Hard, Extreme", Color( 165, 165, 165 ) )
			return false
		end

		params[2] = params[2]:lower()

		if not difficulty_level[params[2]] then Chat:Print( "Неверная сложность!", Color( 255, 0, 0 ) ) return false end

		cpu_difficulty = difficulty_level[params[2]][1]
		angle_modifier = difficulty_level[params[2]][3]
		ball_speed_limit.upper = difficulty_level[params[2]][2]
		ball_speed_limit.lower = -ball_speed_limit.upper

		Mouse:SetVisible( true )
		active = true
		paused = false
		scores = {0, 0}
		ball_pos = Vector2( pong_table_center.x - ( ball_width / 2 ), pong_table_center.y - ( ball_height / 2 ) ) -- Put the ball back in the middle of the game
		ball_speed.x = 2
		ball_speed.y = 0
		return false
	end
end

pong = Pong()

function HandleCPU( args )
	if ball_pos.y > ping_pos_opp + (ping_height / 2) and (ping_pos_opp + ping_height) < pong_table_height then 
		ping_pos_opp = ping_pos_opp + cpu_difficulty
	elseif ball_pos.y < ping_pos_opp + (ping_height / 2) and ping_pos_opp > 0 then
		ping_pos_opp = ping_pos_opp - cpu_difficulty 
	end
end

function DrawStatus( text, colour )
	status_text = text
	status_colour = colour
end

function CalculateBallAngle( ball_y, ping_y )
	return (((ball_y + (ball_height / 2)) - (ping_y + (ping_height / 2))) / 40) * angle_modifier
end

function HandleBallData( args )
	if (ball_pos.x) >= (pong_table_width - ping_width - 20) and (ball_pos.y + ball_height) >= ping_pos_opp and ball_pos.y <= (ping_pos_opp + ping_height) then
		ball_speed.x = -ball_speed.x

		if ball_speed.x > ball_speed_limit.lower then ball_speed.x = ball_speed.x - 1 end

		if ball_speed.x < ball_speed_limit.lower then ball_speed.x = ball_speed_limit.lower end

		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos_opp)

		if (ball_pos.x) > (pong_table_width - ping_width - 20) then 
			ball_pos.x = pong_table_width - ping_width - 20
		end
	elseif ball_pos.x <= ping_width + 10 and (ball_pos.y + ball_height) >= ping_pos and ball_pos.y <= (ping_pos + ping_height) then
		ball_speed.x = -ball_speed.x

		if ball_speed.x < ball_speed_limit.upper then ball_speed.x = ball_speed.x + 1 end

		if ball_speed.x > ball_speed_limit.upper then ball_speed.x = ball_speed_limit.upper end

		ball_speed.y = CalculateBallAngle(ball_pos.y, ping_pos)

		if ball_pos.x < ping_width + 10 then ball_pos.x = ping_width + 10 end
	end

	if (ball_pos.y + ball_height + ball_speed.y) > pong_table_height or ball_pos.y < 0 then ball_speed.y = -ball_speed.y end

	ball_pos.x = ball_pos.x + ball_speed.x
	ball_pos.y = ball_pos.y + ball_speed.y

	if ball_pos.x <= 0 then
		ball_speed.x = 2
		ball_speed.y = 0
		scores[2] = scores[2] + 1

		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))

		if scores[2] == score_limit then 
			Events:Fire( "CastCenterText", { text = "Лох!", time = 2, color = Color.Red } )
			Mouse:SetVisible( false )
			active = false
		end
	elseif ball_pos.x + ball_width >= pong_table_width then
		ball_speed.x = -2
		ball_speed.y = 0
		scores[1] = scores[1] + 1

		ball_pos = Vector2(pong_table_center.x - (ball_width / 2), pong_table_center.y - (ball_height / 2))

		if scores[1] == score_limit then 
			Events:Fire( "CastCenterText", { text = "Молорик!", time = 2, color = Color( 0, 222, 0 ) } )
			Network:Send( "Win" )
			Mouse:SetVisible( false )
			active = false
		end
	end
end