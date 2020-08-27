class 'Jesus'

function Jesus:__init()
	Network:Subscribe( "SetSystemValue", self, self.SetSystemValue )
	Network:Subscribe( "JesusEnable", self, self.JesusEnable )

	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function Jesus:PlayerJoin( args )
	args.player:SetNetworkValue( "JesusModeEnabled", true )
end

function Jesus:ModuleLoad( args )
	for p in Server:GetPlayers() do
		p:SetNetworkValue( "JesusModeEnabled", true )
	end
end

function Jesus:ModuleUnload( args )
	for p in Server:GetPlayers() do
		if p:GetValue( "JesusModeEnabled" ) then
			p:SetNetworkValue( "JesusModeEnabled", nil )
		end
	end
end

function Jesus:SetSystemValue( args )
	args.player:SetNetworkValue( args.name, args.value )
end

function Jesus:JesusEnable( args, sender )
    sender:SetNetworkValue( "JesusModeEnabled", 1 )
end

jesus = Jesus()