class 'Boost'

function Boost:__init()
	self.interval = 3600 * 6 -- DB write interval in seconds (Default: 6h)

	self.settings  = {}
	self.diff      = {}
	self.nextSave  = self.interval

	-- Create DB table
	SQL:Execute("CREATE TABLE IF NOT EXISTS boost_settings (steamid TEXT PRIMARY KEY, " ..
		"land_enabled INTEGER, boat_enabled INTEGER, heli_enabled INTEGER, " ..
		"plane_enabled INTEGER, text_enabled INTEGER, controller_enabled INTEGER, brake INTEGER)")

	-- Load all DB entries into the cache
	local i = 0
	local timer = Timer()
	for _, row in ipairs(SQL:Query("SELECT * FROM boost_settings"):Execute()) do
		self.settings[row.steamid]              = {}
		self.settings[row.steamid].landBoost    = tonumber(row.land_enabled)
		self.settings[row.steamid].boatBoost    = tonumber(row.boat_enabled)
		self.settings[row.steamid].heliBoost    = tonumber(row.heli_enabled)
		self.settings[row.steamid].planeBoost   = tonumber(row.plane_enabled)
		self.settings[row.steamid].textEnabled  = tonumber(row.text_enabled)
		self.settings[row.steamid].padEnabled   = tonumber(row.controller_enabled)
		self.settings[row.steamid].brake   = tonumber(row.brake)
		i = i + 1
	end
	print(string.format( "Loaded %d boost settings in %dms.", i, timer:GetMilliseconds()) )

	Network:Subscribe( "ChangeSetting", self, self.ChangeSetting )

	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Boost:PlayerJoin( args )
	args.player:SetNetworkValue( "BoostEnabled", true )
end

function Boost:ModuleLoad( args )
	for p in Server:GetPlayers() do
		p:SetNetworkValue( "BoostEnabled", true )
	end
end

function Boost:ChangeSetting( args, sender )
	local steamid = sender:GetSteamId().string
	if not self.settings[steamid] then
		self.settings[steamid] = {}
	end
	if not self.diff[steamid] then
		self.diff[steamid] = true
	end
	self.settings[steamid][args.setting] = args.value
end

function Boost:ModuleUnload()
	local i = 0
	local timer = Timer()
	local trans = SQL:Transaction()
	for steamid, _ in pairs(self.diff) do
		local settings = self.settings[steamid]
		if settings and next(settings) then -- Check if there are settings
			local command = SQL:Command("INSERT OR REPLACE INTO boost_settings VALUES (?, ?, ?, ?, ?, ?, ?)")
			command:Bind(1, steamid)
			if settings.landBoost then command:Bind(2, settings.landBoost) end
			if settings.boatBoost then command:Bind(3, settings.boatBoost) end
			if settings.heliBoost then command:Bind(4, settings.heliBoost) end
			if settings.planeBoost then command:Bind(5, settings.planeBoost) end
			if settings.textEnabled then command:Bind(6, settings.textEnabled) end
			if settings.padEnabled then command:Bind(7, settings.padEnabled) end
			if settings.brake then command:Bind(7, settings.brake) end
			command:Execute()
		else
			local command = SQL:Command("DELETE FROM boost_settings WHERE steamid = ?")
			command:Bind(1, steamid)
			command:Execute()
		end
			i = i + 1
		end
	trans:Commit()
	self.diff = {}
	print( string.format("Updated %d boost settings in %dms.", i, timer:GetMilliseconds()) )

	for p in Server:GetPlayers() do
		if p:GetValue( "BoostEnabled" ) then
			p:SetNetworkValue( "BoostEnabled", nil )
		end
	end
end

function Boost:PostTick()
	if Server:GetElapsedSeconds() > self.nextSave then
		self:ModuleUnload()
		self.nextSave = Server:GetElapsedSeconds() + self.interval
	end
end

function Boost:ClientModuleLoad( args )
	Network:Send( args.player, "UpdateSettings", self.settings[args.player:GetSteamId().string] or {} )
end

boost = Boost()