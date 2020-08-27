class 'PanauDrivers'

local jobp = "[Работа] "

local jobWaitText = "Подождите немного, прежде чем начинать новую работу!"
local jobRewardText = "Работа выполнена! Награда: $"

local groundVehicles = {66, 12, 54, 23, 33, 68, 78, 8, 35, 44, 2, 7, 29, 70, 55, 15, 91, 21, 83, 32, 79, 22, 9, 4, 41, 49, 71, 42, 76, 31}
local offroadVehicles = {11, 36, 72, 73, 26, 63, 86, 77, 48, 84, 46, 10, 52, 13, 60, 87, 74, 43, 89, 90, 61, 47, 18, 56, 40}
local waterVehicles = {80, 38, 88, 45, 6, 19, 5, 27, 28, 25, 69, 16, 50}
local heliVehicles = {64, 65, 14, 67, 3, 37, 57, 62}
local jetVehicles = {39, 85, 34}
local planeVehicles = {51, 59, 81, 30}
--vehicle "difficulty" tables
local easyVehicles = {81, 64, 14, 67, 3, 37, 57, 62, 80, 88, 27, 54, 72, 73, 23, 33, 63, 26, 68, 78, 86, 35, 77, 2, 84, 46, 7, 10, 52, 29, 70, 55, 15, 13, 91, 60, 87, 74, 21, 43, 89, 90, 61, 18, 56, 76, 31}
local mediumVehicles = {51, 34, 30, 65, 45, 6, 19, 28, 69, 16, 11, 36, 44, 48, 83, 32, 47, 79, 22, 9, 4, 41, 49, 71, 42}
local hardVehicles = {59, 38, 5, 25, 66, 12, 8, 1, 40}
local harderVehicles = {39, 75, 85, 50}

local easy = 0.20
local medium = 0.21
local hard = 0.21
local harder = 0.21
local shortJobBias = 2

local rewardMultiplier = 0.2

local jobCooldownTime = 1

function string.starts( String,Start )
	return string.sub(String,1,string.len(Start))==Start
end

function string.upto( String,End )
	return string.sub(String, 1, string.find(String,End) - 1)
end

