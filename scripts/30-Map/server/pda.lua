local max = math.max
local insert = table.insert

class 'Map'

function Map:__init()
	self.players = {}
	self.viewers = {}
	self.invisiblePlayers = {}

	self.timer = Timer()
	self.delay = 1000

	Network:Subscribe( "InitialTeleport", self, self.Teleport )
	Network:Subscribe( "CorrectedTeleport", self, self.Teleport )
	Network:Subscribe( "MapShown", self, self.MapShown )
	Network:Subscribe( "MapHidden", self, self.MapHidden )

	Events:Subscribe( "PostTick", self, self.BroadcastUpdate )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "PlayerSpawn", self, self.PlayerSpawn )
	Events:Subscribe( "PlayerDeath", self, self.PlayerDeath )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Map:Teleport( args, sender )
	if offset == nil then
		offset = 250
	end

	sender:SetPosition( Vector3( args.position.x, max(args.position.y, 200) + offset, args.position.z ) )
end

function Map:AddViewer( viewer )
	self.viewers[viewer:GetId()] = viewer
end

function Map:RemoveViewer( viewer )
	self.viewers[viewer:GetId()] = nil
end

function Map:AddPlayer( player )
	self.players[player:GetId()] = player
end

function Map:RemovePlayer( player )
	self.players[player:GetId()] = nil
	self.invisiblePlayers[player:GetId()] = nil
end

function Map:MapShown( _, sender )
	self:AddViewer(sender)
end

function Map:MapHidden( _, sender )
	self:RemoveViewer(sender)
end

function Map:PlayerSpawn( args )
	self:AddPlayer(args.player)
end

function Map:PlayerDeath( args )
	self:RemovePlayer(args.player)
end

function Map:PlayerQuit( args )
	self:RemoveViewer(args.player)
	self:RemovePlayer(args.player)
end

function Map:BroadcastUpdate()
	if self.timer:GetMilliseconds() < self.delay then return end
	self.timer:Restart()

	if not next(self.viewers) then return end

	local send_args = {}

	for _, player in pairs(self.players) do
		local playerId = player:GetId()
		if self.invisiblePlayers[playerId] == nil then
			if IsValid(player) then
				local data = {
					id = player:GetId(),
					name = player:GetName(),
					pos = player:GetPosition(),
					col = player:GetColor(),
					worldId = player:GetWorld():GetId()
				}

				insert(send_args, data)
			end
		end
	end

	Network:SendToPlayers( self.viewers, "PlayerUpdate", send_args )
end

function Map:PlayerChat( args )
	local text = args.text
	local playerId = args.player:GetId()

	if text ~= "/hideme" then return end

	if self.invisiblePlayers[playerId] == nil then
		self.invisiblePlayers[playerId] = true
		Chat:Send( args.player, "[Карта] ", Color.White, "Теперь вы невидимы на карте!", Color( 0, 222, 0, 250 ) )
	else
		self.invisiblePlayers[playerId] = nil
		Chat:Send( args.player, "[Карта] ", Color.White, "Теперь вы видимы на карте!", Color( 0, 222, 0, 250 ) )
	end
end

function Map:ModuleLoad()
	for player in Server:GetPlayers() do
		self.players[player:GetId()] = player
	end
end

map = Map()