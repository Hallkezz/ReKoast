class 'FontCheck'

function FontCheck:__init()
	Network:Subscribe( "FontsFound", self, self.FontsFound )
	Network:Subscribe( "FontDisable", self, self.FontDisable )
end

function FontCheck:FontsFound( args, sender )
	sender:SetNetworkValue( "SystemFonts", true )
end

function FontCheck:FontDisable( args, sender )
	sender:SetNetworkValue( "SystemFonts", false )
end

fontcheck = FontCheck()