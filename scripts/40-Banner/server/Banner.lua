Images = {
	"Adv",
	"Image",
	"Image2",
	"Image3",
	"Image4",
	"Image5",
	"Image6",
	"Image7",
	"Image8",
	"Image9",
	"Image10",
	"Image11",
	"Image12",
	"Image13",
	"Image14",
	"Image15",
	"Image16",
	"Image17",
	"Image18",
	"Image19",
	"Image20",
	"Image21"
}

class 'Banner'

function Banner:__init()
	self.paydayTimer = Timer()
	self.timeDelay = 0.2 -- in minutes
	self.imageIndex = 1

	Events:Subscribe( "PostTick", self, self.PostTick )
end

function Banner:PostTick( args )
	if (self.paydayTimer:GetSeconds() > (60 * self.timeDelay)) then
		local count = 0

		for _, imgs in ipairs(Images) do
			count = count + 1
		end

		if self.imageIndex < count then
			self.imageIndex = self.imageIndex + 1
		else
			self.imageIndex = 1
		end

		for p in Server:GetPlayers() do
			Network:Send( p, "GetImage", {image = Images[self.imageIndex]} )
		end

		self.paydayTimer:Restart()
	end
end

banner = Banner()