class 'Banner'

function Banner:__init()
	self.antibug = true

	self.pos = Vector3( 1052.8500000000, 218.0000000000, -1897.4930000000 )
	self.angle = Angle( -2.919954, -0.000000, 0.000000 )
	self.img = Image.Create( AssetLocation.Resource, "NotFound" )
	self.model = self:CreateSprite( self.img )
	self.banner = "Adv"

	Network:Subscribe( "GetImage", self, self.GetImage )
	Events:Subscribe( "GameRenderOpaque", self, self.GameRenderOpaque )
end

function Banner:GetImage( args )
	self.banner = args.image
	self.antibug = true
end

function Banner:GameRenderOpaque( args )
	self.img = Image.Create( AssetLocation.Resource, self.banner )
	if self.antibug then
		self.model = self:CreateSprite( self.img )
		self.antibug = false
	end
	local rotateAngle = Angle.Zero
	local t = Transform3()
	t:Translate( self.pos ):Rotate( self.angle )
	Render:SetTransform(t)
	self.model:Draw()
end

function Banner:CreateSprite( image )
	local size = Vector2( 5, 3 )
	local uv1, uv2 = image:GetUV()

	local sprite = Model.Create({
		Vertex( Vector2( -size.x, size.y ), Vector2( uv1.x, uv1.y ) ),
		Vertex( Vector2( -size.x,-size.y ), Vector2( uv1.x, uv2.y ) ),
		Vertex( Vector2( size.x,-size.y ), Vector2( uv2.x, uv2.y ) ),
		Vertex( Vector2( size.x,-size.y ), Vector2( uv2.x, uv2.y ) ),
		Vertex( Vector2( size.x, size.y ), Vector2( uv2.x, uv1.y ) ),
		Vertex( Vector2( -size.x, size.y ), Vector2( uv1.x, uv1.y ) )
	})

	sprite:SetTexture( image )
	sprite:SetTopology( Topology.TriangleList )

	return sprite
end

banner = Banner()