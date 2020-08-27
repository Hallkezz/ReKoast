class 'Shop'
class 'BuyMenuEntry'

function BuyMenuEntry:__init( model_id, price, entry_type, template, decal )
	self.model_id = model_id
	self.price = price
    self.entry_type = entry_type
	self.template = template
	self.decal = decal
end

function BuyMenuEntry:GetPrice()
    return self.price
end

function BuyMenuEntry:GetModelId()
    return self.model_id
end

function BuyMenuEntry:GetTemplate()
    return self.template
end

function BuyMenuEntry:GetDecal()
    return self.decal
end

function BuyMenuEntry:GetListboxItem()
    return self.listbox_item
end

function BuyMenuEntry:SetListboxItem( item )
    self.listbox_item = item
end

class 'VehicleBuyMenuEntry' ( BuyMenuEntry )

function VehicleBuyMenuEntry:__init( model_id, price, template, decal, name, rank )
    BuyMenuEntry.__init( self, model_id, price, 1, template, decal )
    self.name = name
	self.rank = rank
end

function VehicleBuyMenuEntry:GetName()
	local modelName = Vehicle.GetNameByModelId( self.model_id )
	local DisplayName = modelName
	if self.name ~= nil and self.name ~= "" then
		DisplayName = modelName .. " - " .. self.name
	end
	if self.template ~= nil and self.template ~= "" then
		DisplayName = DisplayName .. " [" .. self.template .. "]"
	end
	if self.decal ~= nil and self.decal ~= "" then
		DisplayName = DisplayName .. " (" .. self.decal .. ")"
	end
    return DisplayName
end

function VehicleBuyMenuEntry:GetRank()
    return self.rank
end

class 'WeaponBuyMenuEntry' ( BuyMenuEntry )

function WeaponBuyMenuEntry:__init( model_id, price, slot, name, rank )
    BuyMenuEntry.__init( self, model_id, price, 2 )
    self.slot = slot
    self.name = name
	self.rank = rank
end

function WeaponBuyMenuEntry:GetSlot()
    return self.slot
end

function WeaponBuyMenuEntry:GetName()
    return self.name
end

function WeaponBuyMenuEntry:GetRank()
    return self.rank
end

class 'ModelBuyMenuEntry' ( BuyMenuEntry )

function ModelBuyMenuEntry:__init( model_id, price, name, rank )
    BuyMenuEntry.__init( self, model_id, price, 2 )
    self.name = name
	self.rank = rank
end

function ModelBuyMenuEntry:GetName()
    return self.name
end

function ModelBuyMenuEntry:GetRank()
    return self.rank
end

class 'AppearanceBuyMenuEntry' ( BuyMenuEntry )

function AppearanceBuyMenuEntry:__init( model_id, price, itemtype, name, rank )
    BuyMenuEntry.__init( self, model_id, price, itemtype, 2 )
    self.name = name
    self.itemtype = itemtype
	self.rank = rank
end

function AppearanceBuyMenuEntry:GetName()
    return self.name
end

function AppearanceBuyMenuEntry:GetType()
    return self.itemtype
end

function AppearanceBuyMenuEntry:GetRank()
    return self.rank
end

class 'ParachutesBuyMenuEntry' ( BuyMenuEntry )

function ParachutesBuyMenuEntry:__init( model_id, price, name, rank )
    BuyMenuEntry.__init( self, model_id, price, event, 2 )
    self.name = name
	self.rank = rank
end

function ParachutesBuyMenuEntry:GetName()
    return self.name
end

function ParachutesBuyMenuEntry:GetRank()
    return self.rank
end

