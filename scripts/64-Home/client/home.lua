class 'Home'

function Home:__init()
	Events:Subscribe( "BuyHome", self, self.BuyHome )
	Events:Subscribe( "GoHome", self, self.GoHome )
	Events:Subscribe( "BuyHomeTw", self, self.BuyHomeTw )
	Events:Subscribe( "GoHomeTw", self, self.GoHomeTw )
	Network:Subscribe( "SetHome", self, self.SetHome )
end

function Home:BuyHome()
	Network:Send( "SetHome" )
end

function Home:GoHome()
    if LocalPlayer:GetWorld() ~= DefaultWorld then
        Events:Fire( "CastCenterText", { text = "Вы не можете использовать это здесь!", time = 3, color = Color.Red } )
        return
    end
	Network:Send( "GoHome" )
	Events:Fire( "CastCenterText", { text = "Мам, я дома!", time = 6, color = Color.Yellow } )
end

function Home:BuyHomeTw()
	Network:Send( "SetHomeTw" )
end

function Home:GoHomeTw()
    if LocalPlayer:GetWorld() ~= DefaultWorld then
        Events:Fire( "CastCenterText", { text = "Вы не можете использовать это здесь!", time = 3, color = Color.Red } )
        return
    end
	Network:Send( "GoHomeTw" )
	Events:Fire( "CastCenterText", { text = "Мам, я в дом 2!", time = 6, color = Color.Yellow } )
end

function Home:SetHome()
	Events:Fire( "CastCenterText", { text = "Точка дома установлена!", time = 6, color = Color.Yellow } )
end

home = Home()