class 'Settings'

function Settings:__init()
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_color (steamid VARCHAR UNIQUE, r INTEGER, g INTEGER, b INTEGER)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_settings (steamid VARCHAR UNIQUE, clockbol INTEGER)")

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	--Network:Subscribe( "GetDBSettings", self, self.GetDBSettings )
	--Network:Subscribe( "SaveSettings", self, self.SaveSettings )
	Network:Subscribe( "SetPlyColor", self, self.SetPlyColor )
	Network:Subscribe( "SPOff", self, self.SPOff )

	Network:Subscribe( "GetStats", self, self.GetStats )
end

function Settings:SaveSettings( args, sender )
	local getclockbol = args.clockbol
	local steamID = tostring(sender:GetSteamId().id)

    local cmd = SQL:Command( "INSERT OR REPLACE INTO players_settings (steamid, clockbol) values (?, ?)" )
    cmd:Bind( 1, tostring(steamID) )
    cmd:Bind( 2, getclockbol )
	cmd:Execute()
	print(getclockbol)
end

function Settings:SetPlyColor( args, sender )
	local colored = args.pcolor
	local steamID = tostring(sender:GetSteamId().id)

	local qry = SQL:Query('INSERT OR REPLACE INTO players_color (steamid, r, g, b) VALUES(?, ?, ?, ?)')
	qry:Bind(1, tostring(steamID))
	qry:Bind(2, colored.r)
	qry:Bind(3, colored.g)
	qry:Bind(4, colored.b)
	qry:Execute()
	sender:SetColor( args.pcolor )
end

function Settings:PlayerJoin( args )
	local qry = SQL:Query("SELECT r, g, b FROM players_color WHERE steamid = ?")
	qry:Bind(1, args.player:GetSteamId().id)
    local result = qry:Execute()

	if #result > 0 then
		args.player:SetColor( Color( tonumber(result[1].r), tonumber(result[1].g), tonumber(result[1].b) ) )
	end
end

function Settings:GetDBSettings( args, sender )
	local qry = SQL:Query("SELECT clockbol FROM players_settings WHERE steamid = ?")
	qry:Bind(1, sender:GetSteamId().id)
	local result = qry:Execute()

	if #result > 0 then
		Network:Send( sender, "LoadSettings", { clockdb = tonumber(result[1].clockbol) } )
		print(tonumber(result[1].clockbol))
	end
end


function Settings:SPOff( args, sender )
	if not sender:GetValue("SavePos") then
		Chat:Send( sender, "[Сервер] ", Color.White, "Позиция сброшена. Перезайдите в игру.", Color.Yellow )
		sender:SetNetworkValue( "SavePos", true )
		Network:Send( sender, "ResetDone" )
	end
end

function Settings:GetStats( args, sender )
	local text = "Общее:" ..
	"\nИмя: " .. sender:GetName() ..
	"\nЦвет: " .. tostring( sender:GetColor() ) ..
	"\nID: " .. tostring( sender:GetId() ) ..
	"\nSteamID: " .. tostring( sender:GetSteamId() ) ..
	"\nID персонажа: " .. tostring( sender:GetModelId() ) ..
	"\nДеньги: $" .. tostring( sender:GetMoney() ) ..
	"\nПозиция: " .. tostring( sender:GetPosition() ) ..
	"\nЯзык: " .. tostring( sender:GetValue( "Lang" ) ) ..
	"\nРежим: " .. tostring( sender:GetValue( "GameMode" ) ) ..
	"\nУбийств: " .. tostring( sender:GetValue( "Kills" ) ) ..
	"\nНазвание транспорта: " .. tostring( sender:GetVehicle() )
	Network:Send( sender, "UpdateStats", { stats = text } )
end

settings = Settings()