function Shop:CreateItems()
    self.types = {
        ["Транспорт"] = 1,
        ["Оружие"] = 2,
        ["Персонаж"] = 3,
		["Внешность"] = 4,
		["Остальное >"] = 5
    }

    self.id_types = {}

    for k, v in pairs( self.types ) do
        self.id_types[v] = k
    end

    self.items = {
         [self.types["Транспорт"]] = {
            { "Машины", "Мотоциклы", "Джипы", "Пикапы", "Автобусы", "Тяжи", "Трактора", "Вертолёты", "Самолёты", "Лодки", "DLC" },

			["Машины"] = {
				VehicleBuyMenuEntry( 44, 0, "Softtop", nil, "" ),
				-- ^ Hamaya Oldman Softtop
				VehicleBuyMenuEntry( 44, 0,"Cab", nil, "" ),
				-- ^ Hamaya Oldman Opentop
				VehicleBuyMenuEntry( 44, 0,"Hardtop", nil, "" ),
				-- ^ Hamaya Oldman Hardtop
				VehicleBuyMenuEntry( 29, 0, nil, nil, "" ),
				-- ^ Sakura Aquila City
				VehicleBuyMenuEntry( 15, 0, nil, nil, "" ),
				-- ^ Sakura Aquila Space
				VehicleBuyMenuEntry( 70, 0, nil, nil, "" ),
				-- ^ Sakura Aquila Forte (Taxi)
				VehicleBuyMenuEntry( 55, 0, nil, nil, "" ),
				-- ^ Sakura Aquila Metro ST
				VehicleBuyMenuEntry( 13, 0, nil, nil, "" ),
				-- ^ Stinger Dunebug 84
				VehicleBuyMenuEntry( 54, 0, nil, nil, "" ),
				-- ^ Boyd Fireflame 544
				VehicleBuyMenuEntry( 8, 0, nil, nil, "" ),
				-- ^ Columbi Excelsior (Limo)
				VehicleBuyMenuEntry( 8, 0, "Hijack_Rear", nil, "" ),
				-- ^ Columbi Excelsior Rear Stuntjump (Limo)
				VehicleBuyMenuEntry( 78, 0, "Hardtop", nil, "" ),
				-- ^ Civadier 999 Hardtop
				VehicleBuyMenuEntry( 78, 0, "Cab", nil, "" ),
				-- ^ Civadier 999 Opentop
				VehicleBuyMenuEntry( 2, 0, nil, nil, "" ),
				-- ^ Mancini Cavallo 1001
				VehicleBuyMenuEntry( 91, 0, "Hardtop", nil, "" ),
				-- ^ Titus ZJ Hardtop
				VehicleBuyMenuEntry( 91, 0, "Softtop", nil, "" ),
				-- ^ Titus ZJ Softtop
				VehicleBuyMenuEntry( 91, 0, "Cab", nil, "" ),
				-- ^ Titus ZJ Opentop
				VehicleBuyMenuEntry( 35, 0, nil, nil, "" ),
				-- ^ Garret Traver-Z
				VehicleBuyMenuEntry( 35, 500, "FullyUpgraded", nil, "" ),
				-- ^ Garret Traver-Z Armed
			},
			
			["Мотоциклы"] = {
				VehicleBuyMenuEntry( 9, 0 ),
				-- ^ Tuk-Tuk Rickshaw
				VehicleBuyMenuEntry( 22, 0 ),
				-- ^ Tuk-Tuk Laa
				VehicleBuyMenuEntry( 47, 0 ),
				-- ^ Schulz Virginia
				VehicleBuyMenuEntry( 83, 0 ),
				-- ^ Mosca 125 Performance
				VehicleBuyMenuEntry( 32, 0 ),
				-- ^ Mosca 2000
				VehicleBuyMenuEntry( 90, 0 ),
				-- ^ Makota MZ250
				VehicleBuyMenuEntry( 61, 0 ),
				-- ^ Makota MZ 260X
				VehicleBuyMenuEntry( 89, 0 ),
				-- ^ Hamaya Y250S
				VehicleBuyMenuEntry( 43, 0 ),
				-- ^ Hamaya GSY650
				VehicleBuyMenuEntry( 74, 0 ),
				-- ^ Hamaya 1300 Elite Cruiser
				VehicleBuyMenuEntry( 21, 0 ),
				-- ^ Hamaya Cougar 600
				VehicleBuyMenuEntry( 36, 0, "Sport", nil, "" ),
				-- ^ Shimuzu Tracline 
				VehicleBuyMenuEntry( 36, 0, "Gimp", nil, "" ),
				-- ^ Shimuzu Tracline RollCage
				VehicleBuyMenuEntry( 36, 0, "Civil", nil, "" ),
				-- ^ Shimuzu Tracline Racks
				VehicleBuyMenuEntry( 11, 0, "Police", nil, "" ),
				-- ^ Shimuzu Tracline Windshield
			},

			["Джипы"] = {
				VehicleBuyMenuEntry( 48, 0, "Buggy", nil, "" ),
				-- ^ Maddox FVA 45
				VehicleBuyMenuEntry( 48, 100, "BuggyMG", nil, "" ),
				-- ^ Maddox FVA 45 Mounted Gun
				VehicleBuyMenuEntry( 87, 0, "Hardtop", nil, "" ),
				-- ^ Wilforce Trekstar Hardtop
				VehicleBuyMenuEntry( 87, 0, "Softtop", nil, "" ),
				-- ^ Wilforce Trekstar Softtop
				VehicleBuyMenuEntry( 87, 0, "Cab", nil, "" ),
				-- ^ Wilforce Trekstar Opentop
				VehicleBuyMenuEntry( 52, 0, nil, nil, "" ),
				-- ^ Sass PP12 Hogg
				VehicleBuyMenuEntry( 10, 0, "Ingame", nil, "Karl Blaine's" ),
				-- ^ Sass PP12 Hogg (Karl Blaine's)
				VehicleBuyMenuEntry( 46, 0, nil, nil, "" ),
				-- ^ MV V880
				VehicleBuyMenuEntry( 46, 0, "Cab", nil, "" ),
				-- ^ MV V880 Opentop
				VehicleBuyMenuEntry( 46, 0, "Combi", nil, "" ),
				-- ^ MV V880 Loaded with Gear
				VehicleBuyMenuEntry( 46, 0, "CombiMG", nil, "" ),
				-- ^ MV V880 Loaded with Gear, Mounted Gun
				VehicleBuyMenuEntry( 72, 100, nil, nil, "" ),
				-- ^ Chepachet PVD
				VehicleBuyMenuEntry( 84, 100, "HardtopMG", nil, "" ),
				-- ^ Marten Storm III Mounted Gun
				VehicleBuyMenuEntry( 84, 0, "Cab", nil, "" ),
				-- ^ Marten Storm III Opentop Truckbed
				VehicleBuyMenuEntry( 77, 0, "Default", nil, ""),
				-- ^ Hedge Wildchild
				VehicleBuyMenuEntry( 77, 500, nil, nil, ""),
				-- ^ Hedge Wildchild
				VehicleBuyMenuEntry( 77, 1000, "Armed", nil, "" ),
				-- ^ Hedge Wildchild Rockets
			},

			["Пикапы"] = {
				VehicleBuyMenuEntry( 60, 0, nil, nil, "" ),
				-- ^ Vaultier Patrolman
				VehicleBuyMenuEntry( 26, 0, nil, nil, "" ),
				-- ^ Chevalier Traveller SD
				VehicleBuyMenuEntry( 73, 0, nil, nil, "" ),
				-- ^ Chevalier Express HT
				VehicleBuyMenuEntry( 23, 0, nil, nil, "" ),
				-- ^ Chevalier Liner SB
				VehicleBuyMenuEntry( 63, 0, nil, nil, "" ),	
				-- ^ Chevalier Traveller SC
				VehicleBuyMenuEntry( 68, 0, nil, nil, "" ),				
				-- ^ Chevalier Traveller SX
				VehicleBuyMenuEntry( 33, 0, nil, nil, "" ),
				-- ^ Chevalier Piazza IX
				VehicleBuyMenuEntry( 86, 0, nil, nil, "" ),
				-- ^ Dalton N90
				VehicleBuyMenuEntry( 7, 0, "Default", nil, "" ),
				-- ^ Poloma Renegade
				VehicleBuyMenuEntry( 7, 500, "Armed", nil, "" ),
				-- ^ Poloma Renegade
				VehicleBuyMenuEntry( 7, 1000, "FullyUpgraded", nil, "" ),
				-- ^ Poloma Renegade Rockets
			},

			["Автобусы"] = {
				VehicleBuyMenuEntry( 66, 0, "Single", nil, "" ),
				-- ^ Dinggong 134D Single-Decker
				VehicleBuyMenuEntry( 66, 0, "Double", nil, "" ),
				-- ^ Dinggong 134D Double-Decker
				VehicleBuyMenuEntry( 12, 0 ),
				-- ^ Vanderbildt LeisureLiner
			},

			["Тяжи"] = {
				VehicleBuyMenuEntry( 42, 0, nil, nil, "" ),
				-- ^ Niseco Tusker P246
				VehicleBuyMenuEntry( 49, 0, nil, nil, "" ),
				-- ^ Niseco Tusker D18
				VehicleBuyMenuEntry( 71, 0, nil, nil, "" ),
				-- ^ Niseco Tusker G216
				VehicleBuyMenuEntry( 41, 0, nil, nil, "" ),
				-- ^ Niseco Tusker D22
				VehicleBuyMenuEntry( 4, 0, nil, nil, "" ),
				-- ^ Kenwall Heavy Rescue
				VehicleBuyMenuEntry( 79, 0, nil, nil, "" ),
				-- ^ Pocumtruck Nomad			
				VehicleBuyMenuEntry( 40, 0, "Regular", nil, "" ),
				-- ^ Fengding EC14FD2 Longbed
				VehicleBuyMenuEntry( 40, 0, "Crane", nil, "" ),
				-- ^ Fengding EC14FD2 Crane
				VehicleBuyMenuEntry( 40, 0, "Crate", nil, "" ),
				-- ^ Fengding EC14FD2 Shortbed
				VehicleBuyMenuEntry( 31, 0, nil, nil, "" ),
				-- ^ URGA-9380 Tow Cables
				VehicleBuyMenuEntry( 31, 0, "Cab", nil, "" ),
				-- ^ URGA-9380 Empty
				VehicleBuyMenuEntry( 31, 100, "MG", nil, "" ),
				-- ^ URGA-9380 Mounted Gun
				VehicleBuyMenuEntry( 76, 0, nil, nil, "" ),
				-- ^ SAAS PP30 Ox
				VehicleBuyMenuEntry( 18, 100, nil, nil, "" ),
				-- ^ SV-1003 Raider Mounted Gun
				VehicleBuyMenuEntry( 18, 100, "Russian", nil, "" ),
				-- ^ SV-1003 Raider Russin Minigun & Guard
				VehicleBuyMenuEntry( 18, 700, "Cannon", nil, "" ),
				-- ^ SV-1007 Stonewall
				VehicleBuyMenuEntry( 56, 0, "Cab", nil, "" ),
				-- ^ GV-104 Razorback UnArmed
				VehicleBuyMenuEntry( 56, 100, "Armed", nil, "" ),
				-- ^ GV-104 Razorback Minigun
				VehicleBuyMenuEntry( 56, 700, nil, nil, "" ),
				-- ^ GV-104 Razorback Base with Autocannon
				VehicleBuyMenuEntry( 56, 1000, "FullyUpgraded", nil, "" ),
				-- ^ GV-104 Razorback with Autocannon & Machine Guns
			},

			["Трактора"] = {
				VehicleBuyMenuEntry( 1, 0, "Modern_Cab", nil, "" ),
				-- ^ Dongtai Agriboss 35 Modern Open Cab
				VehicleBuyMenuEntry( 1, 0, "Modern_Hardtop", nil, "" ),
				-- ^ Dongtai Agriboss 35 Modern Closed Cab
				VehicleBuyMenuEntry( 1, 0, "Classic_Cab", nil, "" ),
				-- ^ Dongtai Agriboss 35 Old Style Open Cab
				VehicleBuyMenuEntry( 1, 0, "Classic_Hardtop", nil, "" ),
				-- ^ Dongtai Agriboss 35 Old Style Closed Cab
			},

			["Вертолёты"] = {
				VehicleBuyMenuEntry( 3, 0, nil, nil, "" ),
				-- ^ Rowlinson K22
				VehicleBuyMenuEntry( 3, 500, "FullyUpgraded", nil, "" ),
				-- ^ Rowlinson K22 Armed
				VehicleBuyMenuEntry( 14, 0, nil, nil, "" ),
				-- ^ Mullen Skeeter Eagle
				VehicleBuyMenuEntry( 67, 0, nil, nil, "" ),
				-- ^ Mullen Skeeter Hawk
				VehicleBuyMenuEntry( 37, 500 ),
				-- ^ Sivirkin 15 Havoc
				VehicleBuyMenuEntry( 57, 500, "Mission", nil, "" ),
				-- ^ Sivirkin 15 Havoc
				VehicleBuyMenuEntry( 57, 1000, "FullyUpgraded", nil, "" ),
				-- ^ Sivirkin 15 Havoc Rockets
				VehicleBuyMenuEntry( 64, 1000, nil, nil, "" ),
				-- ^ AH-33 Topachula
				VehicleBuyMenuEntry( 65, 0, nil, nil, "" ),
				-- ^ H-62 Quapaw
				VehicleBuyMenuEntry( 62, 0, "UnArmed", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, 600, "Armed", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, 0, "Cutscene", nil, "", 1 ),
				-- ^ UH-10 Chippewa (4 Seater)
				VehicleBuyMenuEntry( 62, 1200, "Dome", nil, "" ),
				-- ^ UH-10 Chippewa (4 Seater) Rockets
			},
			
			["Самолёты"] = {
				VehicleBuyMenuEntry( 59, 0, nil, nil, "" ),
				-- ^ Peek Airhawk 225
				VehicleBuyMenuEntry( 81, 0, nil, nil, "" ),
				-- ^ Pell Silverbolt 6
				VehicleBuyMenuEntry( 51, 0, nil, nil, "" ),
				-- ^ Cassius 192
				VehicleBuyMenuEntry( 30, 500, nil, nil, "" ),
				-- ^ Si-47 Leopard
				VehicleBuyMenuEntry( 34, 700, nil, nil, "" ),
				-- ^ G9 Eclipse
				VehicleBuyMenuEntry( 39, 0, nil, nil, "" ),
				-- ^ Aeroliner 474
				VehicleBuyMenuEntry( 85, 50, nil, nil, "" ),
				-- ^ Bering I-86DP
			},
			
			["Лодки"] = {
				VehicleBuyMenuEntry( 38, 0, "Djonk01", nil, "" ),
				-- ^ Kuang Sunrise
				VehicleBuyMenuEntry( 38, 0, "Djonk02", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 38, 0, "Djonk03", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 38, 0, "Djonk04", nil, "" ),
				-- ^ Kuang Sunrise 
				VehicleBuyMenuEntry( 5, 0, "Cab", nil, "" ),
				-- ^ Pattani Gluay Empty
				VehicleBuyMenuEntry( 5, 0, "Softtop", nil, "" ),
				-- ^ Pattani Gluay Touring (6 Seater)
				VehicleBuyMenuEntry( 5, 0, "Fishing", nil, "" ),
				-- ^ Pattani Gluay Fishing
				VehicleBuyMenuEntry( 6, 0 ),
				-- ^ Orque Grandois 21TT
				VehicleBuyMenuEntry( 19, 0 ),
				-- ^ Orque Living 42T
				VehicleBuyMenuEntry( 45, 0 ),
				-- ^ Orque Bon Ton 71FT
				VehicleBuyMenuEntry( 16, 100 ),
				-- ^ YP-107 Phoenix
				VehicleBuyMenuEntry( 25, 0, "Softtop", nil, "" ),
				-- ^ Trat Tang-mo Cargo
				VehicleBuyMenuEntry( 25, 0, "Cab", nil, "" ),
				-- ^ Trat Tang-mo Empty
				VehicleBuyMenuEntry( 28, 0 ),
				-- ^ TextE Charteu 52CT
				VehicleBuyMenuEntry( 50, 0 ),
				-- ^ Zhejiang 6903
				VehicleBuyMenuEntry( 80, 0 ),
				-- ^ Frisco Catshark S-38
				VehicleBuyMenuEntry( 27, 0 ),
				-- ^ SnakeHead T20
				VehicleBuyMenuEntry( 88, 0, "Default" ),
				-- ^ MTA Powerrun 77
				VehicleBuyMenuEntry( 88, 500, nil, nil, "" ),
				-- ^ MTA Powerrun 77 Armed
				VehicleBuyMenuEntry( 88, 1000, "FullyUpgraded", nil, "" ),
				-- ^ MTA Powerrun 77 Rockets
				VehicleBuyMenuEntry( 69, 100, nil, nil, "" ),
				VehicleBuyMenuEntry( 69, 100, "Roaches", nil, "" ),
			},
			
			["DLC"] = {
				VehicleBuyMenuEntry( 75, 0, nil, nil, "" ),
				-- ^ Tuk Tuk Boom Boom
				VehicleBuyMenuEntry( 58, 0, nil, nil, "" ),
				-- ^ Chevalier Classic
				VehicleBuyMenuEntry( 82, 0, "Мороженка", nil, "" ),
				-- ^ Chevalier Ice Breaker
				VehicleBuyMenuEntry( 20, 0, nil, nil, "" ),
				-- ^ Monster Truck
				VehicleBuyMenuEntry( 53, 0 ),
				-- ^ Agency Hovercraft
				VehicleBuyMenuEntry( 24, 0 ),
				-- ^ F-33 DragonFly
			}
        },

        [self.types["Оружие"]] = {
            { "Правая рука", "Левая рука" , "Основное" },
            ["Правая рука"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 50, 1, "Пузырьковая Пушка" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 100, 1, "Пистолет" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 100, 1, "Револьвер" ),
                WeaponBuyMenuEntry( Weapon.SMG, 300, 1, "СМГ" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 450, 1, "Пилотный Дробовик" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 500, 1, "Гранатомет" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 500, 1, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 0, 1, "DLC - Личное оружие Рико" ),
            },

            ["Левая рука"] = {
				WeaponBuyMenuEntry( Weapon.BubbleGun, 50, 0, "Пузырьковая Пушка" ),
                WeaponBuyMenuEntry( Weapon.Handgun, 100, 0, "Пистолет" ),
                WeaponBuyMenuEntry( Weapon.Revolver, 100, 0, "Револьвер" ),
                WeaponBuyMenuEntry( Weapon.SMG, 300, 0, "СМГ" ),
                WeaponBuyMenuEntry( Weapon.SawnOffShotgun, 450, 0, "Пилотный Дробовик" ),
				WeaponBuyMenuEntry( Weapon.GrenadeLauncher, 500, 0, "Гранатомет" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 500, 0, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.SignatureGun, 0, 0, "DLC - Личное оружие Рико" ),
            },
			
            ["Основное"] = {
				WeaponBuyMenuEntry( Weapon.Assault, 1000, 2, "Штурмовая Винтовка" ),
				WeaponBuyMenuEntry( Weapon.Shotgun, 800, 2, "Дробовик" ),
				WeaponBuyMenuEntry( Weapon.MachineGun, 1000, 2, "Пулемет" ),
				WeaponBuyMenuEntry( Weapon.Sniper, 700, 2, "Снайперская Винтовка" ),
				WeaponBuyMenuEntry( Weapon.RocketLauncher, 1000, 2, "Ракетная Установка" ),
				WeaponBuyMenuEntry( Weapon.Airzooka, 0, 2, "DLC - Воздушное силовое ружье" ),
				WeaponBuyMenuEntry( Weapon.ClusterBombLauncher, 0, 2, "DLC - Кластерный бомбомет" ),
				WeaponBuyMenuEntry( Weapon.MultiTargetRocketLauncher, 0, 2, "DLC - Залповая ракетная установка" ),
				WeaponBuyMenuEntry( Weapon.QuadRocketLauncher, 0, 2, "DLC - Счетвернный гранатомет" ),
				WeaponBuyMenuEntry( Weapon.AlphaDLCWeapon, 0, 2, "DLC - Штурмовая винтовка 'В яблочко'" ),
			}
        },

        [self.types["Персонаж"]] = {
            { "Мальчики", "Девочки", "Тараканы", "Улары", "Жнецы", "Правительство", "Агентство", "Прочее", "*VIP*" },
            ["Мальчики"] = {
				ModelBuyMenuEntry( 54, 0, "Русский телохранитель" ),
                ModelBuyMenuEntry( 96, 0, "Японский телохранитель" ),
				ModelBuyMenuEntry( 6, 0, "Китайский телохранитель" ),
                ModelBuyMenuEntry( 80, 0, "Прохожий 1" ),
                ModelBuyMenuEntry( 93, 0, "Прохожий 2" ),
				ModelBuyMenuEntry( 7, 0, "Прохожий 3" ),
				ModelBuyMenuEntry( 10, 0, "Прохожий 4" ),
				ModelBuyMenuEntry( 13, 0, "Прохожий 5" ),
				ModelBuyMenuEntry( 24, 0, "Прохожий 6" ),
				ModelBuyMenuEntry( 28, 0, "Прохожий 7" ),
				ModelBuyMenuEntry( 29, 0, "Прохожий 8" ),
				ModelBuyMenuEntry( 35, 0, "Прохожий 9" ),
				ModelBuyMenuEntry( 56, 0, "Прохожий 10" ),
				ModelBuyMenuEntry( 68, 0, "Прохожий 11" ),
				ModelBuyMenuEntry( 73, 0, "Прохожий 12" ),
				ModelBuyMenuEntry( 75, 0, "Прохожий 13" ),
				ModelBuyMenuEntry( 76, 0, "Прохожий 14" ),
				ModelBuyMenuEntry( 88, 0, "Прохожий 15" ),
				ModelBuyMenuEntry( 91, 0, "Прохожий 16" ),
				ModelBuyMenuEntry( 99, 0, "Прохожий 17" ),
                ModelBuyMenuEntry( 15, 0, "Стриптизер 1" ),
                ModelBuyMenuEntry( 17, 0, "Стриптизер 2" ),
                ModelBuyMenuEntry( 1, 0, "Бандит 1" ),
                ModelBuyMenuEntry( 39, 0, "Бандит 2" ),
				ModelBuyMenuEntry( 78, 0, "Босс Бандит" ),
				ModelBuyMenuEntry( 50, 0, "Нефтяной работник" ),
				ModelBuyMenuEntry( 57, 0, "Нефтяной работник 2" ),
				ModelBuyMenuEntry( 89, 0, "Фабричный рабочий" ),
                ModelBuyMenuEntry( 40, 0, "Фабричный босс" ),
            },

            ["Девочки"] = {
				ModelBuyMenuEntry( 14, 0, "Прохожая 1" ),
				ModelBuyMenuEntry( 31, 0, "Прохожая 2" ),
				ModelBuyMenuEntry( 41, 0, "Прохожая 3" ),
				ModelBuyMenuEntry( 46, 0, "Прохожая 4" ),
				ModelBuyMenuEntry( 47, 0, "Прохожая 5" ),
				ModelBuyMenuEntry( 62, 0, "Прохожая 6" ),
				ModelBuyMenuEntry( 72, 0, "Прохожая 7" ),
				ModelBuyMenuEntry( 82, 0, "Прохожая 8" ),
				ModelBuyMenuEntry( 92, 0, "Прохожая 9" ),
				ModelBuyMenuEntry( 102, 0, "Прохожая 10" ),
				ModelBuyMenuEntry( 60, 0, "Девушка" ),
				ModelBuyMenuEntry( 86, 0, "Стриптизёрша" ),
            },

            ["Тараканы"] = {
                ModelBuyMenuEntry( 2, 0, "Мутант (Разак Разман)" ),
                ModelBuyMenuEntry( 5, 0, "Элита" ),
                ModelBuyMenuEntry( 32, 0, "Техник" ),
                ModelBuyMenuEntry( 85, 0, "Солдат 1" ),
                ModelBuyMenuEntry( 59, 0, "Солдат 2" )
            },

            ["Улары"] = {
                ModelBuyMenuEntry( 38, 0, "Шри Ираван" ),
                ModelBuyMenuEntry( 87, 0, "Элита" ),
                ModelBuyMenuEntry( 22, 0, "Техник" ),
                ModelBuyMenuEntry( 27, 0, "Солдат 1" ),
                ModelBuyMenuEntry( 103, 0, "Солдат 2" )
            },

            ["Жнецы"] = {
                ModelBuyMenuEntry( 90, 0, "Боло Сантоси" ),
                ModelBuyMenuEntry( 63, 0, "Элита" ),
                ModelBuyMenuEntry( 8, 0, "Техник" ),
                ModelBuyMenuEntry( 12, 0, "Солдат 1" ),
                ModelBuyMenuEntry( 58, 0, "Солдат 2" ),
            },

            ["Правительство"] = {
                ModelBuyMenuEntry( 74, 0, "Малыш Панай" ),
                ModelBuyMenuEntry( 67, 0, "Сгоревший Малыш Панай" ),
                ModelBuyMenuEntry( 101, 0, "Полковник" ),
                ModelBuyMenuEntry( 3, 0, "Демо-эксперт" ),
                ModelBuyMenuEntry( 98, 0, "Пилот" ),
                ModelBuyMenuEntry( 42, 0, "Черная Рука" ),
                ModelBuyMenuEntry( 44, 0, "Ниндзя" ),
				ModelBuyMenuEntry( 49, 0, "Правительственный Капитан" ),
                ModelBuyMenuEntry( 23, 0, "Ученый" ),
                ModelBuyMenuEntry( 52, 0, "Солдат 1" ),
                ModelBuyMenuEntry( 66, 0, "Солдат 2" ) 
            },

            ["Агентство"] = {
                ModelBuyMenuEntry( 9, 0, "Карл Блейн" ),
                ModelBuyMenuEntry( 65, 0, "Джейд Тан" ),
                ModelBuyMenuEntry( 25, 0, "Мария Кейн" ),
                ModelBuyMenuEntry( 30, 0, "Маршалл" ),
                ModelBuyMenuEntry( 34, 0, "Том Шелдон" ),
                ModelBuyMenuEntry( 100, 0, "Дилер Черного рынка" ),
                ModelBuyMenuEntry( 83, 0, "Белый Тигр" ),
                ModelBuyMenuEntry( 51, 0, "Рико Родригес" )
            },

            ["Прочее"] = {
                ModelBuyMenuEntry( 70, 0, "Генерал Масайо" ),
                ModelBuyMenuEntry( 11, 0, "Чжан Сунь" ),
                ModelBuyMenuEntry( 84, 0, "Александр Мириков" ),
                ModelBuyMenuEntry( 19, 0, "Китайский Бизнесмен" ),
                ModelBuyMenuEntry( 36, 0, "Политик" ),
                ModelBuyMenuEntry( 71, 0, "Сауль Сукарно" ),
                ModelBuyMenuEntry( 79, 0, "Японский Ветеран" ),
                ModelBuyMenuEntry( 16, 0, "Полиция Панау" ),
                ModelBuyMenuEntry( 64, 0, "Бом Бом Бохилано" ),
				ModelBuyMenuEntry( 55, 0, "Дед" ),
                ModelBuyMenuEntry( 61, 0, "Солдат" ),
				ModelBuyMenuEntry( 18, 0, "Хакер" ),
                ModelBuyMenuEntry( 26, 0, "Лодочный Капитан" ),
                ModelBuyMenuEntry( 21, 0, "Папарацци" ),
				ModelBuyMenuEntry( 33, 0, "Азартный игрок" ),
				ModelBuyMenuEntry( 45, 0, "Официант" ),
				ModelBuyMenuEntry( 48, 0, "Швейцар" ),
				ModelBuyMenuEntry( 69, 0, "Свидетель" ),
            },

            ["*VIP*"] = {
                ModelBuyMenuEntry( 20, 0, "Невидимка", 1 )
            }
        },

        [self.types["Внешность"]] = {
            { "Головные Уборы", "Колпаки и Шлемы", "Платки", "Волосы", "Лицо", "Шея", "Принадлежности" },

            ["Головные Уборы"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Head", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female2.eez/pd_arcticvillage_female_2-hat_winter.lod", 0, "Head", "Арктическая Льняная Шляпа" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_male2.eez/pd_arcticvillage_male_2-hat_winter.lod", 0, "Head", "Арктическая Льняная Шляпа - Большая" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_linen.lod", 0, "Head", "Льняная Шляпа - Белая" ),
				AppearanceBuyMenuEntry( "pd_generic_male_3.eez/pd_generic_male_3-hat_linen.lod", 0, "Head", "Льняная Шляпа - Пятна" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_linen.lod", 0, "Head", "Льняная Шляпа - Черная Полоса" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_linen.lod", 0, "Head", "Льняная Шляпа - Большая Темная Полоса" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_linen.lod", 0, "Head", "Льняная Шляпа - Белая Полоса" ),
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_cloth.lod", 0, "Head", "Льняная Шляпа - Чёрный и Белый" ),
				AppearanceBuyMenuEntry( "pd_fishervillage_male1.eez/pd_fishervillage_male-hat_fisherman.lod", 0, "Head", "Рыболовная Шляпа" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_fisherman.lod", 0, "Head", "Рыболовная Шляпа - Маленькая" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-fisherhat.lod", 0, "Head", "Fishing Floppy Hat Slanted" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_fisherman.lod", 0, "Head", "Рыболовная Шляпа - Маленькая" ),
				AppearanceBuyMenuEntry( "pd_fishervillage_male1.eez/pd_fishervillage_male-ricehat.lod", 0, "Head", "Worker Ricehat Big - Загар" ),
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_straw2.lod", 0, "Head", "Worker Ricehat - Загар" ),
				AppearanceBuyMenuEntry( "pd_generic_female.eez/generic_female-ricehat.lod", 0, "Head", "Worker Ricehat Level - Бежевый" ),
				AppearanceBuyMenuEntry( "pd_generic_female_3.eez/pd_generic_female_3-hat_straw2.lod", 0, "Head", "Worker Ricehat - Бежевый" ),
				AppearanceBuyMenuEntry( "pd_generic_female_1.eez/pd_generic_female_1-hat_rice.lod", 0, "Head", "Рабочая Соломенная Шляпа" ),
				AppearanceBuyMenuEntry( "pd_generic_male_1.eez/pd_generic_male_1-hat_rice.lod", 0, "Head", "Рабочая Соломенная Шляпа - Большая" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_rice.lod", 0, "Head", "Рабочая Соломенная Шляпа - Желтый" ), 
				AppearanceBuyMenuEntry( "pd_generic_male.eez/pd_generic_male-hat.lod", 0, "Head", "Рабочая Соломенная Шляпа - Светлая" ),
				AppearanceBuyMenuEntry( "pd_thugs1.eez/pd_thugs-h_bandana.lod", 0, "Head", "Бандана Череп - Серый" ),
				AppearanceBuyMenuEntry( "pd_ms_doorman.eez/pd_doorman-h_bandana.lod", 0, "Head", "Бандана Череп - Изношенный Серый" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_fedora.lod", 0, "Head", "Федора - Светло-Серый" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male1.eez/pd_ms_stripper_male-hat.lod", 0, "Head", "Федора - Наклоненный" ),
				AppearanceBuyMenuEntry( "pd_ms_thugboss.eez/pd_executioner-h_felthat.lod", 0, "Head", "Felt Федора - Наклоненный Серый" ),
				AppearanceBuyMenuEntry( "pd_roacheselite1.eez/pd_roaches_elite-h_headwear.lod", 0, "Head", "Тараканы - Элитный Турбан" ),
				AppearanceBuyMenuEntry( "pd_generic_female_2.eez/pd_generic_female_2-hat_towel.lod", 0, "Head", "Ткань Турбан" ),
            },
			
            ["Колпаки и Шлемы"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Head", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-keps.lod", 0, "Head", "Keppy Шляпа" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_male1.eez/pd_arcticvillage_male-hat.lod", 0, "Head", "Артикул Шляпа" ),
				AppearanceBuyMenuEntry( "pd_generic_male_2.eez/pd_generic_male_2-hat_weird.lod", 0, "Head", "Древняя Корона" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male2.eez/pd_ms_stripper_male-cowboyhat.lod", 0, "Head", "Ковбойская Шляпа" ),
				AppearanceBuyMenuEntry( "pd_oilplatform_male1.eez/pd_oilplatform-greycap.lod", 0, "Head", "Масляный Рабочий Шапочка - Серый" ),
				AppearanceBuyMenuEntry( "pd_oilplatform_male1.eez/pd_oilplatform-helmet.lod", 0, "Head", "Буровой Рабочий, Каска - Жётый" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-ht_militarycap.lod", 0, "Head", "Военный Командир" ),
				AppearanceBuyMenuEntry( "pd_reaperselite1.eez/pd_reapers_elite_male-cap.lod", 0, "Head", "Элитная Крышка Жнецов" ),
				AppearanceBuyMenuEntry( "pd_ms_japaneseveterans.eez/pd_ms_japaneseveterans-hat.lod", 0, "Head", "Японская Крышка" ),
				AppearanceBuyMenuEntry( "pd_ms_japaneseveterans.eez/pd_ms_japaneseveterans-helmet.lod", 0, "Head", "Японский Шлем" ),
				AppearanceBuyMenuEntry( "pd_gov_base01.eez/pd_gov_base-hat.lod", 0, "Head", "Шляпа Полиции Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-cap.lod", 0, "Head", "Полицейский Колпачок Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-helmet.lod", 0, "Head", "Полицейский Шлем Панау" ),
				AppearanceBuyMenuEntry( "pd_panaupolice.eez/panaupolice-turban.lod", 0, "Head", "Полиция Панау Турбан" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-helmet.lod", 0, "Head", "Элитный Шлем Правительства" ),
				AppearanceBuyMenuEntry( "pd_gov_base01.eez/pd_gov_base-beret.lod", 0, "Head", "Правительственная Элита Берет" ),
				AppearanceBuyMenuEntry( "pd_reaperselite1.eez/pd_reapers_elite_male-beret.lod", 0, "Head", "Жнецы - Элитный Берет" ),
				AppearanceBuyMenuEntry( "pd_roacheselite1.eez/pd_roaches_elite-h_bandana.lod", 0, "Head", "Тараканы - Элитный Берет" ),
            },
			
            ["Платки"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Covering", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth.lod", 0, "Covering", "Headcloth - Black" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female1.eez/pd_arcticvillage_female-headcloth2.lod", 0, "Covering", "Headcloth - White & Dark" ),
				AppearanceBuyMenuEntry( "pd_desertvillage_female1.eez/pd_desertvillage_female-shawl.lod", 0, "Covering", "Headcloth - White" ), 
				AppearanceBuyMenuEntry( "pd_desertvillage_male1.eez/pd_desertvillage_male-turban.lod", 0, "Covering", "Headcloth & Turban" ),
				AppearanceBuyMenuEntry( "pd_generic_female.eez/generic_female-shawl.lod", 0, "Covering", "Headcloth Beige" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_3.eez/pd_generic_female_3-hat_scarf.lod", 0, "Covering", "Bonnet - Light" ), 
				AppearanceBuyMenuEntry( "pd_generic_female_5.eez/pd_generic_female_5-hat_scarf.lod", 0, "Covering", "Bonnet - Dark" ),
            },

            ["Волосы"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Hair", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_tourist_female2.eez/pd_tourist_female-h_hair.lod", 0, "Hair", "Средний - Чёрный" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-h_hair1.lod", 0, "Hair", "Средний - Серый" ),
				AppearanceBuyMenuEntry( "pd_arcticvillage_female_lod1-dress_col.pfx", 0, "Hair", "Короткий - Оранжевый" ),
            },

            ["Лицо"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Face", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_female1.eez/pd_stripper_female-a_sunglasses.lod", 0, "Face", "Круглые Солнцезащитные Очки" ),
				AppearanceBuyMenuEntry( "pd_ularboyselite1.eez/pd_ularboys_elite_male-glasses.lod", 0, "Face", "Непрозрачные Солнцезащитные Очки - Тёмные" ),
				AppearanceBuyMenuEntry( "pd_blackhand.eez/pd_blackhand-glasses.lod", 0, "Face", "Непрозрачные Солнцезащитные Очки - Светлые" ),
				AppearanceBuyMenuEntry( "pd_ms_scientist_male.eez/pd_ms_scientists-glasses.lod", 0, "Face", "Прозрачные Очки Для Ученых" ),
				AppearanceBuyMenuEntry( "pd_thugs1.eez/pd_thugs-o_glasses.lod", 0, "Face", "Широкие Солнцезащитные Очки" ),
				AppearanceBuyMenuEntry( "pd_tourist_male1.eez/pd_tourist_male-sunglasses.lod", 0, "Face", "Темные Туристические Солнцезащитные Очки" ),
            },

            ["Шея"] = {
				AppearanceBuyMenuEntry( "Neck", 0, "Neck", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ms_civ_strippers_male2.eez/pd_civilian_stripper_male-cowboyscarf.lod", 0, "Neck", "Красный Шарф" ),
				AppearanceBuyMenuEntry( "pd_ms_strippers_male2.eez/pd_ms_stripper_male-cowboyscarf.lod", 0, "Neck", "Ковбойский Шарф" ),
				AppearanceBuyMenuEntry( "pd_blackmarket.eez/pd_blackmarket-scarf.lod", 0, "Neck", "Чёрнокнижковый Шарф" ),
            },

            ["Принадлежности"] = {
				AppearanceBuyMenuEntry( "Clear", 0, "Back", "ОЧИСТИТЬ" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-backpack.lod", 0, "Back", "Рюкзак" ),
				AppearanceBuyMenuEntry( "pd_gov_base02.eez/pd_gov_base-bags.lod", 0, "Back", "Рюкзак для Спецодежды" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest1.lod", 0, "Back", "Баллистический Жилет 1" ),
				AppearanceBuyMenuEntry( "pd_gov_elite.eez/pd_govnewfix_elite-vest2.lod", 0, "Back", "Баллистический Жилет 2" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-ammopouch.lod", 0, "Back", "Боеприпасы" ),
				AppearanceBuyMenuEntry( "pd_ularboysbase1.eez/pd_ularboys_base_male-waterbottle.lod", 0, "Back", "Военная Бутылка Воды" ),
			}
        },

        [self.types["Остальное >"]] = {
            { "Парашюты" },

			["Парашюты"] = {
				ParachutesBuyMenuEntry( "parachute00.pickup.execute", 0, "Обычный парашют" ),
				ParachutesBuyMenuEntry( "parachute01.pickup.execute", 0, "DLC - Парашют с двигателями" ),
				ParachutesBuyMenuEntry( "parachute02.pickup.execute", 0, "DLC - Парашют Сорвиголовы" ),
				ParachutesBuyMenuEntry( "parachute03.pickup.execute", 0, "DLC - Парашют Хаоса" ),
				ParachutesBuyMenuEntry( "parachute04.pickup.execute", 0, "DLC - Камуфляжный парашют" ),
				ParachutesBuyMenuEntry( "parachute05.pickup.execute", 0, "DLC - Тигровый парашют" ),
				ParachutesBuyMenuEntry( "parachute06.pickup.execute", 0, "DLC - Парашют с скорпионом" ),
				ParachutesBuyMenuEntry( "parachute07.pickup.execute", 0, "DLC - Огненный парашют" ),
			}
        }
    }
end