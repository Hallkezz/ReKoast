function Shop:__init()
	self.active = false
	self.home = true
	self.nameBM = "Вы заказали: "
	self.noVipText = "У вас отсувствует VIP-статус :("
	self.unit = 0

	BuyMenuLineColor = Color.White
	BuyMenuMoneyColor = Color( 251, 184, 41 )

	self.HomeImage = Image.Create( AssetLocation.Resource, "HomeImage" )

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.5, 0.63 ) )
	self.window:SetPositionRel( Vector2( 0.7, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetVisible( self.active )
	self.window:SetTitle( "▧ Чёрный рынок" )
	self.window:Subscribe( "WindowClosed", self, self.Close )

	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )

	self.money_text = Label.Create( self.window )
	self.money_text:SetDock( GwenPosition.Fill )
	self.money_text:SetMargin( Vector2( 8, 0 ), Vector2( 8, 0 ) )
    self.money_text:SetAlignment( GwenPosition.Right )
	self.money_text:SetTextSize( 18 )
	self.money_text:SetFont( AssetLocation.SystemFont, "Impact" )
    self.money_text:SetTextColor( BuyMenuMoneyColor )

    self:UpdateMoneyString()

	self.buy_button = Button.Create( self.window )
	self.buy_button:SetWidthAutoRel( 0.5 )
	self.buy_button:SetText( "Взять" )
	self.buy_button:SetTextHoveredColor( Color.LightBlue )
	self.buy_button:SetTextPressedColor( Color.LightBlue )
	self.buy_button:SetTextSize( 15 )
	self.buy_button:SetSize( Vector2( 0, 30 ) )
	self.buy_button:SetDock( GwenPosition.Bottom )
	self.buy_button:Subscribe( "Press", self, self.Buy )

	self.categories = {}

	self.tone1 = Color.White
	self.tone2 = Color.White
	self.pcolor = LocalPlayer:GetColor()

	self.tone1Picker = nil
	self.tone2Picker = nil

	self:CreateItems()
	self:LoadCategories()

	self.sort_dir = false
	self.last_column = -1

	player_hats = {}
	player_coverings = {}
	player_hairs = {}
	player_faces = {}
	player_necks = {}
	player_backs = {}
	player_torso = {}
	player_righthand = {}
	player_lefthand = {}
	player_legs = {}
	player_rightfoot = {}
	player_leftfoot = {}

	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "OpenShop", self, self.OpenShop )
	Events:Subscribe( "CloseShop", self, self.CloseShop )

	Events:Subscribe( "Render", self, self.RenderAppearanceHat )
	Events:Subscribe( "PlayerNetworkValueChange", self, self.PlayerValueChangeAppearance )
	Events:Subscribe( "LocalPlayerMoneyChange", self, self.LocalPlayerMoneyChange )
	Events:Subscribe( "EntitySpawn", self, self.EntitySpawnAppearance )
	Events:Subscribe( "EntityDespawn", self, self.EntityDespawnAppearance )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoadAppearance )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnloadAppearance )
	Events:Subscribe( "GameLoad", self, self.GameLoad )

	Network:Subscribe( "Shop", self, self.Shop )
	Network:Subscribe( "PlayerFired", self, self.Sound )
	Network:Subscribe( "Text", self, self.Text )
	Network:Subscribe( "NoMoneyText", self, self.NoMoneyText )
	Network:Subscribe( "NoVipText", self, self.NoVipText )
	Network:Subscribe( "Parachute", self, self.Parachute )

	Network:Subscribe( "BuyMenuSavedColor", self, self.SavedColor )

	Network:Send( "BuyMenuGetSaveColor" )
end

function Shop:Lang( args )
	self.window:SetTitle( "▧ Black Market" )
	self.buy_button:SetText( "Get" )
	self.nameBM = "You ordered: "
	self.noVipText = "Needed VIP status not found."
end

function Shop:RenderAppearanceHat()
	for p in Client:GetStreamedPlayers() do
		self:MoveAppearance(p)
	end
	self:MoveAppearance(LocalPlayer)
end

