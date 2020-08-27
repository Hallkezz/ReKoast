class 'DateTime'

function DateTime:__init()
	local message1 = os.date ( "%X" )

	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "GetOption", self, self.GetOption )
end

function DateTime:GetOption( args )
	self.DT_visible = args.act
	self.PendosClockFormat = args.pendclockformat
end

function DateTime:Render()
	if Game:GetState() ~= GUIState.Game then return end
	if not self.DT_visible then return end
	if self.PendosClockFormat then
		message1 = os.date("%I:%M:%S %p")
	else
		message1 = os.date ( "%X" )
	end

	local time1 = os.date("%d/%m/%Y")

	local position = Vector2( 20, Render.Height * 0.31 )
	local text = tostring(message1)
	local pos_1 = Vector2( (20)/1, (Render.Height/3) + 5)
	local text1 = tostring(time1)

	local text_width = Render:GetTextWidth(text)
	Render:SetFont( AssetLocation.Disk, "Archivo.ttf" )

	Render:DrawText( position + Vector2.One, text, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 24 )
	Render:DrawText( position, text, Color( 255, 255, 255, Game:GetSetting(4) * 2.25 ), 24 )

	local height = Render:GetTextHeight("A") * 1.5
	position.y = position.y + height
	Render:DrawText( position + Vector2.One, text1, Color( 25, 25, 25, Game:GetSetting(4) * 2.25 ), 16 )
	Render:DrawText( position, text1, Color( 255, 165, 0, Game:GetSetting(4) * 2.25 ), 16 )		
end

datetime = DateTime()