class 'Bank'

function Bank:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.MoneyChange )

	self.money = "Баланс: "

	self.timer = Timer()
	self.message_size = TextSize.VeryLarge
	self.submessage_size = 25
end

function Bank:Lang( args )
	self.money = "Money: "
end

function Bank:Render()
	if self.message_timer and self.message then
		local alpha = 4

		if self.message_timer:GetSeconds() > 4 and self.message_timer:GetSeconds() < 5 then
			alpha = 4 - (self.message_timer:GetSeconds() - 1)
		elseif self.message_timer:GetSeconds() >= 5 then
			self.message_timer = nil
			self.message = nil
			self.submessage = nil
			if self.RenderEvent then
				Events:Unsubscribe( self.RenderEvent )
				self.RenderEvent = nil
			end
			return
		end

		if LocalPlayer:GetValue( "SystemFonts" ) then
			Render:SetFont( AssetLocation.SystemFont, "Impact" )
		end

		local pos_2d = Vector2( (Render.Size.x / 2) - (Render:GetTextSize( self.message .. " | " .. self.submessage, self.submessage_size ).x / 2), 100 )
		local col = Copy( self.colour )
		local colS = Copy( Color( 25, 25, 25, 150 ) )
		col.a = col.a * alpha
		colS.a = colS.a * alpha
	
		Render:DrawText( pos_2d + Vector2.One, self.message .. " | " .. self.submessage, colS, self.submessage_size )
		Render:DrawText( pos_2d, self.message .. " | " .. self.submessage, col, self.submessage_size )
	end
end

function Bank:MoneyChange( args )
	if Game:GetState() ~= GUIState.Game then return end
	if not self.RenderEvent then
		self.RenderEvent = Events:Subscribe( "Render", self, self.Render )
	end
	local diff = args.new_money - args.old_money

	-- Very unlikely you'll be able to get any money in the first 2 seconds!
	if diff > 0 and self.timer:GetSeconds() > 2 then
		self.message_timer = Timer()
		self.message = "+ $" .. tostring(diff)
		self.submessage = self.money .. tostring(args.new_money)
		self.colour = Color( 251, 184, 41 )
	end

	local diff = args.old_money - args.new_money

	if diff > 0 and self.timer:GetSeconds() > 2 then
		self.message_timer = Timer()
		self.message = "- $" .. tostring(diff)
		self.submessage = self.money .. tostring(args.new_money)
		self.colour = Color.OrangeRed
	end	
end

bank = Bank()