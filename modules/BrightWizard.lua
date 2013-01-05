
FearModule[GameData.CareerLine.BRIGHT_WIZARD] = {
	module={
		name = "Bright Wizard",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
--#### Local Variables and Functions

local mod_name = FearModule.BrightWizard.module.name..", "..FearModule.BrightWizard.module.version

local function say(str)
	Fear.Say(str)
end

local function addToLog(str)
	Fear.Log(str)
end

local function verbose(str)
	Fear.Verbose(str)
end
--##############################################################
-- Variables

--##############################################################
-- Functions
function FearModule[GameData.CareerLine.BRIGHT_WIZARD].OnInitialize()
	say("["..Fear.name.."] "..mod_name.." module loaded successfully")
	addToLog(mod_name.." is completed up to level 11.")
end

