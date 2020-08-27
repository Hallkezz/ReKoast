class "Jetpack"

function Jetpack:__init()
	self:initMessages()
	Network:Subscribe( "EnableJetpack", self, self.EnableJetpack )
end

function Jetpack:initMessages()
	self.messages = {}
	self.messages["Incorrect State"] = "Вы не можете использовать реактивный ранец в этом состоянии!"
	self.messages["Prefix"] = "[Реактивный Ранец] "
end

function Jetpack:EnableJetpack( args, sender )
	if sender:GetWorld() ~= DefaultWorld then
        Chat:Send( sender, self.messages["Prefix"], Color.White, "Вы не можете использовать это здесь!", Color.DarkGray )
        return
    end

	if sender:GetState() ~= PlayerState.OnFoot then
		Chat:Send( sender, self.messages["Prefix"], Color.White, self.messages["Incorrect State"], Color.DarkGray )
		return false
	end

	if not sender:GetValue("JP") then
		sender:SetNetworkValue("JP", true)
		return false
	end

	sender:SetNetworkValue("JP", nil)
end

jetpack = Jetpack()