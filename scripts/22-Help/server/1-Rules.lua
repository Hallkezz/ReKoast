class 'HRules'

function HRules:__init()
	Network:Subscribe( "GetRules", self, self.GetRules )
end

function HRules:GetRules( args, sender )
	local getrulesfile = io.open("server/rules.txt", "r")
	s = getrulesfile:read("*a")

	if s then
		Network:Send( sender, "LoadRules", { ntext = s } )
	end
	getrulesfile:close()
end

hrules = HRules()