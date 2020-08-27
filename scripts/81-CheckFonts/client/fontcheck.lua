class 'FontCheck'

function FontCheck:__init()
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Console:Subscribe( "font", self, self.FontToggle )
end

function FontCheck:ModuleLoad()
	self.checkFont = Label.Create()
	self.checkFont:SetFont( AssetLocation.SystemFont, "Impact" )
	self.checkFont:SetVisible( false )
	self.checkFont:SetText( "" )
	self.checkFont:SetPosition( Vector2( 1, 1 ) )
	self:LoadFonts()
end

function FontCheck:LoadFonts()
	self.checkFont:Remove()
	Network:Send( "FontsFound" )
end

function FontCheck:FontToggle( args )
	if args.text == "default" then
		Network:Send( "FontDisable" )
		print( "Font set: Default" )
	elseif args.text == "server" then
		Network:Send( "FontsFound" )
		print( "Font set: Server font" )
	end
end

fontcheck = FontCheck()