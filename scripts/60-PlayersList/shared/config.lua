SCOREBOARD_CONFIGURATION = 
{
	WIDTH = 0.5, -- Width of the board. Scale from Screen Size.
	HEIGHT = 0.75, -- Heigth of the board. Scale from Screen Size.

	ACTIVATION_BUTTON = 116, -- Show scoreboard button.

	COLUMNS = -- Scoreboard collumns
	{	
		{name = " ", width = 35, getter = function() return " " end },
		{name = "ID:", width = 35, getter = function(CBoardClientInstance, p) return p:GetId(); end },
		{name = "Игрок:", width = 200, getter = function(CBoardClientInstance, p) return string.sub(p:GetName(), 1, 40); end},
		{name = "Клан:", width = 200, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].clantag); end},
		{name = "Убийств:", width = 90, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].kills); end},
		{name = "Режим:", width = 130, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].gamemode); end},
		{name = "Язык:", width = 80, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].lang); end},
		{name = "Пинг:", width = 60, getter = function(CBoardClientInstance, p) return tostring(CBoardClientInstance.tServerPlayersData[p:GetId()].ping); end},
	},

	SYNC_DATA =
	{
		ping = function(player) return player:GetPing(); end,
		clantag = function(player) return player:GetValue( "ClanTag" ); end,
		kills = function(player) return player:GetValue("Kills") end,
		gamemode = function(player) return player:GetValue("GameMode") end,
		lang = function(player) return player:GetValue("Lang") end
	},

	SCROLL_SPEED = 2,

	SYNC_INTERVAL = 5, -- Sync interval in seconds;
}