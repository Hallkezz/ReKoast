-- Player extension methods
function Player:SendErrorMessage( str )
	self:SendChatMessage( "[Магазин] ", Color.White, str, Color.DarkGray )
end

function Player:SendSuccessMessage( str )
	self:SendChatMessage( "[Магазин] ", Color.White, str, Color( 255, 170, 0 ) )
end

function Shop:__init()
	self.items      = {}
	self.vehicles   = {}
	self.vehicles2   = {}
	self.ammo_counts            = {
--		ID			Mag		Reserve			Weapon Name
        [2]		= {	12,		300 },		--	Pistol
		[43]	= {	125,	500 },		--	Bubble Blaster
		[4]		= {	7,		175 },		--	Revolver
        [6]		= {	3,		150 },		--	Sawed-Off Shotgun
		[5]		= {	30,		750 },		--	Submachine Gun
		[13]	= {	6,		150 },		--	Shotgun
		[11]	= {	20,		500 },		--	Assault Rifle
        [28]	= {	26,		650 },		--	Machine Gun
        [14]	= {	4,		100 },		--	Sniper Rifle
		[17]	= {	5,		125 },		--	Grenade Launcher
		[16]	= {	3,		75 },		--	Rocket Launcher
		[26]	= {	100,	500 },		--	?????
		[66]	= {	116,	111 },		--	Panay's Rocket Launcher Modification
		[103]	= {	6,		150 },		--	Rico's Signature Gun			DLC
		[101]	= {	100,	5000 },		--	Air Propulsion Gun				DLC
		[100]	= {	24,		600 },		--	Bull's Eye Assault Rifle		DLC
		[104]	= {	8,		400 },		--	Quad Rocket Launcher			DLC
		[102]	= {	1,		125 },		--	Cluster Bomb Launcher			DLC
		[105]	= {	4,		200 },		--	Multi-Lock Missile Launcher		DLC
		[31]	= {	3,		75 },		--	SAM
		[116]	= {	3,		75 },		--	RocketARVE
		[129]	= {	3,		75 },		--	HeavyMachineGun
	}

	self:CreateItems()
	self.skin = nil

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Network:Subscribe( "GiveMeParachute", self, self.GiveMeParachute )
	Network:Subscribe( "Skin", self, self.Skin )
	Network:Subscribe( "HealMe", self, self.HealMe )
	Network:Subscribe( "ClearInv", self, self.ClearInv )

	Network:Subscribe( "PlayerFired", self, self.PlayerFired )
	Network:Subscribe( "ColorChanged", self, self.ColorChanged )

	SQL:Execute( "CREATE TABLE IF NOT EXISTS buymenu_parachutes (steamid VARCHAR UNIQUE, model_id INTEGER)")
	SQL:Execute( "CREATE TABLE IF NOT EXISTS buymenu_colors (steamid VARCHAR UNIQUE, r1 INTEGER, g1 INTEGER, b1 INTEGER, r2 INTEGER, g2 INTEGER, b2 INTEGER)")
	SQL:Execute( "CREATE TABLE IF NOT EXISTS buymenu_players_appearances (steamid VARCHAR UNIQUE, head VARCHAR, covering VARCHAR, hair VARCHAR, face VARCHAR, neck VARCHAR, back VARCHAR, torso VARCHAR, righthand VARCHAR, lefthand VARCHAR, legs VARCHAR, rightfoot VARCHAR, leftfoot VARCHAR)")

	-- Save color
	Network:Subscribe( "BuyMenuGetSaveColor", self, self.GetSaveColor )
	Network:Subscribe( "BuyMenuSaveColor", self, self.SaveColor )
end

function Shop:Skin( message )
    self.skin = message
end

function Shop:HealMe( args, sender )
    sender:SetHealth( 1 )
end

function Shop:ClearInv( args, sender )
    sender:ClearInventory()
end