function Shop:CreateAppearance( player )
	self:RemoveAppearance( player )	
	local hatModel = player:GetValue("AppearanceHat")
	local coveringModel = player:GetValue("AppearanceCovering")
	local hairModel = player:GetValue("AppearanceHair")
	local faceModel = player:GetValue("AppearanceFace")
	local neckModel = player:GetValue("AppearanceNeck")
	local backModel = player:GetValue("AppearanceBack")
	local torsoModel = player:GetValue("AppearanceTorso")
	local righthandModel = player:GetValue("AppearanceRightHand")
	local lefthandModel = player:GetValue("AppearanceLeftHand")
	local legsModel = player:GetValue("AppearanceLegs")
	local rightfootModel = player:GetValue("AppearanceRightFoot")
	local leftfootModel = player:GetValue("AppearanceLeftFoot")
	if hatModel ~= nil and string.len(hatModel) >= 10 then
			player_hats[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = hatModel
			})
	else
		if player_hats[player:GetId()] ~= nil then
			if IsValid( player_hats[player:GetId()] ) then
				player_hats[player:GetId()]:Remove()
			end
			player_hats[player:GetId()] = nil
		end
	end
	if coveringModel ~= nil and string.len(coveringModel) >= 10 then
			player_coverings[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = coveringModel
			})
	else
		if player_coverings[player:GetId()] ~= nil then
			if IsValid( player_coverings[player:GetId()] ) then
				player_coverings[player:GetId()]:Remove()
			end
			player_coverings[player:GetId()] = nil
		end
	end
	if hairModel ~= nil and string.len(hairModel) >= 10 then
		player_hairs[player:GetId()] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_Head"),
		angle = player:GetBoneAngle("ragdoll_Head"),
		model = hairModel
		})
	else
		if player_hairs[player:GetId()] ~= nil then
			if IsValid( player_hairs[player:GetId()] ) then
				player_hairs[player:GetId()]:Remove()
			end
			player_hairs[player:GetId()] = nil
		end
	end
	if faceModel ~= nil and string.len(faceModel) >= 10 then
			player_faces[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = faceModel
			})
	else
		if player_faces[player:GetId()] ~= nil then
			if IsValid( player_faces[player:GetId()] ) then
				player_faces[player:GetId()]:Remove()
			end
			player_faces[player:GetId()] = nil
		end
	end
	if neckModel ~= nil and string.len(neckModel) >= 10 then
			player_necks[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Head"),
			angle = player:GetBoneAngle("ragdoll_Head"),
			model = neckModel
			})
	else
		if player_necks[player:GetId()] ~= nil then
			if IsValid( player_necks[player:GetId()] ) then
				player_necks[player:GetId()]:Remove()
			end
			player_necks[player:GetId()] = nil
		end
	end
	if backModel ~= nil and string.len(backModel) >= 10 then
			player_backs[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = backModel
			})
	else
		if player_backs[player:GetId()] ~= nil then
			if IsValid( player_backs[player:GetId()] ) then
				player_backs[player:GetId()]:Remove()
			end
			player_backs[player:GetId()] = nil
		end
	end
	if torsoModel ~= nil and string.len(torsoModel) >= 10 then
			player_torso[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Spine1"),
			angle = player:GetBoneAngle("ragdoll_Spine1"),
			model = torsoModel
			})
	else
		if player_torso[player:GetId()] ~= nil then
			if IsValid( player_torso[player:GetId()] ) then
				player_torso[player:GetId()]:Remove()
			end
			player_torso[player:GetId()] = nil
		end
	end
	if righthandModel ~= nil and string.len(righthandModel) >= 10 then
			player_righthand[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightForeArm"),
			angle = player:GetBoneAngle("ragdoll_RightForeArm"),
			model = righthandModel
			})
	else
		if player_righthand[player:GetId()] ~= nil then
			if IsValid( player_righthand[player:GetId()] ) then
				player_righthand[player:GetId()]:Remove()
			end
			player_righthand[player:GetId()] = nil
		end
	end
	if lefthandModel ~= nil and string.len(lefthandModel) >= 10 then
		player_lefthand[player:GetId()] = ClientStaticObject.Create({
		position = player:GetBonePosition("ragdoll_LeftForeArm"),
		angle = player:GetBoneAngle("ragdoll_LeftForeArm"),
		model = lefthandModel
		})
	else
		if player_lefthand[player:GetId()] ~= nil then
			if IsValid( player_lefthand[player:GetId()] ) then
				player_lefthand[player:GetId()]:Remove()
			end
			player_lefthand[player:GetId()] = nil
		end
	end
	if legsModel ~= nil and string.len(legsModel) >= 10 then
			player_legs[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_Hips"),
			angle = player:GetBoneAngle("ragdoll_Hips"),
			model = legsModel
			})
	else
		if player_legs[player:GetId()] ~= nil then
			if IsValid( player_legs[player:GetId()] ) then
				player_legs[player:GetId()]:Remove()
			end
			player_legs[player:GetId()] = nil
		end
	end
	if rightfootModel ~= nil and string.len(rightfootModel) >= 10 then
			player_rightfoot[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_RightFoot"),
			angle = player:GetBoneAngle("ragdoll_RightFoot"),
			model = rightfootModel
			})
	else
		if player_rightfoot[player:GetId()] ~= nil then
			if IsValid( player_rightfoot[player:GetId()] ) then
				player_rightfoot[player:GetId()]:Remove()
			end
			player_rightfoot[player:GetId()] = nil
		end
	end
	if leftfootModel ~= nil and string.len(leftfootModel) >= 10 then
			player_leftfoot[player:GetId()] = ClientStaticObject.Create({
			position = player:GetBonePosition("ragdoll_LeftFoot"),
			angle = player:GetBoneAngle("ragdoll_LeftFoot"),
			model = leftfootModel
			})
	else
		if player_leftfoot[player:GetId()] ~= nil then
			if IsValid( player_leftfoot[player:GetId()] ) then
				player_leftfoot[player:GetId()]:Remove()
			end
			player_leftfoot[player:GetId()] = nil
		end
	end
