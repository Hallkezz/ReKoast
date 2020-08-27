class 'Messages'

function Messages:__init()
	self.timer = Timer()

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Messages:PostTick()
	if self.timer:GetSeconds() <= 15 then return end
	for p in Server:GetPlayers() do
		if p:GetPing() >= 700 then
			Network:Send( p, "text" )
		end
		self.timer:Restart()
	end
end

messages = Messages()