function Shop:SaveColor( args, player )
	local tone1 = args.tone1
	local tone2 = args.tone2

	local cmd = SQL:Command("INSERT OR REPLACE INTO buymenu_colors (steamid, r1, g1, b1, r2, g2, b2) values (?, ?, ?, ?, ?, ?, ?)")
    cmd:Bind(1, player:GetSteamId().id)
    cmd:Bind(2, tone1.r)
    cmd:Bind(3, tone1.g)
    cmd:Bind(4, tone1.b)
    cmd:Bind(5, tone2.r)
    cmd:Bind(6, tone2.g)
    cmd:Bind(7, tone2.b)
    cmd:Execute()
end

function Shop:GetSaveColor( args, player )
    local colorQuery = SQL:Query("SELECT r1, g1, b1, r2, g2, b2 FROM buymenu_colors WHERE steamid = ?")
    colorQuery:Bind(1, player:GetSteamId().id)
    local colorResult = colorQuery:Execute()

    if #colorResult == 1 then
		local row = colorResult[1]
		Network:Send(player, "BuyMenuSavedColor", {
			tone1 = Color(tonumber(row.r1), tonumber(row.g1), tonumber(row.b1)),
			tone2 = Color(tonumber(row.r2), tonumber(row.g2), tonumber(row.b2))
		})
    end
end

function Shop:ColorChanged( args, sender )
    local veh = sender:GetVehicle()
	if IsValid(veh) then
		if IsValid(self.vehicles[sender:GetId()]) then
			if self.vehicles[sender:GetId()]:GetId() == veh:GetId() then
				veh:SetColors( args.tone1, args.tone2 )
			else
				sender:SendChatMessage( "Это не ваш транспорт!", Color( 255, 0, 0 ) )
			end
		end
    end
end

-- Events
function Shop:PlayerJoin( args )
	self:SetPlayerAppearancesFromDB(args)
end

function Shop:GiveMeParachute( args, sender )
	self:SetParachutesFromDB(args, sender)
end

function Shop:SetParachutesFromDB( args, sender )
    local qry = SQL:Query( "select model_id from buymenu_parachutes where steamid = (?)" )
    qry:Bind( 1, sender:GetSteamId().id )
    local result = qry:Execute()

    if #result > 0 then
        Network:Send( sender, "Parachute", result[1].model_id )
    end
end

function Shop:SetPlayerAppearancesFromDB( args )
    local qry = SQL:Query( "SELECT head, covering, hair, face, neck, back, torso, righthand, lefthand, legs, rightfoot, leftfoot FROM buymenu_players_appearances where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

    if #result > 0 then
		args.player:SetNetworkValue( "AppearanceHat", result[1].head) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceCovering", result[1].covering) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceHair", result[1].hair) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceFace", result[1].face) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceNeck", result[1].neck) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceBack", result[1].back) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceTorso", result[1].torso) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceRightHand", result[1].righthand) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceLeftHand", result[1].lefthand) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceLegs", result[1].legs) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceRightFoot", result[1].rightfoot) -- Store the Appearance Item as a player value
		args.player:SetNetworkValue( "AppearanceLeftFoot", result[1].leftfoot) -- Store the Appearance Item as a player value
    end
end

function Shop:PlayerQuit( args )
    if IsValid( self.vehicles[ args.player:GetId() ] ) then
        self.vehicles[ args.player:GetId() ]:Remove()
        self.vehicles[ args.player:GetId() ] = nil
    end
	if IsValid( self.vehicles2[ args.player:GetId() ] ) then
        self.vehicles2[ args.player:GetId() ]:Remove()
        self.vehicles2[ args.player:GetId() ] = nil
    end
end

function Shop:ModuleUnload()
    for k, v in pairs(self.vehicles) do
        if IsValid( v ) then
            v:Remove()
        end
    end
	for k, v in pairs(self.vehicles2) do
        if IsValid( v ) then
            v:Remove()
        end
    end
end

