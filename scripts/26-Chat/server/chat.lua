class 'BetterChat'

valueses = { "Неудачно", "Удачно", "Неудачно" }

function BetterChat:__init( args )
    Network:Subscribe( "toggle", self, self.Mode )
    Events:Subscribe( "PlayerJoin", self, self.Join )
	Events:Subscribe( "PlayerChat", self, self.Chat )

    self.distance = 20
    self.toggle = 0
end

function BetterChat:Join( args )
    args.player:SetValue( "chat",0 )
end

function BetterChat:Mode( toggler, player )
    player:SetValue( "chat", toggler )
end

function BetterChat:Chat( args )
	if args.text:sub(1,1) != "/" then
		if not args.player:GetValue( "Mute" ) then
			local chatsetting = args.player:GetValue("chat")
			if chatsetting == 0 then
				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "ENG" then
						p:SendChatMessage( "[Global] ", Color.LightSkyBlue, args.player:GetName(), args.player:GetColor(), ": "..args.text, Color.White )
					else
						p:SendChatMessage( "[Общий] ", Color.LightSkyBlue, args.player:GetName(), args.player:GetColor(), ": "..args.text, Color.White )
					end
				end
				Events:Fire( "ToDiscordConsole", { text = "[" .. args.player:GetValue( "Lang") .. "] [Global] " .. args.player:GetName() .. ": "..args.text } )
				print( "[" .. args.player:GetValue( "Lang") .. "] [Global] " .. args.player:GetName()..": "..args.text )
				return false
			elseif chatsetting == 1 then
				for p in Server:GetPlayers() do
					jDist = args.player:GetPosition():Distance( p:GetPosition() )
					if jDist < 50 then
						p:SendChatMessage( "[Локальный] ", Color.DarkGray, args.player:GetName(), args.player:GetColor(), ": ".. args.text, Color.White )
						return false
           			end
           		end
			elseif chatsetting == 2 then
				return false
			end
		end
	else
		local cmd_args = string.split( args.text," ",true )
	end

    local msg = args.text
    if ( msg:sub ( 1, 1 ) ~= "/" ) then
        return true
    end

    local msg = msg:sub( 2 )
    local cmd_args = msg:split( " " )
    local cmd_name = cmd_args [ 1 ]:lower()
	if ( cmd_name == "me" ) then
		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			jDist = args.player:GetPosition():Distance( p:GetPosition() )
			if jDist < 50 then
				p:SendChatMessage( args.player:GetName() .. " " .. tostring( table.concat ( cmd_args, " " ) ), Color.Magenta )
			end
		end
	end

	if ( cmd_name == "l" ) then
		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			jDist = args.player:GetPosition():Distance( p:GetPosition() )
			if jDist < 50 then
				p:SendChatMessage( "[Локальный] ", Color.DarkGray, args.player:GetName(), args.player:GetColor(), ": ".. tostring( table.concat ( cmd_args, " " ) ), Color.White )
		   end
		end
	end

	if ( cmd_name == "try" ) then
		wtf = valueses[math.random(#valueses)]
		table.remove( cmd_args, 1 )
		for p in Server:GetPlayers() do
			jDist = args.player:GetPosition():Distance( p:GetPosition() )
			if jDist < 50 then
				p:SendChatMessage( args.player:GetName() .. " " .. tostring( table.concat ( cmd_args, " " ) ), Color.Magenta, " | ", Color.White, wtf, Color.Magenta, " | ", Color.White )
			end
		end
	end
end

betterchat = BetterChat()