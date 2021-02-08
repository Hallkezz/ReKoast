class 'Tetris'

function Tetris:__init()
	self.inTetrisMode = false
	self.gridNotCurrent = {}

	self.moveDownTimer = Client:GetElapsedSeconds()
	self.moving = false

	self.current = {}
	self.currentLoc = Vector2.Zero
	self.currentRot = 1
	self.currentPiece = 0

	self.currentLeaderboard = {}
	self.rows = {}

	--levels				1		2		3		4		5		6		7		8		9		10
	self.levelScore = 		{30,	50,		70,		100,	150,	200,	500,	750,	1000,	5000}
	self.dropTimeLevel = 	{1,		0.9,	0.75,	0.5,	0.4,	0.3,	0.2,	0.1,	0.075,	0.05}

	self.firstGo = true
	self.score = 0
	self.totalScore = 0
	self.level = 1

	self.dropTime = self.dropTimeLevel[self.level]
	self.inGame = false

	self.pieces = {
		{
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,0)},
				{x = 1, y = 2, c = Color(255,0,0)},
				{x = 2, y = 1, c = Color(255,0,0)},
				{x = 2, y = 2, c = Color(255,0,0)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 1, y = 2, c = Color(0,255,0)},
				{x = 1, y = 3, c = Color(0,255,0)},
				{x = 2, y = 3, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 2, c = Color(0,255,0)},
				{x = 2, y = 2, c = Color(0,255,0)},
				{x = 3, y = 2, c = Color(0,255,0)},
				{x = 3, y = 1, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 2, y = 1, c = Color(0,255,0)},
				{x = 2, y = 2, c = Color(0,255,0)},
				{x = 2, y = 3, c = Color(0,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,0)},
				{x = 2, y = 1, c = Color(0,255,0)},
				{x = 3, y = 1, c = Color(0,255,0)},
				{x = 1, y = 2, c = Color(0,255,0)}
			}
		},
		{
			{
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 2, y = 2, c = Color(0,0,255)},
				{x = 2, y = 3, c = Color(0,0,255)},
				{x = 1, y = 3, c = Color(0,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 3, y = 1, c = Color(0,0,255)},
				{x = 3, y = 2, c = Color(0,0,255)}
			},
			{
				{x = 2, y = 1, c = Color(0,0,255)},
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 1, y = 2, c = Color(0,0,255)},
				{x = 1, y = 3, c = Color(0,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,0,255)},
				{x = 1, y = 2, c = Color(0,0,255)},
				{x = 2, y = 2, c = Color(0,0,255)},
				{x = 3, y = 2, c = Color(0,0,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 1, y = 3, c = Color(0,255,255)},
				{x = 1, y = 4, c = Color(0,255,255)}
			},
			{
				{x = 0, y = 2, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 2, y = 2, c = Color(0,255,255)},
				{x = 3, y = 2, c = Color(0,255,255)}
			},
			{
				{x = 1, y = 1, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 1, y = 3, c = Color(0,255,255)},
				{x = 1, y = 4, c = Color(0,255,255)}
			},
			{
				{x = 0, y = 2, c = Color(0,255,255)},
				{x = 1, y = 2, c = Color(0,255,255)},
				{x = 2, y = 2, c = Color(0,255,255)},
				{x = 3, y = 2, c = Color(0,255,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)}
			},
			{
				{x = 2, y = 0, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 3, y = 1, c = Color(255,255,0)},
				{x = 2, y = 0, c = Color(255,255,0)}
			},
			{
				{x = 2, y = 0, c = Color(255,255,0)},
				{x = 2, y = 1, c = Color(255,255,0)},
				{x = 2, y = 2, c = Color(255,255,0)},
				{x = 1, y = 1, c = Color(255,255,0)}
			}
		},
		{
			{
				{x = 3, y = 1, c = Color(255,0,255)},
				{x = 2, y = 1, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 2, y = 3, c = Color(255,0,255)}
			},
			{
				{x = 3, y = 1, c = Color(255,0,255)},
				{x = 2, y = 1, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)}
			},
			{
				{x = 1, y = 1, c = Color(255,0,255)},
				{x = 1, y = 2, c = Color(255,0,255)},
				{x = 2, y = 2, c = Color(255,0,255)},
				{x = 2, y = 3, c = Color(255,0,255)}
			}
		},
		{
			{
				{x = 1, y = 1, c = Color(255,165,0)},
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 3, y = 2, c = Color(255,165,0)}
			},
			{
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 1, y = 2, c = Color(255,165,0)},
				{x = 1, y = 3, c = Color(255,165,0)}
			},
			{
				{x = 1, y = 1, c = Color(255,165,0)},
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 3, y = 2, c = Color(255,165,0)}
			},
			{
				{x = 2, y = 1, c = Color(255,165,0)},
				{x = 2, y = 2, c = Color(255,165,0)},
				{x = 1, y = 2, c = Color(255,165,0)},
				{x = 1, y = 3, c = Color(255,165,0)}
			}
		}
	}

	local minLeftSpacing = 1/4
	local minTopSpacing = 1/8
	local makeThemSquares = math.min(Render.Size.x / 10 * (1 - 2 * minLeftSpacing), Render.Size.y / 20 * (1 - 2 * minTopSpacing))

	self.tileWidthV = Vector2( makeThemSquares, 0 )
	self.tileHeightV = Vector2( 0, makeThemSquares )
	self.tileSize = self.tileWidthV + self.tileHeightV
	self.offset = Render.Size / 2 - self.tileWidthV * 5 - self.tileHeightV * 10

	self.settingsVisible = false

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.6 ) )
	self.window:SetPositionRel( Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.settingsVisible )
	self.window:SetTitle( "Тетрис" )
	self.window:Subscribe( "WindowClosed", self, self.Close )

	self.list = SortedList.Create( self.window )
	self.list:SetDock( GwenPosition.Fill )
	self.list:SetMargin( Vector2.Zero, Vector2.Zero )
	self.list:SetBackgroundVisible( false )
	self.list:AddColumn( "Имя" )
	self.list:AddColumn( "Очки" )
	self.list:SetButtonsVisible( true )

	self.g_o = HorizontalSlider.Create( self.window )
	self.g_o:SetDock( GwenPosition.Bottom )
	self.g_o:SetRange( 1, 255 )
	self.g_o:SetSize( Vector2( 1, 20 ) )
	self.g_o:Subscribe("ValueChanged", self, self.ValueChanged)

	self.globalOpacity = 150
	self.g_o:SetValue( self.globalOpacity )

	self.borderCol = Color( 0, 0, 0, self.globalOpacity )
	self.tileOpacity = Color( 0, 0, 0, self.globalOpacity )

	self:PopulateGrid()

	self.tWidg = "Лучший Тетрис:"
	self.tWidgTw = "Лучший "
	self.tTetris = "Тетрис: "
	self.tRecord = "Личный рекорд по тетрису: "
	self.tDied = "ПОТРАЧЕНО!\n\n\n\n"
	self.tScores = "Счёт: "
	self.tSetHelp = "Нажмите Ctrl, чтобы открыть настройки\n\n\n\n"
	self.tSetHelp2 = "и просмотреть таблицу лидеров"
	self.tSetHelp3 = " \n\n\n\nНажмите 'Пробел', чтобы начать."
	self.tSetGOver = "Финальный счёт: "
	self.tSetGOver2 = " \n\n\n\nНажмите 'Пробел', чтобы повторить попытку."

	Network:Subscribe( "NewLeaderboard", self, self.NewLeaderboard )

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "TetrisToggle", self, self.Toggle )
	Events:Subscribe( "Render", self, self.Render )

	Network:Subscribe( "003", self, self.onTetrisAttempt )
