class 'HControls'

function HControls:__init()
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "EngHelp", self, self.EngHelp )
end

function HControls:EngHelp()
	Events:Fire( "HelpRemoveItem",
		{
			name = "Часто задаваемые вопросы (FAQ)"
		} )
	Events:Fire( "HelpAddItem",
		{
			name = "FAQ",
			text =
                "> What languages can I use to chat?\n" ..
                "    You can chat in absolutely any language!\n \n" ..
				"> The market and map doesn't work?\n" ..
				"    You don't have needed files in 'images' folder.\n" ..
				"    You need to verify your game files, using the 'Properties->Verify Game Files' buttons in Steam.\n \n" ..
				"> The model of player is broken. What i should do?\n" ..
				"    Bug can be obtained on entering the server.\n" ..
				"    To fix this, you need to re-enter the game. Or have fun with it :3\n \n" ..
				"Enjoy the game on the Russian server! :D"
		} )
end

function HControls:ModulesLoad()
	Events:Fire( "HelpAddItem",
		{
			name = "Часто задаваемые вопросы (FAQ)",
			text =
				"> Что даёт VIP?\n" ..
				"    - Возможность иметь 2-й дом.\n" ..
				"    - Возможность приобрести некоторые товары в черном рынке.\n" ..
				"    - Префикс 'VIP' (Чтобы включить, нажмите на 'H').\n \n" ..
			    "> Не работает магазин/карта или другие функции?\n" ..
				"    1. У вас отсутствуют нужные файлы в папке images.\n" ..
				"       Чтобы восстановить файлы, достаточно переустановить клиент\n       или через свойства стима выполнить проверку цельности файлов игры.\n" ..
				"    2. У вас отсутствуют нужные системные или игровые шрифты.\n" ..
				"       Чтобы восстановить игровые шрифты, переустановите клиент.\n" ..
				"    3. Возможно сервер использует устарвший игровой мод, либо сервер настроен неправильно.\n \n" ..
			    "> Сломались кости персонажа?\n" ..
				"    Баг появляется после любого перезахода на сервер.\n" ..
				"     Чтобы исправить, просто перезайдите в игру или наслаждайтесь :3"
		} )
end

hcontrols = HControls()