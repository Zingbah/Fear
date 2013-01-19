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
FearPlayer.CONDITIONS = {
    heal    = "isHealing",
    dbuf    = "isDebuff",
    buf     = "isBuff",
    def     = "isDefensive",
    off     = "isOffensive",
    dam     = "isDamaging",
    sbuf    = "isStatsBuff",
    hex     = "isHex",
    cur     = "isCurse",
    crip    = "isCripple",
    ail     = "isAilment",
    bols    = "isBolster",
    aug     = "isAugmentation",
    bless   = "isBlessing",
    ench    = "isEnchantment",
    unst    = "isUnstoppable",
    imm     = "isImmovable",
    sna     = "isSnared",
    roo     = "isRooted",
    det     = "isDetaunted",
    mou     = "isMounted"
}
FearPlayer.position = {current = GetPlayerPosition(), track = {x=0,y=0,z=0}}
FearPlayer.cast_timer = {current = 0, old = L"0.0s"}
FearPlayer.GUID = nil
FearPlayer.name = string.sub(WStringToString(GameData.Player.name), 1, -3)
FearPlayer.group_data = nil
FearPlayer.can_resurrect = false
FearPlayer.can_heal = false
FearPlayer.in_group = false
FearPlayer.is_moving = false
FearPlayer.is_casting = false
FearPlayer.in_scenario = false
FearPlayer.in_warband = false
FearPlayer.group_info = {}
FearPlayer.group = nil
FearPlayer.cast_pause = 0
FearPlayer.cast_time = 0
FearPlayer.last_cast = nil
FearPlayer.equipment_data = {}
FearPlayer.cast_pause = 0


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
		FearPlayer.position.current.x = x
		FearPlayer.position.current.y= y
	end
end

function FearPlayer.isMoving()
	if FearPlayer.position.track.x == FearPlayer.position.current.x and FearPlayer.position.track.y == FearPlayer.position.current.y then
		if FearPlayer.is_moving then 
			addToLog("Player stopped")
		end
		FearPlayer.is_moving = false
	else
		if not FearPlayer.is_moving then
			addToLog("Player is moving")
		end
		FearPlayer.position.track = GetPlayerPosition()
		FearPlayer.is_moving = true
	end
end

function FearPlayer.OnBeginCast(abilityId, isChannel, desiredCastTime, averageLatency)
	if Fear.ENV.ENABLED then
		local abilityData = GetAbilityData(abilityId)
		FearPlayer.last_cast = abilityData

	    addToLog(L"Player is casting "..abilityData.name)
	    FearPlayer.is_casting = true
	end
end

function FearPlayer.Cast(ability, target)	
	if FearAbility.IsReady(ability) then
		local tGUID = target.GUID --issues??
		local aID = ability.id --issues??
		addToLog(tostring(ability.name)..": "..tostring(target.name))		

		addToLog("Cast2")
		if tGUID  and aID  then
			addToLog("Spell Cast")
			Target(tGUID)
			Cast(aID)
		end
	end
	return true
end

function FearPlayer.DecCastPause()
	FearPlayer.cast_pause = FearPlayer.cast_pause - 1
	if FearPlayer.cast_pause < 0 then
		FearPlayer.cast_pause = 0
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
			Cast(FearPlayer.last_cast.id)
			addToLog("Cast Interupted")
	    else
		    if FearPlayer.is_casting then
		    	--addToLog("Player end cast")
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

function FearPlayer.IsRVR() -- WORKING
    return GameData.Player.rvrZoneFlagged
end

function FearPlayer.InCombat()
    return GameData.Player.inCombat
end

function FearPlayer.InAParty()
    return GetNumGroupmates() > 0
end

function FearPlayer.InWarBand()
    return IsWarBandActive()
end

function FearPlayer.inScenario()
    return GameData.Player.isInScenario
end

function FearPlayer.HasActionPoints(value) 
    return GameData.Player.actionPoints.current >= value
end

function FearPlayer.Level()
	return GameData.Player.level
end

function FearPlayer.SetSpeed(speed)
	if speed then
		SetSpeed(speed)
	else
		SetSpeed(1)
	end
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
			FearPlayer.UseHealthPotion()
		end
    else
        return false
	end
    return true
end

function FearPlayer.UseHealthPotion()
	local potion = {[208211] = "Lesser Potion of Healing",}
end

function FearPlayer.CanHeal() --WORKING
	if FearCareer.db[GameData.Player.career.line].arch.heal then
		FearPlayer.can_heal = true
		return true
	else
		return false
	end
end

function FearPlayer.CanResurrect()
	if FearCareer.db[GameData.Player.career.line].arch.heal then
		for k,v in pairs(FearAbility.resurrect_ability) do

			if FearCareer.modules[FearCareer.module_loaded].abilities[k] then
				FearPlayer.can_resurrect = true
				return true
			end
		end
	 end 
	 return false
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
