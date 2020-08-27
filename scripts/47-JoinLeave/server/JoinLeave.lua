class 'JoinLeave'

function JoinLeave:__init()
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
  	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
end

function JoinLeave:PlayerJoin( args )
	args.player:SetNetworkValue( "GameMode", "FREEROAM" )
	args.player:SetNetworkValue( "Lang", "..." )
	args.player:SetNetworkValue( "TagHide", true )
	args.player:SetNetworkValue( "ClanTag", "" )
	for p in Server:GetPlayers() do
		if p:GetValue( "Lang" ) == "ENG" then
			p:SendChatMessage( args.player:GetName(), args.player:GetColor(), " joined to the server!", Color( 255, 215, 0 ) )
		else
			p:SendChatMessage( args.player:GetName(), args.player:GetColor(), " присоединился(лась) к серверу!", Color( 255, 215, 0 ) )
		end
	end
	Events:Fire( "ToDiscordConsole", { text = args.player:GetName() .. " joined to the server." } )
end

function JoinLeave:PlayerQuit( args )
	for p in Server:GetPlayers() do
		if p:GetValue( "Lang" ) == "ENG" then
			p:SendChatMessage( args.player:GetName() .. " left the server(", Color( 137, 137, 137 ) )
		else
			p:SendChatMessage( args.player:GetName() .. " покинул(а) нас(", Color( 137, 137, 137 ) )
		end
	end
	Events:Fire( "ToDiscordConsole", { text = args.player:GetName() .. " left the server." } )
end

joinLeave = JoinLeave()