end

function Shop:RemoveAppearance( player )
	if player_hats[player:GetId()] ~= nil then
		if IsValid( player_hats[player:GetId()] ) then
			player_hats[player:GetId()]:Remove()
		end
		player_hats[player:GetId()] = nil
	end
	if player_coverings[player:GetId()] ~= nil then
		if IsValid( player_coverings[player:GetId()] ) then
			player_coverings[player:GetId()]:Remove()
		end
		player_coverings[player:GetId()] = nil
	end
	if player_hairs[player:GetId()] ~= nil then
		if IsValid( player_hairs[player:GetId()] ) then
			player_hairs[player:GetId()]:Remove()
		end
		player_hairs[player:GetId()] = nil
	end
	if player_faces[player:GetId()] ~= nil then
		if IsValid( player_faces[player:GetId()] ) then
			player_faces[player:GetId()]:Remove()
		end
		player_faces[player:GetId()] = nil
	end
	if player_necks[player:GetId()] ~= nil then
		if IsValid( player_necks[player:GetId()] ) then
			player_necks[player:GetId()]:Remove()
		end
		player_necks[player:GetId()] = nil
	end
	if player_backs[player:GetId()] ~= nil then
		if IsValid( player_backs[player:GetId()] ) then
			player_backs[player:GetId()]:Remove()
		end
		player_backs[player:GetId()] = nil
	end
	
	if player_torso[player:GetId()] ~= nil then
		if IsValid( player_torso[player:GetId()] ) then
			player_torso[player:GetId()]:Remove()
		end
		player_torso[player:GetId()] = nil
	end
	if player_righthand[player:GetId()] ~= nil then
		if IsValid( player_righthand[player:GetId()] ) then
			player_righthand[player:GetId()]:Remove()
		end
		player_righthand[player:GetId()] = nil
	end
	if player_lefthand[player:GetId()] ~= nil then
		if IsValid( player_lefthand[player:GetId()] ) then
			player_lefthand[player:GetId()]:Remove()
		end
		player_lefthand[player:GetId()] = nil
	end
	if player_legs[player:GetId()] ~= nil then
		if IsValid( player_legs[player:GetId()] ) then
			player_legs[player:GetId()]:Remove()
		end
		player_legs[player:GetId()] = nil
	end
	if player_rightfoot[player:GetId()] ~= nil then
		if IsValid( player_rightfoot[player:GetId()] ) then
			player_rightfoot[player:GetId()]:Remove()
		end
		player_rightfoot[player:GetId()] = nil
	end
	if player_leftfoot[player:GetId()] ~= nil then
		if IsValid( player_leftfoot[player:GetId()] ) then
			player_leftfoot[player:GetId()]:Remove()
		end
		player_leftfoot[player:GetId()] = nil
	end
end

