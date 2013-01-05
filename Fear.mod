<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="Fear" version="0.1" date="12/29/2010">
        <Author name="Zingbah" email="noreply@gmail.com" />
        <Description text="An interactive combat and healing system designed for WARExtDLL." />
		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
        </Dependencies>
        <Files>
			<File name="Util.lua" />
            <File name="Fear.lua" />
			<File name="GUI.lua" />
			<File name="Ability.lua" />
			<File name="Player.lua" />
			<File name="Target.lua" />
			<File name="Career.lua" />
			<File name="Cache.lua" />
			<File name="modules/Shaman.lua" />
			<File name="Fear.xml" />
        </Files>
		<SavedVariables>
			<SavedVariable name="Fear.ENV.ENABLED" />
			<SavedVariable name="Fear.ENV.TARGETINGMODE" />
			<SavedVariable name="Fear.ENV.TARGETPREF" />
			<SavedVariable name="Fear.ENV.SUPPORTMODE" />
			<SavedVariable name="Fear.ENV.HEALTHTHRESHOLD" />
			<SavedVariable name="Fear.ENV.SHOWWINDOW" />
			<SavedVariable name="Fear.ENV.MODULESELECT" />
			<SavedVariable name="Fear.ENV.STAYONCAST" />
			<SavedVariable name="Fear.ENV.VERSION" />
			<SavedVariable name="Fear.ENV.LOS" />
			
		</SavedVariables>	

        <OnInitialize>
            <CallFunction name="Fear.OnInitialize" />
        </OnInitialize>
        <OnUpdate>
			 <CallFunction name="Fear.OnUpdate" />
	    </OnUpdate>
        <OnShutdown>
		 <CallFunction name="Fear.OnShutdown" />
        </OnShutdown>
         <WARInfo>
            <Categories>
                <Category name="COMBAT" />
                <Category name="RVR" />
                <Category name="OTHER" />
            </Categories>
            <Careers>
                <Career name="ARCHMAGE" />
               <!--  <Career name="BLACKGUARD" />
                <Career name="BLACK_ORC" /> -->
                <Career name="BRIGHT_WIZARD" />
               <!--  <Career name="CHOPPA" />
                <Career name="CHOSEN" />
                <Career name="DISCIPLE" />
                <Career name="ENGINEER" />
                <Career name="IRON_BREAKER" />
                <Career name="KNIGHT" /> -->
                <Career name="SHAMAN" />
                <!-- <Career name="SQUIG_HERDER" />
                <Career name="MAGUS" />
                <Career name="MARAUDER" />
                <Career name="RUNE_PRIEST" />
                <Career name="SHADOW_WARRIOR" />
                <Career name="SLAYER" />
                <Career name="SORCERER" />
                <Career name="SWORDMASTER" />
                <Career name="WARRIOR_PRIEST" />
                <Career name="WHITE_LION" />
                <Career name="WITCH_ELF" />
                <Career name="WITCH_HUNTER" /> -->
                <Career name="ZEALOT" />
            </Careers>
        </WARInfo>

    </UiMod>
</ModuleFile>
