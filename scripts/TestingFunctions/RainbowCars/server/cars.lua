local RainbowPlayers = {}
class "RainbowCars"

function RainbowCars:__init()
    Chat:Broadcast("Reload", Color.Green)
    self.timer = Timer()
    self.rT = Timer()
    Events:Subscribe("PreTick", self, self.PreTick)
    Events:Subscribe("PlayerChat", self, self.PlayerChat)
    Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("RAddPlayer", self, self.RAddPlayer)
    Events:Subscribe("RDelPlayer", self, self.RDelPlayer)
end
function RainbowCars:PlayerQuit(args)
    self:RDelPlayer(args.player:GetId())
end

function RainbowCars:PlayerChat(args)
    if args.text == "/rnb 1" then
        self:RAddPlayer(args.player:GetId())
    end
    if args.text == "/rnb 0" then
        self:RDelPlayer(args.player:GetId())
    end
end

function RainbowCars:RAddPlayer(id)
    for i, val in ipairs(RainbowPlayers) do
        if val == id then
            return
        end
    end
    table.insert(RainbowPlayers, id)
end

function RainbowCars:RDelPlayer(id)
    for i, val in ipairs(RainbowPlayers) do
        if val == id then
            table.remove(RainbowPlayers, i)
        end
    end
end

function RainbowCars:Colorim()
    for i, val in ipairs(RainbowPlayers) do
        local p = Player.GetById(val)
        if p:InVehicle() then
            local h = (0.01 * self.rT:GetMilliseconds() - string.len(p:GetName())) * 10
            local color = Color.FromHSV(h % 360, 1, 1)
            p:GetVehicle():SetColors(color, color)
        end
    end
end

function RainbowCars:PreTick(args)
    self:Colorim()
    self.timer:Restart()
end
rainbowcars = RainbowCars()