function Shop:MoveAppearance( player )
	if IsValid(player) then
		local hat = player_hats[player:GetId()]
		local covering = player_coverings[player:GetId()]
		local hair = player_hairs[player:GetId()]
		local face = player_faces[player:GetId()]
		local neck = player_necks[player:GetId()]
		local back = player_backs[player:GetId()]
		local torso = player_torso[player:GetId()]
		local righthand = player_righthand[player:GetId()]
		local lefthand = player_lefthand[player:GetId()]
		local legs = player_legs[player:GetId()]
		local rightfoot = player_rightfoot[player:GetId()]
		local leftfoot = player_leftfoot[player:GetId()]

		if hat ~= nil and IsValid(hat) then
			hat:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = hat:GetAngle() * Vector3( 0, 1.62, .03 )
			hat:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if covering ~= nil and IsValid(covering) then
			covering:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = covering:GetAngle() * Vector3( 0, 1.62, .03 )
			covering:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if hair ~= nil and IsValid(hair) then
			hair:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = hair:GetAngle() * Vector3( 0, 1.61, .03 )
			hair:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if face ~= nil and IsValid(face) then
			face:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = face:GetAngle() * Vector3( 0, 1.65, .0375 )
			face:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if neck ~= nil and IsValid(neck) then
			neck:SetAngle(player:GetBoneAngle("ragdoll_Head"))
			local AppearanceOffset = neck:GetAngle() * Vector3( 0, 1.54, .065 )
			neck:SetPosition(player:GetBonePosition("ragdoll_Head") - AppearanceOffset) 
		end
		if back ~= nil and IsValid(back) then
			back:SetAngle(player:GetBoneAngle("ragdoll_Spine1"))
			local AppearanceOffset = back:GetAngle() * Vector3( 0, 1.225, 0.05 )
			back:SetPosition(player:GetBonePosition("ragdoll_Spine1") - AppearanceOffset) 
		end

		if torso ~= nil and IsValid(torso) then
			torso:SetAngle(player:GetBoneAngle("ragdoll_Spine1"))
			local AppearanceOffset = torso:GetAngle() * Vector3( 0, 1.225, 0.05 )
			torso:SetPosition(player:GetBonePosition("ragdoll_Spine1") - AppearanceOffset) 
		end
		if righthand ~= nil and IsValid(righthand) then
			righthand:SetAngle(player:GetBoneAngle("ragdoll_RightForeArm"))
			local AppearanceOffset = righthand:GetAngle() * Vector3( 0, 0, 0 )
			righthand:SetPosition(player:GetBonePosition("ragdoll_RightForeArm") - AppearanceOffset) 
		end
		if lefthand ~= nil and IsValid(lefthand) then
			lefthand:SetAngle(player:GetBoneAngle("ragdoll_LeftForeArm"))
			local AppearanceOffset = lefthand:GetAngle() * Vector3( 0, 0, 0 )
			lefthand:SetPosition(player:GetBonePosition("ragdoll_LeftForeArm") - AppearanceOffset) 
		end
		if legs ~= nil and IsValid(legs) then
			legs:SetAngle(player:GetBoneAngle("ragdoll_Hips"))
			local AppearanceOffset = legs:GetAngle() * Vector3( 0, 0, 0 )
			legs:SetPosition(player:GetBonePosition("ragdoll_Hips") - AppearanceOffset) 
		end
		if rightfoot ~= nil and IsValid(rightfoot) then
			rightfoot:SetAngle(player:GetBoneAngle("ragdoll_RightFoot"))
			local AppearanceOffset = rightfoot:GetAngle() * Vector3( 0, 0, 0 )
			rightfoot:SetPosition(player:GetBonePosition("ragdoll_RightFoot") - AppearanceOffset) 
		end
		if leftfoot ~= nil and IsValid(leftfoot) then
			leftfoot:SetAngle(player:GetBoneAngle("ragdoll_LeftFoot"))
			local AppearanceOffset = leftfoot:GetAngle() * Vector3( 0, 0, 0 )
			leftfoot:SetPosition(player:GetBonePosition("ragdoll_LeftFoot") - AppearanceOffset) 
		end
	end
end

function Shop:PlayerValueChangeAppearance( args )
	if args.key == "AppearanceHat" or 
		args.key == "AppearanceCovering" or
		args.key == "AppearanceHair" or
		args.key == "AppearanceFace" or
		args.key == "AppearanceNeck" or
		args.key == "AppearanceBack" or
		args.key == "AppearanceTorso" or
		args.key == "AppearanceRightHand" or
		args.key == "AppearanceLeftHand" or
		args.key == "AppearanceLegs" or
		args.key == "AppearanceRightFoot" or
		args.key == "AppearanceLeftFoot" then
		self:CreateAppearance(args.player)
	end
end

function Shop:EntitySpawnAppearance( args )
	if args.entity.__type == "Player" then
		self:CreateAppearance(args.entity)
	end
end

function Shop:EntityDespawnAppearance( args )
	if args.entity.__type == "Player" then
		self:RemoveAppearance(args.entity)
	end
end

function Shop:ModuleLoadAppearance()
	for p in Client:GetStreamedPlayers() do
		self:CreateAppearance(p)
	end
	self:CreateAppearance(LocalPlayer)
end

function Shop:ModuleUnloadAppearance()
	for k, v in pairs(player_hats) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_coverings) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_hairs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_faces) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_necks) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_backs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_torso) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_righthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_lefthand) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_legs) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_rightfoot) do
		if IsValid(v) then
			v:Remove()
		end
	end
	for k, v in pairs(player_leftfoot) do
		if IsValid(v) then
			v:Remove()
		end
	end
end

function Shop:SavedColor( args )
	if self.tone1Picker == nil or self.tone2Picker == nil then return end

	local tone1 = args.tone1
	local tone2 = args.tone2

	self.tone1 = tone1
	self.tone2 = tone2
	self.tone1Picker:SetColor( self.tone1 )
	self.tone2Picker:SetColor( self.tone2 )
end

function Shop:CreateCategory( category_name )
	local t = {}
	t.window = BaseWindow.Create( self.window )
	t.window:SetDock( GwenPosition.Fill )
	t.button = self.tab_control:AddPage( category_name, t.window )

	t.tab_control = TabControl.Create( t.window )
	t.tab_control:SetDock( GwenPosition.Fill )

	t.categories = {}

	self.categories[category_name] = t

    return t
end

