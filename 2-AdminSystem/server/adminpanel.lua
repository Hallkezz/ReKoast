class 'AdminPanel'

function AdminPanel:__init()
    self.warns = {}

    self.weaponNames =
    {
        [ 2 ] = "Пистолет",
        [ 4 ] = "Револьвер",
        [ 5 ] = "СМГ",
        [ 6 ] = "Пилотный Дробовик",
        [ 11 ] = "Штурмовая Винтовка",
        [ 13 ] = "Дробовик",
        [ 14 ] = "Снайперская Винтовка",
        [ 16 ] = "Ракетная Установка",
        [ 17 ] = "Гранатомет",
        [ 28 ] = "Пулемет",
        [ 43 ] = "Пузырьковая Пушка",
        [ 66 ] = "СУПЕР Ракетная Установка",
        [ 100 ] = "(DLC) Штурмовая винтовка 'В яблочко",
        [ 101 ] = "(DLC) Воздушное силовое ружье",
        [ 102 ] = "(DLC) Кластерный бомбомет",
        [ 103 ] = "(DLC) Личное оружие Рико",
        [ 104 ] = "(DLC) Счетвернный гранатомет",
        [ 105 ] = "(DLC) Залповая ракетная установка",
        [ 31 ] = "ПВО",
        [ 116 ] = "Ракеты",
        [ 26 ] = "Миниган",
        [ 129 ] = "СУПЕР Пулемет",
        [ 32 ] = "Параша"
    }

    Network:Subscribe( "RequestInformation", self, self.RequestInformation )
    Network:Subscribe( "SendMessage", self, self.SendMessage )
    Network:Subscribe( "SaveMessages", self, self.SaveMessages )
    Network:Subscribe( "LoadMessages", self, self.LoadMessages )

    Network:Subscribe( "AddWarn", self, self.AddWarn )
    Network:Subscribe( "SetHealth", self, self.SetHealth )
    Network:Subscribe( "KickPlayer", self, self.KickPlayer )
    Network:Subscribe( "AddMoney", self, self.AddMoney )
    Network:Subscribe( "Teleport", self, self.Teleport )
    Network:Subscribe( "TeleportToMe", self, self.TeleportToMe )
    Events:Subscribe( "LogMessage", self, self.LogMessage )
end

function AdminPanel:RequestInformation ( player, admin )
    if IsValid ( player, false ) then
		local weapon = player:GetEquippedWeapon()
		local vehicle = player:GetVehicle()
		local steamID = tostring ( player:GetSteamId() )
		local data =
			{
				name = player:GetName() .. " ( ID: " .. player:GetId() .. " )",
				ip = player:GetIP(),
				steamID = steamID,
				ping = player:GetPing(),
				health = math.floor ( ( player:GetHealth ( ) * 100 ) ) .."%",
				money = "$" .. player:GetMoney(),
				position = player:GetPosition(),
				angle = player:GetAngle(),
				vehicle = ( player:InVehicle() and vehicle:GetName ( ) .." ( ID: ".. vehicle:GetModelId ( ) .." ) " or "Пешком" ),
				vehicleHealth = ( player:InVehicle() and math.floor ( player:GetVehicle ( ):GetHealth ( ) * 100 ) or 0 ) .."%",
				model = player:GetModelId(),
				weapon = ( self.weaponNames [ weapon.id ] or "Неизвестно" ) .. " ( ID: ".. weapon.id .." )",
				weaponAmmo = ( weapon.ammo_clip + weapon.ammo_reserve ),
                worldid = player:GetWorld():GetId(),
                groups = player:GetValue( "Tag" ),
                lang = player:GetValue( "Lang" ),
                gamemode = player:GetValue( "GameMode" ),
                kills = player:GetValue( "Kills" )
			}
		Network:Send( admin, "DisplayInformation", data )
	end
end

function AdminPanel:SendMessage( args, sender )
    for p in Server:GetPlayers() do
        if p:GetValue( "Tag" ) == "Owner" or p:GetValue( "Tag" ) == "GlAdmin" or p:GetValue( "Tag" ) == "Admin" or p:GetValue( "Tag" ) == "AdminD" or p:GetValue( "Tag" ) == "ModerD" then
            Network:Send( p, "ToChat", { text = os.date( "[%X] " ) .. sender:GetName() .. ": " .. args.msg, tcolor = Color.White } )
            p:SendChatMessage( "[Админ-чат] ", Color.White, sender:GetName() .. ": " .. args.msg, Color.Yellow )
            print( "[Admin-chat] " .. sender:GetName() .. ": " .. args.msg )
        end
    end
