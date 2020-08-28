class 'Admin'

local vipPrefix = "[VIP] "
local youtuberPrefix = "[YouTube Деятель] "
local moderDPrefix = "[Модератор $] "
local adminDPrefix = "[Админ $] "
local adminPrefix = "[Админ] "
local gladminPrefix = "[Гл. Админ] "
local zvezdaPrefix = "★ "
local ownerPrefix = "[Владелец] "

local warns = {}

local vips = {}
local youtubers = {}
local modersD = {}
local adminsD = {}
local admins = {}
local gladmins = {}
local owners = {}

local admincount = 0

local invalidArgs = "Вы ввели недопустимые аргументы!"
local warning = "Вы не можете использовать это здесь!"
local invalidNum = "Вы ввели недопустимый номер!"
local nullPlayer = "Этот игрок не существует!"
local kicked = " кикнут с сервера!"
local inVehicle = "Вы должны находиться внутри транспорта и быть водителем!"
local playerInVehicle = "Этот игрок сейчас находится в транспорте!"
local playerTele = " телепортировал вас к себе!"
local playerTele2 = " телепортировался к вам!"
local killedSelf = "Вы убили себя!"
local playerKill = " убил тебя!"
local playerPetyx = " сделал вас петухом!"
local playerUnpetyx = " сделал вас не петухом!"
local vehicleRepaired = "Ваш автомобиль был отремонтирован!"
local vehicleKilled = "Ваш автомобиль был уничтожен!"
local playerTeleport = "Вы телепортировались к "
local paydayCash = 15

local adminKillReward = false
timerAdmin = ""
paydayTimer = Timer()
local timeDelay = 8
local paydayCount = 0

