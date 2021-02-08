class 'Freeroam'

continuousFireTable = { [66] = true, [116] = true }

velueses = { 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 20, 15, 25, 35, 45, 55, 65, 75, 85, 95, 120, 170 }
veluesesTw = { 200, 250, 300, 350, 400, 450, 500 }
veluesesTh = { 550, 600, 650, 700, 750, 800, 850, 950, 1000 }

function Freeroam:__init()
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_poss (steamid VARCHAR UNIQUE, possX INTEGER, possY INTEGER, possZ INTEGER)" )
    SQL:Execute( "CREATE TABLE IF NOT EXISTS players_kills (steamid VARCHAR UNIQUE, kills INTEGER)")

    self.vehicles               = {}
    self.player_spawns          = {}
    self.teleports              = {}
    self.hotspots               = {}
    self.kills                  = {}

    self.one_handed             = { Weapon.Handgun, Weapon.Revolver, Weapon.SMG, 
                                    Weapon.SawnOffShotgun }

    self.two_handed             = { Weapon.Assault, Weapon.Shotgun, 
                                    Weapon.Sniper, Weapon.MachineGun }

    self.ammo_counts            = {
        [2] = { 12, 60 }, [4] = { 7, 35 }, [5] = { 30, 90 },
        [6] = { 3, 18 }, [11] = { 20, 100 }, [13] = { 6, 36 },
        [14] = { 4, 32 }, [16] = { 3, 12 }, [17] = { 5, 5 },
        [28] = { 26, 130 }
    }

    self:LoadSpawns( "spawns.txt" )

    Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
    Events:Subscribe( "PlayerDeath", self, self.PlayerDeath )
    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "PlayerSpawn", self, self.PlayerRecon )
    Network:Subscribe( "GiveMeWeapon", self, self.GiveMeWeapon )
    Network:Subscribe( "PlayerSpawn", self, self.PlayerSpawn )
    Network:Subscribe( "PlayerSpawnAndPassive", self, self.PlayerSpawnAndPassive )
end

function Freeroam:LoadSpawns( filename )
    print("Opening " .. filename)
    local file = io.open( filename, "r" )

    if file == nil then
        print( "No spawns.txt, aborting loading of spawns" )
        return
    end

    local timer = Timer()

    for line in file:lines() do
        if line:sub(1,1) == "V" then
            self:ParseVehicleSpawn( line )
        elseif line:sub(1,1) == "P" then
            self:ParsePlayerSpawn( line )
        elseif line:sub(1,1) == "T" then
            self:ParseTeleport( line )
        end
    end

    for k, v in pairs(self.teleports) do
        table.insert( self.hotspots, { k, v } )
    end

    print( string.format( "Loaded spawns, %.02f seconds", 
                            timer:GetSeconds() ) )

    file:close()
end

function Freeroam:ParseVehicleSpawn( line )
    line = line:gsub( "VehicleSpawn%(", "" )
    line = line:gsub( "%)", "" )
    line = line:gsub( " ", "" )

    local tokens = line:split( "," )   

    local model_id_str  = tokens[1]

    local pos_str       = { tokens[2], tokens[3], tokens[4] }
    local ang_str       = { tokens[5], tokens[6], tokens[7], tokens[8] }

    local args = {}

    args.model_id       = tonumber( model_id_str )
    args.position       = Vector3(   tonumber( pos_str[1] ), 
                                    tonumber( pos_str[2] ),
                                    tonumber( pos_str[3] ) )

    args.angle          = Angle(    tonumber( ang_str[1] ),
                                    tonumber( ang_str[2] ),
                                    tonumber( ang_str[3] ),
                                    tonumber( ang_str[4] ) )

    if #tokens > 8 then
        if tokens[9] ~= "NULL" then
            -- If there's a template, set it
            args.template = tokens[9]
        end

        if #tokens > 9 then
            if tokens[10] ~= "NULL" then
                -- If there's a decal, set it
                args.decal = tokens[10]
            end
        end
    end

    args.enabled = true
    local v = Vehicle.Create( args )

    self.vehicles[ v:GetId() ] = v
end

function Freeroam:ParsePlayerSpawn( line )
    line = line:gsub( "P", "" )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create table containing appropriate strings
    local pos_str       = { tokens[1], tokens[2], tokens[3] }
    -- Create vector
    local vector        = Vector3(   tonumber( pos_str[1] ), 
                                    tonumber( pos_str[2] ),
                                    tonumber( pos_str[3] ) )

    table.insert( self.player_spawns, vector )
