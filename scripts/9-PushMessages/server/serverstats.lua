class 'Messages'

function Messages:__init()
	Events:Subscribe( "ModuleError", self, self.ModuleError )
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
end

function Messages:ModuleError( e )
	Events:Fire( "ToDiscord", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" })
	Events:Fire( "ToDiscordConsole", { text = "**[Error] Critical server error has occurred! Module: " .. e.module .. "**" .. "\nERROR CODE:\n```" .. e.error .. "```" } )
	for p in Server:GetPlayers() do
		Network:Send( p, "textTw", { error = e.module } )
	end
end

function Messages:ModulesLoad()
	Events:Fire( "ToDiscordConsole", { text = "[Status] Module(s) loaded." } )
end

messages = Messages()