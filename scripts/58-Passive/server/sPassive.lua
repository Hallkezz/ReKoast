class 'Passive'

function Passive:__init()
	self.interval = 3600 * 6 -- DB write interval in seconds (Default: 6h)

	self.passives = {}
	self.diff     = {}
	self.nextSave = self.interval

	SQL:Execute("CREATE TABLE IF NOT EXISTS passive (steamid VARCHAR PRIMARY KEY)")

	-- Load all DB entries into the cache
	local i = 0
	local timer = Timer()
	for _, row in ipairs(SQL:Query("SELECT * FROM passive"):Execute()) do
		self.passives[row.steamid] = true
		i = i + 1
	end
	print(string.format("Loaded %d passives in %dms.", i, timer:GetMilliseconds()))

	Network:Subscribe("Toggle", self, self.Toggle)
	Network:Subscribe("Disable", self, self.Disable)
	--Network:Subscribe("CheckPassive", self, self.CheckPassive)

	--Events:Subscribe( "PlayerExitVehicle", self, self.PlayerExitVehicle )
	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Events:Subscribe( "PlayerEnterVehicle", self, self.PlayerEnterVehicle )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function Passive:Toggle( state, sender )
	sender:SetNetworkValue("Passive", state or nil)

	local vehicle = sender:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == sender then
		vehicle:SetInvulnerable(state == true)
	end

	Network:Send( sender, "Text", "Мирный режим " .. (state and "включён" or "отключён") )

	local steamid = sender:GetSteamId().string
	self.diff[steamid] = not self.diff[steamid] or nil
	self.passives[steamid] = state or nil
end

function Passive:Disable( state, sender )
	sender:SetNetworkValue("Passive", state or nil)

	local vehicle = sender:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == sender then
		vehicle:SetInvulnerable(state == true)
	end

	local steamid = sender:GetSteamId().string
	self.diff[steamid] = not self.diff[steamid] or nil
	self.passives[steamid] = state or nil
end

function Passive:ClientModuleLoad( args )
	local state = self.passives[args.player:GetSteamId().string]
	args.player:SetNetworkValue("Passive", state)
	local vehicle = args.player:GetVehicle()
	if IsValid(vehicle) and vehicle:GetDriver() == args.player then
		vehicle:SetInvulnerable(state ~= nil)
	end
end

function Passive:PlayerEnterVehicle( args )
	if args.is_driver then args.vehicle:SetInvulnerable(args.player:GetValue("Passive") == true) end
end

function Passive:PlayerExitVehicle( args )
	if args.player:GetValue( "Passive" ) then
		args.player:EnableCollision( CollisionGroup.Vehicle, CollisionGroup.Player )
	end
end

function Passive:PostTick()
	if Server:GetElapsedSeconds() > self.nextSave then
		self:ModuleUnload()
		self.nextSave = Server:GetElapsedSeconds() + self.interval
	end
end

function Passive:CheckPassive( args, sender )
	for p in Server:GetPlayers() do
		jDist = sender:GetPosition():Distance( p:GetPosition() )
		if sender:GetVehicle() then
		if jDist < 5 then
				p:DisableCollision( CollisionGroup.Vehicle, CollisionGroup.Player )
			else
				p:EnableCollision( CollisionGroup.Vehicle, CollisionGroup.Player )
			end
		end
	end
end

function Passive:ModuleUnload()
	local i = 0
	local timer = Timer()
	local trans = SQL:Transaction()
	for steamid, _ in pairs(self.diff) do
		local state = self.passives[steamid]
		local command
		if state then
			command = SQL:Command("INSERT OR REPLACE INTO passive VALUES (?)")
		else
			command = SQL:Command("DELETE FROM passive WHERE steamid = ?")
		end
		command:Bind(1, steamid)
		command:Execute()
		i = i + 1
	end
	trans:Commit()
	self.diff = {}
	print(string.format("Saved %d passives in %dms.", i, timer:GetMilliseconds()))
end

passive = Passive()