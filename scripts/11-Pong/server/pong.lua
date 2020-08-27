class 'Pong'

function Pong:__init()
	Network:Subscribe( "Win", self, self.Win )
end

function Pong:Win( args, sender )
	sender:SetMoney( sender:GetMoney() + 5 )
	print( sender:GetName(), " win pong!" )
end

pong = Pong()