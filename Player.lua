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

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables
FearPlayer.position = {
	current_x = 0,
	current_y = 0,
	last_x = 0,
	last_y = 0,
}
FearPlayer.guid = 0
FearPlayer.name = GameData.Player.name
FearPlayer.can_heal = nil
FearPlayer.group_data = nil
FearPlayer.can_resurrect = false
FearPlayer.is_casting = false
FearPlayer.in_group = false
FearPlayer.is_moving = false
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
	verbose(FearPlayer.info.name..", "..FearPlayer.info.version.." loaded succesfully")
end

function FearPlayer.OnZoneChange()
	FearPlayer.GUID = GetPlayer().GUID
end

function FearPlayer.OnMove(x, y)
    FearPlayer.position.current_x = x
    FearPlayer.position.current_y = y
end

function FearPlayer.OnBeginCast(abilityId, isChannel, desiredCastTime, averageLatency)
    addToLog("Player is casting")    
	FearAbility.is_casting = true
end

function FearPlayer.OnCastSetback(new_cast_time)
    if STAYONCAST and FearPlayer.cast_time ~= 0 then
        FearPlayer.cast_time = new_cast_time
    end
	addToLog("Cast interupted")
end

function FearPlayer.OnEndCast(interupt)
    if interupt and FearPlayer.is_casting then
		FearPlayer.Cast(FearPlayer.last_cast)
    end
    
    addToLog("Player end cast")
    FearPlayer.is_casting = false
    CastTime = 0
end

function FearPlayer.OnGroupUpdate()
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

function FearPlayer.IsRVR()
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

function FearPlayer.HeathCheck()
	local player = GetPlayer()
    
	--Try to heal or potion player is below threshold
	if player.health < HEALTHTHRESHOLD.health then
		if FearPlayer.can_heal and (ability.apCost < player.actionPoints) then

		elseif FearPlayer.can_heal and (ability.apCost > player.actionPoints) then
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

function FearPlayer.PotionCheck()
	return false
end

function FearPlayer.UseHealthPotion()
	
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