end

function Tetris:GetOption( args )
	self.Display = args.actDr
end

function Tetris:Lang( args )
	self.tWidg = "Best Tetris:"
	self.tWidgTw = "Best "
	self.tTetris = "Tetris: "
	self.tRecord = "Personal tetris record: "
	self.tDied = "GAME OVER\n\n\n\n"
	self.tScores = "Scores: "
	self.tSetHelp = "Press Ctrl to open settings.\n\n\n\n"
	self.tSetHelp2 = "and view the leaderboard"
	self.tSetHelp3 = " \n\n\n\nPress 'Space' to start."
	self.tSetGOver = "Final score: "
	self.tSetGOver2 = " \n\n\n\nPress 'Space' to try again."
end

function Tetris:Toggle()
	self.firstGo = true
	self:PopulateGrid()
	self.inTetrisMode = not self.inTetrisMode
	if self.inTetrisMode then
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		self.KeyDownEvent = Events:Subscribe( "KeyDown", self, self.KeyDown )
	else
		Events:Unsubscribe( self.LocalPlayerInputEvent )
		Events:Unsubscribe( self.KeyDownEvent )
		self.LocalPlayerInputEvent = nil
		self.KeyDownEvent = nil
	end
end

function Tetris:Render()
	if Game:GetState() ~= GUIState.Game then return end

	local object = NetworkObject.GetByName("Tetris")

	if self.Display then
		if Game:GetSetting(4) >= 1 then
			if object and LocalPlayer:GetValue("GetWidget") == 1 then
				if LocalPlayer:GetValue( "SystemFonts" ) then
					Render:SetFont( AssetLocation.SystemFont, "Impact" )
				end
				local record = object:GetValue("S")
				local text = self.tWidg
				local position = Vector2( 20, Render.Height * 0.4 )
				Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 15 )
				Render:DrawText( position + Vector2( Render:GetTextWidth( self.tWidgTw, 15 ), 0 ), self.tTetris, Color( 255, 165, 0, Game:GetSetting(4) * 2.25 ), 15 )
				local height = Render:GetTextHeight("A") * 1.2
				position.y = position.y + height
				local record = object:GetValue("S")
				if record then
					text = tostring(record) .. " - " .. object:GetValue("N")
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position, text, Color( 0, 150, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record )
					Render:DrawText( position + Vector2 (Render:GetTextWidth( text, 16 ), 0 ), " - ", Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 16 )
					text = tostring( record ) .. " - "
					Render:DrawText( position + Vector2 (Render:GetTextWidth( text, 16 ), 0 ), object:GetValue("N"), object:GetValue("C") + Color( 0, 0, 0, Game:GetSetting(4) * 2.25 ), 16 )
					text = ""
					for i = 1, object:GetValue("E") do text = text .. ">" end

					position.y = position.y + height * 0.95
					Render:SetFont( AssetLocation.Disk, "LeagueGothic.ttf" )
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 13 )
					Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 13 )
					if LocalPlayer:GetValue( "SystemFonts" ) then
						Render:SetFont( AssetLocation.SystemFont, "Impact" )
					end
					if self.attempt then
						local player = Player.GetById(self.attempt[2] - 1)
						if player then
							position.y = position.y + height * 0.6
							local alpha = math.min(self.attempt[3], 1)
							text = tostring( self.attempt[1] ) .. " - " .. player:GetName()
							Render:DrawText( position + Vector2.One, text, Color(0, 0, 0, 100 * alpha), 16 )
							Render:DrawText( position, text, Color(255, 255, 255, 255 * alpha), 16 )
							text = tostring( self.attempt[1] )
							Render:DrawText( position + Vector2.One, text, Color(0, 0, 0, 100 * alpha), 16 )
							Render:DrawText( position, text, Color(240, 220, 70, 255 * alpha), 16 )
							self.attempt[3] = self.attempt[3] - 0.02
							if self.attempt[3] < 0.02 then self.attempt = nil end
						end
					end
				else
					text = "–"
					Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
					Render:DrawText( position, text, Color( 200, 200, 200, Game:GetSetting(4) * 2.25 ), 16 )
				end
			end
		end
	end

	if self.inTetrisMode then
		if self.inGame then
			if (Client:GetElapsedSeconds() - self.moveDownTimer) > self.dropTime then
				self.moveDownTimer = Client:GetElapsedSeconds()
				self:MoveCurrent(0,1)
			end

			self:CheckTiles()
		end
		self:RenderTiles()
		self:ShowScore()

		self.window:SetVisible( self.settingsVisible )
	end
