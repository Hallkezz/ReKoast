class 'Bank'

function Player:SteamId()
    return self:GetSteamId().id
end

function Bank:__init()
    self.tag = "[Сервер] "

    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "PlayerChat", self, self.PlayerChat )
    Events:Subscribe( "PlayerMoneyChange", self, self.PlayerMoneyChange )
    Events:Subscribe( "PostTick", self, self.PostTick )
    Events:Subscribe( "ModuleUnload", self, self.CommitChanges )
    Console:Subscribe( "bank", self, self.Console )

    -- Map of player money changes that need to be committed to the database
    self.money_queue    = {}
    -- List of players who have had their first update on join from bank
    self.updated        = {}
    -- Used to determine whether the bank should be updated
    self.timer          = Timer()

    for p in Server:GetPlayers() do
        self:MarkUpdated( p )
    end

    SQL:Execute( "create table if not exists bank_players (steamid VARCHAR UNIQUE, money INTEGER)" )
end

-- Utility
function Bank:IsUpdated( player )
    return (self.updated[player:SteamId()] == true)
end

function Bank:MarkUpdated( player )
    self.updated[player:SteamId()] = true
end

function Bank:UnmarkUpdated( player )
    self.updated[player:SteamId()] = false
end

function Bank:AddToQueue( player, money )
    if not IsValid(player) then return end

    self.money_queue[player:SteamId()] = money
end

-- Events
function Bank:PlayerJoin( args )
    local qry = SQL:Query( "select money from bank_players where steamid = (?)" )
    qry:Bind( 1, args.player:SteamId() )
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetMoney( tonumber(result[1].money) )
    end

    self:MarkUpdated( args.player )
end

function Bank:PlayerQuit( args )
    self:AddToQueue( args.player, args.player:GetMoney() )
    self:UnmarkUpdated( args.player )
end

function Bank:PlayerMoneyChange( args )
    if self:IsUpdated( args.player ) then
        self:AddToQueue( args.player, args.new_money )
    end
end

function Bank:PlayerChat( args )
	local msg = args.text
	local player = args.player

	if ( msg:sub(1, 1) ~= "/" ) then
		return true
	end    

	local cmdargs = {}
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(cmdargs, word)
	end

    if (cmdargs[1] == "/sendmoney") or (cmdargs[1] == "/pay") then
        if #cmdargs < 3 then
            args.player:SendChatMessage( self.tag, Color.White, "Пример: /pay <игрок> <кол-во денег>", Color.DarkGray )
            return false
        end

        local player = Player.Match( cmdargs[2] )[1]

        if not IsValid( player ) then
            args.player:SendChatMessage( self.tag, Color.White, "Игрок " .. cmdargs[2] .. " не существует!", Color.DarkGray )
            return false
        end

        if player == args.player then
            args.player:SendChatMessage( self.tag, Color.White, "Вы не можете отправить деньги самому себе!", Color.DarkGray )
            return false
        end

        local amount = tonumber( cmdargs[3] )
        if amount == nil then
            args.player:SendChatMessage( self.tag, Color.White, "Это недействительная сумма денег для отправки!", Color.DarkGray )
            return false
        end

        if amount < 0 then
            args.player:SendChatMessage( self.tag, Color.White, "Это недействительная сумма денег для отправки!", Color.DarkGray )
            return false
        end

        if amount > 10000 then
            args.player:SendChatMessage( self.tag, Color.White, "Вы не можете отправить более $10.000!", Color.DarkGray )
            return false
        end

        local player_new_money = args.player:GetMoney() - amount
        if player_new_money < 0 then
            args.player:SendChatMessage( self.tag, Color.White, "У вас недостаточно для отправки $" .. tostring(amount) .. "!", Color.DarkGray )
            return false
        end

        args.player:SetMoney( player_new_money )

        player_new_money = player:GetMoney() + amount
        player:SetMoney( player_new_money )

        args.player:SendChatMessage( self.tag, Color.White, "Успешно отправлено $" .. tostring(amount) .. " для " .. player:GetName() .. ".", Color( 0, 255, 0 ) )

        player:SendChatMessage( self.tag, Color.White, "Получено $" .. tostring(amount) .. " от " .. args.player:GetName() .. ".", Color( 0, 255, 0 ) )
        return false
    end
	return false
end

function Bank:PostTick( args )
    if self.timer:GetSeconds() >= 30 then
        self:CommitChanges()
        self.timer:Restart()
    end
end

function Bank:CommitChanges( )
    local count = table.count(self.money_queue)
    if count > 0 then
        print( "Committing " .. tostring(count) .. " changes to db" )
        Events:Fire( "ToDiscordConsole", { text = "[Bank] Committing " .. tostring(count) .. " changes to db" } )

        local transaction = SQL:Transaction()
        do
            for k, v in pairs(self.money_queue) do
                local cmd = SQL:Command( 
                    "insert or replace into bank_players (steamid, money) values (?, ?)" )
                cmd:Bind( 1, k )
                cmd:Bind( 2, v )
                cmd:Execute()
            end
        end
        transaction:Commit()

        self.money_queue = {}
    end
end

-- Console event
function Bank:Console( args )
    local cmd_name = args[1]
    table.remove( args, 1 )

    if cmd_name == "list" then
        local result = SQL:Query( "select * from bank_players" ):Execute()

        if #result > 0 then
            for i, v in ipairs(result) do
                print( v.steamid .. ": " .. v.money )
            end
        end
    end
end

bank = Bank()
