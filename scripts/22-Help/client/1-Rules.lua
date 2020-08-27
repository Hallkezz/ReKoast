class 'HRules'

function HRules:__init()
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Network:Subscribe( "LoadRules", self, self.LoadRules )
end

function HRules:ModulesLoad( args )
	Network:Send( "GetRules" )
end

function HRules:LoadRules( args )
	Events:Fire( "HelpAddItem",
	{
		name = "ПРАВИЛА",
		text = args.ntext
	} )
end

hrules = HRules()