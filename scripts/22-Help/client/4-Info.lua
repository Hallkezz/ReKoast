class 'HControls'

function HControls:__init()
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "EngHelp", self, self.EngHelp )
end

function HControls:EngHelp()
	Events:Fire( "HelpRemoveItem",
		{
			name = "Информация"
		} )
	Events:Fire( "HelpAddItem",
		{
			name = "Information",
			text =
				"> Server gamemode developer:\n" ..
				"     Hallkezz\n \n" ..
				"> Also thanks for scripts:\n" ..
				"     Proxwian\n" ..
				"     JasonMRC\n" ..
				"     Lord_Farquaad\n" ..
				"     Dev_34\n" ..
				"     DaAlpha\n" ..
				"     SinisterRectus\n" ..
				"     SK83RJOSH\n" ..
				"     dreadmullet\n" ..
				"     Trix\n" ..
				"     And many other developers..."
		} )
end

function HControls:ModulesLoad()
	Events:Fire( "HelpAddItem",
		{
			name = "Информация",
			text =
				"> Разработчик серверного игрового мода:\n" ..
				"     Hallkezz\n \n" ..
				"> Заимствованный код:\n" ..
				"     Proxwian\n" ..
				"     JasonMRC\n" ..
				"     Lord_Farquaad\n" ..
				"     Dev_34\n" ..
				"     DaAlpha\n" ..
				"     SinisterRectus\n" ..
				"     SK83RJOSH\n" ..
				"     dreadmullet\n" ..
				"     Trix\n" ..
				"     И много других разработчиков..."
		} )
end

hcontrols = HControls()