end

function AdminPanel:SaveMessages( args )
	self.savetext = args.gettext
end

function AdminPanel:LoadMessages( args )
    if self.savetext then
        for p in Server:GetPlayers() do
            if p:GetValue( "Tag" ) == "Owner" or p:GetValue( "Tag" ) == "GlAdmin" or p:GetValue( "Tag" ) == "Admin" or p:GetValue( "Tag" ) == "AdminD" or p:GetValue( "Tag" ) == "ModerD" then
                Network:Send( p, "ToChat", { text = self.savetext } )
            end
        end
    end
end

function AdminPanel:AddWarn( args, player )
    if args.number == 0 then
        Chat:Broadcast( "[Сервер] ", Color.White, args.pname:GetName() .. " получил предупреждение! ( " .. args.text .. " )", Color.Red )
    else
        self.warns[ args.pname:GetId() ] = args.number
        Chat:Broadcast( "[Сервер] ", Color.White, args.pname:GetName() .. " получил предупреждение! " .. self.warns[ args.pname:GetId() ] .. "/3 " .. "( " .. args.text .. " )", Color.Red )
    end
    print( args.pname:GetName() .. " gives warning to " .. player:GetName() .. " | Reason: " .. args.text )
end

function AdminPanel:SetHealth( args, player )
    args.pname:SetHealth( args.number / 100 )
    Chat:Send( player, "[Сервер] ", Color.White, "Вы установили здоровье " .. args.pname:GetName() .. " на " .. args.number .. "%", Color.Lime )
    Chat:Send( args.pname, "[Сервер] ", Color.White, player:GetName() .. " установил ваше здоровье на " .. args.number .. "%", Color.DarkGray )
    print( player:GetName() .. " set health " .. args.number .. "% to " .. args.pname:GetName() )
end

function AdminPanel:KickPlayer( args, player )
    args.pname:Kick( args.text )
    Chat:Broadcast( "[Сервер] ", Color.White, args.pname:GetName() .. " был кикнут. Причина: " .. args.text, Color.Red )
    print( args.pname:GetName() .. " has been kicked by " .. player:GetName() .. " | Reason: " .. args.text )
end

function AdminPanel:AddMoney( args, player )
    args.pname:SetMoney( args.pname:GetMoney() + args.number )
    Chat:Send( player, "[Сервер] ", Color.White, "Вы выдали $" .. args.number .. " для " .. args.pname:GetName() .. "!", Color.Lime )
    Chat:Send( args.pname, "[Сервер] ", Color.White, player:GetName() .. " добавил вам $" .. args.number .. "!", Color.DarkGray )
    print( player:GetName() .. " gives $" .. args.number .. " to " .. args.pname:GetName() )
end

function AdminPanel:Teleport( args, player )
    player:SetPosition( args.pname:GetPosition() )
    Chat:Send( player, "[Сервер] ", Color.White, "Вы были телепортированы к " .. args.pname:GetName() .. ".", Color.Lime )
    Chat:Send( args.pname, "[Сервер] ", Color.White, player:GetName() .. " телепортировался к вам.", Color.DarkGray )
    print( player:GetName() .. " has been teleported to " .. args.pname:GetName() )
end

function AdminPanel:TeleportToMe( args, player )
    args.pname:SetPosition( player:GetPosition() )
    Chat:Send( player, "[Сервер] ", Color.White, args.pname:GetName() .. " был телепортирован к вам.", Color.Lime )
    Chat:Send( args.pname, "[Сервер] ", Color.White, player:GetName() .. " телепортировал вас к себе.", Color.DarkGray )
    print( player:GetName() .. " teleported to yourself " .. args.pname:GetName() )
end

function AdminPanel:LogMessage( args )
    for p in Server:GetPlayers() do
        if p:GetValue( "Tag" ) == "Owner" or p:GetValue( "Tag" ) == "GlAdmin" then
            Network:Send( p, "ToLogs", { text = args.text, tcolor = Color.White } )
        end
    end
end

adminpanel = AdminPanel()