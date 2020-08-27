class 'HCommands'

function HCommands:__init()
	Events:Subscribe( "LoadAdminsTab", self, self.LoadAdminsTab )
	Events:Subscribe( "UnloadAdminsTab", self, self.UnloadAdminsTab )
end

function HCommands:LoadAdminsTab()
	if LocalPlayer:GetValue( "Tag" ) == "Owner" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "AdminD" then
		Events:Fire( "HelpAddItem",
			{
				name = "Админское :3",
				text =
					"> Админам:\n" ..
					"    /warn                  Выдать предупреждение.\n" ..
					"    /getwarns          Узнать сколько предупреждений у игрока.\n" ..
					"    /getmoney        Узнать сколько денег у игрока.\n" ..
					"    /addmoney        Дать денег.\n" ..
					"    /setmoney         Установить баланс.\n" ..
					"    /boom                Взорвать тс.\n" ..
					"    /kick                   Выгнать игрока.\n" ..
					"    /skick                 Скрытно выгнать игрока.\n" ..
					"    /boton                Включить бота-чистильщика.\n" ..
					"    /botoff                Выключить бота-чистильщика.\n" ..
					"    /kill                     Убить игрока.\n" ..
					"    /sky                    Отправить игрока в небо.\n" ..
					"    /hidetag             Скрыть/показать тэг над головой.\n" ..
					"    /ptphere             Телепортировать к себе.\n" ..
					"    /time                   Изменить игровое время.\n" ..
					"    /weather             Изменить погоду.\n \n" ..
					"> Гл. Админам:\n" ..
					"    /ban                    Кинуть игрока в ЧС (разбан только владельцем).\n" ..
					"    /remveh              Удалить весь ТС с сервера до его рестарта (В САМЫХ КРАЙНИХ СЛУЧАЯХ).\n" ..
					"    /clearchat           Очистить чат (не очищает историю).\n" ..
					"    /notice                Сообщение на экраны игроков.\n" ..
					"    /setgm                Изменить режим игроку (только визуально).\n" ..
					"    /setlang              Изменить язык игроку (только визуально)."
			} )
	end
end

function HCommands:UnloadAdminsTab()
	if LocalPlayer:GetValue( "Tag" ) == "Owner" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "AdminD" then
		Events:Fire( "HelpRemoveItem",
			{
				name = "Админское :3"
			} )
	end
end

hcommands = HCommands()