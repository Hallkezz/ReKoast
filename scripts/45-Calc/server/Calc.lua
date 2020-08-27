class 'Calc'

function Calc:__init()
	Events:Subscribe( "PlayerChat", self, self.PlayerChat )
end

function Calc:PlayerChat( args )
	local cmd_args = args.text:split( " " )
	if (cmd_args[1]) == "/calc" then
		if #cmd_args < 3 then
			Chat:Send( args.player, "[Калькулятор] ", Color.White, "Использование: /calc <число> <действие> <число>", Color.DarkGray )
			return false
		end
		if not tonumber(cmd_args[2]) then
			Chat:Send( args.player, "[Калькулятор] ", Color.White, "Использование: /calc <число> <действие> <число>", Color.DarkGray )
			return false
		end
		if not tonumber(cmd_args[4]) then
			Chat:Send( args.player, "[Калькулятор] ", Color.White, "Использование: /calc <число> <действие> <число>", Color.DarkGray )
			return false
		end
		Chat:Send( args.player, "Пример: " .. tostring( tonumber(cmd_args[2]) .. " " .. cmd_args[3] .. " " .. tonumber(cmd_args[4]) ), Color.White )
		if cmd_args[3] == "+" then
			self.otvet = tonumber(cmd_args[2]) + tonumber(cmd_args[4])
			Chat:Send( args.player, "Ответ: " .. tostring( self.otvet ), Color.White )
		elseif cmd_args[3] == "-" then
			self.otvet = tonumber(cmd_args[2]) - tonumber(cmd_args[4])
			Chat:Send( args.player, "Ответ: " .. tostring( self.otvet ), Color.White )
		elseif cmd_args[3] == "*" then
			self.otvet = tonumber(cmd_args[2]) * tonumber(cmd_args[4])
			Chat:Send( args.player, "Ответ: " .. tostring( self.otvet ), Color.White )
		elseif cmd_args[3] == "/" then
			self.otvet = tonumber(cmd_args[2]) / tonumber(cmd_args[4])
			Chat:Send( args.player, "Ответ: " .. tostring( self.otvet ), Color.White )
		end
	end
end

calc = Calc()