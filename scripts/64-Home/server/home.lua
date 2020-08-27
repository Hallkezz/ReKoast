class 'Home'

function Home:__init()
	SQL:Execute("CREATE TABLE IF NOT EXISTS players_home (steamid VARCHAR UNIQUE, homeX INTEGER, homeY INTEGER, homeZ INTEGER)")
	SQL:Execute("CREATE TABLE IF NOT EXISTS players_homeTw (steamid VARCHAR UNIQUE, homeX INTEGER, homeY INTEGER, homeZ INTEGER)")

	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Network:Subscribe( "SetHome", self, self.SetHome )
	Network:Subscribe( "GoHome", self, self.GoHome )
	Network:Subscribe( "SetHomeTw", self, self.SetHomeTw )
	Network:Subscribe( "GoHomeTw", self, self.GoHomeTw )
end

function Home:PlayerChat( args )
	local cmd_args = args.text:split(" ")
	
	if cmd_args[1] == "/gethome" then
		self:GetHome(args)
	end
end

function Home:SetHome( args, sender )
	local playerPos = sender:GetPosition()
	local steamID = tostring(sender:GetSteamId().id)

	local qry = SQL:Query('INSERT OR REPLACE INTO players_home (steamid, homeX, homeY, homeZ) VALUES(?, ?, ?, ?)')
	qry:Bind(1, tostring(steamID))
	qry:Bind(2, playerPos.x)
	qry:Bind(3, playerPos.y)
	qry:Bind(4, playerPos.z)
	qry:Execute()
	Network:Send( sender, "SetHome")
	sender:SendChatMessage( string.format("Точка дома установлена на: (%i x %i x %i)", playerPos.x, playerPos.y, playerPos.z), Color( 54, 204, 113 ) )
	print( sender:GetName() .. string.format(" set home. Coordinates: (%i x %i x %i)", playerPos.x, playerPos.y, playerPos.z) )
end

function Home:GoHome( args, sender )
	local steamID = tostring(sender:GetSteamId().id)
	local qry = SQL:Query("SELECT * FROM players_home WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		for i, v in ipairs(result) do
			sender:SetPosition(Vector3(tonumber(v.homeX), tonumber(v.homeY), tonumber(v.homeZ)))
        end
	end
end

function Home:SetHomeTw( args, sender )
	local playerPos = sender:GetPosition()
	local steamID = tostring(sender:GetSteamId().id)

	local qry = SQL:Query('INSERT OR REPLACE INTO players_homeTw (steamid, homeX, homeY, homeZ) VALUES(?, ?, ?, ?)')
	qry:Bind(1, tostring(steamID))
	qry:Bind(2, playerPos.x)
	qry:Bind(3, playerPos.y)
	qry:Bind(4, playerPos.z)
	qry:Execute()
	Network:Send( sender, "SetHome")
	sender:SendChatMessage( string.format("Точка второго дома установлена на: (%i x %i x %i)", playerPos.x, playerPos.y, playerPos.z), Color( 54, 204, 113 ) )
	print( sender:GetName() .. string.format(" set home 2. Coordinates: (%i x %i x %i)", playerPos.x, playerPos.y, playerPos.z) )
end

function Home:GoHomeTw( args, sender )
	local steamID = tostring(sender:GetSteamId().id)
	local qry = SQL:Query("SELECT * FROM players_homeTw WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		for i, v in ipairs(result) do
			sender:SetPosition(Vector3(tonumber(v.homeX), tonumber(v.homeY), tonumber(v.homeZ)))
        end
	end
end

function Home:GetHome( args )
	local steamID = tostring(args.player:GetSteamId().id)
	local qry = SQL:Query("SELECT * FROM players_home WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		str = string.format("Ваш дом на: (%i x %i x %i)", tonumber(result[1].homeX), tonumber(result[1].homeY), tonumber(result[1].homeZ))
		args.player:SendChatMessage( str, Color( 115, 255, 203 ) )
	end
end

home = Home()