end

function Freeroam:ParseTeleport( line )
    -- Remove start, spaces
    line = line:sub( 3 )
    line = line:gsub( " ", "" )

    -- Split into tokens
    local tokens        = line:split( "," )
    -- Create table containing appropriate strings
    local pos_str       = { tokens[2], tokens[3], tokens[4] }
    -- Create vector
    local vector        = Vector3(   tonumber( pos_str[1] ), 
                                    tonumber( pos_str[2] ),
                                    tonumber( pos_str[3] ) )

    self.teleports[ tokens[1] ] = vector
end

function Freeroam:GiveNewWeapons( p )
    p:ClearInventory()

    local one_id = table.randomvalue( self.one_handed )
    local two_id = table.randomvalue( self.two_handed )

    p:GiveWeapon( WeaponSlot.Right, 
        Weapon( one_id, 
            self.ammo_counts[one_id][1],
            self.ammo_counts[one_id][2] * 16 ) )
    p:GiveWeapon( WeaponSlot.Primary, 
        Weapon( two_id, 
            self.ammo_counts[two_id][1],
            self.ammo_counts[two_id][2] * 16 ) )
end

function Freeroam:RandomizePosition( pos, magnitude, offset )
    if magnitude == nil then
        magnitude = 10
    end

    if offset == nil then
        offset = 250
    end

    return pos + Vector3(    math.random( -magnitude, magnitude ), 
                            math.random( -magnitude, 0 ) + offset, 
                            math.random( -magnitude, magnitude ) )
end

ChatHandlers = {}

function ChatHandlers:teleport( args )
    local dest = args[1]

    -- Handle user help
    if dest == "" or dest == nil or dest == "help" then
        args.player:SendChatMessage( "Места для телепортации: ", Color( 0, 255, 0 ) )

        local i = 0
        local str = ""

        for k,v in pairs(self.teleports) do
            -- Send message every 4 teleports
            i = i + 1
            str = str .. k

            if i % 4 ~= 0 then
                -- If it's not the last teleport of the line, add a comma
                str = str .. ", "
            else
                args.player:SendChatMessage( "    " .. str, Color( 255, 255, 255 ) )
                str = ""
            end
        end
    elseif self.teleports[dest] ~= nil then
        if args.player:GetWorld() ~= DefaultWorld then
            args.player:SendChatMessage( "Вы не в главном мире! Выйдите из любых режимов и повторите попытку.", Color( 255, 0, 0 ) )
            return
        end

        -- If the teleport is valid, teleport them there
        args.player:SetPosition( self:RandomizePosition( self.teleports[dest] ) )
    else
        -- Notify of invalid teleport
        args.player:SendChatMessage( "Недопустимый пункт телепортации!", Color( 255, 0, 0 ) )
    end
end

ChatHandlers.tp = ChatHandlers.teleport

function Freeroam:ClientModuleLoad( args )
    Network:Send( args.player, "Горячая точка", self.hotspots )
end

function Freeroam:ModuleUnload( args )
    for k,v in pairs(self.vehicles) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

function Freeroam:ModulesLoad()
    for _, v in ipairs(self.player_spawns) do
        Events:Fire( "SpawnPoint", v )
    end

    for _, v in pairs(self.teleports) do
        Events:Fire( "TeleportPoint", v )
    end
end

function Freeroam:PlayerRecon( args )
    local default_spawn = true

	if args.player:GetWorld() == DefaultWorld then
		if #self.player_spawns > 0 then
			local position = table.randomvalue( self.player_spawns )
			default_spawn = false
		end
	end

    return default_spawn
end

function Freeroam:PlayerSpawn( args, sender )
    local default_spawn = true

	if sender:GetWorld() == DefaultWorld then
		if #self.player_spawns > 0 then
			local position = table.randomvalue( self.player_spawns )

			sender:SetPosition( self:RandomizePosition( position ) )
			default_spawn = false
		end
	end

    return default_spawn
end

function Freeroam:PlayerSpawnAndPassive( args, sender )
    sender:SetNetworkValue( "Passive", args.pvalue )
    local vehicle = sender:GetVehicle()
    if IsValid(vehicle) and vehicle:GetDriver() == sender then
        vehicle:SetInvulnerable( false )
    end