function Shop:PlayerFired( args, player )
    local category_id       = args[1]
    local subcategory_name  = args[2]
    local index             = args[3]
    local tone1             = args[4]
    local tone2             = args[5]

    if player:GetWorld() ~= DefaultWorld then
        player:SendErrorMessage( "Вы не можете использовать это здесь!" )
        return
    end

    local item = self.items[category_id][subcategory_name][index]

    if item == nil then
        player:SendErrorMessage( "Недопустимый элемент!" )
        return
    end

	if player:GetMoney() < item:GetPrice() then
        local str = string.format(
            "Недостаточно денег! Требуется: $%i",
            item:GetPrice() - player:GetMoney() )

		Network:Send( player, "NoMoneyText", str )
        return
	end 

    local success, err    

    if category_id == self.types["Транспорт"] then
        success, err = self:BuyVehicle( player, item, tone1, tone2 )
    elseif category_id == self.types["Оружие"] then
        success, err = self:BuyWeapon( player, item )
    elseif category_id == self.types["Персонаж"] then
        success, err = self:BuyModel( player, item )
	elseif category_id == self.types["Внешность"] then
        success, err = self:BuyAppearance( player, item )
	elseif category_id == self.types["Остальное >"] then
        success, err = self:BuyParachutes( player, item )
    end

	if success then
		Network:Send( player, "PlayerFired" )
        player:SetMoney( player:GetMoney() - item:GetPrice() )

        local str = string.format(
            "%s!",
            item:GetName(),
            item:GetPrice(),
            player:GetMoney() )

		Network:Send( player, "Text", str )
    else
		Network:Send( player, "Text", err )
    end
end

function Shop:BuyVehicle( player, item, tone1, tone2 )
	if item:GetRank() ~= nil then
		if player:GetValue( "Tag" ) == "VIP" or player:GetValue( "Tag" ) == "YouTuber" or player:GetValue( "Tag" ) == "ModerD" or 
		player:GetValue( "Tag" ) == "AdminD" or player:GetValue( "Tag" ) == "Admin" or player:GetValue( "Tag" ) == "GlAdmin" or player:GetValue( "Tag" ) == "Owner" then
			self:ExecuteVehicle( player, item, tone1, tone2 )
			return true, ""
		else
			return false, "У вас отсутствует VIP статус!", Network:Send( player, "NoVipText" )
		end
	end

	if not player:HasVehicleDLC(item:GetModelId()) then
		return false, "У вас отсутствует DLC!"
	end

	if player:GetState() == PlayerState.InVehiclePassenger then
        return false, "Вы не можете заказать транспорт на пассажирском месте!"
	end

	self:ExecuteVehicle( player, item, tone1, tone2 )
    return true, ""	--	Return true must be right after the execution else the confirmation message gives an error.
end

function Shop:ExecuteVehicle( player, item, tone1, tone2 )
    if player:InVehicle() == true then
			if IsValid( self.vehicles[ player:GetId() ] ) and player:GetVehicle() == self.vehicles[ player:GetId() ] then
				player:GetVehicle():Remove()
				self.vehicles[ player:GetId() ] = nil
			elseif IsValid( self.vehicles2[ player:GetId() ] ) and player:GetVehicle() == self.vehicles2[ player:GetId() ] then
				player:GetVehicle():Remove()
				self.vehicles2[ player:GetId() ] = self.vehicles[ player:GetId() ]
			elseif IsValid( self.vehicles2[ player:GetId() ] ) then
				player:GetVehicle():Remove()
				self.vehicles2[ player:GetId() ]:Remove()
				self.vehicles2[ player:GetId() ] = self.vehicles[ player:GetId() ]
				self.vehicles[ player:GetId() ] = nil
			else
				player:GetVehicle():Remove()
				self.vehicles2[ player:GetId() ] = self.vehicles[ player:GetId() ]
				self.vehicles[ player:GetId() ] = nil
			end
    elseif IsValid( self.vehicles2[ player:GetId() ] ) then
            self.vehicles2[ player:GetId() ]:Remove()
            self.vehicles2[ player:GetId() ] = self.vehicles[ player:GetId() ]
    elseif IsValid( self.vehicles[ player:GetId() ]) then
            self.vehicles2[ player:GetId() ] = self.vehicles[ player:GetId() ]
			self.vehicles[ player:GetId() ] = nil
    end	

    if IsValid( self.vehicles[ player:GetId() ] ) then
        self.vehicles[ player:GetId() ]:Remove()
        self.vehicles[ player:GetId() ] = nil
    end
	
    local args = {}
    args.model_id           = item:GetModelId()
	
	if item:GetTemplate() ~= nil then
		args.template = item:GetTemplate()
	end

	args.decal = self.skin

    args.position           = player:GetPosition()
    args.angle              = player:GetAngle()
    args.linear_velocity    = player:GetLinearVelocity() * 1.1
    args.enabled            = true
    args.tone1              = tone1
    args.tone2              = tone2

    local v = Vehicle.Create( args )
    self.vehicles[ player:GetId() ] = v

    v:SetUnoccupiedRespawnTime( nil )
	v:SetDeathRemove(true)
    player:EnterVehicle( v, VehicleSeat.Driver )

    return true, ""