end

function Tetris:onTetrisAttempt( data )
	self.attempt = data
	self.attempt[3] = 4
end

function Tetris:RenderTiles()
	for i = 1, 10 do
		local tilePos = self.offset + self.tileWidthV * (i-1) + self.tileHeightV * (-1)
		for j = 1, 20 do
			tilePos = tilePos + self.tileHeightV
			if self.gridNotCurrent[i][j] then
				local tilePos = self.offset + self.tileWidthV * (i-1) + self.tileHeightV * (j-1)
				Render:FillArea(tilePos, self.tileSize, self.gridNotCurrent[i][j] + self.tileOpacity)
			end
		end
	end

	if self.current[self.currentRot] then
		for _,v in pairs(self.current[self.currentRot]) do
			local tilePos = self.offset + self.tileWidthV * (v.x+self.currentLoc.x-1) + self.tileHeightV * (v.y+self.currentLoc.y-1)
			Render:FillArea(tilePos, self.tileSize, v.c + self.tileOpacity)
		end
	end

	Render:FillArea( self.offset - self.tileWidthV, self.tileWidthV * (10+2) - self.tileHeightV, self.borderCol ) --top
	Render:FillArea( self.offset - self.tileWidthV, self.tileWidthV + self.tileHeightV * 20, self.borderCol ) --left
	Render:FillArea( self.offset + 10 * self.tileWidthV, self.tileWidthV + self.tileHeightV * 20, self.borderCol ) --right
	Render:FillArea( self.offset + 20 * self.tileHeightV - self.tileWidthV, self.tileWidthV * (10+2) + self.tileHeightV, self.borderCol ) --bottom
