FearAbility = {
    info ={
        program = Fear.info.program,
        name = "Ability",
        version = 0.1,
        author = "Zingbah"
    }
}

--##############################################################
-- Local Variables and Functions

local info = FearAbility.info.name..", "..FearAbility.info.version
local last_morale_ability_cast  = -1
local non_abilities = {245, 0, 8237}

local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables

FearAbility.current_ability = nil
FearAbility.storage = {abilities, items}
FearAbility.cast_time = 0

--##############################################################
-- Functions

function FearAbility.OnInitialize()
    verbose(info.. " loaded succesfully")
end

function FearAbility.Check(ability_type)
    for rank,ability in OrderedPairs(FearAbility.storage.abilities) do
        if FearAbility.IsReady(ability) then
            
        end
    end
end

function FearAbility.IsReady(ability)
    if ability and IsAbilityEnabled(ability.id) and not FearAbility.OnCooldown(ability) then
        return true
    else
        return false
    end 
end

function FearAbility.OnCooldown(ability)
    changeHotbar(hotbar_test_slot, ability.id)
    local cooldown = GetHotbarCooldown(hotbar_test_slot)    
    local global_cooldown = GetGCD()

    return cooldown and (cooldown > global_cooldown + 0.1)
end

function FearAbility.IsUseful(ability)
    local is_useful = true
    
    for _,non_ability in pairs(non_abilities) do
        if non_ability.id == ability.id then
            is_useful = false
        end
    end
end

function FearAbility.IsAbility(ability)
    if ability.actionType then return true end
    return false
end

function FearAbility.IsItem(item)
    if item.actionType then return true end
    return false
end

function FearAbility.RequiresGroupMember(ability)
    if ability.id == nil or ability.id == 0 then
        return false
    end

    local rst = {}
    rst[1], rst[2], rst[3] = ability.tooltip.English.requirements
    local name = "group"

    for i = 1,3,1 do
        if rst[i] ~= nil and rst[i] ~= L"" then
            local this = tostring(rst[i])
            if string.find(name, this) then
                return true
            end
        end
    end
    return false
end

--##############################################################
-- Abilities parser code modified from WarCache

function FearAbility.GetObjectDetails(obj, objName, targetDepth, previousDepth)
    local contents = ""
    local currentDepth = previousDepth + 1

    if type(obj) == "table" and (targetDepth == 0 or targetDepth >= currentDepth) then 

        if temporary_object_list[tostring(obj)] then
            return "Endless Loop detected on object ["..tostring(objName).."]\n"
        else
            temporary_object_list[tostring(obj)] = true
        end

        for k, a in pairs(obj) do
            contents = contents..FearAbility.GetObjectDetails(a, tostring(objName).."."..tostring(k), targetDepth, currentDepth)
        end
    else
        contents = tostring(objName).." = "
        if type(obj) == "wstring" then
            contents = contents.."\""..tostring(obj).."\"\n"
        else
            contents = contents..tostring(obj).."\n"
        end
    end
    return contents
end

function FearAbility.GetAbilityCastTimeText (abilityData)
    if (abilityData.numTacticSlots > 0)
    then
        return GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_PASSIVE_CAST)
    end
    
    local castTime = GetAbilityCastTime (abilityData.id)
    
    if (castTime > 0) 
    then
        local _, castTimeFraction = math.modf (castTime)
        local params = nil
        
        if (castTimeFraction ~= 0)
        then
            params = { wstring.format( L"%.1f", castTime) }
        else
            params = { wstring.format( L"%d", castTime) }
        end
            
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_CAST_TIME, params))
    end    
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_INSTANT_CAST))
end

function FearAbility.GetAbilityCostText (abilityData)
    if (abilityData.moraleLevel ~= 0) 
    then    
        local params = { abilityData.moraleLevel }
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_MORALE_COST, params))
    elseif (abilityData.numTacticSlots ~= 0) 
    then
        local params = { abilityData.numTacticSlots, Tooltips.TacticsTypeStrings[abilityData.tacticType] }
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_TACTIC_COST, params))
    else
        local apCost = GetAbilityActionPointCost (abilityData.id)
        
        if (apCost > 0)
        then
            local params = { apCost }
            
            if (abilityData.hasAPCostPerSecond)
            then
                return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_AP_COST_PER_SECOND, params))
            else
                return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_ACTION_POINT_COST, params))
            end
        end
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_COST))
end

-- takes ability data and returns the range as a string
function FearAbility.GetAbilityRangeText (abilityData)
    local labelText = GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_RANGE)
    local minRange, maxRange = GetAbilityRanges (abilityData.id)
    
    local fConstFootToMeter = 0.3048
    local bUseInternationalSystemUnit = SystemData.Territory.KOREA    
    
    if ((minRange > 0) and (maxRange > 0))
    then
        local stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MIN_RANGE_TO_MAX_RANGE
        if bUseInternationalSystemUnit
        then
            minRange = string.format( "%d", minRange * fConstFootToMeter + 0.5 )
            maxRange = string.format( "%d", maxRange * fConstFootToMeter + 0.5 )
            stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE_METERS
        end
        local params = { minRange, maxRange }
        labelText = GetStringFormat (stringID, params)  
    elseif (maxRange > 0) 
    then
        local stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MAX_RANGE
        if bUseInternationalSystemUnit
        then
            maxRange = string.format( "%d", maxRange * fConstFootToMeter + 0.5 )
            stringID = StringTables.Default.LABEL_ABILITY_TOOLTIP_MAX_RANGE_METERS
        end
        local params = { maxRange }
        labelText = GetStringFormat (stringID, params)
    end
    
    return (labelText)
end

