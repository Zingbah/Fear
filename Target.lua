
FearTarget = {
	info={
		program = Fear.info.program,
		name = "Target",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
--#### Local Variables and Functions
local info = FearTarget.info.name..", "..FearTarget.info.version

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables
FearTarget.last_known_hostile = false
FearTarget.entity_list = {friendly = {}, hostile = {}}
FearTarget.search_radius = 300
FearTarget.heal_radius = 150
FearTarget.dps_radius = 100
FearTarget.friendly_entity_string = nil
FearTarget.hostile_entity_string = nil
FearTarget.dots = {}
FearTarget.rating = {
	-- 0 = lowest to 1 = highest
	friend = {tank = .8, heal = .6, damage = .5},
	enemy  = {tank = .4, heal = .8, damage = .6},	
}


--##############################################################
-- Functions
function FearTarget.OnInitialize()

	FearTarget.CreateFriendlyEntityString()
	FearTarget.CreateHostileEntityString()

	verbose(info.." loaded succesfully")
end

function FearTarget.Check()
	
	
end

function FearTarget.Friendly()
	   	-- Create a support target list based on player's priorities
    local group_data = FearPlayer.group_data
    local entity_list = EntityList(FearTarget.friendly_entity_string)
    table.sort(entity_list, FearTarget.SortByHealth)
   
    if table.maxn(entity_list) > 0 then
        for GUID,entity in pairs(entity_list) do
            if entity.healthPercent < Fear.ENV.HEALTHTHRESHOLD.heal then
            	if not FearTarget.last_known_friendly or (entity.name ~= FearTarget.last_known_friendly.name and entity.healthPercent ~= FearTarget.last_known_friendly.healthPercent) then
            		FearTarget.last_known_friendly = entity
					addToLog("Friendly Low Health: "..tostring(FearTarget.last_known_friendly.name).." ["..FearTarget.last_known_friendly.healthPercent.."]")
				end
                if #FearPlayer.group_info > 0 then
                    for _,group_player in pairs(FearPlayer.group_info) do
                        if string.find(tostring(entity.name), tostring(group_player.name)) then
                            if Fear.ENV.SUPPORTMODE == "group" then
                                if group_player.group == FearPlayer.group then
                                    entity.inGroup = true
                                    entity.inWarband = true
                                    table.insert(FearTarget.entity_list.friendly, entity)
                                end
                            end
                        end
                    end
                end
            end
        end
    end	
end



function FearTarget.IsDead(entity)
	if entity.healthPercent <= 0 then
		return true
	end
	return false
end

function FearTarget.HasLowHealth(guid, threshold)
	local low_health = false
	local entiity = GetEntity(guid)
	
	if entity.healthPercent == threshold then
		low_health = true
	end
	
	return low_health
end

function FearTarget.SetDotTimer(GUID,ability,elapsed_time)
	addToDebug(GUID.." "..ability.id.." "..elapsed_time)
	if FearTarget.dots[GUID] == nil then
		FearTarget.dots[GUID] = {}
	end
	FearTarget.dots[GUID][ability.id] = elapsed_time
end

function FearTarget.HasDots(GUID,ability)
	if FearTarget.GetEffectTime(ability.id) <= 0 then
		return false
	else
		if FearTarget.dots[GUID] ~= nil and FearTarget.dots[GUID][ability.id] ~= nil then
			if FearTarget.dots[GUID][ability.id] ~= 0 then
				return true
			end
		end
	end
	return false
end

function FearTarget.CreateFriendlyEntityString()
	entity_str ="friendly,"
	
	if Fear.ENV.SUPPORTMODE ~= "dps" then
		entity_str = entity_str .. "player,"
	end
	if Fear.ENV.TARGETINGMODE.npc then
		entity_str = entity_str .. "npc,"
	end
	if not Fear.ENV.LOS then
		entity_str = entity_str .. "los,"
	end
	if FearPlayer.can_resurrect then
		entity_str =  entity_str .. "dead,"
	end	
	if FearPlayer.heal_radius then
		entity_str =  entity_str .. "maxdistance="..heal_radius
	else
		entity_str =  entity_str .. "maxdistance=150"
	end	
	
	FearTarget.friendly_entity_string = entity_str

	return true	
end

function FearTarget.FriendlyEntities()
	if FearTarget.friendly_entity_string then
		if EntityList(FearTarget.friendly_entity_string) then
			return true
		end
	end
	addToDebug("FearTarget.friendly_entity_string is nil!")
	return false
end

function FearTarget.CreateHostileEntityString()
	entity_str ="hostile,alive,"
	
	if Fear.ENV.SUPPORTMODE ~= "dps" then
		entity_str = entity_str .. "player,"
	end
	if Fear.ENV.TARGETINGMODE.npc then
		entity_str = entity_str .. "npc,"
	end
	if not Fear.ENV.LOS then
		entity_str = entity_str .. "los,"
	end
	if FearPlayer.heal_radius then
		entity_str =  entity_str .. "maxdistance="..dps_radius
	else
		entity_str =  entity_str .. "maxdistance=100"
	end	
	
	FearTarget.hostile_entity_string = entity_str
	
	return true	
end	

function FearTarget.HostileEntities()
	if FearTarget.hostile_entity_string then
		if EntityList(FearTarget.hostile_entity_string) then
			return true
		end
	end
	addToDebug("FearTarget.hostile_entity_string is nil!")
	return false
end

function FearTarget.IsTargettingMe(GUID)
	local TargetsOnMe = EntityList("targetingme")

	for i, Details in pairs (EntityList("targetingme")) do
		if i == GUID then
			return true
		end
	end
	return false
end

function FearTarget.InGroup(entity)
    if entity.TargetType == 3 then 
    	if GroupWindow.IsPlayerInGroup(entity.name) then
        	return true
		end
    end
    return false
end

function FearTarget.InWarband(entity)
	if FearPlayer.InScenario() then
		if FearTarget.IsScenarioMember(entity.name) == true then
			return true
		else
			return false
		end
	end

	local warband_data = PartyUtils.GetWarbandData()
	local name = tostring(entity.name)

    if warband_data[1].players[1] == nil then
		return false
	else
	    for group_index = 4,1,-1 do
			local group_size = #warband_data[group_index].players
			for member_index = 1,6 do
				if member_index <= group_size then
					local member_data = warband_data[group_index].players[member_index]
					if not member_data then return false end
					local this = tostring(member_data.name)
					if string.find(name, this) then
						return true
					end
				end
			end
		end
    end
	return false
end

function FearTarget.IsScenarioMember(entity)
	local group_data = GameData.GetScenarioPlayers()
	local name = tostring(entity.name)

    if not group_data then return false end

	for id, details in pairs (group_data) do
		local this = tostring(group_data[id].name)
		if string.find(name, this) then
			return true
		end
	end
	return false
end

function FearTarget.GetDistance(pos_a, pos_b)
	local delta_x = pos_a.x - pos_b.x
	local delta_y = pos_a.y - pos_b.y
	local distance = math.sqrt(math.abs(delta_x) ^ 2 + math.abs(delta_y) ^ 2)
	return distance
end


function FearTarget.SortByHealth(table1, table2 )
    if(table1 == nil or table2 == nil) then return false end

    if(table1.healthPercent == nil or table2.healthPercent == nil ) then
        addToDebug("FearTarget.SortByHealth may only be used on tables containing 'healthPercent' variables.")
        return false
    end

    if(table1.healthPercent == 0) then return false end
	if(table2.healthPercent == 0) then return true end

    return (table1.healthPercent < table2.healthPercent)
end

function FearTarget.SortByDistance( table1, table2 )
    if(table1 == nil or table2 == nil) then return false end

    if(table1.distance == nil or table2.distance == nil) then
        addToDebug("Fear.SortByHealth may only be used on tables containing 'distance' variables.")
        return false
    end

    if(table1.distance == 0) then return false end
    if(table2.distance == 0) then return true end

    return (table1.distance < table2.distance)
end