end


function Freeroam:PlayerJoin( args )
	self:GiveNewWeapons( args.player )
	local steamID = tostring(args.player:GetSteamId().id)
	local qry = SQL:Query("SELECT * FROM players_poss WHERE steamid = ?")
	qry:Bind(1, steamID)
    local result = qry:Execute()

	if #result > 0 then
		for i, v in ipairs(result) do
			args.player:SetPosition( Vector3(tonumber(v.possX), tonumber(v.possY), tonumber(v.possZ)) + Vector3( 0, 250, 0 ) )
        end
    end

    local qry = SQL:Query( "select kills from players_kills where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetNetworkValue( "Kills", tonumber(result[1].kills) )
    else
        args.player:SetNetworkValue( "Kills", 0 )
    end
end

function Freeroam:GiveMeWeapon( args, sender )
	self:GiveNewWeapons( sender )
end

function Freeroam:PlayerQuit( args )
    if not args.player:GetValue("SavePos") then
        local playerPos = args.player:GetPosition()
        local steamID = tostring(args.player:GetSteamId().id)

        local qry = SQL:Query('INSERT OR REPLACE INTO players_poss (steamid, possX, possY, possZ) VALUES(?, ?, ?, ?)')
        qry:Bind(1, tostring(steamID))
        qry:Bind(2, playerPos.x)
        qry:Bind(3, playerPos.y)
        qry:Bind(4, playerPos.z)
        qry:Execute()
    else
        local playerPos = table.randomvalue( self.player_spawns )
        local steamID = tostring(args.player:GetSteamId().id)
    
        local qry = SQL:Query('INSERT OR REPLACE INTO players_poss (steamid, possX, possY, possZ) VALUES(?, ?, ?, ?)')
        qry:Bind(1, tostring(steamID))
        qry:Bind(2, playerPos.x)
        qry:Bind(3, playerPos.y)
        qry:Bind(4, playerPos.z)
        qry:Execute()
    end

    self.kills[ args.player:GetId() ] = nil

    local cmd = SQL:Command( "insert or replace into players_kills (steamid, kills) values (?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    cmd:Bind( 2, args.player:GetValue( "Kills" ) )
    cmd:Execute()
end

function Freeroam:PlayerChat( args )
    local msg = args.text

    if msg:sub(1, 1) ~= "/" then
        return true
    end

    msg = msg:sub(2)

    local cmd_args = msg:split(" ")
    local cmd_name = cmd_args[1]

    table.remove( cmd_args, 1 )
    cmd_args.player = args.player

    local func = ChatHandlers[string.lower(cmd_name)]
    if func ~= nil then
        -- If it's valid, call it
        func( self, cmd_args )
    end

    return false
end

function Freeroam:PlayerDeath( args )
    if args.player:GetWorld() ~= DefaultWorld then return end
    if args.killer and args.killer:GetSteamId() ~= args.player:GetSteamId() then
        if args.killer:GetValue( "Passive" ) then
		    args.killer:SetHealth( 0 )
		else
            if args.killer:GetValue( "Kills" ) then
                if args.killer:GetValue( "Kills" ) < 1000 then
                    self.kills[ args.killer:GetId() ] = args.killer:GetValue( "Kills" ) + 1
                    args.killer:SetNetworkValue( "Kills", self.kills[ args.killer:GetId() ] )
                end
                if args.player:GetValue( "Kills" ) == 0 then
                    args.killer:SetMoney( args.killer:GetMoney() + 0 )
                    if continuousFireTable[args.killer:GetEquippedWeapon().id] == true then
                        Network:Send( args.killer, "KillerStats", { text = "Без награды :c, используйте обычное оружие!" } )
                    end
                elseif args.player:GetValue( "Kills" ) >= 0 then
                    if not continuousFireTable[args.killer:GetEquippedWeapon().id] == true then
                        args.killer:SetMoney( args.killer:GetMoney() + args.player:GetValue( "Kills" ) * 10 )
                        args.player:SetNetworkValue( "Kills", 0 )
                    else
                        Network:Send( args.killer, "KillerStats", { text = "Без награды :c, используйте обычное оружие!" } )
                    end
                end
            end
        end
        Network:Send( args.player, "PlayerKilled" )
	end
end

freeroam = Freeroam()
