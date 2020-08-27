class 'HCommands'

function HCommands:__init()
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "EngHelp", self, self.EngHelp )
end

function HCommands:EngHelp()
	Events:Fire( "HelpRemoveItem",
		{
			name = "Команды"
		} )
	Events:Fire( "HelpAddItem",
		{
			name = "Commands",
			text =
				"* All commands must be entered in the game chat (T).\n \n" ..
				"> Basic:\n" ..
				"    /hideme               Hide yourself from the map and mini-map.\n" ..
				"    /clear                    Clear Inventory.\n" ..
				"    /calc                     Calculator.\n" ..
				"    /bind             Key binding.\n" ..
				"    /gethome             Get Home Coordinates.\n \n" ..
				"> Chat:\n" ..
				"    /me <text>        Action.\n" ..
				"    /try <text>         Solving disputes.\n" ..
				"    /cd <time>        Countdown.\n" ..
				"    /pm <player> <message>      Send a private message.\n \n" ..
				"> Mini-games:\n" ..
				"    /tron             Join/Leave on Tron.\n" ..
				"    /khill              Join/Leave on King Of The Hill.\n" ..
				"    /derby            Join/Leave on Derby.\n" ..
				"    /race              Open Racing Menu.\n" ..
				"    /tetris             Playing Tetris.\n" ..
				"    /pong <difficulty> Playing Pong.\n" ..
				"       *difficulties: Noob, Easy, Medium, Hard, Extreme"
		} )
end

function HCommands:ModulesLoad()
	Events:Fire( "HelpAddItem",
		{
			name = "Команды",
			text =
				"* Все команды нужно вводить в игровой чат (T).\n \n" ..
				"> Часто используемые:\n" ..
				"    /hideme               Скрыть себя с карты и мини-карты.\n" ..
				"    /clear                    Очистить инвентарь.\n" ..
				"    /calc                     Калькулятор.\n" ..
				"    /bind                    Привязка клавиш.\n" ..
				"    /gethome             Получить координаты дома.\n \n" ..
				"> Чат:\n" ..
				"    /me <текст>        Действие.\n" ..
				"    /try <текст>         Решение спорных ситуаций.\n" ..
				"    /cd <время>        Обратный отсчёт.\n" ..
				"    /pm <игрок> <сообщение>      Отправить личное сообщение.\n \n" ..
				"> Развлечения:\n" ..
				"    /tron              Войти/выйти в лобби на Трон.\n" ..
				"    /khill              Войти/выйти в лобби на Царь Горы.\n" ..
				"    /derby            Войти/выйти в лобби на Дерби.\n" ..
				"    /race              Открыть меню гонок.\n" ..
				"    /tetris             Играть в тетрис.\n" ..
				"    /pong <сложность> Играть в понг.\n" ..
				"       *сложности: Noob, Easy, Medium, Hard, Extreme"
		} )
end

hcommands = HCommands()