function Shop:SortFunction( column, a, b )
	if column ~= -1 then
		self.last_column = column
	elseif column == -1 and self.last_column ~= -1 then
		column = self.last_column
	else
		column = 0
	end

	local a_value = a:GetCellText( column )
	local b_value = b:GetCellText( column )

	if column == 1 then
		local a_num = tonumber( a_value )
		local b_num = tonumber( b_value )

		if a_num ~= nil and b_num ~= nil then
			a_value = a_num
			b_value = b_num
		end
	end

	if self.sort_dir then
		return a_value > b_value
	else
		return a_value < b_value
	end
end

function Shop:CreateSubCategory( category, subcategory_name )
	local t = {}
	t.window = BaseWindow.Create( self.window )
	t.window:SetDock( GwenPosition.Fill )
	t.button = category.tab_control:AddPage( subcategory_name, t.window )

	t.listbox = SortedList.Create( t.window )
	t.listbox:SetDock( GwenPosition.Fill )
	t.listbox:AddColumn( subcategory_name .. ":" )
	t.listbox:AddColumn( "Цена:", 80 )
	t.listbox:SetSort( self, self.SortFunction )

	t.listbox:Subscribe( "SortPress",
		function( button )
			self.sort_dir = not self.sort_dir
		end )

	category.categories[subcategory_name] = t

	if (subcategory_name == "Машины" or subcategory_name == "Мотоциклы" or subcategory_name == "Джипы" or subcategory_name == "Пикапы" or subcategory_name == "Автобусы" or subcategory_name == "Тяжи" or 
	subcategory_name == "Трактора" or subcategory_name == "Вертолёты" or subcategory_name == "Самолёты" or subcategory_name == "Лодки" or subcategory_name == "DLC") then
		local skin = RadioButtonController.Create( t.window )
		skin:SetMargin( Vector2( 0, 5 ), Vector2( 0, 0 ) )
		skin:SetSize( Vector2( 0, 20 ) )
		skin:SetDock( GwenPosition.Bottom )
		local units = { "Декаль Панау", "Декаль Японцев", "Декаль Уларов", "Декаль Жнецов", "Декаль Тараканов"}
		for i, v in ipairs( units ) do
			local option = skin:AddOption( v )
			option:SetSize( Vector2( 128, 0 ) )
			option:SetDock( GwenPosition.Left )

			if i-1 == self.unit then
				option:Select()
			end

			option:GetRadioButton():Subscribe( "Checked", function() self.unit = i-1 end )
		end
	end

	return t
end

