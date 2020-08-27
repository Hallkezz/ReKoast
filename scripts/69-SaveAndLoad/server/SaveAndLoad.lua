class 'SaveAndLoad'

function SaveAndLoad:__init()
	Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
	Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )

	SQL:Execute( "CREATE TABLE IF NOT EXISTS players_models (steamid VARCHAR UNIQUE, model_id INTEGER)")
end

function SaveAndLoad:PlayerJoin( args )
	self:LoadModel( args )
end

function SaveAndLoad:LoadModel( args )
    local qry = SQL:Query( "select model_id from players_models where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

	if #result > 0 then
        args.player:SetModelId( tonumber(result[1].model_id) )
    end
end

function SaveAndLoad:PlayerQuit( args )
	self:SaveModel(args)
end

function SaveAndLoad:SaveModel( args )
    local cmd = SQL:Command( "insert or replace into players_models (steamid, model_id) values (?, ?)" )
    cmd:Bind( 1, args.player:GetSteamId().id )
    cmd:Bind( 2, args.player:GetModelId() )
    cmd:Execute()
end

saveandload = SaveAndLoad()