end

function Tetris:PopulateGrid()
	self.inGame = false
	self.score = 0
	self.totalScore = 0
	self.level = 1
	self.dropTime = self.dropTimeLevel[self.level]

	self.gridNotCurrent = {}

	for i = 1, 10 do
		self.gridNotCurrent[i] = {}
	end
end

function Tetris:NewBlock()
	if self.inGame and self.current[self.currentRot] then
		for _,v in pairs(self.current[self.currentRot]) do
			self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] = v.c
		end
	end
	self.firstGo = false
	self.currentRot = 1
	self.currentLoc = Vector2(math.ceil(10 / 2) - 1,0)
	self.currentPiece = math.random(1,#self.pieces)
	self.current = {}
	self.current = self.pieces[self.currentPiece]
	for _,v in pairs(self.current[self.currentRot]) do
		if self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] then
			self:GameOver()
			return
		end
	end
	self.inGame = true
end

function Tetris:MoveCurrent( x, y )
	local canMove = true
	for _,v in pairs(self.current[self.currentRot]) do
		if (v.x+self.currentLoc.x+x)<1 or (v.x+self.currentLoc.x+x)>10 then
			self.moving = false
			return
		elseif y==0 and self.gridNotCurrent[v.x+self.currentLoc.x+x][v.y+self.currentLoc.y] then
			self.moving = false
			return
		elseif (v.y+self.currentLoc.y+y)>20 or self.gridNotCurrent[v.x+self.currentLoc.x+x][v.y+self.currentLoc.y+y] then
			canMove = false
		end
	end
	if canMove then
		self.currentLoc.x = self.currentLoc.x + x
		self.currentLoc.y = self.currentLoc.y + y
	else
		self:NewBlock()
	end
end

function Tetris:Rotate()
	local newRot = self.currentRot % 4 + 1
	for _,v in pairs(self.current[newRot]) do
		if (v.x+self.currentLoc.x)<1 or (v.x+self.currentLoc.x)>10 then
			return
		elseif (v.y+self.currentLoc.y)>20 or self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] then
			return
		end
	end
	self.currentRot = newRot
end

function Tetris:CheckTiles()
	for y = 1, 20 do
		local full = true
		for x = 1, 10 do
			if not self.gridNotCurrent[x][y] then
				full = false
			end
		end
		if full then
			for x = 1, 10 do
				for y2 = y, 2, -1 do
					self.gridNotCurrent[x][y2] = self.gridNotCurrent[x][y2-1]
					self.gridNotCurrent[x][y2-1] = nil
				end
			end
			self.score = self.score + 10
			self.totalScore = self.totalScore + 10
			self:CheckTiles()
		end
	end

	if self.levelScore[self.level] and self.score >= self.levelScore[self.level] then
		self.score = self.score - self.levelScore[self.level]
		self.level = self.level + 1
		if self.dropTimeLevel[self.level] then
			self.dropTime = self.dropTimeLevel[self.level]
		end
	end
end

