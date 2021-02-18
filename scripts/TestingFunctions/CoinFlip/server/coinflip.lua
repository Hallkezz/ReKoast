class 'CoinFlip'

function CoinFlip:__init()
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
    self.prefix = "[Монетка] "
    self.chance = 50
    self.cmd = "/cflip"
end

function CoinFlip:PlayerChat( args )

    if ( args.text:sub(1, 1) ~= "/" ) then
		return true
	end

    local cmdargs = {}

	for word in string.gmatch(args.text, "[^%s]+") do
		table.insert(cmdargs, word)
    end

    if (cmdargs[1] != self.cmd) then return false end
    
    if #cmdargs > 2 or #cmdargs < 2 then
         args.player:SendChatMessage( self.prefix, Color.White, "Пример: " .. self.cmd .. " <кол-во денег>", Color.DarkGray )
        return false
    end

    local amount = tonumber( cmdargs[2] )
        if amount == nil then
            args.player:SendChatMessage( self.prefix, Color.White, "Это недействительная сумма денег для ставки!", Color.DarkGray )
            return false
        end

        if amount <= 0 then
            args.player:SendChatMessage( self.prefix, Color.White, "Это недействительная сумма денег для ставки!", Color.DarkGray )
            return false
        end

        if amount > 1000 then
            args.player:SendChatMessage( self.prefix, Color.White, "Вы не можете поставить более $1.000!", Color.DarkGray )
            return false
        end

        if args.player:GetMoney() < amount then 
        args.player:SendChatMessage( self.prefix, Color.White, "У вас недостаточно денег для ставки!", Color.DarkGray )
        return false
        end

        if math.random(0,100) < self.chance then
            args.player:SetMoney(args.player:GetMoney() + amount * 2)
            args.player:SendChatMessage( self.prefix, Color.White, "Вы выиграли " .. "$" .. amount * 2 .. "!", Color.Lime )
        else
            args.player:SetMoney(args.player:GetMoney() - amount)
            args.player:SendChatMessage( self.prefix, Color.White, "Вы проиграли " .. "$" .. amount .. "!", Color.Red )
        end
end

coinflip = CoinFlip()   
