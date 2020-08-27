class "BetterMinimap"

function BetterMinimap:__init()
	self.playerPositions = {}
	self.currentPlayerId = LocalPlayer:GetId()

	Network:Subscribe( "BMPlayerPositions", self, self.PlayerPositions )
	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "Render", self, self.Render )
end

function BetterMinimap:GetOption( args )
	self.minimap = args.actMb
end

function BetterMinimap:PlayerPositions(positions)
	self.playerPositions = positions

	for playerId, data in pairs(self.playerPositions) do
		local posp = data.position.y + 30
		local posm = data.position.y - 30

		if ( LocalPlayer:GetPosition().y > posp ) then
			data.triangle = "down"
		elseif ( LocalPlayer:GetPosition().y < posm ) then
			data.triangle = "up"
		else
			triangle = "none"
		end
	end
end

function Vector3:IsNaN()
	return (self.x ~= self.x) or (self.y ~= self.y) or (self.z ~= self.z)
end

function BetterMinimap:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not self.minimap then return end
	local pos, ok = Render:WorldToMinimap(Vector3(5465, 282, -7699))

	local updatedPlayers = {}
	for player in Client:GetStreamedPlayers() do
		local position = player:GetPosition()
		local tringle = "none"
		if not position:IsNaN() then
			updatedPlayers[player:GetId()] = true
			local posp = position.y + 30
			local posm = position.y - 30
			
			if (LocalPlayer:GetPosition().y > posp) then
				triangle = "down"
			elseif (LocalPlayer:GetPosition().y < posm) then
				triangle = "up"
			else
				triangle = "none"
			end
			BetterMinimap.DrawPlayer(position, triangle, player:GetColor())
		end
	end

	for playerId, data in pairs(self.playerPositions) do
		if not updatedPlayers[playerId] and self.currentPlayerId ~= playerId and LocalPlayer:GetWorld():GetId() == data.worldId then
			BetterMinimap.DrawPlayer( data.position, data.triangle, data.color )
		end
	end
end

function BetterMinimap.DrawPlayer( position, triangle, color )
	local pos, ok = Render:WorldToMinimap( position )
	local playerPosition = LocalPlayer:GetPosition()
	local distance = Vector3.Distance( playerPosition, position )

	if Game:GetSetting(4) >= 1 then
		if distance <= 5000 then
			local size = Render.Size.x / 300
			local sSize = Render.Size.x / 250

			if triangle == "up" then
				Render:FillTriangle( Vector2( pos.x,pos.y - sSize-3 ), Vector2( pos.x - sSize-1,pos.y + sSize-1 ), Vector2( pos.x + sSize,pos.y + sSize-1 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
				Render:FillTriangle( Vector2( pos.x,pos.y - size-2 ), Vector2( pos.x - size-1,pos.y + size-1 ), Vector2( pos.x + size,pos.y + size-1 ), color + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
			elseif triangle == "down" then
				Render:FillTriangle( Vector2( pos.x,pos.y + sSize-0 ), Vector2( pos.x - sSize-1,pos.y - sSize-1 ), Vector2( pos.x + sSize-1,pos.y - sSize-1 ), Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
				Render:FillTriangle( Vector2( pos.x,pos.y + size-1 ), Vector2( pos.x - size-1,pos.y - size-1 ), Vector2( pos.x + size-1,pos.y - size-1 ), color + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
			else
				Render:FillCircle( pos, size, color + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
				Render:DrawCircle( pos, size, Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ) )
			end
		end
	end
end

betterminimap = BetterMinimap()