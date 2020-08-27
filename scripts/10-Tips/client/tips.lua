class 'Tips'

function Tips:__init()
	self.active = true
	self.tip = "СОВЕТ: "
	self.text = "Чат: T  I Открыть меню сервера: B"

	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
end

function Tips:GetOption( args )
	self.tipsed = args.actTip
	self.backgorund = args.actBk
end

function Tips:Lang( args )
	self.tip = "TIP: "
	self.text = "Chat: T  I Open Server Menu: B"
end

function Tips:Render()
	if self.active then
		if Game:GetState() == GUIState.PDA then
			Chat:SetEnabled( false )
			self.activeTw = true
		end
	end

	if self.activeTw then
		if Game:GetState() ~= GUIState.PDA then
			Chat:SetEnabled( true )
			self.active = true
			self.activeTw = false
		end
	end
	if Chat:GetEnabled() and Chat:GetUserEnabled() and not Chat:GetActive() then
		local text_width = Render:GetTextWidth( self.text )

		if self.backgorund then
			Render:FillArea( Chat:GetPosition() + Vector2( -4, 0 ), Vector2( 508, -216 ), Color( 0, 0, 0, 80 ) )
		end

		if self.tipsed then
			Render:FillArea( Chat:GetPosition() + Vector2( 0, 3 ), Vector2( 490, 1 ), Color( 165, 165, 165 ) )
			if LocalPlayer:GetValue( "SystemFonts" ) then
				Render:SetFont( AssetLocation.SystemFont, "Impact" )
			end
			Render:DrawText( Chat:GetPosition() + Vector2( 1, 11 ), self.tip .. self.text, Color( 25, 25, 25, 150 ), 13 + 1 )
			Render:DrawText( Chat:GetPosition() + Vector2( 0, 10 ), self.tip .. self.text, Color( 200, 200, 200 ), 13 + 1 )
		end
	end
end

tips = Tips()