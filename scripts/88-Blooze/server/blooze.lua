class 'BloozeMod'

function BloozeMod:__init()
    Network:Subscribe( "MinusHP", self, self.MinusHP )
end

function BloozeMod:MinusHP( args, sender )
    sender:SetHealth( sender:GetHealth() - 0.1 )
end

bloozemod = BloozeMod()