end

function Shop:BuyWeapon( player, item )
	if item:GetRank() ~= nil then
		if player:GetValue( "Tag" ) == "VIP" or player:GetValue( "Tag" ) == "YouTuber" or player:GetValue( "Tag" ) == "ModerD" or 
		player:GetValue( "Tag" ) == "AdminD" or player:GetValue( "Tag" ) == "Admin" or player:GetValue( "Tag" ) == "GlAdmin" or player:GetValue( "Tag" ) == "Owner" then
			self:ExecuteWeapon( player, item )
			return true, ""
		else
			return false, "У вас отсутствует VIP статус!", Network:Send( player, "NoVipText" )
		end
	end

	if not player:HasWeaponDLC(item:GetModelId()) then
		return false, "У вас отсутствует DLC!"
	end

	self:ExecuteWeapon( player, item )
    return true, ""	--	Return true must be right after the execution else the confirmation message gives an error.
end

function Shop:ExecuteWeapon( player, item )
    player:GiveWeapon( item:GetSlot(), Weapon( item:GetModelId(), self.ammo_counts[item:GetModelId()][1] or 0, (self.ammo_counts[item:GetModelId()][2] or 200) * 6 ) )

    return true, ""
end

function Shop:BuyModel( player, item )
	if item:GetRank() ~= nil then
		if player:GetValue( "Tag" ) == "VIP" or player:GetValue( "Tag" ) == "YouTuber" or player:GetValue( "Tag" ) == "ModerD" or 
		player:GetValue( "Tag" ) == "AdminD" or player:GetValue( "Tag" ) == "Admin" or player:GetValue( "Tag" ) == "GlAdmin" or player:GetValue( "Tag" ) == "Owner" then
			self:ExecuteModel( player, item )
			return true, ""
		else
			return false, "У вас отсутствует VIP статус!", Network:Send( player, "NoVipText" )
		end
	end
	self:ExecuteModel( player, item )
    return true, ""	--	Return true must be right after the execution else the confirmation message gives an error.
end

function Shop:ExecuteModel( player, item )
    player:SetModelId( item:GetModelId() )

    return true, ""
end

function Shop:BuyAppearance( player, item )
	if item:GetRank() ~= nil then
	if player:GetValue( "Tag" ) == "VIP" or player:GetValue( "Tag" ) == "YouTuber" or player:GetValue( "Tag" ) == "ModerD" or 
	player:GetValue( "Tag" ) == "AdminD" or player:GetValue( "Tag" ) == "Admin" or player:GetValue( "Tag" ) == "GlAdmin" or player:GetValue( "Tag" ) == "Owner" then
			self:ExecuteAppearance( player, item )
			return true, ""
		else
			return false, "У вас отсутствует VIP статус!", Network:Send( player, "NoVipText" )
		end
	end
	self:ExecuteAppearance( player, item )
    return true, ""	--	Return true must be right after the execution else the confirmation message gives an error.
