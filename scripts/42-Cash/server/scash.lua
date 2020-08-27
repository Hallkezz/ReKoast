class "CashCrate"

function CashCrate:__init()
	self.resptime = 21600

	RefillQueue = {}

	ents = {}
	poss = {}

	os_clock = Timer()

	refill_loot_args = {}

	time = Timer()
	time2 = Timer()

	SQL:Execute( "CREATE TABLE IF NOT EXISTS crates (id INTEGER, loc VARCHAR, cash INTEGER)")
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Network:Subscribe( "66cratelist", self, self.WTFCrateList )
	Network:Subscribe( "66crate_remove", self, self.WTFCrateRemove )
	Network:Subscribe( "SyncReq", self, self.SyncPlayerData )

	local counter = 0
	local file = io.open("lootspawns.txt", "r")
	if file ~= nil then
		local args = {}
		args.world = DefaultWorld
		for line in file:lines() do
			line = line:trim()

			if string.len(line) > 0 then
				line = line:gsub("LootSpawn%(", "")
				line = line:gsub("%)", "")
				line = line:gsub(" ", "")
				local tokens = line:split(",")
				local mdl_str = tokens[1]
				local model = tostring(mdl_str)
				if model == "geo.cbb.eez/go152-a.lod" then
					local pos_str = {tokens[3], tokens[4], tokens[5]}
					local pos = Vector3( tonumber(pos_str[1]), tonumber(pos_str[2]), tonumber(pos_str[3]) )
					local ang_str = {tokens[6], tokens[7], tokens[8]}
					local angle = Angle( tonumber(ang_str[1]), tonumber(ang_str[2]), tonumber(ang_str[3]) )

					if pos:Distance2D( Vector3 ( -6568, 208, -3442 ) ) > 650 and pos:Distance2D( Vector3( 13199, 1094, -4928 ) ) > 250 and pos:Distance2D( Vector3( 2150, 711, 1397 ) ) > 300 and pos:Distance2D( Vector3( -1573, 358, 990 ) ) > 750 and pos:Distance2D( Vector3( 13753, 270, -2373 ) ) > 900 and pos:Distance2D( Vector3( -13603, 422, -13746 ) ) > 900 then

					local ent = StaticObject.Create({
						position = pos,
						angle = angle,
						model = "pickup.boost.cash.eez/pu05-a.lod",
						collision = "pickup.boost.cash.eez/pu05_lod1-a_col.pfx",
						world = DefaultWorld
					})

					ent:SetStreamDistance( 200 )
					ent:SetNetworkValue( "Cash", true )

					local objid = ent:GetId()
					local mult = math.random(0, 4)
					local cash = 5
					if mult == 0 then cash = 25
					elseif mult == 1 then cash = 25
					elseif mult == 2 then cash = 25
					elseif mult == 3 then cash = 25
					elseif mult == 4 then cash = 50 end

					table.insert(ents, {ent = ent, cash = cash})
					table.insert(poss, { pos = pos, id = ent:GetId() })

					counter = counter+1
					end
				end
			end
		end
		file:close()
		print( "Loaded " .. counter .. " cashes." )
	else
		print( "Fatal Error: Could not load loot from file" )
	end
end

function CashCrate:PostTick()
	if time:GetSeconds() > 5 then
		time:Restart()
	end

	if time2:GetSeconds() > 5 then
		local tosync = {}
		local current_time = os_clock:GetSeconds()
		for old_time, val_table in pairs(RefillQueue) do
			local tier = val_table.tier
			local itime = math.abs(current_time - old_time)
			if itime > self.resptime then
				local pos = val_table.pos
				local angle = val_table.ang

				local ent = StaticObject.Create({
					position = pos,
					angle = angle,
					model = "pickup.boost.cash.eez/pu05-a.lod",
					collision = "pickup.boost.cash.eez/pu05_lod1-a_col.pfx",
					world = DefaultWorld
				})

				ent:SetStreamDistance( 200 )
				ent:SetNetworkValue( "Cash", true )

				local objid = ent:GetId()
				local mult = math.random(0, 4)
				local cash = 5
				if mult == 0 then cash = 25
				elseif mult == 1 then cash = 25
				elseif mult == 2 then cash = 25
				elseif mult == 3 then cash = 25
				elseif mult == 4 then cash = 50 end

				table.insert(ents, {ent = ent, cash = cash})
				table.insert(poss, { pos = ent:GetPosition(), id = ent:GetId() })
				table.insert(tosync, { pos = ent:GetPosition(), id = ent:GetId() })

				RefillQueue[old_time] = nil
			end
		end
		time2:Restart()

		for p in Server:GetPlayers() do
			Network:Send(p, "SyncTriggers", tosync)
		end
	end
end

function CashCrate:onSyncRequest( source )
	self:SyncPlayerData(source);
end

function CashCrate:SyncPlayerData( player )
	poss = {}
	for _,ent2 in pairs(ents) do
		if IsValid(ent2.ent) then
			table.insert(poss, { pos = ent2.ent:GetPosition(), id = ent2.ent:GetId() })
		end
	end
	Network:Send( player, "SyncTriggers", poss )
end

function CashCrate:ModuleUnload()
	for _,ent2 in pairs(ents) do
		if IsValid(ent2.ent) then
			ent2.ent:Remove() 
		end
	end
end

function CashCrate:WTFCrateList( crates )
	local cmd = SQL:Query("SELECT * FROM crates")
	local result = cmd:Execute()
	for k in pairs(result) do
		crates[k] = result[k].loc
	end
	return 0
end

function CashCrate:WTFCrateRemove( args, ply )
	ent = StaticObject.GetById( args )

	local cnt = 0

	for _,ent2 in pairs(ents) do
		if ent2 ~= nil and ent2.ent ~= nil then
			if IsValid(ent2.ent)then
				if ent2.ent == ent then
					ply:SetMoney( ply:GetMoney() + 25 )

					refill_loot_args.pos = ent:GetPosition()
					refill_loot_args.ang = ent:GetAngle()
					refill_loot_args.cidx = ent:GetCellId().x
					refill_loot_args.cidy = ent:GetCellId().y
					RefillQueue[os_clock:GetSeconds() + math.random()] = Copy(refill_loot_args)

					for p in Server:GetPlayers() do
						Network:Send( p, "SyncTriggersRemove", { id = ent2.ent:GetId() } )
					end

					ent2.ent:Remove()
					ent2 = nil
					break
				end
			end
		end
	end
	
	Network:Send( ply, "66playsound", cnt )
end

function CashCrate:CrateRemove( ply, ent )
	Network:Send( ply, "66playsound", ply )

	for _,ent2 in pairs(ents) do
		if ent2 == ent then
			ply:SetMoney( ply:GetMoney() + 25 )
			print( ent2.cash )
			ent2:Remove()
		end
	end
end

cashcrate = CashCrate()