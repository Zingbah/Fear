--[[##############################################################

  FEAR

  An interactive combat and healing system designed for WARExtDLL.
  You drive and let FEAR do the rest.

  AUTHOR:
  Zingbah -- The name by which FEAR is defined...  :-/

  LICENSE:
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  DEPENDENCIES:
   - WarExtDLL by HansW (http://www.mmoelites.com/forum/9-warextdll/)

  CREDITS:
  First off a huge wave of appreciation to HansW! Without WarExtDLL this
  couldn't happen. Please support HansW by becoming a supporter:
	http://www.mmoelites.com/index.php?/topic/71-warextdll-faq/

  Code was blatantly taken and/or modified from many add-on sources for which
  I would like to give credit:

   - Zeabot by PharmerPhale
     http://www.mmoelites.com/topic/15-addon-zeabot/
   - WarCache by NerfedWar
     http://www.nerfedwar.net/addons/warcache/
   - NerfedButtons by NerfedWar
     http://www.nerfedwar.net/addons/nerfedbuttons/
   - Xenon by fxfire
     http://www.mmoelites.com/topic/1496-addon-xenon-bot-067/
]]--
--##############################################################
-- Addon Setup

Fear = {
	info = {
		program = "Fear",
		name = "Main",
		version = 0.1,
		author = "Zingbah",
	}
}

--##############################################################
-- Local Variables and Functions

local FEAR_DELAY = 0.2
local MOVING_THROTTLE = 0.1
local MAP_PATHS_THROTTLE = 1
local timer = 0
local delay_throttle = FEAR_DELAY
local moving_throttle = MOVING_THROTTLE
local fear_init = {
	FearGUI,
	FearPlayer,
	FearCareer,
	FearTarget,
	FearAbility,
	FearShaman, 
}

local environment = {
	"ENABLED", 
	"TARGETINGMODE", 
	"TARGETPREF", 
	"SUPPORTMODE", 
	"HEALTHTHRESHOLD", 
	"SHOWWINDOW", 
	"MODULESELECT", 
	"STAYONCAST", 
	"VERSION",
    "MODULEACTIVE",
	"LOS",
}

local Languages = {
	"English",
	"French",
	"German",
	"Italian",
	"Spanish",
	"Korean",
	"Simple_Chinese",
	"Traditional_Chinese",
	"Japanese",
	"Russian"
}

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables
Fear.status = false
Fear.verbose = true -- Verbose logging in chat window
Fear.debug = true -- Debugging in log window
Fear.language = Languages[SystemData.Settings.Language.active]
Fear.support_mode_options = {"self", "group", "warband", "all"}

-- Environment Default Setup
Fear.ENV = {
	ENABLED = false, -- Turns Fear on or off
	TARGETINGMODE = {player = true, npc = false,},
	TARGETPREF = {health = true, distance = false,},
	SUPPORTMODE = "all",
	HEALTHTHRESHOLD = {heal=85, potion=40},
	SHOWWINDOW = false,
	MODULESELECT = 1,
	STAYONCAST = true,
	VERSION = Fear.info.version,
	MODULEACTIVE = 1,
	LOS = false,
}
--##############################################################
-- Functions

-- Warhammer startup
function Fear.OnInitialize() 

    -- If the WarExtDLL isn't running Fear won't work
	if (WarExtDLLInfo) then 
		local item_count = 0
		local item_total = #fear_init	
		verbose("Starting in VERBOSE mode")
		verbose("Debug info will be written to log")
        verbose("Loading "..item_total.." items")

		-- Initialize required classes
        for _,v in pairs(fear_init) do

            if not v.OnInitialize() then
            	verbose("A Module FAILED to load")
            else
            	verbose( v.info.name..", "..v.info.version.." Loaded successfully")
            	item_count = item_count + 1
            end
        end 

		-- Setup savedVariables
        if Fear.SetupEnvironment() then
            verbose("Environment variables loaded")
        else
        	verbose("ERROR loading Environment variables")
        end
        
	    RegisterEventHandler(SystemData.Events.PLAYER_POSITION_UPDATED, "FearPlayer.OnMove")
		RegisterEventHandler(SystemData.Events.PLAYER_NEW_ABILITY_LEARNED, "Fear.RefreshEnvironment" )
	    RegisterEventHandler(SystemData.Events.PLAYER_ABILITIES_LIST_UPDATED, "Fear.RefreshEnvironment" )
	    RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "FearPlayer.OnBeginCast" )
	    RegisterEventHandler(SystemData.Events.PLAYER_END_CAST, "FearPlayer.OnEndCast" )
	    RegisterEventHandler(SystemData.Events.PLAYER_ZONE_CHANGED, "FearPlayer.OnZoneChange")