function FearAbility.GetAbilityLevelText (abilityData)
    local upgradeRank = GetAbilityUpgradeRank (abilityData.id)
    
    if (upgradeRank > 0)
    then
        return (GetStringFormat (StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_RANK, {upgradeRank}))
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_NO_RANK))
end

function FearAbility.GetAbilityCooldownText( cooldown )
    if ( cooldown > 0 ) 
    then
        -- For abilities with cooldowns under a min, we care about the first decimal.
        -- For instance some abilities have a 1.5 sec cooldown
        local timeText
        if( cooldown < 60 )
        then
            timeText = TimeUtils.FormatRoundedSeconds( cooldown, 0.1, true, false )
        else
            timeText = TimeUtils.FormatSeconds( cooldown, true )
        end
        return ( GetStringFormat( StringTables.Default.LABEL_ABILITY_TOOLTIP_COOLDOWN, { timeText } ) )
    end
    
    return (GetString (StringTables.Default.LABEL_ABILITY_TOOLTIP_NO_COOLDOWN))
end

function FearAbility.Reset()
    FearAbility.Storage.abilities = {}
    FearAbility.Storage.items = {}
end

function FearAbility.Collect()

    local language = Fear.language  
    local extracted_abilities = {}
    local current_ability_data = TableMerge(GetAbilityTable(GameData.AbilityType.STANDARD), GetAbilityTable(GameData.AbilityType.MORALE)) 
    local no_rank = 5000
    local rank = 0
    current_ability_data = TableMerge(current_ability_data, FearCareer.modules[MODULESELECT].abilities)
    addToLog("Updating abilities")

    -- extract the data
    for key,data in pairs(current_ability_data) do
        local db_index = 0
        local db_name = tostring(data.name)

        -- get the abilityId and remove from the array
        local abilityId = key -- the actual unique id of the ability
        
        -- temporary store for the ability data as we flatten the structure
        local abilityData = data
       
        local _,maxrange = GetAbilityRanges(abilityId) --since 1.3.6 there's no need for minrange
        abilityData.range = maxrange
        abilityData.apCost = GetAbilityActionPointCost(abilityId)
        abilityData.casttime = GetAbilityCastTime(abilityId)
        
        -- rounding of timers
        abilityData.reuseTimer = math.floor(data.reuseTimer) -- remove the useless microseconds
        abilityData.reuseTimerMax = math.floor(data.reuseTimerMax)
        abilityData.cooldown = math.floor(data.cooldown)
        
        -- add career
        abilityData.careername = GameData.Player.career.name
        
        -- tooptip display
        abilityData.tooltip = {}
        abilityData.tooltip[language] = {}
        abilityData.tooltip[language].name = GetStringFormat(StringTables.Default.LABEL_ABILITY_TOOLTIP_ABILITY_NAME, {data.name})
        abilityData.tooltip[language].description = GetAbilityDesc (abilityId, FearPlayer.Level())
        abilityData.tooltip[language].specline = DataUtils.GetAbilitySpecLine (data)
        abilityData.tooltip[language].cost = FearAbility.GetAbilityCostText (data)
        abilityData.tooltip[language].casttime = FearAbility.GetAbilityCastTimeText (data)
        abilityData.tooltip[language].type = DataUtils.GetAbilityTypeText (data)
        abilityData.tooltip[language].level = FearAbility.GetAbilityLevelText (data)
        abilityData.tooltip[language].range = FearAbility.GetAbilityRangeText (data)

        local realCooldown = GetAbilityCooldown(abilityId) / 1000
        abilityData.tooltip[language].cooldown = FearAbility.GetAbilityCooldownText( realCooldown ) 
        local reqs = {}
        reqs[1], reqs[2], reqs[3] = GetAbilityRequirements (abilityId) 
        abilityData.tooltip[language].requirements = reqs
        
        -- remove useless values
        abilityData.key=nil
        abilityData.advanceIcon=nil
        abilityData.advanceID=nil
        abilityData.advanceName=nil
        abilityData.advanceValue=nil
        abilityData.packageId=nil
        abilityData.requiredActionCounterID=nil
        abilityData.abilityInfo=nil

        -- Rank index
        if abilityData.rank then
            rank = abilityData.rank
        else 
            rank = no_rank
            no_rank = no_rank + 1
        end

        table.insert(extracted_abilities, rank, abilityData)
    end

    FearAbility.storage.abilities = extracted_abilities --TableMerge(current_ability_data, extracted_abilities)

    return extracted_abilities        
     
    
    -- store data in persistant cache
    --
    
    -- gather metadata, like careerstats for additional calculations like statcontribution
    --metaData = {}
    --metaData.Language = {}
    --metaData.Language.id = SystemData.Settings.Language.active
    --metaData.Language.name = Languages[metaData.Language.id]
    
    --metaData.Player = {}
    --metaData.Player.STRENGTH = GetBonus(GameData.BonusTypes.EBONUS_STRENGTH,GameData.Player.Stats[GameData.Stats.STRENGTH].baseValue)
    --metaData.Player.BALLISTIC = GetBonus(GameData.BonusTypes.EBONUS_BALLISTICSKILL,GameData.Player.Stats[GameData.Stats.BALLISTICSKILL].baseValue)
    --metaData.Player.INTELLIGENCE = GetBonus(GameData.BonusTypes.EBONUS_INTELLIGENCE,GameData.Player.Stats[GameData.Stats.INTELLIGENCE].baseValue)
    --metaData.Player.WILLPOWER = GetBonus(GameData.BonusTypes.EBONUS_WILLPOWER,GameData.Player.Stats[GameData.Stats.WILLPOWER].baseValue)
    
    --FearAbility.Storage.abilities[string.gsub(tostring(GameData.Player.career.name), " ", "_")].meta = metaData
    
    
end

