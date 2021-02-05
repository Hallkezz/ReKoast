class 'Version'

function Version:__init()
    self.ver = "050221.0"
    self.sname = ""

    self:GetServerName()

    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
end

function Version:PlayerJoin( args )
    args.player:SetNetworkValue( "KoastBuild", self.ver )
    args.player:SetNetworkValue( "ServerName", self.sname )
end

function Version:ModuleLoad( args )
    for p in Server:GetPlayers() do
        if p:GetValue( "KoastBuild" ) then
            if p:GetValue( "KoastBuild" ) ~= self.ver then
                p:SetNetworkValue( "KoastBuild", self.ver )
            end
        end

        if p:GetValue( "ServerName" ) then
            if p:GetValue( "ServerName" ) ~= self.ver then
                p:SetNetworkValue( "ServerName", self.sname )
            end
        end
    end
end

function Version:GetServerName()
    local file = io.open("servername.txt", "r")
    s = file:read("*a")

    if s then
        self.sname = s
    end
    file:close()
end

version = Version()
