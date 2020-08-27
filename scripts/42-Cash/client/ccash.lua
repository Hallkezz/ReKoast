class "Cases"

function Cases:__init()
	self.timmy = Timer()

	sound = nil
	crates = {}

	Console:Subscribe( "reloadtriggers", self, self.RTWarningMessage )
	Events:Subscribe( "Render", self, self.Render )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
	Events:Subscribe( "ShapeTriggerEnter", self, self.ShapeTriggerEnter )

	Network:Subscribe( "66playsound", self, self.ClientFunction )
	Network:Subscribe( "SyncTriggers", self, self.ClientFunction3 )
	Network:Subscribe( "SyncGlow", self, self.ClientGlow )
	Network:Subscribe( "SyncTriggersRemove", self, self.RemoveSync )
end

function Cases:ModuleLoad()
	Network:Send( "SyncReq", LocalPlayer )
end

math.round = function( num, idp )
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function Cases:Render()
	if self.timmy:GetSeconds() > 1 then
		local heat = 0
		for i = 1, #crates do
			if crates[i] ~= nil then
				if crates[i].trigger ~= nil then
					local radius = crates[i].trigger:GetPosition():Distance( LocalPlayer:GetPosition() )
					if radius < 500 then
						local ent = StaticObject.GetById(crates[i].id)
						if radius < 51 and radius > 40 then
							if heat < 0.3 then
								heat = 0.2
							end
							if IsValid(ent) then
								ent:SetOutlineEnabled( false )
							end
						elseif radius < 41 and radius > 30 then
							if heat < 0.5 then
								heat = 0.4
							end
							if IsValid(ent) then
								ent:SetOutlineEnabled( false )
							end
						elseif radius < 31 and radius > 20 then
							if heat < 0.7 then
								heat = 0.6
							end
							if IsValid(ent) then
								ent:SetOutlineEnabled( false )
							end
						elseif radius < 21 and radius > 10 then
							if heat < 0.9 then
								heat = 0.8
							end
							if IsValid(ent) then
								ent:SetOutlineEnabled( false )
							end
						elseif radius < 11 then
							heat = 1
							if IsValid(ent) then
								ent:SetOutlineColor( Color.White )
								ent:SetOutlineEnabled( true )
							end
						else
							if IsValid(ent) then
								ent:SetOutlineEnabled( false )
							end
						end
					end
				end
			end
		end
		self.timmy:Restart()
	end
end

function Cases:ModuleUnload()
	for i = 1, #crates do
		if crates[i] ~= nil then
			if crates[i].trigger ~= nil then
				crates[i].trigger:Remove()
			end
		end
	end
end

function Cases:RTWarningMessage()
	print( "WARNING:\nFPS Lower. Do you want to continue?\n> Enter: yes/no\nRecommended reconnect to the server and not use this event.\n> Enter: reconnect" )
	if not self.yescmessage then
		self.yescmessage = Console:Subscribe( "yes", self, self.RTYes )
	end
	if not self.nocmessage then
		self.nocmessage = Console:Subscribe( "no", self, self.RTNo )
	end
end

function Cases:RTYes()
	Network:Send( "SyncReq", LocalPlayer )
	if self.yescmessage then
		print( "Triggers has been successfully reloaded." )
		Console:Unsubscribe( self.yescmessage )
		self.yescmessage = nil
		Console:Unsubscribe( self.nocmessage )
		self.nocmessage = nil
	end
end

function Cases:RTNo()
	if self.nocmessage then
		print( "Canceled." )
		Console:Unsubscribe( self.nocmessage )
		self.nocmessage = nil
		Console:Unsubscribe( self.yescmessage )
		self.yescmessage = nil
	end
end

function Cases:ShapeTriggerEnter( args )
	for i = 1, #crates do
		if crates[i] ~= nil then
			if crates[i].trigger == args.trigger then
				if args.entity.__type == "LocalPlayer" or args.entity.__type == "Player" then
					if args.entity.__type == "LocalPlayer" then
						local id = args.entity:GetId()
						Network:Send( "66crate_remove", crates[i].id )
					end
					crates[i].trigger:Remove()
					crates[i] = nil
					break
				end
			end
		end
	end
end

function Cases:RemoveSync( args )
	for i = 1, #crates do
		if crates[i] ~= nil then
			if crates[i].id == args.id then
				crates[i].trigger:Remove()
				crates[i] = nil
				break
			end
		end
	end
end

function Cases:ClientFunction( ply )
	local numcrates = 0

	for i = 1, #crates do
		if crates[i] ~= nil then
			if crates[i].trigger ~= nil then
				numcrates = numcrates + 1
			end
		end
	end

	local sound = ClientSound.Create(AssetLocation.Game, {
		bank_id = 19,
		sound_id = 3,
		position = LocalPlayer:GetPosition(),
		angle = Angle()

	})
	sound:SetParameter(0,1)
	Game:ShowPopup( "Ящики: " .. 3754-numcrates .. "/3754", true )
end

function Cases:ClientFunction3( args )
	for i = 1, #args do
		table.insert(crates, {
			trigger = ShapeTrigger.Create(
			{
				position = args[i].pos,
				angle = Angle.Zero,
				components = {
				{
					type = TriggerType.Box,
					size = Vector3.One,
					position = Vector3.Zero,
				}
				},
				trigger_player = true,
				trigger_player_in_vehicle = true,
				trigger_vehicle = false,
			}),
			radius = 1
	, id = args[i].id})
	end
end

function Cases:ClientGlow( args )
	for i = 1, #args do
		local ent = StaticObject.GetById(args[i].id)
		if IsValid(ent) then
			ent:SetOutlineColor( Color.White )
			ent:SetOutlineEnabled( true )
		end
	end
end

cases = Cases()