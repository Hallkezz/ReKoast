Cashes = { 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2100, 2000, 2200, 2300, 2400, 2500, 100, 200, 300, 400, 500, 600, 700, 800, 900 }

class 'ServerMenu'

function ServerMenu:__init()
	GoCashes = Cashes[math.random(#Cashes)]

	Network:Subscribe( "PlayerKick", self, self.PlayerKick )
	Network:Subscribe( "Cash", self, self.Cash )

	Events:Subscribe( "PostTick", self, self.PostTick )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )

	self.timer = Timer()
end

function ServerMenu:PlayerKick( args, sender )
	sender:Kick()
end

function ServerMenu:PostTick( args )
	if self.timer:GetHours() >= 1 then
		for p in Server:GetPlayers() do
			Network:Send( p, "Bonus" )
		end
		self.timer:Restart()
	end
end

function ServerMenu:Cash( args, sender )
	GoCashes = Cashes[math.random(#Cashes)]
	if sender:GetMoney() >= 10000 then
		sender:SetMoney( sender:GetMoney() + GoCashes )
	end
end

function ServerMenu:PlayerChat( args )
	local msg = args.text
	local player = args.player

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end    

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

	if (cmdargs[1] == "/menu") or (cmdargs[1] == "/help") or (cmdargs[1] == "/pda") then
		Network:Send( args.player, "Settings" )
		return false
	end

	return false
end

servermenu = ServerMenu()
