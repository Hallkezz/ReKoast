class "Wingsuit"

function Wingsuit:__init()
	self:initVars()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Network:Subscribe( "0001", self, self.onFlyingRecord )
	Network:Subscribe( "0002", self, self.onFlyingAttempt )
end

function Wingsuit:initVars()
	self.timer = Timer()
	self.delay = 240
end

function Wingsuit:ModuleLoad()
	NetworkObject.Create("Flying")
end

function Wingsuit:PlayerChat( args )
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
	if args.text == "/clearflying" then
		if args.player:GetValue("Creator") then
			self:Reward(object:GetValue("N"), true)
			object:SetNetworkValue("S", nil)
			object:SetNetworkValue("N", nil)
			object:SetNetworkValue("P", nil)
			object:SetNetworkValue("E", nil)
			object:SetNetworkValue("C", nil)
			object:SetNetworkValue("I", nil)
		return
		end
	end
end

function Wingsuit:PostTick()
	if self.timer:GetSeconds() < self.delay then return end
	self.timer:Restart()
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
	if not object:GetValue("E") then return end
	local expire = object:GetValue("E") - 1
	if expire < 1 then
		self:Reward(object:GetValue("N"), true)
		object:SetNetworkValue("S", nil)
		object:SetNetworkValue("N", nil)
		object:SetNetworkValue("P", nil)
		object:SetNetworkValue("E", nil)
		object:SetNetworkValue("C", nil)
		object:SetNetworkValue("I", nil)
		return
	else
		self:Reward(object:GetValue("N"), false)
	end
	object:SetNetworkValue("E", expire)
end

function Wingsuit:onFlyingRecord( score, player )
	local object = NetworkObject.GetByName("Flying") or NetworkObject.Create("Flying")
	if score < (object:GetValue("S") or 0) then return end
	if object:GetValue("N") ~= player:GetName() then
		if object:GetValue("N") ~= nil then
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "ENG" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new wingsuit flying record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд по полётам на вингсьюте!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " has broken the player's flying record " .. object:GetValue("N") .. ", his reward: $150!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " побил рекорд по полётам игрока " .. object:GetValue("N") .. ", его награда: $150!", Color( 255, 150, 0 ) )
				end
			end
		else
			player:SetMoney( player:GetMoney() + 50 )
			if player:GetValue( "Lang" ) == "ENG" then
				player:SendChatMessage( "[Record] ", Color.White, "Reward: $50 for a new wingsuit flying record!", Color( 255, 150, 0 ) )
			else
				player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $50 за новый рекорд по полётам!", Color( 255, 150, 0 ) )
			end

			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " set a new wingsuit flying record: " .. score .. "!", Color( 255, 150, 0 ) )
				else
					p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " установил новый рекорд по полётам на вингсьюте: " .. score .. "!", Color( 255, 150, 0 ) )
				end
			end
		end
	else
		for p in Server:GetPlayers() do
			if p:GetValue( "Lang" ) == "ENG" then
				p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " updated a fantastic wingsuit record: " .. score .. "!", Color( 255, 150, 0 ) )
			else
				p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " обновил хорошечный рекорд по полётам на вингсьюте: " .. score .. "!", Color( 255, 150, 0 ) )
			end
		end
	end
	object:SetNetworkValue("S", score)
	object:SetNetworkValue("N", player:GetName())
	object:SetNetworkValue("P", player)
	object:SetNetworkValue("E", 10)
	object:SetNetworkValue("C", player:GetColor())
	object:SetNetworkValue("I", player:GetSteamId())
	self.timer:Restart()
end

function Wingsuit:onFlyingAttempt( score, player )
	Network:Broadcast( "0003", {score, player:GetId() + 1} )
end

function Wingsuit:Reward( name, last )
	for player in Server:GetPlayers() do
		if player:GetName() == name then
			if not last then
				player:SetMoney( player:GetMoney() + 15 )
				if player:GetValue( "Lang" ) == "ENG" then
					player:SendChatMessage( "[Record] ", Color.White, "Reward: $15 for keeping flying record!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Награда: $15 за удержание рекорда по полёту!", Color( 255, 150, 0 ) )
				end
			else
				player:SetMoney( player:GetMoney() + 500 )
				if player:GetValue( "Lang" ) == "ENG" then
					player:SendChatMessage( "[Record] ", Color.White, "You won a fantastic flying! Your reward: $500!", Color( 255, 150, 0 ) )
				else
					player:SendChatMessage( "[Рекорд] ", Color.White, "Вы победили в полётах на вингсьюте! Ваша награда: $500!", Color( 255, 150, 0 ) )
				end

				for p in Server:GetPlayers() do
					if p:GetValue( "Lang" ) == "ENG" then
						p:SendChatMessage( "[Record] ", Color.White, player:GetName() .. " won a fantastic flying and won $500!", Color( 255, 150, 0 ) )
					else
						p:SendChatMessage( "[Рекорд] ", Color.White, player:GetName() .. " победил в полётах на вингсьюте и выиграл $500!", Color( 255, 150, 0 ) )
					end
				end
			end
		end
	end
end

wingsuit = Wingsuit()