--[[		
	    
--	    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "NerfedUtils.doHooks" ) 
		 RegisterEventHandler(SystemData.Events.LOADING_END, "Fear.SetupEnvironment" )


--		


		
		
		RegisterEventHandler(SystemData.Events.GROUP_UPDATED, "FearPlayer.OnGroupUpdate")
	    RegisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "FearPlayer.OnGroupUpdate")
	    RegisterEventHandler(SystemData.Events.SCENARIO_END, "FearPlayer.OnGroupUpdate")
 		RegisterEventHandler(SystemData.Events.CITY_SCENARIO_BEGIN, "FearPlayer.OnGroupUpdate")
		RegisterEventHandler(SystemData.Events.CITY_SCENARIO_END, "FearPlayer.OnGroupUpdate")
	    RegisterEventHandler(SystemData.Events.SCENARIO_GROUP_JOIN, "FearPlayer.OnGroupUpdate")
	    RegisterEventHandler(SystemData.Events.SCENARIO_GROUP_LEAVE, "FearPlayer.OnGroupUpdate")
	    RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED, "FearPlayer.OnGroupUpdate")
--]]	    
		
--	    RegisterEventHandler(SystemData.Events.PLAYER_NEW_PET_ABILITY_LEARNED,  "Fear.RefreshEnvironment" )
--	    RegisterEventHandler(SystemData.Events.PLAYER_INVENTORY_SLOT_UPDATED,   "Fear.SetupEnvironment" )
--	    RegisterEventHandler(SystemData.Events.PLAYER_EQUIPMENT_SLOT_UPDATED,   "Fear.SetupEnvironment" )
	    	
--[[
		RegisterEventHandler(SystemData.Events.LOADING_END,      "NerfedMatchMaking.OnPlayerItemsListUpdated" )    
	    RegisterEventHandler(SystemData.Events.LOADING_END,      "NerfedUtils.doHooks" ) 
	    RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "NerfedUtils.doHooks" ) 
		RegisterEventHandler (SystemData.Events.PLAYER_CUR_HIT_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_MAX_HIT_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_CUR_ACTION_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_MAX_ACTION_POINTS_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_CAREER_RANK_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_MORALE_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")

		RegisterEventHandler (SystemData.Events.PLAYER_COMBAT_FLAG_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_RVR_FLAG_UPDATED, "Enemy.Groups_OnCurrentPlayerUpdated")

		RegisterEventHandler (SystemData.Events.PLAYER_TARGET_UPDATED, "Enemy.Groups_OnPlayerTargetUpdated")
		RegisterEventHandler (SystemData.Events.SHOW_ALERT_TEXT, "Enemy.Groups_OnShowAlertText")

		RegisterEventHandler (SystemData.Events.SCENARIO_BEGIN, "Enemy.GroupsUpdateType")
		RegisterEventHandler (SystemData.Events.SCENARIO_END, "Enemy.GroupsUpdateType")
		RegisterEventHandler (SystemData.Events.SCENARIO_GROUP_JOIN, "Enemy.GroupsUpdateType")
		RegisterEventHandler (SystemData.Events.SCENARIO_GROUP_LEAVE, "Enemy.GroupsUpdateType")

		RegisterEventHandler(SystemData.Events.CITY_SCENARIO_BEGIN, "Enemy.GroupsUpdateType")
		RegisterEventHandler(SystemData.Events.CITY_SCENARIO_END, "Enemy.GroupsUpdateType")

		RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_GROUPS_UPDATED, "Enemy.GroupsUpdate")
		RegisterEventHandler (SystemData.Events.SCENARIO_PLAYERS_LIST_RESERVATIONS_UPDATED, "Enemy.GroupsUpdate")

		RegisterEventHandler (SystemData.Events.SCENARIO_PLAYER_HITS_UPDATED, "Enemy.Groups_OnScenarioPlayerHitsUpdated")

		RegisterEventHandler (SystemData.Events.GROUP_UPDATED, "Enemy.GroupsUpdateType")
		RegisterEventHandler (SystemData.Events.GROUP_PLAYER_ADDED, "Enemy.GroupsUpdate")
		RegisterEventHandler (SystemData.Events.GROUP_STATUS_UPDATED, "Enemy.Groups_OnGroupStatusUpdated")

		RegisterEventHandler (SystemData.Events.BATTLEGROUP_UPDATED, "Enemy.GroupsUpdateType")
		RegisterEventHandler (SystemData.Events.BATTLEGROUP_MEMBER_UPDATED, "Enemy.Groups_OnBattlegroupMemberUpdated")

		RegisterEventHandler (SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "Enemy.Groups_OnPlayerTargetEffectsUpdated")
		RegisterEventHandler (SystemData.Events.PLAYER_EFFECTS_UPDATED, "Enemy.Groups_OnCurrentPlayerEffectsUpdated")
		RegisterEventHandler (SystemData.Events.GROUP_EFFECTS_UPDATED, "Enemy.Groups_OnGroupEffectUpdated")

	    
--]]	

		say(Fear.info.program.." is loaded")
		return true
	else
        Fear.ENV.ENABLE = false
		say("WarExtDLL doesn't appear to be injected exiting...")
		return false
	end
end

