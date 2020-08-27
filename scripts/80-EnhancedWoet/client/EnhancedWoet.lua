class 'Woet'

function Woet:__init()
	Events:Subscribe( "GetOption", self, self.GetOption )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
end

function Woet:GetOption( args )
	self.roll = args.roll
	self.spin = args.spin
	self.flip = args.flip
end

function Woet:KeyUp( args )
	if Game:GetState() ~= GUIState.Game then return end

	if not LocalPlayer:GetValue("Passive") then
    	if args.key == string.byte( "0" ) then
    		if self.roll then
    			Network:Send( "EnhancedWoet", "roll" )
    		end

    		if self.spin then
    			Network:Send( "EnhancedWoet", "spin" )
    		end

    		if self.flip then
    			Network:Send( "EnhancedWoet", "flip" )
			end
		end
	end
end

woet = Woet()