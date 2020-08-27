class 'Hook'

function Hook:__init()
	Events:Subscribe( "GameRenderOpaque", self, self.GameRenderOpaque )
end

function Hook:GameRenderOpaque()
	for player in Client:GetStreamedPlayers() do
		if (player:GetBaseState() == 208) and player:GetAimTarget().position then
			Render:DrawLine(
				player:GetBonePosition("ragdoll_LeftHand"),
				player:GetAimTarget().position,
				Color( 15, 15, 15, 255 * math.max(0, 1 - (Vector3.Distance(player:GetPosition(), Camera:GetPosition()) / 1024)) )
			)
		end
		if (player:GetBaseState() == 207) then
			ClientEffect.Play(AssetLocation.Game, {
				effect_id = 11,
				position = player:GetPosition(),
				angle = player:GetAngle()
			})
		end
	end	
end

hook = Hook()