function Shop:LoadCategories()
	for category_id, category in ipairs( self.items ) do
		local category_table = self:CreateCategory( self.id_types[category_id] )

		for _, subcategory_name in ipairs( category[1] ) do
			local subcategory = category[subcategory_name]

			local subcategory_table = self:CreateSubCategory( category_table, subcategory_name )

			local item_id = 0

			for _, entry in pairs( subcategory ) do
				item_id = item_id + 1
				local row = subcategory_table.listbox:AddItem( entry:GetName() )
				row:SetTextColor( BuyMenuLineColor )
				row:SetDataNumber( "id", item_id )
				row:SetCellText( 1, "$" .. tostring(entry:GetPrice()) )
				if entry:GetPrice() > 0 then
					row:SetTextColor( BuyMenuMoneyColor )
				else
					row:SetTextColor( BuyMenuLineColor )
				end
                row:SetBackgroundOddSelectedColor( Color( 0, 150, 255, 100 ) )
				row:SetBackgroundEvenSelectedColor( Color( 0, 150, 255, 100 ) )
				entry:SetListboxItem( row )
			end
		end

		if category_id == self.types["Остальное >"] then
			local window = BaseWindow.Create( self.window )
			window:SetDock( GwenPosition.Fill )
			category_table.tab_control:AddPage( "Действия", window )

			local text = Label.Create( window )
			text:SetVisible( true )
			text:SetText( "Действия:" )
			text:SetDock( GwenPosition.Top )
			text:SetMargin( Vector2( 5, 5 ), Vector2( 5, 5 ) )

			local actionBtn = Button.Create( window )
			actionBtn:SetText( "Вылечить себя" )
			actionBtn:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
			actionBtn:SetTextHoveredColor( Color.GreenYellow )
			actionBtn:SetTextPressedColor( Color.GreenYellow )
			actionBtn:SetTextSize( 14 )
			actionBtn:SetSize( Vector2( 0, 30 ) )
			actionBtn:SetDock( GwenPosition.Top )
			actionBtn:Subscribe( "Press", self, self.Heal )

			local actionBtn = Button.Create( window )
			actionBtn:SetText( "Очистить инвентарь" )
			actionBtn:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
			actionBtn:SetTextSize( 14 )
			actionBtn:SetSize( Vector2( 0, 30 ) )
			actionBtn:SetDock( GwenPosition.Top )
			actionBtn:Subscribe( "Press", function() Network:Send( "ClearInv") self:Close() end )

			local actionBtn = Button.Create( window )
			actionBtn:SetText( "Бухнуть" )
			actionBtn:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
			actionBtn:SetTextSize( 14 )
			actionBtn:SetSize( Vector2( 0, 30 ) )
			actionBtn:SetDock( GwenPosition.Top )
			actionBtn:Subscribe( "Press", function() Events:Fire( "BloozingStart" ) self:Close() end )

			local actionBtn = Button.Create( window )
			actionBtn:SetText( "Сесть" )
			actionBtn:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
			actionBtn:SetTextSize( 14 )
			actionBtn:SetSize( Vector2( 0, 30 ) )
			actionBtn:SetDock( GwenPosition.Top )
			actionBtn:Subscribe( "Press", self, self.Seat )

			local actionBtn = Button.Create( window )
			actionBtn:SetText( "Лечь" )
			actionBtn:SetMargin( Vector2( 0, 2 ), Vector2( 0, 2 ) )
			actionBtn:SetTextSize( 14 )
			actionBtn:SetSize( Vector2( 0, 30 ) )
			actionBtn:SetDock( GwenPosition.Top )
			actionBtn:Subscribe( "Press", self, self.Sleep )

			local tab_control = TabControl.Create( window )
			tab_control:SetDock( GwenPosition.Fill )

			local window = BaseWindow.Create( self.window )
			window:SetDock( GwenPosition.Fill )
			category_table.tab_control:AddPage( "Цвет транспорта", window )

			local tab_control = TabControl.Create( window )
			tab_control:SetDock( GwenPosition.Fill )

			self.tone1Picker = HSVColorPicker.Create()
			tab_control:AddPage( "▧ Тон 1", self.tone1Picker )
			self.tone1Picker:SetDock( GwenPosition.Fill )

			self.tone1Picker:Subscribe( "ColorChanged", function()
				self.tone1 = self.tone1Picker:GetColor()
				self.colorChanged = true
			end )

			self.tone1Picker:SetColor( Color.White )
			self.tone1 = self.tone1Picker:GetColor()

			self.tone2Picker = HSVColorPicker.Create()
			tab_control:AddPage( "▨ Тон 2", self.tone2Picker )
			self.tone2Picker:SetDock( GwenPosition.Fill )

			self.tone2Picker:Subscribe( "ColorChanged", function()
				self.tone2 = self.tone2Picker:GetColor() 
				self.colorChanged = true
			end )

			self.tone2Picker:SetColor( Color.White )
			self.tone2 = self.tone2Picker:GetColor()
			self.tone1Picker:SetColor( LocalPlayer:GetColor() )
			self.tone2Picker:SetColor( LocalPlayer:GetColor() )

			local setColorBtn = Button.Create( window )
			setColorBtn:SetText( "Установить цвет »" )
			setColorBtn:SetTextHoveredColor( Color.GreenYellow )
			setColorBtn:SetTextPressedColor( Color.GreenYellow )
			setColorBtn:SetTextSize( 15 )
			setColorBtn:SetSize( Vector2( 0, 30 ) )
			setColorBtn:SetDock( GwenPosition.Bottom )
			setColorBtn:Subscribe( "Down", function()
				Network:Send( "ColorChanged", { tone1 = self.tone1, tone2 = self.tone2 } )
				local sound = ClientSound.Create(AssetLocation.Game, {
						bank_id = 20,
						sound_id = 22,
						position = LocalPlayer:GetPosition(),
						angle = Angle()
				})

				sound:SetParameter(0,1)	
				Game:FireEvent( "bm.savecheckpoint.go" )
			end )

			local window = BaseWindow.Create( self.window )
			window:SetDock( GwenPosition.Fill )
			category_table.tab_control:AddPage( "Дом", window )

			self.texter = Label.Create( window )
			self.texter:SetVisible( true )
			self.texter:SetText( "Дом:" )
			self.texter:SetPosition( Vector2( 5, 10 ) )

			self.toggleH = Button.Create( window )
			self.toggleH:SetVisible( true )
			self.toggleH:SetText( ">" )
			self.toggleH:SetSize( Vector2( 40, 20 ) )
			self.toggleH:SetTextSize( 15 )
			self.toggleH:SetPosition( Vector2( 270, 5 ) )
			self.toggleH:Subscribe( "Press", self, self.ToggleHome )

			self.Home_Image = ImagePanel.Create( window )
			self.Home_Image:SetImage( self.HomeImage )
			self.Home_Image:SetPosition( Vector2( 5, 40 ) )
			self.Home_Image:SetHeight( Render.Size.x / 9 )
			self.Home_Image:SetWidth( Render.Size.x / 5.5 )

			self.Home_button = MenuItem.Create( window )
			self.Home_button:SetPosition( Vector2( 5, 40 ) )
			self.Home_button:SetHeight( Render.Size.x / 7 )
			self.Home_button:SetWidth( Render.Size.x / 5.5 )
			self.Home_button:SetText( "Переместиться домой »" )
			self.Home_button:SetTextHoveredColor( Color.GreenYellow )
			self.Home_button:SetTextPressedColor( Color.GreenYellow )
			self.Home_button:SetTextPadding( Vector2( 0, Render.Size.x / 9 ), Vector2.Zero )
			self.Home_button:SetTextSize( Render.Size.x / 70 )
			self.Home_button:Subscribe( "Press", self, self.GoHome )

			self.buttonHB = Button.Create( window )
			self.buttonHB:SetVisible( true )
			self.buttonHB:SetText( "Установить точку дома здесь" )
			self.buttonHB:SetSize( Vector2( Render.Size.x / 5.5, Render.Size.x / 40 ) )
			self.buttonHB:SetTextHoveredColor( Color.GreenYellow )
			self.buttonHB:SetTextPressedColor( Color.GreenYellow )
			self.buttonHB:SetTextSize( 12 )
			self.buttonHB:SetPosition( Vector2( 50, 5 ) )
			self.buttonHB:SetSize( Vector2( 210, 20 ) )
			self.buttonHB:Subscribe( "Press", self, self.BuyHome )

			self.texterHTw = Label.Create( window )
			self.texterHTw:SetVisible( false )
			self.texterHTw:SetText( "Дом 2:" )
			self.texterHTw:SetPosition( Vector2( 5, 10 ) )
		end	
	end
