class 'SaveAndLoad'

function SaveAndLoad:__init()
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	self.one_handed = { Weapon.Handgun, Weapon.Revolver }

	self.ammo_counts = {
		[2] = { 12, 60 }, [4] = { 7, 35 }, [5] = { 30, 90 },
		[6] = { 3, 18 }, [11] = { 20, 100 }, [13] = { 6, 36 },
		[14] = { 4, 32 }, [16] = { 3, 12 }, [17] = { 5, 5 },
		[28] = { 26, 130 }
	}

	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_models (steamid VARCHAR UNIQUE, model_id INTEGER)" )
	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_weapons (steamid VARCHAR UNIQUE, two INTEGER, ammo_two_c INTEGER, ammo_two_r INTEGER, left INTEGER, ammo_left_c INTEGER, ammo_left_r INTEGER, right INTEGER, ammo_right_c INTEGER, ammo_right_r INTEGER)" )
end

function SaveAndLoad:PlayerJoin( args )
	self:LoadModel( args )
	self:LoadWeapons( args )
end

function SaveAndLoad:LoadModel( args )
    local qry = SQL:Query( "select model_id from players_models where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetModelId( tonumber(result[1].model_id) )
    end
end

function SaveAndLoad:LoadWeapons( args )
    local qry = SQL:Query( "SELECT two, ammo_two_c, ammo_two_r, left, ammo_left_c, ammo_left_r, right, ammo_right_c, ammo_right_r FROM players_weapons WHERE steamid = ?" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local weaponResult = qry:Execute()

    if #weaponResult == 1 then
		local row = weaponResult[1]
		args.player:ClearInventory()
		if tonumber( row.two ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Primary, Weapon( tonumber( row.two ), tonumber( row.ammo_two_c ), tonumber( row.ammo_two_r ) ) )
		end
		if tonumber( row.left ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Left, Weapon( tonumber( row.left ), tonumber( row.ammo_left_c ), tonumber( row.ammo_left_r ) ) )
		end
		if tonumber( row.right ) ~= 0 then
		    args.player:GiveWeapon( WeaponSlot.Right, Weapon( tonumber( row.right ), tonumber( row.ammo_right_c ), tonumber( row.ammo_right_r ) ) )
		end
    else
		args.player:ClearInventory()

		local one_id = table.randomvalue( self.one_handed )

		args.player:GiveWeapon( WeaponSlot.Right, Weapon( one_id, self.ammo_counts[one_id][1], self.ammo_counts[one_id][2] * 16 ) )
	end
end


function SaveAndLoad:PlayerQuit( args )
	self:SaveModel(args)
	self:SaveWeapons( args )
end

function SaveAndLoad:SaveModel( args )
    local cmd = SQL:Command( "insert or replace into players_models (steamid, model_id) values (?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    cmd:Bind( 2, args.player:GetModelId() )
    cmd:Execute()
end

function SaveAndLoad:SaveWeapons( args )
	if args.player:GetWorld() ~= DefaultWorld then return end
	local inventory = args.player:GetInventory()

	local two = 0
	local left = 0
	local right = 0

	local ammo_two_c = 0
	local ammo_two_r = 0
	local ammo_left_c = 0
	local ammo_left_r = 0
	local ammo_right_c = 0
	local ammo_right_r = 0

	for slot, weapon in pairs( inventory ) do
		if slot == 2 then
			two = weapon.id
			ammo_two_c = weapon.ammo_clip
			ammo_two_r = weapon.ammo_reserve
		elseif slot == 0 then
			left = weapon.id
			ammo_left_c = weapon.ammo_clip
			ammo_left_r = weapon.ammo_reserve
		elseif slot == 1 then
			right = weapon.id
			ammo_right_c = weapon.ammo_clip
			ammo_right_r = weapon.ammo_reserve
		end
	end

    local cmd = SQL:Command( "INSERT OR REPLACE INTO players_weapons (steamid, two, ammo_two_c, ammo_two_r, left, ammo_left_c, ammo_left_r, right, ammo_right_c, ammo_right_r) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    cmd:Bind( 2, two )
    cmd:Bind( 3, ammo_two_c )
    cmd:Bind( 4, ammo_two_r )
    cmd:Bind( 5, left )
    cmd:Bind( 6, ammo_left_c )
    cmd:Bind( 7, ammo_left_r )
    cmd:Bind( 8, right )
    cmd:Bind( 9, ammo_right_c )
    cmd:Bind( 10, ammo_right_r )
    cmd:Execute()
end

saveandload = SaveAndLoad()