function PanauDrivers:__init()
	math.randomseed(os.time())

	self.locations = {}

	self.gLocs = {}
	self.oLocs = {}
	self.wLocs = {}
	self.hLocs = {}
	self.jLocs = {}
	self.pLocs = {}
	self.xLocs = {}
	self.dLocs = {}

	self.availableJobs = {}

	self.playerJobs = {}

	self.playerJobTimers = {}

	self.jobCancelTimer = Timer()
	self.jobsToCancel = {}

	self.companies = {}

	self.playerComps = {}

	self:LoadLocations( "locations.txt" )

	self:GenerateJobs()

	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerExitVehicle", self, self.OnPlayerExitV )
	Events:Subscribe( "PlayerDeath", self, self.OnPlayerDeath )
	Events:Subscribe( "PreTick", self, self.PreTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Network:Subscribe( "TakeJob", self, self.PlayerTakeJob )
	Network:Subscribe( "CompleteJob", self, self.PlayerCompleteJob )
end

function PanauDrivers:LoadLocations( filename )
	print( "now opening " .. filename )
	local file = io.open( filename, "r" )
	if file == nil then
		print( filename .. " is missing, can't load spawns" )
		return
	end

	for line in file:lines() do 
		if line:sub(1,1) == "L" then
			self:ParseVehicleLocation(line:sub(3))
		end
	end
	file:close()

	for key,location in pairs(self.locations) do
		if location.type == "G" then
			table.insert(self.gLocs, key)
		elseif location.type == "O" then
			table.insert(self.oLocs, key)
		elseif location.type == "W" then
			table.insert(self.wLocs, key)
		elseif location.type == "H" then
			table.insert(self.hLocs, key)
		elseif location.type == "J" then
			table.insert(self.jLocs, key)
		elseif location.type == "P" then
			table.insert(self.pLocs, key)
		elseif location.type == "X" then
			table.insert(self.xLocs, key)
		elseif location.type == "D" then
			table.insert(self.dLocs, key)			
		end
	end
end

function PanauDrivers:ParseVehicleLocation( line )
	local vehicleType = string.sub(line, 1, 1)

	local tokens = line:split(",")

	local locName = tokens[1]

	local locPos = { tokens[2]:gsub(" ",""), tokens[3]:gsub(" ",""), tokens[4]:gsub(" ","")}
	local locAngle = {tokens[5]:gsub(" ",""), tokens[6]:gsub(" ",""), tokens[7]:gsub(" ","")}

	local locArgs = {}
	locArgs.name = locName
	locArgs.type = vehicleType
	locArgs.position = Vector3(tonumber(locPos[1]),tonumber(locPos[2]),tonumber(locPos[3]))
	locArgs.angle = Angle(tonumber(locAngle[1]),tonumber(locAngle[2]),tonumber(locAngle[3]))

	table.insert(self.locations, locArgs)
end

function PanauDrivers:GenerateJobs()
	print( "generating jobs" )
	for key,location in pairs(self.locations) do
		local job = self:MakeJob(key)
		--search for shorter jobs
		for i = 1,shortJobBias do
			job2 = self:MakeJob(key)
			if job2.distance < job.distance and job2.distance > 100 then
				job = job2
			end
		end
		self.availableJobs[key] = job
	end
end

function PanauDrivers:MakeJob( key )
	local location = self.locations[key]
	local job = {}
	job.start = key
	--set a destination (and make sure it's not the same as the start)
	--watch out, this will go forever if there's not at least 2 of each type of destination.
	local destKey = self:GetRandomDestination(location.type, key)
	job.destination = destKey
	--set a vehicle
	local dest = self.locations[job.destination]
	if dest.type == "O" or location.type == "O" then
		job.vehicle = self:GetRandomVehicleOfType("O")
	else
		job.vehicle = self:GetRandomVehicleOfType(dest.type)
	end
	--set the direction between the start and destination
	local startPoint = location.position
	local destPoint = dest.position
	local direction = startPoint - destPoint
	direction = direction:Normalized()
	job.direction = direction
	--calculate a reward
	local distance = startPoint:Distance(destPoint)
	job.distance = distance
	local multiplier = self:GetVehicleRewardMultiplier(job.vehicle)
	job.reward = math.floor(multiplier * distance * rewardMultiplier)
	job.description = "Доставить к " .. dest.name
	return job
end

function PanauDrivers:GetVehicleRewardMultiplier( vehicleType )
	for k,v in pairs(easyVehicles) do
		if v == vehicleType then
			return easy
		end
	end
	for k,v in pairs(mediumVehicles) do
		if v == vehicleType then
			return medium
		end
	end
	for k,v in pairs(hardVehicles) do
		if v == vehicleType then
			return hard
		end
	end
	for k,v in pairs(harderVehicles) do
		if v == vehicleType then
			return harder
		end
	end
	return easy
end

function PanauDrivers:GetRandomVehicleOfType( vehicleType )
	math.random()
	math.random()
	math.random()
	if (vehicleType == "G") then
		return groundVehicles[math.random(#groundVehicles)]
	elseif (vehicleType == "O") then
		return offroadVehicles[math.random(#offroadVehicles)]	
	elseif (vehicleType == "W") then
		return waterVehicles[math.random(#waterVehicles)]
	elseif (vehicleType == "H") then
		return heliVehicles[math.random(#heliVehicles)]
	elseif (vehicleType == "J") then
		return jetVehicles[math.random(#jetVehicles)]
	elseif (vehicleType == "P") then
		return planeVehicles[math.random(#planeVehicles)]
	elseif (vehicleType == "X") then
		return offroadVehicles[math.random(#offroadVehicles)]
	elseif (vehicleType == "D") then
		return offroadVehicles[math.random(#offroadVehicles)]		
	else 
		print( "tried to spawn invalid vehicle type. Made tractor instead" )
		return 1
	end
end

function PanauDrivers:GetRandomDestination( startType, key )
	math.random()
	math.random()
	math.random()
	local i = 1
	local r = 1
	if (startType == "G") or (startType == "O") then
		if math.random(2) == 1 then
			i = math.random(#self.oLocs)
			r = self.oLocs[i]
			if r == key then
				if i < #self.oLocs then
					i = i + 1
					r = self.oLocs[i]
				elseif i > #self.oLocs then
					i = i - 1
					r = self.oLocs[i]
				end
			end
		else
			i = math.random(#self.gLocs)
			r = self.gLocs[i]
			if r == key then
				if i < #self.gLocs then
					i = i + 1
					r = self.gLocs[i]
				elseif i > #self.gLocs then
					i = i - 1
					r = self.gLocs[i]
				end
			end
		end
	elseif (startType == "W") then
		i = math.random(#self.wLocs)
			r = self.wLocs[i]
			if r == key then
				if i < #self.wLocs then
					i = i + 1
					r = self.wLocs[i]
				elseif i > #self.wLocs then
					i = i - 1
					r = self.wLocs[i]
				end
			end
	elseif (startType == "H") then
		i = math.random(#self.hLocs)
			r = self.hLocs[i]
			if r == key then
				if i < #self.hLocs then
					i = i + 1
					r = self.hLocs[i]
				elseif i > #self.hLocs then
					i = i - 1
					r = self.hLocs[i]
				end
			end
	elseif (startType == "J") then
		i = math.random(#self.jLocs)
			r = self.jLocs[i]
			if r == key then
				if i < #self.jLocs then
					i = i + 1
					r = self.jLocs[i]
				elseif i > #self.jLocs then
					i = i - 1
					r = self.jLocs[i]
				end
			end
	elseif (startType == "P") then
		i = math.random(#self.pLocs)
			r = self.pLocs[i]
			if r == key then
				if i < #self.pLocs then
					i = i + 1
					r = self.pLocs[i]
				elseif i > #self.pLocs then
					i = i - 1
					r = self.pLocs[i]
				end
			end
	elseif (startType == "X") then
		i = math.random(#self.xLocs)
			r = self.xLocs[i]
			if r == key then
				if i < #self.xLocs then
					i = i + 1
					r = self.xLocs[i]
				elseif i > #self.xLocs then
					i = i - 1
					r = self.xLocs[i]
				end
			end
	elseif (startType == "D") then
		i = math.random(#self.dLocs)
			r = self.dLocs[i]
			if r == key then
				if i < #self.dLocs then
					i = i + 1
					r = self.dLocs[i]
				elseif i > #self.dLocs then
					i = i - 1
					r = self.dLocs[i]
				end
			end			
	else
		print( "tried to create job with invalid type" )
		return locations[1]
	end
	return r
end

function PanauDrivers:getComp( str )
	for k,v in ipairs(self.companies) do
		if v.name == str then
			return k
		end
	end
	return false
end

function PanauDrivers:compByPId( id )
	return self.companies[self:getComp(self.playerComps[id])]
end

function string.Split( str )
	tab = {}
	for s in str:gmatch("%S+") do 
		table.insert(tab,s)
	end
	return tab
end

function PanauDrivers:CompanyBroadcast( comp, message, color )
	for k, v in ipairs(comp.employees) do
		Player.GetById(v):SendChatMessage( message, color )
	end
end

function PanauDrivers:RemovePlayerFromCompany( playerId )
	comp = self.companies[self:getComp(self.playerComps[playerId])]
	player = Player.GetById( playerId )

	self.playerJobs[playerId] = nil

	for k, v in ipairs(comp.employees) do
		if v == playerId then
			table.remove( comp.employees, k )
		end
	end

	if comp.job != nil then
		for k, v in ipairs(comp.employeesOnJobs) do
			if v == playerId then
				table.remove(comp.employeesOnJobs, k)
				comp.vehicles[playerId]:Remove()
			end
		end
		for k, v in ipairs(comp.employeesWaitJobs) do
			if v == playerId then
				table.remove(comp.employeesWaitJobs, k)
			end
		end
		for k, v in ipairs(comp.employeesDoneJobs) do
			if v == playerId then
				table.remove(comp.employeesDoneJobs, k)
			end
		end
		
		if player != nil then
			Network:Send( player, "JobCancel", true )
		end
	end

	if #comp.employees == 0 then
		table.remove(self.companies, self:getComp(self.playerComps[playerId]))
	elseif comp.boss == playerId then
		comp.boss = comp.employees[1]
	end
	
	self.playerComps[playerId] = nil
end

function PanauDrivers:PreTick( args )
	if self.jobCancelTimer:GetSeconds() > 2 then
		self.jobCancelTimer:Restart()
		--cancel jobs in queue
		for player in Server:GetPlayers() do
			pId = player:GetId()
			if self.jobsToCancel[pId] == true then
				self.playerJobTimers[pId]:Restart()
				if self.playerJobs[pId] != nil then
					if self.playerComps[pId] == nil then
						self.playerJobs[pId].vehiclePointer:Remove()
					end
					self.playerJobs[pId] = nil
				end
				Network:Send( player, "JobCancel", true )
				self.jobsToCancel[pId] = false

				--if player was in a company, remove them frome the company job list
				if self.playerComps[pId] != nil then
					comp = self.companies[self:getComp(self.playerComps[pId])]
					for k, v in ipairs(comp.employeesOnJobs) do
						if v == pId then
							table.remove(comp.employeesOnJobs, k)
							comp.vehicles[pId]:Remove()
						end
					end
				end
			end
		end

		for k, comp in ipairs(self.companies) do
			if comp.job != nil then
				if #comp.employeesOnJobs == 0 and #comp.employeesWaitJobs == 0 then
					--remove company job and distribute bonuses if everyone is done
					comp.job.bonus = math.floor((comp.job.bonus - 1) * companyBonusMultiplier * comp.job.reward)
					if comp.job.bonus < 0 then comp.job.bonus = 0 end
					self:CompanyBroadcast( comp, compFinishJobText .. tostring(comp.job.bonus), Color( 0, 255, 0 ) )
					for k, p in ipairs(comp.employeesDoneJobs) do
						Player.GetById(p):SetMoney(Player.GetById(p):GetMoney() + comp.job.bonus)
					end
					comp.job = nil
				elseif #comp.employeesOnJobs == 0 then
					--start the first employee's job
					playerToStart = comp.employeesWaitJobs[1]
					table.insert(comp.employeesOnJobs, 1, playerToStart)
					table.remove(comp.employeesWaitJobs, 1)

					actualPlayer = Player.GetById(playerToStart)
					--spawn vehicle
					local vArgs = {}
					vArgs.model_id = comp.job.vehicle
					--if it's the H-62 Quapaw, spawn it a bit higher up or else it'll sometimes randomly explode
					if vArgs.model_id == 65 then
						vArgs.position = self.locations[comp.job.start].position + Vector3(0, 2.5, 0)
					else
						vArgs.position = self.locations[comp.job.start].position
					end
					vArgs.angle = self.locations[comp.job.start].angle
					vArgs.enabled = true
					vArgs.world = actualPlayer:GetWorld()
					vArgs.tone1 = Color( 255, 225, 0 )
					vArgs.tone2 = Color( 255, 238, 0 )
					local veh = Vehicle.Create( vArgs )
					veh:SetUnoccupiedRemove(true)
					veh:SetDeathRemove(true)
					veh:SetUnoccupiedRespawnTime(nil)
					veh:SetDeathRespawnTime(nil)
					actualPlayer:EnterVehicle( veh, VehicleSeat.Driver )
					comp.vehicles[playerToStart] = veh
					--tell the player that they got the job!
					Network:Send( actualPlayer, "JobStart", comp.job)
					--put job in table
					self.playerJobs[actualPlayer:GetId()] = comp.job
					--generate a new job for that location, and tell the clients about it
					self.availableJobs[comp.job.start] = self:MakeJob( comp.job.start )
					jUpdate = {comp.job.start, self.availableJobs[comp.job.start]}
					Network:Broadcast("JobsUpdate", jUpdate)
				elseif #comp.employeesWaitJobs != 0 then
					--start more employees on the job
					--check if most recent player is far enough from the start
					lastPlayer = Player.GetById(comp.employeesOnJobs[1])
					distFromStart = Vector3.Distance(Player.GetPosition(lastPlayer), self.locations[comp.job.start].position)
					if distFromStart > 30 then
						playerToStart = comp.employeesWaitJobs[1]
						table.insert(comp.employeesOnJobs, 1, playerToStart)
						table.remove(comp.employeesWaitJobs, 1)
						
						actualPlayer = Player.GetById(playerToStart)
						Player.SetPosition(actualPlayer, self.locations[comp.job.start].position)
						--spawn vehicle
						local vArgs = {}
						vArgs.model_id = comp.job.vehicle
						--if it's the H-62 Quapaw, spawn it a bit higher up or else it'll sometimes randomly explode
						if vArgs.model_id == 65 then
							vArgs.position = self.locations[comp.job.start].position + Vector3(0, 2.5, 0)
						else
							vArgs.position = self.locations[comp.job.start].position
						end
						vArgs.angle = self.locations[comp.job.start].angle
						vArgs.enabled = true
						vArgs.world = actualPlayer:GetWorld()
						vArgs.tone1 = Color( 255, 225, 0 )
						vArgs.tone2 = Color( 255, 238, 0 )
						local veh = Vehicle.Create( vArgs )
						veh:SetUnoccupiedRemove(true)
						veh:SetDeathRemove(true)
						veh:SetUnoccupiedRespawnTime(nil)
						veh:SetDeathRespawnTime(nil)
						actualPlayer:EnterVehicle( veh, VehicleSeat.Driver )
						comp.vehicles[playerToStart] = veh
						--tell the player that they got the job!
						Network:Send( actualPlayer, "JobStart", comp.job)
						--put job in table
						self.playerJobs[actualPlayer:GetId()] = comp.job						
					end
				end
			end
		end
	end
end

function PanauDrivers:OnPlayerExitV( args )
	self.jobsToCancel[args.player:GetId()] = true
end

function PanauDrivers:OnPlayerDeath( args )
	self.jobsToCancel[args.player:GetId()] = true
end

function PanauDrivers:PlayerTakeJob( args, player )
	--check if they're in a vehicle
	if player:GetState() == PlayerState.InVehiclePassenger or player:GetVehicle() != nil then
        return false
    end
	--cooldown timer
	if self.playerJobTimers[player:GetId()]:GetSeconds() < jobCooldownTime then
		player:SendChatMessage( jobp, Color.White, jobWaitText, Color( 255, 0, 0 ))
		return false
	end
	--make sure the job is valid
	local thatJob = self.availableJobs[args.job]
	if thatJob == nil then
		return false
	end
	--do special stuff for players in companies
	if self.playerComps[player:GetId()] != nil then
		comp = self.companies[self:getComp(self.playerComps[player:GetId()])]
		if comp != nil then
			if comp.boss != player:GetId() then
				player:SendChatMessage( jobTakeNotBossText, Color( 255, 0, 0))
				return false
			end
			if comp.job != nil then
				player:SendChatMessage( companyAlreadyOnJobText, Color( 255, 0, 0))
				return false
			end
			--start the company job
			comp.job = thatJob
			comp.job.bonus = 0
			--add all current employees to table of employees waiting to start
			for k, v in ipairs( comp.employees ) do
				table.insert( comp.employeesWaitJobs, v)
			end
			comp.employeesOnJobs = {}
			comp.employeesDoneJobs = {}
			comp.vehicles = {}
		
			return false
		end
	end

	local jobDist = self.locations[thatJob.start].position:Distance(player:GetPosition())
	if jobDist < 20 then
		--restart timer
		self.playerJobTimers[player:GetId()]:Restart()
		--spawn vehicle
		local vArgs = {}
		vArgs.model_id = thatJob.vehicle
		--if it's the H-62 Quapaw, spawn it a bit higher up or else it'll sometimes randomly explode
		if vArgs.model_id == 65 then
			vArgs.position = self.locations[thatJob.start].position + Vector3(0, 2.5, 0)
		else
			vArgs.position = self.locations[thatJob.start].position
		end
		vArgs.angle = self.locations[thatJob.start].angle
		vArgs.enabled = true
		vArgs.world = player:GetWorld()
		vArgs.tone1 = Color( 255, 225, 0 )
		vArgs.tone2 = Color( 255, 238, 0 )
		local veh = Vehicle.Create( vArgs )
		veh:SetUnoccupiedRemove(true)
		veh:SetDeathRemove(true)
		veh:SetUnoccupiedRespawnTime(nil)
		veh:SetDeathRespawnTime(nil)
		player:EnterVehicle( veh, VehicleSeat.Driver )
		thatJob.vehiclePointer = veh
		--tell the player that they got the job!
		Network:Send( player, "JobStart", thatJob)
		--put job in table
		self.playerJobs[player:GetId()] = thatJob
		--generate a new job for that location, and tell the clients about it
		self.availableJobs[args.job] = self:MakeJob( args.job )
		jUpdate = {args.job, self.availableJobs[args.job]}
		Network:Broadcast("JobsUpdate", jUpdate)
	end
end

function PanauDrivers:PlayerCompleteJob( args, player )
	local thatJob = self.playerJobs[player:GetId()]
	if thatJob == nil then
		print("player tried to complete a nil job, something went horribly wrong")
		return
	end
	local destDist = self.locations[thatJob.destination].position:Distance(player:GetPosition())
	local pVehicle = player:GetVehicle()
	if pVehicle == nil then
		return
	end
	local vVel = pVehicle:GetLinearVelocity():Length()
	stopped = false
	if vVel < 1 then
		stopped = true
	end

	playerId = player:GetId()

	--if player is in a company
	if destDist < 20 and self.playerComps[playerId] != nil and 
		pVehicle == comp.vehicles[playerId] and stopped then

		player:GetVehicle():Remove()
		local reward = thatJob.reward
		player:SetMoney(player:GetMoney() + reward)
		self.playerJobs[playerId] = nil
		Network:Send( player, "JobFinish", reward)
		player:SendChatMessage( jobp, Color.White, jobRewardText .. reward, Color( 0, 255, 0 ) )
		print(player:GetName() .. " completed work in Panau! His reward: $" .. reward)
		self.playerJobTimers[playerId]:Restart()
		comp = self.companies[self:getComp(self.playerComps[playerId])]
		table.insert(comp.employeesDoneJobs, playerId)
		for k, v in ipairs(comp.employeesOnJobs) do
			if v == playerId then
				table.remove(comp.employeesOnJobs, k)
			end
		end
		comp.job.bonus = comp.job.bonus + 1
	end

	--if player isn't in a company
	if destDist < 20 and self.playerComps[playerId] == nil and pVehicle == thatJob.vehiclePointer and stopped then
		player:GetVehicle():Remove()
		local reward = thatJob.reward
		player:SetMoney(player:GetMoney() + reward)
		self.playerJobs[playerId] = nil
		Network:Send( player, "JobFinish", reward)
		player:SendChatMessage( jobp, Color.White, jobRewardText .. reward, Color( 0, 255, 0 ) )
		print(player:GetName(), " completed work in Panau! His reward: $" .. reward)
		self.playerJobTimers[playerId]:Restart()
	end
end

function PanauDrivers:ClientModuleLoad( args )
    Network:Send( args.player, "Locations", self.locations )
	Network:Send( args.player, "Jobs", self.availableJobs)
	self.playerJobTimers[args.player:GetId()] = Timer()
end

function PanauDrivers:PlayerQuit( args )
	pId = args.player:GetId()
	self.playerJobs[pId] = nil
	if self.playerComps[pId] != nil then
		self:RemovePlayerFromCompany(pId)
	end
end

function PanauDrivers:PlayerChat( args )
	local msg = args.text
	local player = args.player

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end    

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if (cmdargs[1] == "/drive" or cmdargs[1] == "/jobs") then
		Network:Send( args.player, "Active", false )
        return false
    end
	return false
end

panaudrivers = PanauDrivers()