end

function Shop:Heal( args )
	Network:Send( "HealMe" )
	local sound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 19,
		sound_id = 30,
		position = LocalPlayer:GetPosition(),
		angle = Angle()
	})

	sound:SetParameter(0,1)
	self:Close()
end

function Shop:Seat( args )
	if LocalPlayer:GetBaseState() == 6 then
		if not self.SeatInputEvent then
			self.SeatInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.SeatInput )
			self.CalcViewEvent = Events:Subscribe( "CalcView", self, self.CalcView )
		end
		LocalPlayer:SetBaseState( AnimationState.SIdlePassengerVehicle )
		self:Close()
	elseif LocalPlayer:GetBaseState() == AnimationState.SIdlePassengerVehicle then
		LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		if self.SeatInputEvent then
			Events:Unsubscribe( self.SeatInputEvent )
			self.SeatInputEvent = nil
			Events:Unsubscribe( self.CalcViewEvent )
			self.CalcViewEvent = nil
		end
		self:Close()
	end
end

function Shop:SeatInput( args )
	if args.input == 39 or args.input == 40 or args.input == 41 or args.input == 42 then
		LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
		Events:Unsubscribe( self.SeatInputEvent )
		self.SeatInputEvent = nil
		Events:Unsubscribe( self.CalcViewEvent )
		self.CalcViewEvent = nil
	end
end

function Shop:Sleep( args )
	if LocalPlayer:GetBaseState() == AnimationState.SUprightIdle then
		LocalPlayer:SetBaseState( AnimationState.SSwimDie )
		self:Close()
	else
		if LocalPlayer:GetBaseState() == AnimationState.SDead then
			LocalPlayer:SetBaseState( AnimationState.SUprightIdle )
			self:Close()
		end
	end
end

function Shop:CalcView( args )
	Camera:SetPosition( Camera:GetPosition() - Vector3( 0, 1, 0 ) )
end

function Shop:ToggleHome()
	if self.home then
		self.home = false
		self.texter:SetVisible( false )
		self.texterHTw:SetVisible( true )
	else
		self.home = true
		self.texter:SetVisible( true )
		self.texterHTw:SetVisible( false )
	end
end

function Shop:GoHome()
	self:Close()
	if self.home then
		Events:Fire( "GoHome" )
	else
		Events:Fire( "GoHomeTw" )
	end
end

function Shop:BuyHome()
	self:Close()
	if self.home then
		Events:Fire( "BuyHome" )
	else
		Events:Fire( "BuyHomeTw" )
	end
end

function Shop:GetUnitString()
	if self.unit == 0 then
		Network:Send( "Skin", nil )
	elseif self.unit == 1 then
		Network:Send( "Skin", "OldJapan" )
	elseif self.unit == 2 then
		Network:Send( "Skin", "UlarBoys" )
	elseif self.unit == 3 then
		Network:Send( "Skin", "Reapers" )
	elseif self.unit == 4 then
		Network:Send( "Skin", "Roaches" )
	end
end

function Shop:UpdateMoneyString( money )
    if money == nil then
        money = LocalPlayer:GetMoney()
    end

	self.money_text:SetText( string.format( "Баланс: $%i", money ) )
end

function Shop:LocalPlayerMoneyChange( args )
    self:UpdateMoneyString( args.new_money )
end

function Shop:GetActive()
    return self.active