function Admin:loadVips(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "YouTubers were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			vips[i] = line
		end
	end
	file:close()
end

function Admin:loadYouTubers(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "YouTubers were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			youtubers[i] = line
		end
	end
	file:close()
end

function Admin:loadModersD(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "ModersD were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			modersD[i] = line
		end
	end
	file:close()
end

function Admin:loadAdminsD(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "AdminsD were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			adminsD[i] = line
		end
	end
	file:close()
end

function Admin:loadAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Admins were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			admins[i] = line
		end
	end
	file:close()
end

function Admin:loadGlAdmins(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Gl Admins were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			gladmins[i] = line
		end
	end
	file:close()
end

function Admin:loadOwners(filename)
	local file = io.open(filename, "r")
	local i = 0

	if file == nil then
		print( "Owners were not found" )
		return
	end

	for line in file:lines() do
		i = i + 1
		
		if string.sub(filename, 1, 2) ~= "--" then
			owners[i] = line
		end
	end
	file:close()
end

function Admin:__init()
	Events:Subscribe( "ClientModuleLoad", self, self.ClientModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
	Events:Subscribe( "PostTick", self, self.PostTick )

	Console:Subscribe( "getroles", self, self.GetRoles )

	Console:Subscribe( "addvip", self, self.AddVip )
	Console:Subscribe( "addmoderD", self, self.AddModerD )

	self:loadVips( "server/vips.txt" )
	self:loadYouTubers( "server/youtubers.txt" )
	self:loadModersD( "server/modersD.txt" )
	self:loadAdminsD( "server/adminsD.txt" )
	self:loadAdmins( "server/admins.txt" )
	self:loadGlAdmins( "server/gladmins.txt" )
	self:loadOwners( "server/owners.txt" )
end

function Admin:GetRoles( args )
	if args.text == "vips" or args.text == "youtubers" or args.text == "modersD" or args.text == "adminsD" or args.text == "admins" 
	or args.text == "gladmins" or args.text == "owners" then
		local file = io.open("server/" .. args.text .. ".txt", "r")
		local i = 0
		local ctext = args.text
		s = file:read("*a")
	
		if s then
			print( args.text .. ":\n" .. s )
			Events:Fire( "ToDiscordConsole", { text = "**" .. args.text .. ":**\n" .. s })
		end
		file:close()
	else
		print( "getroles <rolename>" )
		Events:Fire( "ToDiscordConsole", { text = "getroles <rolename>" })
	end
end

function Admin:AddVip( args )
	local file = io.open("server/vips.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	print( "Vip added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "Vip added: " .. args.text })
end

function Admin:AddModerD( args )
	local file = io.open("server/modersD.txt", "a")
	local text = args.text

	file:write("\n" .. text)
	file:close()

	print( "ModerD added: " .. args.text )
	Events:Fire( "ToDiscordConsole", { text = "ModerD added: " .. args.text })
end

function Admin:PostTick( args )
	if paydayCash == 0 then
		return
	end

	if paydayCash ~= "0" then
		if paydayTimer:GetMinutes() >= timeDelay then
			local count = 0
			for p in Server:GetPlayers() do
				count = count + 1
				p:RequestGroupMembership( SteamId("103582791460674447"), function(args)
					if args.member then
						p:SetMoney(p:GetMoney() + paydayCash)
						if p:GetValue( "Lang" ) == "ENG" then
							p:SendChatMessage( "[Reward №" .. paydayCount .. "] ", Color.White, "$15" .. " for subscribed on the server group! :3", Color( 255, 180, 3 ) )
						else
							p:SendChatMessage( "[Награда №" .. paydayCount .. "] ", Color.White, "$15" .. " за участие в группе сервера! :3", Color( 255, 180, 3 ) )
						end
					end
				end )
			end
			Events:Fire( "ToDiscord", { text = "[Status] Server is now online. Players: " .. count })
			paydayCount = paydayCount + 1
			paydayTimer:Restart()
		end
	end
end

function isVip( player )
	local vipsstring = ""
	for i,line in ipairs(vips) do
		vipsstring = vipsstring .. line .. " "
	end

	if(string.match(vipsstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isYouTuber( player )
	local youtubersstring = ""
	for i,line in ipairs(youtubers) do
		youtubersstring = youtubersstring .. line .. " "
	end

	if(string.match(youtubersstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isModerD( player )
	local modersDstring = ""
	for i,line in ipairs(modersD) do
		modersDstring = modersDstring .. line .. " "
	end

	if(string.match(modersDstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isAdminD( player )
	local adminsDstring = ""
	for i,line in ipairs(adminsD) do
		adminsDstring = adminsDstring .. line .. " "
	end

	if(string.match(adminsDstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end
	
function isAdmin( player )
	local adminstring = ""
	for i,line in ipairs(admins) do
		adminstring = adminstring .. line .. " "
	end

	if(string.match(adminstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isGlAdmin( player )
	local gladminstring = ""
	for i,line in ipairs(gladmins) do
		gladminstring = gladminstring .. line .. " "
	end

	if(string.match(gladminstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function isOwner( player )
	local ownerstring = ""
	for i,line in ipairs(owners) do
		ownerstring = ownerstring .. line .. " "
	end

	if (string.match(ownerstring, tostring(player:GetSteamId()))) then
		return true
	end

	return false
end

function confirmationMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color( 124, 242, 0 ) )
end

function deniedMessage( player, message )
	Chat:Send( player, "[Сервер] ", Color.White, message, Color.DarkGray )
end

function Admin:ClientModuleLoad( args )
	if (isYouTuber(args.player)) then
		args.player:SetNetworkValue( "Tag", "YouTuber" )
	elseif (isVip(args.player)) then
		args.player:SetNetworkValue( "Tag", "VIP" )
	elseif (isModerD(args.player)) then
		args.player:SetNetworkValue( "Tag", "ModerD" )
	elseif (isAdminD(args.player)) then
		args.player:SetNetworkValue( "Tag", "AdminD" )
	elseif (isAdmin(args.player)) then
		args.player:SetNetworkValue( "Tag", "Admin" )
	elseif (isGlAdmin(args.player)) then
		args.player:SetNetworkValue( "Tag", "GlAdmin" )
	elseif (isOwner(args.player)) then
		args.player:SetNetworkValue( "Tag", "Owner" )
	end

	args.player:SetNetworkValue("NT_TagName", nil)
	args.player:SetNetworkValue("NT_TagColor", nil)

	local tagname = ""
	local tagcolor = Color.White
	for steamid, tagn in pairs(sp) do
		if tostring(args.player:GetSteamId()) == tostring(steamid) then
			tagname = tagn
			tagcolor = spcol[tagn]
			args.player:SetNetworkValue( "NT_TagName", tagname )
			args.player:SetNetworkValue( "NT_TagColor", tagcolor )
		end
	end
end

function Admin:PlayerChat( args )
    local cmd_args = args.text:split( " " )
	sender = args.player

	if (isOwner(args.player)) or (isGlAdmin(args.player)) or (isAdmin(args.player)) or (isAdminD(args.player)) or (isModerD(args.player)) then
		if (cmd_args[1]) == "/hidetag" then
			if args.player:GetValue( "TagHide" ) then
				Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой отключён.", Color( 124, 242, 0 ) )
				args.player:SetNetworkValue( "TagHide", false )
			else
				Chat:Send( args.player, "[Сервер] ", Color.White, "Тэг над головой включён.", Color( 124, 242, 0 ) )
				args.player:SetNetworkValue( "TagHide", true )
			end
		end

		if (cmd_args[1]) == "/warn" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end
			local player = Player.Match(cmd_args[2])[1]

			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			if cmd_args[3] == "" then
				deniedMessage(args.player, "Причина не указана.")
				return false
			end

			warns[ player:GetId() ] = 1
			if #cmd_args < 3 then
				Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " получил предупреждение!", Color.Red )
			else
				Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " получил предупреждение! " .. "( " .. cmd_args[3] .. " )", Color.Red )
			end
			return true
		end

		if (cmd_args[1]) == "/getwarns" or (cmd_args[1]) == "/gw" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end
			if warns[ player:GetId() ] then
				Chat:Send( sender, "[Сервер] ", Color.White, "Предупреждений у " .. player:GetName() .. ": " .. warns[ player:GetId() ], Color.DarkGray )
			else
				Chat:Send( sender, "[Сервер] ", Color.White, "Предупреждений у " .. player:GetName() .. ": " .. "Нету ", Color.DarkGray )
			end
			return true
		end

		if (cmd_args[1]) == "/getmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, player:GetName() .. " имеет $" .. player:GetMoney() .. " на этом сервере." )
			return true
		end

		if (cmd_args[1]) == "/boom" then
			if args.player:GetWorld() ~= DefaultWorld then
				deniedMessage( sender, warning )
				return
			end	
			if not args.player:GetVehicle() then
				deniedMessage( sender, inVehicle )
				return
			end
			if args.player:GetVehicle():GetDriver() then
				args.player:GetVehicle():SetHealth( 0 )
				confirmationMessage( sender, vehicleKilled )
			else
				deniedMessage( sender, inVehicle )
			end
		end
	end

	if (isOwner(args.player)) or (isGlAdmin(args.player)) or (isAdmin(args.player)) then
		if (cmd_args[1]) == "/skick" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, player:GetName() .. " беспалевно кикнут по причине " .. args.text:sub(7) )
			player:Kick( "\nВы были бесшумно выгнаны по причине:\n" .. args.text:sub(7) )
			Events:Fire( "ToDiscordConsole", { text = player:GetName() .. " has invisibly kicked by " .. sender:GetName() .. " Reason: " .. args.text:sub(7) } )
			return true
		end

		if (cmd_args[1]) == "/ptphere" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			if (isOwner(args.player)) then
				if cmd_args[2] == "all*" then
					for p in Server:GetPlayers() do
						p:Teleport(sender:GetPosition(), sender:GetAngle())
						confirmationMessage( p, sender:GetName() .. " телепортировал всех игроков к себе." )
					end
					confirmationMessage( sender, "Все игроки были телепортированы к вам." )
					Events:Fire( "ToDiscordConsole", { text = sender:GetName() .. " warp all players to yourself." } )
					return true
				end
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:Teleport( args.player:GetPosition(), args.player:GetAngle() )
			confirmationMessage( player, args.player:GetName() .. playerTele )
			confirmationMessage( sender, player:GetName() .. playerTele2 )
			return true
		end

		if (cmd_args[1]) == "/boton" then
			if not self.boton then
				Chat:Send( args.player, "[Админ-система] ", Color.White, "Фильтрация чата включена!", Color.Brown )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Enabled!" } )
				print( args.player, " - Bot Enabled" )
				Events:Fire( "EnableWF" )
				self.boton = true
			else
				Chat:Send( args.player, "[Админ-система] ", Color.White, "Фильтрация чата уже включена!", Color.Brown )
			end
		end

		if (cmd_args[1]) == "/botoff" then
			if self.boton then
				Chat:Send( args.player, "[Админ-система] ", Color.White, "Фильтрация чата отключена!", Color.Brown )
				print( args.player, " - Bot Disabled" )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] Bot Disabled!" } )
				Events:Fire( "DisableWF" )
				self.boton = false
			end
		end

		if (cmd_args[1]) == "/weather" then
			if #cmd_args < 2 then
				deniedMessage( args.player, "Используйте: /weather <число>" )
				return false
			end
			if not tonumber(cmd_args[2]) then
				deniedMessage( args.player, "Используйте: /weather <число>" )
				return false
			end

			if tonumber(cmd_args[2]) > 2 then
				deniedMessage( args.player, "Невозможно установить большее значение для погоды." )
				return false
			elseif tonumber(cmd_args[2]) < 0 then
				deniedMessage( args.player, "Невозможно установить значения меньше 0 для погоды." )
				return false
			end
	
			if (cmd_args[2]) then
				args.player:GetWorld():SetWeatherSeverity( tonumber(cmd_args[2]) )
				confirmationMessage( args.player, "Погода изменена на " .. tonumber(cmd_args[2]) )
			end
		end
	end

	if (isOwner(args.player)) or (isGlAdmin(args.player)) then
		if (cmd_args[1]) == "/clearchat" then
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "", Color.White )
			Chat:Broadcast( "[Сервер] ", Color.White, "Чат очищен администратором " .. args.player:GetName() .. ".", Color.White )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] Chat has been cleared by " .. args.player:GetName() .. "." } )
		end

		if (cmd_args[1]) == "/remveh" then
			for veh in Server:GetVehicles() do
				veh:Remove()
			end

			confirmationMessage( sender, "Все транспортные средства на сервере были удалены." )
			return true
		end

		if (cmd_args[1]) == "/ban" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			Chat:Broadcast( "[Сервер] ", Color.White, player:GetName() .. " был внесён в черный список сервера.", Color( 255, 0, 0 ) )
			Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. player:GetName() .. " has been banned from the server by " .. sender:GetName() } )
			Server:AddBan(player:GetSteamId())
			player:Kick( "You have been banned from the server." )
			return true
		end

		if (cmd_args[1]) == "/notice" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local stringname = args.text:sub(9, 256)

			for p in Server:GetPlayers() do
				Network:Send( p, "Notice", { text = stringname } )
			end
		end

		if (cmd_args[1]) == "/addmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			amount = cmd_args[3]
			if(tonumber(amount) == nil) then
				deniedMessage( sender, invalidNum )
				return false
			end

			if cmd_args[2] == "all*" then
				for p in Server:GetPlayers() do
					p:SetMoney(p:GetMoney() + tonumber(cmd_args[3]))
				end
				Chat:Broadcast( "[Сервер] ", Color.White, "У всех теперь есть дополнительные $" .. tonumber(cmd_args[3]) .. "! Любезно предоставлено " .. args.player:GetName() .. ".", Color( 0, 255, 45 ) )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. "У всех теперь есть дополнительные $" .. tonumber(cmd_args[3]) .. "! Любезно предоставлено " .. args.player:GetName() .. "." } )
				return true
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:SetMoney(player:GetMoney() + tonumber(cmd_args[3]))
			confirmationMessage( sender, player:GetName() .. " добавил вам $" .. cmd_args[3] )
			return true
		end

		if (cmd_args[1]) == "/setmoney" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			amount = cmd_args[3]
			if(tonumber(amount) == nil) then
				deniedMessage( sender, invalidNum )
				return false
			end

			if cmd_args[2] == "all*" then
				for p in Server:GetPlayers() do
					p:SetMoney(tonumber(cmd_args[3]))
				end
				Chat:Broadcast( "[Сервер] ", Color.White, args.player:GetName() .. " установил всем $" .. tonumber(cmd_args[3]) .. "!", Color( 0, 255, 45 ) )
				Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. args.player:GetName() .. " установил всем $" .. tonumber(cmd_args[3]) .. "!" } )
				return true
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:SetMoney(tonumber(cmd_args[3]))
			confirmationMessage( sender, player:GetName() .. " установил ваш баланс на $" .. cmd_args[3] )
			return true
		end

		if (cmd_args[1]) == "/setgm" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, "Установлен режим: " .. cmd_args[3] .. " для " .. player:GetName() )
			player:SetNetworkValue( "GameMode", cmd_args[3] )
			return true
		end

		if (cmd_args[1]) == "/setlang" then
			if #cmd_args < 2 then
				deniedMessage( sender, invalidArgs )
				return false
			end

			local player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			confirmationMessage( sender, "Установлен язык: " .. cmd_args[3] .. " для " .. player:GetName() )
			player:SetNetworkValue( "Lang", cmd_args[3] )
			return true
		end
	end

	if (cmd_args[1]) == "/time" then
		if #cmd_args < 3 then
			deniedMessage( args.player, "Используйте: <set:add:step> <число>" )
			return false
		end
		if not tonumber(cmd_args[3]) then
			deniedMessage( args.player, "Используйте: <set:add:step> <число>" )
			return false
		end

		if (cmd_args[2]) == "set" then
			args.player:GetWorld():SetTime( tonumber(cmd_args[3]) )
			confirmationMessage( args.player, "Игровое время установлено на " .. tonumber(cmd_args[3]) .. "." )
		elseif (cmd_args[2]) == "add" then
			args.player:GetWorld():SetTime( args.player:GetWorld():GetTime() + tonumber(cmd_args[3]) )
			confirmationMessage( args.player, "Добавлено " .. tonumber(cmd_args[3]) .. " к игровому времени." )
		elseif (cmd_args[2]) == "step" then
			args.player:GetWorld():SetTimeStep( tonumber(cmd_args[3]) )
			confirmationMessage( args.player, "Скорость времени суток изменена на " .. tonumber(cmd_args[3]) )
		end
	end

	if (cmd_args[1]) == "/mass" then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end	
		if #cmd_args < 2 then
			deniedMessage( sender, invalidArgs )
			return false
		end

		if not tonumber( cmd_args[2] ) then
			deniedMessage( sender, invalidArgs )
			return false
		end

		playerVehicle = sender:GetVehicle()

		if not playerVehicle then
			deniedMessage( sender, inVehicle )
			return false
		end

		if playerVehicle:GetDriver() and args.player:GetState() == PlayerState.InVehicle then
			playerVehicle:SetMass( tonumber(cmd_args[2]) )
			confirmationMessage( sender, "Масса вашего автомобиля установлена ​​на " .. tonumber(cmd_args[2]) )
		else
			deniedMessage( sender, inVehicle )
		end
		return true
	end

	if (cmd_args[1]) == "/kill" or (cmd_args[1]) == "/suicide" then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end	
		if #cmd_args < 2 then
			args.player:SetHealth( 0 )
			confirmationMessage( sender, killedSelf )
			for p in Server:GetPlayers() do
				if p:GetValue( "Lang" ) == "ENG" then
					p:SendChatMessage( "[Server] ", Color.White, args.player:GetName() .. " has been suicided(", Color( 137, 137, 137 ) )
				else
					p:SendChatMessage( "[Сервер] ", Color.White, args.player:GetName() .. " покончил(а) жизнь самоубийством(", Color( 137, 137, 137 ) )
				end
			end
			return true
		end
	end

	if (cmd_args[1]) == "/repair" then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end
		if not args.player:GetVehicle() then
			deniedMessage( sender, inVehicle )
			return false
		end
		if(args.player:GetMoney() >= 0) then
			veh = args.player:GetVehicle()
			args.player:GetVehicle():SetHealth( 1 )
			confirmationMessage( sender, vehicleRepaired )
			confirmationMessage( sender, "Ваше транспортное средство будет выглядеть поврежденным, но здоровье восстанавливается." )
		end
	end

	if (cmd_args[1]) == "/sky" then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end

		if #cmd_args < 2 then
			local pos = args.player:GetPosition()
			args.player:Teleport( Vector3( pos.x, pos.y + 800, pos.z ), args.player:GetAngle() )
			confirmationMessage( sender, "Поехали!"  )
			return true
		else
			if (isOwner(args.player)) or (isAdmin(args.player)) then
				local player = Player.Match(cmd_args[2])[1]
				if not IsValid(player) then
					deniedMessage( sender, nullPlayer )
					return false
				end
				
				local pos = player:GetPosition()
				player:Teleport( Vector3( pos.x, pos.y + 800, pos.z ), player:GetAngle() )
				confirmationMessage( sender, args.player:GetName() .. " запустил тебя в небо." )
				confirmationMessage( sender, "Ты отправил " .. player:GetName() .. " в небо." )
				return true
			end
		end
	end

	if (cmd_args[1]) == "/clear" then
		if #cmd_args < 2 then
			sender:ClearInventory()
			confirmationMessage( sender, "Ваш инвентарь был очищен." )
			return true
		end
		if #cmd_args >= 2 then
			player = Player.Match(cmd_args[2])[1]
			if not IsValid(player) then
				deniedMessage( sender, nullPlayer )
				return false
			end

			player:ClearInventory()
			confirmationMessage( player, "Ваш инвентарь был очищен " .. sender:GetName() )
			confirmationMessage( sender, "Вы очистили " .. player:GetName() .. " инвентарь." )
			return true
		end
	end

	if (cmd_args[1]) == "/pinkmobile" then
		if not sender:GetVehicle() then
			deniedMessage( sender, inVehicle )
			return false
		end

		if sender:GetMoney() >= 0 then
			confirmationMessage( sender, "Наслаждайтесь своим Розовым Транспортом!" )

			veh = sender:GetVehicle()
			veh:SetColors( Color( 255, 62, 150 ), Color( 205, 41, 144 ) )
			veh:Respawn()
			sender:EnterVehicle( veh, VehicleSeat.Driver )
			return true
		end
	end

	if (cmd_args[1]) == "/down" then
		if args.player:GetWorld() ~= DefaultWorld then
			deniedMessage( sender, warning )
			return
		end
		pos = sender:GetPosition()
		sender:Teleport( Vector3( pos.x, pos.y - 10,  pos.z ), sender:GetAngle() )
		confirmationMessage( sender, "Мы идём вниз." )
	end

	if not args.player:GetValue( "Mute" ) then
		if (isVip(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), vipPrefix, Color( 255, 100, 232 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( vipPrefix, args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = vipPrefix .. args.player:GetName() .. ": " .. args.text  } )
				end
				return false
			end
		end

		if (isYouTuber(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), youtuberPrefix, Color( 255, 0, 50 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( "[YouTuber] ", args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[YouTuber] " .. args.player:GetName() .. ": " .. args.text } )
				end
				return false
			end
		end

		if (isModerD(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), moderDPrefix, Color( 255, 148, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( "[Moder $] " .. args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[Moder $] " .. args.player:GetName() .. ": " .. args.text } )
				end
				return false
			end
		end

		if (isAdminD(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminDPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( "[Admin $] " .. args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[Admin $] " .. args.player:GetName() .. ": " .. args.text } )
				end
				return false
			end
		end

		if (isAdmin(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), adminPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( "[Admin] ", args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[Admin] " .. args.player:GetName() .. ": " .. args.text } )
				end
				return false
			end
		end

		if (isGlAdmin(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), gladminPrefix, Color( 255, 48, 48 ), args.player:GetName(), args.player:GetColor(), ": " .. text, Color.White )
					print( "[Gl Admin] ", args.player:GetName() .. ": " .. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[Gl Admin] " .. args.player:GetName() .. ": " .. args.text } )
				end
				return false
			end
		end

		if (isOwner(args.player)) then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), ownerPrefix, Color( 200, 100, 255 ), args.player:GetName(), args.player:GetColor(), ": " .. args.text, Color.White )
					print( "[Owner] " .. args.player:GetName() .. ": ".. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[Owner] " .. args.player:GetName() .. ": ".. args.text } )
				end
				return false
			end
		end

		if args.player:GetValue("NT_TagName") then
			local text = args.text
			if string.sub(text, 1, 1) ~= "/" then
				if args.player:GetValue("chat") == 2 then
					Chat:Broadcast( zvezdaPrefix, Color( 255, 255, 50 ), "[" .. args.player:GetValue("NT_TagName") .. "] ", args.player:GetValue("NT_TagColor"), args.player:GetName(), args.player:GetColor(), ": " .. args.text, Color.White )
					print( "[" .. args.player:GetValue("NT_TagName") .. "] " .. args.player:GetName() .. ": ".. args.text )
					Events:Fire( "ToDiscordConsole", { text = "[" .. args.player:GetValue("NT_TagName") .. "] " .. args.player:GetName() .. ": ".. args.text } )
				end
				return false
			end
		end
	end
end

function Admin:ModuleUnload()
	if self.boton then
		print( "Server - Bot Disabled" )
		Events:Fire( "DisableWF" )
	end
end

admin = Admin()