function Fear.OnUpdate(elapsed) 
	if Fear.ENV.ENABLED then
	 --[[
	    if FearAbility.cast_time > 0 then
	        FearAbility.cast_time = FearAbility.cast_time - elapsed

	        if FearAbility.cast_time <= 0 then
	            FearAbility.cast_time = 0
	            FearAbility.is_casting = false
	        end
	    end
	    
	    delay_throttle = delay_throttle - elapsed

	    if delay_throttle > 0 then
	 --       return -- cut out early
	    end	
	   ]]
		FearTarget.Friendly()
		FearTarget.Hostile()
		FearPlayer.isMoving()
		Fear.Action()
	end
end

function Fear.Action()
	for _,rating in pairs(FearAbility.sorted_keys) do
		ability = FearAbility.storage.abilities[rating]
		Target(FearTarget.last_known_friendly.GUID)
		Target(FearTarget.last_known_hostile.GUID)

		if not FearAbility.is_casting  then
			--addToLog(tostring(ability.name)..": "..rating)		
			if FearTarget.last_known_friendly.GUID then
				Cast(ability.id)
				return true
			end

			if FearTarget.last_known_hostile.GUID  then
				Cast(ability.id)
				return true
			end
		end
	end
	
end

function Fear.OnShutdown() -- Warhammer close events

end

function Fear.Toggle()
	FearGUI.LClick()
end

function Fear.ToggleWindow()
	FearGUI.RClick()
end

function Fear.Test() -- Testing using the Fear window Test button
--	Cast(1898)
	ObjectInspector.ShowWindow()
--	local curCD,maxCD = GetHotbarCooldown(1903)
--	addToLog("curCD="..tostring(curCD).." | maxCD="..tostring(maxCD))
--	ShowPlayer()
--	addToLog("GameData.Player.career.id="..GameData.Player.career.id)
--	ShowAbilityData((14406)
--	addToLog(tostring(GameData.CareerLine.SHAMAN))
--	GetAbilityTable(GameData.AbilityType.STANDARD)
--	ShowAbilityTable(GameData.AbilityType.STANDARD)
--	ShowAbilityTable(GameData.AbilityType.FIRST)
--	ShowAbilityTable(GameData.AbilityType.GRANTED)
--	ShowAbilityTable(GameData.AbilityType.MORALE)
end

function Fear.Say(s)	
    TextLogAddEntry("Chat", SystemData.ChatLogFilters.SAY, towstring("["..Fear.info.program.."] "..s))
end

function Fear.Alert(s)
	AlertTextWindow.AddLine (SystemData.AlertText.Types.ENTERZONE, towstring(s))
end

function Fear.Log(s)
	TextLogAddEntry("FearLog", 1, towstring(s))
end

function Fear.Debug(s)
	if(Fear.debug) then Fear.Log(s) end
end

function Fear.Verbose(s)
	if(Fear.verbose) then Fear.Say(s) end
end

function Fear.TypeCheck(value, check_type, desc)
   types = {n="number", s="string", t="table", b="boolean", f="function",}   
   if desc == nil then desc = "" end
   if (value ~= nil) and (type(value) ~= GetField("types."..check_type)) then 
      addToDebug(tostring(value).."("..type(value)..") does not match "..GetField("types."..check_type).. ": " ..desc) 
   end   
end

function Fear.SetupEnvironment(reset, refresh)
	-- Check for modules
	if #FearCareer.modules < 1 then
        Fear.ENV.ENABLED = false 
        say("No modules for "..FearCareer.name.." exiting...")
        return false
    else
    	Fear.ENV.ENABLED = true
	end
	
    if not Fear.ENV.MODULESELECT then
        Fear.ENV.MODULESELECT = 1
    end

	-- Setup savedVariables	
	if not refresh then
		for n,v in pairs(Fear.ENV) do -- Iterate of dynamic list of savedVariables
			 -- Dynamicly assign savedVariable
		
		    if not saved_variable or reset then              
                SetField(n, v)
			else
                local saved_variable = GetField(v)
			    SetField(v, saved_variable)
            end
		end
		
		if reset then
			verbose("Saved variables reset to default")
		else
			addToLog("Saved variables loaded")
		end		
	end
	
	
	--Identify if player is dps or support and set a default
	if not Fear.ENV.SUPPORTMODE or reset then
		if FearCareer.db[GameData.Player.career.line].arch.heal then
			FearPlayer.can_heal = true
			Fear.ENV.SUPPORTMODE = "all"
		else
			FearPlayer.can_heal = false
			Fear.ENV.SUPPORTMODE = false
		end
	end
	
    -- Load ability cache
    if not FearAbility.storage.abilities or refresh then FearAbility.Collect() end
	-- Create friendy target entity string
	
    -- Get player GUID if required
    if not FearPlayer.GUID then
        FearPlayer.GUID = GetPlayer().GUID
    end
	
	return true
end

function Fear.ResetEnvironment()
	return Fear.SetupEnvironment(true)
end

function Fear.RefreshEnvironment()
	return Fear.SetupEnvironment(false, true)
end