end

function Shop:SetActive( active )
    if self.active ~= active then
        self.active = active
        Mouse:SetVisible( self.active )
		if not self.active and self.colorChanged then
			self.colorChanged = false
			Network:Send( "BuyMenuSaveColor", {tone1 = self.tone1, tone2 = self.tone2} )
		end
    end
end

function Shop:Render()
	local is_visible = self.active and (Game:GetState() == GUIState.Game)

	if self.window:GetVisible() ~= is_visible then
		self.window:SetVisible( is_visible )
	end

	if self.active then
		Mouse:SetVisible( true )
	end
end

function Shop:OpenShop()
	if Game:GetState() ~= GUIState.Game then return end
	if LocalPlayer:GetWorld() ~= DefaultWorld then return end
	ClientEffect.Play(AssetLocation.Game, {
		effect_id = 382,

		position = Camera:GetPosition(),
		angle = Angle()
	})
	self:SetActive( not self:GetActive() )
	if self.active then
		if LocalPlayer:GetValue( "SystemFonts" ) then
			self.Home_button:SetFont( AssetLocation.SystemFont, "Impact" )
		end
		self.KeyDownEvent = Events:Subscribe( "KeyDown", self, self.KeyDown )
		self.LocalPlayerInputEvent = Events:Subscribe( "LocalPlayerInput", self, self.LocalPlayerInput )
		if LocalPlayer:GetValue( "Tag" ) == "VIP" or LocalPlayer:GetValue( "Tag" ) == "YouTuber" or LocalPlayer:GetValue( "Tag" ) == "ModerD" or 
		LocalPlayer:GetValue( "Tag" ) == "AdminD" or LocalPlayer:GetValue( "Tag" ) == "Admin" or LocalPlayer:GetValue( "Tag" ) == "GlAdmin" or LocalPlayer:GetValue( "Tag" ) == "Owner" then
			self.toggleH:SetEnabled( true )
		else
			self.toggleH:SetEnabled( false )
		end
	else
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

function Shop:CloseShop()
	if Game:GetState() ~= GUIState.Game and LocalPlayer:GetWorld() ~= DefaultWorld then return end
	if self.window:GetVisible() == true then
		self:SetActive( false )
		if self.KeyDownEvent then
			Events:Unsubscribe( self.KeyDownEvent )
			self.KeyDownEvent = nil
		end
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
	end
end

function Shop:KeyDown( args )
	if args.key == VirtualKey.Escape then
		self:SetActive( false )
		Events:Unsubscribe( self.KeyDownEvent )
		Events:Unsubscribe( self.LocalPlayerInputEvent )
	end
end

function Shop:LocalPlayerInput( args )
	return false
end

function Shop:Buy( args )
	local category_name = self.tab_control:GetCurrentTab():GetText()
	local category = self.categories[category_name]

	local subcategory_name = category.tab_control:GetCurrentTab():GetText()
	local subcategory = category.categories[subcategory_name]

	if subcategory == nil then return end

	local listbox = subcategory.listbox

	local first_selected_item = listbox:GetSelectedRow()

	if first_selected_item ~= nil then
		local index = first_selected_item:GetDataNumber( "id" )
		self:GetUnitString()
		Network:Send( "PlayerFired", { self.types[category_name], subcategory_name, index, self.tone1, self.tone2 } )
		self:Close()
	end
end

function Shop:Close( args )
	if self.active then
		self:SetActive( false )
		if self.KeyDownEvent then
			Events:Unsubscribe( self.KeyDownEvent )
			self.KeyDownEvent = nil
		end
		if self.LocalPlayerInputEvent then
			Events:Unsubscribe( self.LocalPlayerInputEvent )
			self.LocalPlayerInputEvent = nil
		end
		ClientEffect.Create(AssetLocation.Game, {
			effect_id = 383,

			position = Camera:GetPosition(),
			angle = Angle()
		})
	end
end

function Shop:Text( message )
	Events:Fire( "CastCenterText", { text = self.nameBM .. message, time = 6, color = Color.Gold } )
end

function Shop:NoMoneyText( message )
	Events:Fire( "CastCenterText", { text = message, time = 6, color = Color.Red } )
end

function Shop:NoVipText()
	Events:Fire( "CastCenterText", { text = self.noVipText, time = 3, color = Color.Red } )
end

function Shop:Parachute( message )
	Game:FireEvent( message )
end

function Shop:GameLoad()
	Network:Send( "GiveMeParachute" )
end

function Shop:Sound()
	Game:FireEvent( "ply.blackmarket.item_ordered" )

	local sound = ClientSound.Create(AssetLocation.Game, {
			bank_id = 19,
			sound_id = 30,
			position = LocalPlayer:GetPosition(),
			angle = Angle()
	})

	sound:SetParameter(0,1)
end

function Shop:Shop( args )
	self.active = true
end

shop = Shop()