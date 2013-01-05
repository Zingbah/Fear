FearCareer = {
	info={
		program = Fear.info.program,
		name = "Career",
		version = 0.1,
		author = "Zingbah"
	}
}

--############################################################## 
-- Local Variables and Functions
local info = FearCareer.info.name..", "..FearCareer.info.version

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end
--##############################################################
-- Variables

FearCareer.modules_loaded = false
FearCareer.custom_modules = {}
FearCareer.modules = {}
FearCareer.module_names = {}
FearCareer.db = {
		[GameData.CareerLine.IRON_BREAKER] 	=  {name = "Iron Breaker", 				arch = {tank=true, close=true, weapon=true}},
		[GameData.CareerLine.BLACKGUARD] 	=  {name = "Blackguard", 				arch = {tank=true, close=true, weapon=true}}, 
		[GameData.CareerLine.SWORDMASTER]	=  {name = "Swordmaster", 				arch = {tank=true, close=true, weapon=true}},
		[GameData.CareerLine.BLACK_ORC] 	=  {name = "Black Orc", 				arch = {tank=true, close=true, weapon=true}}, 
		[GameData.CareerLine.KNIGHT] 		=  {name = "Knight of the Blazing Sun",	arch = {tank=true, close=true, weapon=true}}, 
		[GameData.CareerLine.CHOSEN] 		=  {name = "Chosen", 					arch = {tank=true, close=true, weapon=true}},
		[GameData.CareerLine.WITCH_HUNTER] 	=  {name = "Witch Hunter", 				arch = {damage=true, close=true, weapon=true}},
		[GameData.CareerLine.WITCH_ELF] 	=  {name = "Witch Elf", 				arch = {damage=true, close=true, weapon=true}},
		[GameData.CareerLine.WHITE_LION] 	=  {name = "White Lion", 				arch = {damage=true, close=true, weapon=true}}, 
		[GameData.CareerLine.MARAUDER] 		=  {name = "Marauder", 					arch = {damage=true, close=true, weapon=true}}, 
		[GameData.CareerLine.SLAYER] 		=  {name = "Slayer", 					arch = {damage=true, close=true, weapon=true}}, 
		[GameData.CareerLine.CHOPPA] 		=  {name = "Choppa", 					arch = {damage=true, close=true, weapon=true}},
		[GameData.CareerLine.ENGINEER] 		=  {name = "Engineer", 					arch = {damage=true, ranged=true, weapon=true}},
		[GameData.CareerLine.SHADOW_WARRIOR]=  {name = "Shadow Warrior", 			arch = {damage=true, ranged=true, weapon=true}},
		[GameData.CareerLine.SQUIG_HERDER] 	=  {name = "Squig Herder", 				arch = {damage=true, ranged=true, weapon=true}},
		[GameData.CareerLine.BRIGHT_WIZARD] =  {name = "Bright Wizard", 			arch = {damage=true, ranged=true, magic=true}},
		[GameData.CareerLine.SORCERER] 		=  {name = "Sorcerer", 					arch = {damage=true, ranged=true, magic=true}},
		[GameData.CareerLine.MAGUS] 		=  {name = "Magus", 					arch = {damage=true, ranged=true, magic=true}},
		[GameData.CareerLine.ARCHMAGE] 		=  {name = "Archmage", 					arch = {heal=true, range=true, magic=true}},
		[GameData.CareerLine.SHAMAN] 		=  {name = "Shaman", 					arch = {heal=true, range=true, magic=true}},
		[GameData.CareerLine.RUNE_PRIEST] 	=  {name = "Rune Priest",  				arch = {heal=true, range=true, magic=true}},
		[GameData.CareerLine.ZEALOT] 		=  {name = "Zealot", 					arch = {heal=true, range=true, magic=true}},
		[GameData.CareerLine.WARRIOR_PRIEST]=  {name = "Warrior Priest", 			arch = {heal=true, close=true, magic=true}},
		[GameData.CareerLine.DISCIPLE]		=  {name = "Disciple of Khane", 		arch = {heal=true, close=true, magic=true}},
}
FearCareer.name = FearCareer.db[GameData.Player.career.line].name
FearCareer.resurrect_abilities = {
	697,		-- Alter Fate
	1598,		-- Rune Of Life
	1619,		-- Grimnir's Fury
	1908,		-- Gedup!
	8248,		-- Breath Of Sigmar
	8555,		-- Tzeentch Shall Remake You
	9246,		-- Gift Of Life
	14526,		-- Rally
}
FearCareer.support_mechanic = {
	8237,		-- Supplication
	9561,		-- Blood Offering (need to confirm ID)
	
}
--##############################################################
-- Functions

function FearCareer.OnInitialize()
	verbose(info.." loaded succesfully")
end

function FearCareer.LoadModules() -- Loads and career ability FearTarget. into the ability class
--[[
	local custom_modules = {}

	for mod_k,mod_v in pairs(FearCareer.custom_modules) do
		local player_level = FearPlayer.Level()
		local reindexed_abilities = {}
		local no_rank = 1000
		local merged_abilities = TableMerge(FearAbility.storage.abilities, mod_v.abilities)
		custom_modules[mod_k] = mod_v
		
        -- Rank Abilities
		for ability_id, ability in pairs(merged_abilities) do
            if ability.rank ~= nil then
                reindexed_abilities[ability.rank] = ability
            else
                reindexed_abilities[no_rank] = ability  
                no_rank = no_rank + 1
            end
		end
					
		custom_modules[mod_k].abilities = reindexed_abilities
		custom_modules[mod_k].mergedStatus = true
		
		FearCareer.module_names[mod_k] = {}
		FearCareer.module_names[mod_k].name = tostring(mod_v.name.. " - " ..mod_v.description)
	end
	
	FearCareer.modules = custom_modules
	FearCareer.modules_loaded = true

	return true
--]]
end

function FearCareer.IsSupport()
	local is_support = false
	if FearCareer.db[GameData.Player.career.line].arch.heal then
		is_support = true
	end
	return is_support
end

function NerfedAPI.hasMechanic(needed_mechanic_value)
    needed_mechanic_value = tonumber(needed_mechanic_value)
    local current_mechanic_value = tonumber(GetCareerResource( GameData.BuffTargetType.SELF ))
        
    -- archmage and shaman
    if GameData.Player.career.line == 20 or GameData.Player.career.line == 7 then
        if needed_mechanic_value > 0 then
            -- AM: tranquility test
            needed_mechanic_value = needed_mechanic_value +5
            if current_mechanic_value >= needed_mechanic_value then
                return true
            end
        else
            -- AM: force test
            needed_mechanic_value = needed_mechanic_value*-1
            if current_mechanic_value <= 5 and current_mechanic_value >= needed_mechanic_value then
                return true
            end
        end
    -- zealot and runepriest
    elseif GameData.Player.career.line == 15 or GameData.Player.career.line == 3 then
    	return NerfedEngine.getRunepriestZealotMechanic() == needed_mechanic_value
    else    
        -- other careers
        if current_mechanic_value >= needed_mechanic_value then
            return true
        end
    end
    return false
end
