class 'Lost'

function Lost:__init()
	self.lost = true
	self.island = { Vector3( -13715.291015625, 647.15295410156, -14165.701171875 ) }

	self.timer = Timer()

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Lost:PostTick()
	if self.timer:GetSeconds() <= 4 then return end

	self.timer:Restart()

	local lp_pos = LocalPlayer:GetPosition()

	for k,v in pairs(self.island) do
		local dist = lp_pos:DistanceSqr( v )

		if dist < 4000000 then
			if k == 1 then
				if self.lost then
					Network:Send( "Weather" )
					self.nolost = true
					self.lost = false
				end
				return
			end
		else
			if self.nolost then
				self.lost = true
				self.nolost = false
				Network:Send( "WeatherC" )
			end
		end
	end
end

lost = Lost()