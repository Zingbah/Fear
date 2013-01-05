FearModule.Archmage ={ 
	module = {
		name = "Archmage Ability",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
--#### Local Variables and Functions

local mod_name = FearModule.Archmage.module.name..", "..FearModule.Archmage.module.version


--##############################################################
-- Variables

--##############################################################
-- Functions
function FearModule.Archmage.OnInitialize()
	if (GameData.Player.career.line == GameData.CareerLine.ARCHMAGE)  then
		Fear.Say("["..Fear.name.."] "..mod_name.." module loaded successfully")
		Fear.Log(mod_name.." is completed up to level 11.")
	else
		Fear.Verbose("["..Fear.name.."] "..mod_name.." module disabled")
	end
end

