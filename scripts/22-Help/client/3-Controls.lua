class 'HControls'

function HControls:__init()
	Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
	Events:Subscribe( "EngHelp", self, self.EngHelp )
end

function HControls:EngHelp()
	Events:Fire( "HelpRemoveItem",
		{
			name = "Управление"
		} )
	Events:Fire( "HelpAddItem",
		{
			name = "Control",
			text =
			    "> Main:\n" ..
				"    'F1'              Open game map.\n" ..
				"    'F2' or 'M'      Open players map (you can teleport).\n" ..
				"    'F3'              Disable/Enable chat.\n" ..
				"    'F4'              Open Console.\n" ..
				"    'F5'		       Open Players List.\n" ..
				"    'F6'              Enable/Disable firstperson.\n" ..
				"    'F11'             Hide server interface.\n" ..
				"    'H'               Change the chat mode.\n" ..
				"    'B'               Open Server Menu.\n" ..
				"    'G'               Grenades Selector.\n" ..
				"    'V'               The teleport menu.\n" ..
                "    'Shift' 2x      Enable Pigeon-Mod.\n" ..
				"    'L'               Open the door of military bases.\n \n" ..
				"> Vehicles:\n" ..
				"    'X'               Hand brake.\n" ..
				"    'C'               Change the camera view.\n" .. 
				"    'Q'               Siren/Signal.\n" ..
				"    'Y'               Tuning.\n" ..
				"    'X' or 'W,A,S,D'   Hydraulics.\n \n" ..
				"> Aircraft:\n" ..
				"    'Ctrl' + 'Z'    Vertical takeoff.\n" ..
				"    'X'               Reverse.\n" ..
				"    'R'               Autopilot.\n \n" ..
				"> FREECAM:\n" ..
				"    'O'               Enable FREECAM.\n" ..
				"    'Shift'           Boost.\n" ..
				"    'Ctrl'            Slow down.\n" ..
				"    '↑'               Rotate Camera.\n" ..
				"    'W'               Move forward.\n" ..
				"    'A'               Move left.\n" .. 
				"    'S'               Move backward.\n" ..
				"    'D'               Move right."
		} )
end

function HControls:ModulesLoad()
	Events:Fire( "HelpAddItem",
		{
			name = "Управление",
			text =
			    "> Основное:\n" ..
				"    'F1'              Открыть карту.\n" ..
				"    'F2' / 'M'      Открыть карту игроков (можно телепортироваться).\n" ..
				"    'F3'              Выключить/включить чат.\n" ..
				"    'F4'              Открыть консоль.\n" ..
				"    'F5'		       Показать список игроков.\n" ..
				"    'F6'              Включить/отключить вид от 1-го лица.\n" ..
				"    'H'               Сменить режим чата.\n" ..
				"    'F11'            Скрыть/показать интерфейс сервера.\n" ..
				"    'B'                Открыть меню сервера.\n" ..
				"    'G'                Сменить взрывчатку.\n" ..
				"    'V'                Меню телепортации.\n" ..
                "    'Shift' 2x     Включить голубь-мод.\n" ..
				"    'L'                 Открыть ворота военных баз.\n \n" ..
				"> Транспорт:\n" ..
				"    'X'               Ручной тормоз.\n" ..
				"    'C'               Изменить вид камеры.\n" .. 
				"    'Q'               Сигналить.\n" ..
				"    'Y'               Тюнинг.\n" ..
				"    '>'               Переключить трек.\n" ..
				"    'X' и 'W,A,S,D'   Гидравлика.\n \n" ..
				"> Самолёты:\n" ..
				"    'Ctrl' + 'Z'    Вертикальная посадка.\n" ..
				"    'X'               Задний ход.\n" ..
				"    'R'               Автопилот.\n \n" ..
				"> Свободная камера:\n" ..
				"    'O'               Включить свободную камеру.\n" ..
				"    'Shift'          Ускориться.\n" ..
				"    'Ctrl'            Замедлиться.\n" ..
				"    '↑'               Вертеть камеру.\n" ..
				"    'npad1'        Сбросить траекторию.\n" ..
				"    'npad2 / ЛКМ'           Добавить путевую точку для траектории.\n" ..
				"    'npad3 / СКМ'           Воспроизвести траекторию (С первой точки).\n" ..
				"    'npad4'        Воспроизвести траекторию (С последней точки).\n" ..
				"    'npad5 / ПКМ'           Поставить траекторию на паузу."
		} )
end

hcontrols = HControls()