function Tetris:ShowScore()
	local pos = Vector2.Zero
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	pos = Chat:GetPosition() + Vector2( 0, 40 )
	Render:DrawText( pos + Vector2.One, self.tScores .. tostring(self.totalScore), Color( 25, 25, 25, 150 ), 20 )
	Render:DrawText( pos, self.tScores .. tostring(self.totalScore), Color( 255, 255, 0 ), 20 )
	if not self.inGame then
		if self.firstGo then
			local pos = ( Render.Size - Render:GetTextSize( self.tSetHelp, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, self.tSetHelp, Color( 25, 25, 25, 150 ), 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetHelp2, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, self.tSetHelp2, Color( 25, 25, 25, 150 ), 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetHelp3, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, self.tSetHelp3, Color( 25, 25, 25, 150 ), 32 )		

			local pos = ( Render.Size - Render:GetTextSize( self.tSetHelp, 32 ) ) / 2
			Render:DrawText( pos, self.tSetHelp, Color.White, 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetHelp2, 32 ) ) / 2
			Render:DrawText( pos, self.tSetHelp2, Color.White, 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetHelp3, 32 ) ) / 2
			Render:DrawText( pos, self.tSetHelp3, Color.White, 32 )
		else
			local pos = ( Render.Size - Render:GetTextSize( self.tDied, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, self.tDied, Color( 25, 25, 25, 150 ), 32 )
			local msg = self.tSetGOver .. tostring( self.totalScore )
			pos = ( Render.Size - Render:GetTextSize( msg, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, msg, Color( 25, 25, 25, 150 ), 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetGOver2, 32 ) ) / 2
			Render:DrawText( pos + Vector2.One, self.tSetGOver2, Color( 25, 25, 25, 150 ), 32 )

			local pos = ( Render.Size - Render:GetTextSize( self.tDied, 32 ) ) / 2
			Render:DrawText( pos, self.tDied, Color.Red, 32 )
			local msg = self.tSetGOver .. tostring( self.totalScore )
			pos = ( Render.Size - Render:GetTextSize( msg, 32 ) ) / 2
			Render:DrawText( pos, msg, Color.White, 32 )
			pos = ( Render.Size - Render:GetTextSize( self.tSetGOver2, 32 ) ) / 2
			Render:DrawText( pos, self.tSetGOver2, Color.White, 32 )
		end
	end
end

function Tetris:GameOver()
	self.inGame = false
	for _,v in pairs(self.current[self.currentRot]) do
		self.gridNotCurrent[v.x+self.currentLoc.x][v.y+self.currentLoc.y] = v.c
	end

	local object = NetworkObject.GetByName("Tetris")
	if not object or self.totalScore > (object:GetValue("S") or 0) then
		if LocalPlayer:GetWorld() == DefaultWorld then
			Network:Send("001", self.totalScore)
		end
	elseif self.totalScore > ((object:GetValue("S") or 0) * 0.6) and (object:GetValue("N") or "None") ~= LocalPlayer:GetName() then
		Network:Send("002", self.totalScore)
	end

	local shared = SharedObject.Create("Tetris")
	if self.totalScore > (shared:GetValue("Record") or 0) then
		shared:SetValue( "Record", self.totalScore )
	end

	Network:Send( "NewScore", self.totalScore )
	Game:ShowPopup( self.tRecord .. self.totalScore, true )
end

function Tetris:KeyDown( args )
	if self.inTetrisMode and self.inGame then
		if args.key == VirtualKey.Left then
			self:MoveCurrent(-1,0)
		elseif args.key == VirtualKey.Right then
			self:MoveCurrent(1,0)
		elseif args.key == VirtualKey.Down then
			self:MoveCurrent(0,1)
		elseif args.key == VirtualKey.Up then
			self:Rotate()
		end
	elseif self.inTetrisMode and (args.key == VirtualKey.Space) and not self.inGame then
		self:PopulateGrid()
		self.moveDownTimer = Client:GetElapsedSeconds()
		self:NewBlock()
	end

	if self.inTetrisMode and (args.key == VirtualKey.Control) and not self.settingsVisible and not self.inGame then
		Network:Send( "TopScores", self.totalScore )
		self.settingsVisible = true
		Mouse:SetVisible( self.settingsVisible )
		ClientEffect.Play(AssetLocation.Game, {
			effect_id = 382,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	end
end

function Tetris:Close()
	self.settingsVisible = false
	Mouse:SetVisible( self.settingsVisible )
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 383,

		position = Camera:GetPosition(),
		angle = Angle()
	})
end

function Tetris:ValueChanged()
	self.globalOpacity = self.g_o:GetValue()
	self.borderCol = Color( 0, 0, 0, self.globalOpacity )
	self.tileOpacity = Color( 0, 0, 0, self.globalOpacity )
end

function Tetris:NewLeaderboard( tData )
	self.list:Clear()

	self.currentLeaderboard = tData

	for _,v in pairs(self.currentLeaderboard) do
		self.list:AddItem( v.name ):SetCellText( 1, tostring(v.score) )
	end
end

function Tetris:LocalPlayerInput( args )
	if self.settingsVisible then
		return false
	end
end

tetris = Tetris()
