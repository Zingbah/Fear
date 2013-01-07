FearPlayer = {
	info={
		program = Fear.info.program,
		name = "Player",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
--#### Local Variables and Functions

local info = FearPlayer.info.name..", "..FearPlayer.info.version
local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables
FearPlayer.position = {current = GetPlayerPosition(), old = {x = 0, y = 0, z = 0,}}
FearPlayer.cast_timer = {current = 0, old = L"0.0s"}
FearPlayer.guid = 0
FearPlayer.name = GameData.Player.name
FearPlayer.group_data = nil
FearPlayer.can_resurrect = false
FearPlayer.is_casting = false
FearPlayer.in_group = false
FearPlayer.is_moving = true
FearPlayer.in_scenario = false
FearPlayer.in_warband = false
FearPlayer.group_info = {}
FearPlayer.group = nil
FearPlayer.cast_pause = 0
FearPlayer.cast_time = 0
FearPlayer.last_cast = nil
FearPlayer.equipment_data = {}

--##############################################################
-- Functions

function FearPlayer.OnInitialize()
	return true
end

function FearPlayer.OnZoneChange()
	if Fear.ENV.ENABLED then
		FearPlayer.GUID = GetPlayer().GUID
	end
end

function FearPlayer.OnMove(x, y) 
	if Fear.ENV.ENABLED then

	end
end

function FearPlayer.OnBeginCast(abilityId, isChannel, desiredCastTime, averageLatency)
	if Fear.ENV.ENABLED then
		local abilityData = GetAbilityData(abilityId)
	    addToLog(L"Player is casting "..abilityData.name)
	    FearAbility.is_casting = true
	end
end

function FearPlayer.OnCastSetback(new_cast_time)
	if Fear.ENV.ENABLED then
	    if Fear.ENV.STAYONCAST and FearPlayer.cast_time ~= 0 then
	        FearPlayer.cast_time = new_cast_time
	    end
		addToLog("Cast disrupted")
	end
end

function FearPlayer.OnEndCast(interupt)
	if Fear.ENV.ENABLED then
	    if interupt then
	--		FearPlayer.Cast(FearPlayer.last_cast)
			addToLog("Cast Interupted")
	    else
		    if FearAbility.is_casting then
		    	addToLog("Player end cast")
		    end
		end
		FearPlayer.is_casting = false
	end
end

function FearPlayer.OnGroupUpdate()
	if Fear.ENV.ENABLED then
		FearPlayer.in_warband = IsWarBandActive()
		
		if GameData.Player.isInSiege or GameData.Player.isInScenario then
	    	FearPlayer.in_scenario = true
		else
			FearPlayer.in_scenario = false
		end
		
		if GetNumGroupmates() > 0 then
			FearPlayer.in_group = true        
		else
			FearPlayer.in_group = false
		end
		
		if FearPlayer.in_warband or FearPlayer.in_scenario or FearPlayer.in_group then
			FearTarget.group_names = {}
			local group_data = GetGroupData()
			
			for group_number,group_players in pairs(group_data) do
				for _,group_players in pairs(group_player) do
					if string.find(tostring(entity.name), tostring(group_player.name)) then
						if string.find(tostring(FearPlayer.name), tostring(group_player.name)) then
							FearPlayer.group = group_number
						else
							table.insert(FearTarget.group_info, {name = player.name, group = group_number})
						end
					end
				end
			end
			
		else
			FearTarget.group_names = {}
		end
	end
end

function FearPlayer.Cast(ability,GUID)
	if FearAbility.Check(ability,GUID) then
		Cast(ability.id)
		FearPlayer.last_cast = ability
		addToLog("Casting ".. ability.name .." on ".. Target(GUID).name)
		return true
	else
		return false
	end				
end

function FearPlayer.IsRVR() -- WORKING
    return GameData.Player.rvrZoneFlagged
end

function FearPlayer.HasActionPoints(value) 
    return GameData.Player.actionPoints.current >= value
end

function FearPlayer.Level()
	return GameData.Player.level
end

function FearPlayer.GetEquipmentData()
	if CharacterWindow then
        FearPlayer.equipment_data = {
            CharacterWindow.equipmentData,
            DataUtils.GetItems(),
            DataUtils.GetQuestItems()
        }
    else 
        dataTables = {
            DataUtils.GetItems(),
            DataUtils.GetQuestItems()
        }    
    end
end

function FearPlayer.HeathCheck() --Broken
	local player = GetPlayer()
    
	--Try to heal or potion player is below threshold
	if player.health < Fear.ENV.HEALTHTHRESHOLD.heal then
		if FearPlayer.CanHeal() and (ability.apCost < player.actionPoints) then

		elseif FearPlayer.CanHeal() and (ability.apCost > player.actionPoints) then
			if FearPlayer.UseHealthPotion() then
				FearTarget.Friendly(ability)
			end
		end
		FearPlayer.UseHealthPotion()
    else
        return false
	end
    return true
end

function FearPlayer.CanHeal() --WORKING
	if FearCareer.db[GameData.Player.career.line].arch.heal then
		return true
	else
		return false
	end
end

function FearPlayer.CanResurrect(ability)
	for _,resurrect_id in pairs(resurrect_abilities) do
		if ability.id == resurrect_id then
			FearPlayer.can_resurrect = ability.id
		end
	end
end

function FearPlayer.CheckForPlayerAttackers()
	local MyGUID = GetPlayer().GUID
	for GUID , Details in pairs(EntityList("player,hostile,maxdistance=300")) do
		if Details.offtarget == MyGUID then
			return true
		end
	end
	return false
end
