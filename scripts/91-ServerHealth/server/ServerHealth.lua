class 'ServerHealth'

function ServerHealth:__init()
    self:CheckServerHealth()
    Events:Subscribe( "ServerStart", self, self.ServerStart )
    Console:Subscribe( "online", self, self.GetOnline )
    Console:Subscribe( "help", self, self.GetHelp )
end

function ServerHealth:CheckServerHealth()
    local func = coroutine.wrap( function()
        local last_time = Server:GetElapsedSeconds()
        local players_history = {}
        
        while true do
            Timer.Sleep( 1000 )

            local players = {}

            for p in Server:GetPlayers() do
                if IsValid(p) then
                    players[p:GetId()] = p
                end
            end

            local seconds_elapsed = Server:GetElapsedSeconds()

            if seconds_elapsed - last_time > 3 then
                local msg = string.format( "**[Status] Hitch warning: Server is running %.2f seconds behind!**", seconds_elapsed - last_time )
                Events:Fire( "ToDiscord", { text = msg })
                Events:Fire( "LogMessage", { text = msg })
                print( msg )

                local last_players = players_history[tostring(string.format("%.0f", last_time))]
            end

            -- Erase old players
            players_history[tostring(string.format("%.0f", last_time))] = nil

            last_time = seconds_elapsed

            -- Add new players
            players_history[tostring(string.format("%.0f", last_time))] = players
        end
    end )()
end

function ServerHealth:ServerStart()
    Events:Fire( "ToDiscord", { text = "**[Status] Server is running.**" })
end

function ServerHealth:GetOnline( args )
    local players = {}
    local count = 0
    Events:Fire( "ToDiscordConsole", { text = "Command completed. If you do not see anything, then the server is empty." } )
    for p in Server:GetPlayers() do
        count = count + 1
        if IsValid(p) then
            players[p:GetId()] = p
            if args.text == "full" then
                Events:Fire( "ToDiscordConsole", { text = "Players on server: " .. tostring( p ) })
            end
        end
    end
    if args.text ~= "full" then
        Events:Fire( "ToDiscordConsole", { text = "Online: " .. count })
    end
end

function ServerHealth:GetHelp( args )
    Events:Fire( "ToDiscordConsole", { text = "**Documentation:** \n" ..
    "Chat: \n" ..
    "> say <text> - write console message. \n" ..
    "Admin: \n" ..
    "> online - get online on the server. \n" ..
    "> online full - get full online on the server. \n" ..
    "> kick <player> - kick the player. \n" ..
    "> ban <player> - ban the player. (Unban only by the owner) \n" ..
    "> reloadbans - update bans list. \n" ..
    "> add<rolename> <steamID> - add SteamID to role. \n" ..
    "> getroles <rolename> - get all SteamId in role. \n" ..
    "Modules control: \n" ..
    "> reload <module> - reload module. \n" ..
    "> load <module> - load module. \n" ..
    "> unload <module> - unload module." } )

   print( "**Documentation:** \n" ..
    "Chat: \n" ..
    "> say <text> - write console message. \n" ..
    "Admin: \n" ..
    "> online - get online on the server. \n" ..
    "> online full - get full online on the server. \n" ..
    "> kick <player> - kick the player. \n" ..
    "> ban <player> - ban the player. (Unban only by the owner) \n" ..
    "> reloadbans - update bans list. \n" ..
    "> add<rolename> <steamID> - add SteamID to role. \n" ..
    "> getroles <rolename> - get all SteamId in role. \n" ..
    "Modules control: \n" ..
    "> reload <module> - reload module. \n" ..
    "> load <module> - load module. \n" ..
    "> unload <module> - unload module." )
end

serverhealth = ServerHealth()