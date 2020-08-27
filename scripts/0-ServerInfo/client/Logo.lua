class 'Logo'

function Logo:__init()
	if LocalPlayer:GetValue( "ServerName" ) ~= nil and LocalPlayer:GetValue( "ServerName" ) ~= "" then
		Events:Subscribe( "Render", self, self.Render )
	end

	if LocalPlayer:GetValue( "KoastBuild" ) then
		print( "ReKoast-mod v" .. LocalPlayer:GetValue( "KoastBuild" ) .. " loaded." )
	else
		print( "ReKoast-mod loaded." )
	end
end

function Logo:Render()
	if LocalPlayer:GetValue( "SystemFonts" ) then
		Render:SetFont( AssetLocation.SystemFont, "Impact" )
	end
	Render:DrawText( Vector2( 20, (Render.Height - 30) ), LocalPlayer:GetValue( "ServerName" ), Color( 255, 255, 255, 30 ), TextSize.Default )
end

logo = Logo()