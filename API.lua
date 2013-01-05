FearAPI = {}



function FearAPI.say(s)
    EA_ChatWindow.Print(towstring(s))
end



--[[
FearAPI.archetypes = {
    -- Basic archetypes
    TANK    = "tank",   -- Tank
    MDPS    = "mdps",   -- Melee DPS
    RPDPS   = "rpdps",  -- Ranged Physical DPS
    RMDPS   = "rmdps",  -- Ranged Magical DPS
    RSUPP   = "rsupp",  -- Ranged Support
    MSUPP   = "msupp",  -- Melee Support
    
    -- Composite archetypes
    MELEE   = "melee",  -- Melee
    CASTER  = "cast",   -- Caster
    DPS     = "dps",    -- DPS
    PDPS    = "pdps",   -- Physical DPS
    RDPS    = "rdps",   -- Ranged DPS
    SUPP    = "supp",   -- Support
    WU      = "wu",     -- Weapon user (MELEE + RPDPS)
    
    -- Other
    NPC     = "npc"
}

local archetype = FearAPI.ARCHETYPE

FearAPI.compositeArchetype = {
    [archetype.TANK]  = { archetype.MELEE, archetype.WU },
    [archetype.RPDPS] = { archetype.DPS, archetype.PDPS, archetype.RDPS, archetype.WU },
    [archetype.MDPS]  = { archetype.MELEE, archetype.DPS, archetype.PDPS, archetype.WU },
    [archetype.RMDPS] = { archetype.CASTER, archetype.DPS, archetype.RDPS },
    [archetype.RSUPP] = { archetype.CASTER, archetype.SUPP },
    [archetype.MSUPP] = { archetype.MELEE, archetype.CASTER, archetype.SUPP, archetype.WU }
}

FearAPI.career = {
    -- Ranged physical DPS
    [en]  = {[id] =	 4, [data] = GameData.CareerLine.ENGINEER},
    [sw]  = {[id] = 18, [data] = GameData.CareerLine.SHADOW_WARRIOR},
    [sh]  = {[id] =  8, [data] = GameData.CareerLine.SQUIG_HERDER},
    
    -- Tank
    [ib]  = {[id] =  1, [data] = GameData.CareerLine.IRON_BREAKER},
    [bg]  = {[id] = 21, [data] = GameData.CareerLine.BLACKGUARD},
    [sm]  = {[id] = 17, [data] = GameData.CareerLine.SWORDMASTER},
    [bo]  = {[id] =  5, [data] = GameData.CareerLine.BLACK_ORC},
    [kbs] = {[id] = 10, [data] = GameData.CareerLine.KNIGHT},
    [chs] = {[id] = 13, [data] = GameData.CareerLine.CHOSEN},
    
    -- Melee DPS
    [wh]  = {[id] =  9, [data] = GameData.CareerLine.WITCH_HUNTER},
    [we]  = {[id] = 22, [data] = GameData.CareerLine.WITCH_ELF},
    [wl]  = {[id] = 19, [data] = GameData.CareerLine.WHITE_LION},
    [ma]  = {[id] = 14, [data] = GameData.CareerLine.MARAUDER},
    [sl]  = {[id] =  2, [data] = GameData.CareerLine.SLAYER},
    [chp] = {[id] =  6, [data] = GameData.CareerLine.CHOPPA},
    
    -- Ranged support
    [am]  = {[id] = 20, [data] = GameData.CareerLine.ARCHMAGE},
    [sha] = {[id] =  7, [data] = GameData.CareerLine.SHAMAN},
    [rp]  = {[id] =  3, [data] = GameData.CareerLine.RUNE_PRIEST},
    [zlt] = {[id] = 15, [data] = GameData.CareerLine.ZEALOT},
    
    -- Ranged magical DPS
    [bw]  = {[id] = 11, [data] = GameData.CareerLine.BRIGHT_WIZARD},
    [sor] = {[id] = 24, [data] = GameData.CareerLine.SORCERER},
    [mag] = {[id] = 16, [data] = GameData.CareerLine.MAGUS},
    
    -- Melee support
    [wp]  = {[id] = 12, [data] = GameData.CareerLine.WARRIOR_PRIEST},
    [dok] = {[id] = 23, [data] = GameData.CareerLine.DISCIPLE},
    
    -- Other
    npc = 0,
    obj = -1
}

FearAPI.archetypeDB= {
    -- Ranged physical DPS
    [FearAPI.careerDB.en]  = archetype.RPDPS,
    [FearAPI.careerDB.sw]  = archetype.RPDPS,
    [FearAPI.careerDB.sh]  = archetype.RPDPS,
    
    -- Tank
    [FearAPI.careerDB.ib]  = archetype.TANK,
    [FearAPI.careerDB.bg]  = archetype.TANK,
    [FearAPI.careerDB.sm]  = archetype.TANK,
    [FearAPI.careerDB.bo]  = archetype.TANK,
    [FearAPI.careerDB.kbs] = archetype.TANK,
    [FearAPI.careerDB.chs] = archetype.TANK,
    
    -- Melee DPS
    [FearAPI.careerDB.wh]  = archetype.MDPS,
    [FearAPI.careerDB.we]  = archetype.MDPS,
    [FearAPI.careerDB.wl]  = archetype.MDPS,
    [FearAPI.careerDB.ma]  = archetype.MDPS,
    [FearAPI.careerDB.sl]  = archetype.MDPS,
    [FearAPI.careerDB.chp] = archetype.MDPS,
    
    -- Ranged support
    [FearAPI.careerDB.am]  = archetype.RSUPP,
    [FearAPI.careerDB.sha] = archetype.RSUPP,
    [FearAPI.careerDB.rp]  = archetype.RSUPP,
    [FearAPI.careerDB.zlt] = archetype.RSUPP,
    
    -- Ranged magical DPS
    [FearAPI.careerDB.bw]  = archetype.RMDPS,
    [FearAPI.careerDB.sor] = archetype.RMDPS,
    [FearAPI.careerDB.mag] = archetype.RMDPS,
    
    -- Melee support
    [FearAPI.careerDB.wp]  = archetype.MSUPP,
    [FearAPI.careerDB.dok] = archetype.MSUPP,
    
    -- Other
    [FearAPI.careerDB.npc] = archetype.NPC,
    [FearAPI.careerDB.obj] = archetype.NPC
}
--]]