end

function Shop:ExecuteAppearance( player, item )
	local itemModel = item:GetModelId()
	local itemType = item:GetType()
	local qry = SQL:Query( "SELECT head, covering, hair, face, neck, back, torso, righthand, lefthand, legs, rightfoot, leftfoot FROM buymenu_players_appearances where steamid = (?)" )
	qry:Bind( 1, player:GetSteamId().id )
	local result = qry:Execute()

	if #result > 0 then
		if itemType == "Head" then
			player:SetNetworkValue( "AppearanceHat", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET head = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Covering" then
			player:SetNetworkValue( "AppearanceCovering", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET covering = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Hair" then
			player:SetNetworkValue( "AppearanceHair", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET hair = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Face" then
			player:SetNetworkValue( "AppearanceFace", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET face = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Neck" then
			player:SetNetworkValue( "AppearanceNeck", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET neck = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Back" then
			player:SetNetworkValue( "AppearanceBack", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET back = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Torso" then
			player:SetNetworkValue( "AppearanceTorso", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET torso = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "RightHand" then
			player:SetNetworkValue( "AppearanceRightHand", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET righthand = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "LeftHand" then
			player:SetNetworkValue( "AppearanceLeftHand", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET lefthand = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Legs" then
			player:SetNetworkValue( "AppearanceLegs", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET legs = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "RightFoot" then
			player:SetNetworkValue( "AppearanceRightFoot", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET rightfoot = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "LeftFoot" then
			player:SetNetworkValue( "AppearanceLeftFoot", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "UPDATE buymenu_players_appearances SET leftfoot = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		end
	else
		if itemType == "Head" then
			player:SetNetworkValue( "AppearanceHat", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, head) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Hair" then
			player:SetNetworkValue( "AppearanceHair", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, hair) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Covering" then
			player:SetNetworkValue( "AppearanceCovering", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, covering) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Face" then
			player:SetNetworkValue( "AppearanceFace", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, face) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Neck" then
			player:SetNetworkValue( "AppearanceNeck", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, neck) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Back" then
			player:SetNetworkValue( "AppearanceBack", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE into buymenu_players_appearances (steamid, back) values (?, ?)" )
			cmd:Bind( 1, player:GetSteamId().id )
			cmd:Bind( 2, itemModel )
			cmd:Execute()
		elseif itemType == "Torso" then
			player:SetNetworkValue( "AppearanceTorso", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET torso = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "RightHand" then
			player:SetNetworkValue( "AppearanceRightHand", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET righthand = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "LeftHand" then
			player:SetNetworkValue( "AppearanceLeftHand", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET lefthand = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "Legs" then
			player:SetNetworkValue( "AppearanceLegs", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET legs = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "RightFoot" then
			player:SetNetworkValue( "AppearanceRightFoot", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET rightfoot = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		elseif itemType == "LeftFoot" then
			player:SetNetworkValue( "AppearanceLeftFoot", itemModel) -- Store the Appeance Item as a player value
			local cmd = SQL:Command( "INSERT or REPLACE buymenu_players_appearances SET leftfoot = (?) WHERE steamid = (?)" )
			cmd:Bind( 1, itemModel )
			cmd:Bind( 2, player:GetSteamId().id )
			cmd:Execute()
		end
	end
	return true, ""
end

function Shop:BuyParachutes( player, item )
	self:ExecuteParachutes( player, item )
    return true, ""	--	Return true must be right after the execution else the confirmation message gives an error.
end

function Shop:ExecuteParachutes( player, item )
	Network:Send( player, "Parachute", item:GetModelId() )

    local cmd = SQL:Command( "insert or replace into buymenu_parachutes (steamid, model_id) values (?, ?)" )
    cmd:Bind( 1, player:GetSteamId().id )
    cmd:Bind( 2, item:GetModelId() )
    cmd:Execute()

    return true, ""
end

shop = Shop()
