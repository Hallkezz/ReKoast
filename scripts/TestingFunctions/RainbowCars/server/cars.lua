class "RainbowCars"

function RainbowCars:__init()
    self.prefix = "[Радуга] "

    self.rT = Timer()

    Events:Subscribe( "PreTick", self, self.PreTick )
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function RainbowCars:PlayerChat( args )
    if args.text == "/rnb" then
        if args.player:GetValue( "RainbowCar" ) then
            args.player:SetNetworkValue( "RainbowCar", nil )
            Chat:Send( args.player, self.prefix, Color.White, "Переливание цвета транспорта отключено.", Color.Pink )
        else
            args.player:SetNetworkValue( "RainbowCar", 1 )
            Chat:Send( args.player, self.prefix, Color.White, "Переливание цвета транспорта включено.", Color.Pink )
        end
    end
end

function RainbowCars:Colorim()
    for p in Server:GetPlayers() do
        if p:GetValue( "RainbowCar" ) then
            if p:InVehicle() then
                local h = ( 0.01 * self.rT:GetMilliseconds() - string.len( p:GetName() ) ) * 10
                local color = Color.FromHSV( h % 360, 1, 1 )
                p:GetVehicle():SetColors( color, color )
            end
        end
    end
end

function RainbowCars:PreTick( args )
    self:Colorim()
end

rainbowcars = RainbowCars()
