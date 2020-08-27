class "DerbyManager"

function DerbyManager:__init()
	self.count = 1
	self.players = {}
	self.playerIds = {}

	self.events = {}
	self.largeActive = false
	self:CreateDerbyEvent()

	Events:Subscribe("PlayerChat", self, self.ChatMessage)
end

function DerbyManager:CreateDerbyEvent()
	self.currentDerby = self:DerbyEvent(self:GenerateName())
end
function DerbyManager:DerbyEvent(name)
	local Derby = Derby(name, self, World.Create())
	table.insert(self.events, Derby)

	self.count = self.count + 1
	return Derby
end
function DerbyManager:RemoveDerby(derby)
	for index, event in ipairs(self.events) do
		if event.name == derby.name then
				table.remove(self.events, index)
				break
		end
	end	
end
function DerbyManager:GenerateName()
	return "Дерби #"..tostring(self.count)
end

function DerbyManager:MessagePlayer(player, message)
	player:SendChatMessage( "[Дерби #" .. tostring(self.count) .. "] " .. message, Color( 228, 142, 56 ) )
end

function DerbyManager:MessageGlobal(message)
	Chat:Broadcast( "[Дерби #" .. tostring(self.count) .."] " .. message, Color( 228, 142, 56 ) )
end

function DerbyManager:HasPlayer(player)
	return self.playerIds[player:GetId()]
end
function DerbyManager:RemovePlayer(player)
	for index, event in ipairs(self.events) do
		if (event.players[player:GetId()]) then
			event:RemovePlayer(player, "Вы были удалены из дерби.")
		end
	end
end

function DerbyManager:ChatMessage(args)
	local msg = args.text
	local player = args.player
	
	-- If the string is't a command, we're not interested!
	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end    
	
	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end
	
	if (cmdargs[1] == "/derby") then 
		if (self.currentDerby:HasPlayer(player)) then
			self.currentDerby:RemovePlayer(player, "Вы были удалены из дерби.")
		else        
			if (self:HasPlayer(player)) then
				self:RemovePlayer(player)
			else
				self.currentDerby:JoinPlayer(player)
			end
		end
	end
	if player:GetValue( "Tag" ) == "Owner" or player:GetValue( "Tag" ) == "GlAdmin" then
		if (cmdargs[1] == "/debugstart") then
			self.currentDerby:Start()
		end
		if (cmdargs[1] == "/joinall") then
			for player in Server:GetPlayers() do
				if not self.currentDerby:HasPlayer(player) then
					self.currentDerby:JoinPlayer(player)
				end
			end
			self.currentDerby:Start()
		end
	end
	return false
end