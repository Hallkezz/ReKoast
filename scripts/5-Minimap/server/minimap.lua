class "BetterMinimap"

function BetterMinimap:__init()
	self.interval = 2 -- Seconds (Default: 2)
	self.timer = Timer()

	self.invisiblePlayers = {}

	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function BetterMinimap:PlayerQuit( args )
	self.invisiblePlayers[args.player:GetId()] = nil
end

function BetterMinimap:PostTick()
	if self.timer:GetSeconds() > self.interval then
        local playerPositions = {}

        for player in Server:GetPlayers() do
            local playerId = player:GetId()
            if self.invisiblePlayers[playerId] == nil then
                playerPositions[playerId] = { position = player:GetPosition(), color = player:GetColor(), worldId = player:GetWorld():GetId(), tringle = "none" }
             end
        end
        self.timer:Restart()
    	Network:Broadcast( "BMPlayerPositions", playerPositions )
    end
end

function BetterMinimap:PlayerChat( args )
	local text = args.text
	local playerId = args.player:GetId()

	if text ~= "/hideme" then return end

	if self.invisiblePlayers[playerId] == nil then
		self.invisiblePlayers[playerId] = true
	else
		self.invisiblePlayers[playerId] = nil
	end
end

betterminimap = BetterMinimap()