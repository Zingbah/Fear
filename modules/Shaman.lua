FearShaman = {
	info={
		program = Fear.info.program,
		name = "Shaman ability",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
--#### Local Variables and Functions
local info = FearShaman.info.name..", "..FearShaman.info.version

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables



--##############################################################
-- Functions

FearShaman.career_module = {
	id = "shaman-default",
	career = GameData.CareerLine.SHAMAN,
	name = "Shaman Healer",
	description = "Healing focused.",
	max_level = 11,
	abilities = {
		[1910]  = {id = 1910,  name = "Mork's Buffer", 					rank = 20},
		[1932]  = {id = 1932,  name = "Don' Feel Nuthin", 				rank = 5, isShield=true, maxHealth = 35, minHealth = 0},
		
		[1904]  = {id = 1904,  name = "Bigger, Better, An' Greener",	rank = 10, maxHealth = 75, minHealth = 20,},
		[1901]  = {id = 1901,  name = "Ey, Quit Bleedin", 				rank = 13, maxHealth = 85, minHealth = 0,},
		[1898]  = {id = 1898,  name = "Gork'll Fix It", 				rank = 15, maxHealth = 95, minHealth = 0,},
		[1908]  = {id = 1908,  name = "Gedup!", 						rank = 8,},
		
		[1912]  = {id = 1912,  name = "Bleed Fer' Me", 					rank = 17, maxHealth = 95, minHealth = 0,},
		[1930]  = {id = 1930,  name = "I'll Take That!", 				rank = 19, maxHealth = 95, minHealth = 0,},

		[1900]  = {id = 1900,  name = "Life Leaka", 					rank = 52,},
		[1903]  = {id = 1903,  name = "Bunch o' Waaagh", 				rank = 50,},
		[1899]  = {id = 1899,  name = "Brain Bursta", 					rank = 60,},
	},
}

function FearShaman.OnInitialize()
	if (GameData.Player.career.line == GameData.CareerLine.SHAMAN)  then
		table.insert(FearCareer.modules, FearShaman.career_module)
		say(info.." loaded successfully")
		addToLog(info.." is complete up to level " .. FearShaman.career_module.max_level)
	else
		verbose(info.." is disabled")
	end
end

