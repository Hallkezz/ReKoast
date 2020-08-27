class 'Menu'

function Menu:__init()
	Chat:Broadcast( "Был выполнен рестарт мода. Появились баги? Перезайдите!", Color.Yellow )

	Network:Subscribe( "DefaultWorld", self, self.DefaultWorld )
	Network:Subscribe( "SetFreeroam", self, self.SetFreeroam )
	Network:Subscribe( "SetEng", self, self.SetEng )
	Network:Subscribe( "SetRus", self, self.SetRus )
	Network:Subscribe( "Exit", self, self.Exit )
	Network:Subscribe( "GoMenu", self, self.GoMenu )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Menu:DefaultWorld( args, sender )
	sender:SetWorld( DefaultWorld )
end

function Menu:SetFreeroam( args, sender )
	sender:SetNetworkValue( "GameMode", "FREEROAM" )
end

function Menu:SetEng( args, sender )
	if sender:GetValue( "ServerName" ) ~= nil and sender:GetValue( "ServerName" ) ~= "" then
		Chat:Send( sender, "Welcome to " .. sender:GetValue( "ServerName" ) .. "!" .. " Have a nice game :3", Color( 200, 120, 255 ) )
	else
		Chat:Send( sender, "Welcome to server! Have a nice game :3", Color( 200, 120, 255 ) )
	end
	Chat:Send( sender, "==============", Color( 255, 255, 255 ) )
	Chat:Send( sender, "> Players List: ", Color.White, "F5", Color.Yellow )
	Chat:Send( sender, "> Server Map: ", Color.White, "F2", Color.Yellow )
	Chat:Send( sender, "> Server Menu: ", Color.White, "B", Color.Yellow )
	Chat:Send( sender, "==============", Color( 255, 255, 255 ) )
	sender:SetNetworkValue( "Lang", "ENG" )
end

function Menu:SetRus( args, sender )
	sender:SetNetworkValue( "Lang", "РУС" )
end

function Menu:Exit( args, sender )
	sender:Kick()
end

function Menu:GoMenu( args, sender )
	Network:Send( sender, "BackMe" )
end

function Menu:PlayerJoin( args )
	if args.player:GetValue( "ServerName" ) ~= nil and args.player:GetValue( "ServerName" ) ~= "" then
		Chat:Send( args.player, "Добро пожаловать на " .. args.player:GetValue( "ServerName" ) .. "!" .. " Приятной игры :3", Color( 200, 120, 255 ) )
	else
		Chat:Send( args.player, "Добро пожаловать на сервер! Приятной игры :3", Color( 200, 120, 255 ) )
	end
	Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
	Chat:Send( args.player, "> Список игроков: ", Color.White, "F5", Color.Yellow )
	Chat:Send( args.player, "> Серверная карта: ", Color.White, "F2", Color.Yellow )
	Chat:Send( args.player, "> Меню сервера: ", Color.White, "B", Color.Yellow )
	Chat:Send( args.player, "==============", Color( 255, 255, 255 ) )
end

function Menu:PlayerChat( args )
	local msg = args.text

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if (cmdargs[1] == "/menu") then
		Network:Send( args.player, "MOTDActive", false )
        return false
    end
	return false
end

menu = Menu()