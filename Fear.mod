<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="Fear" version="0.1" date="12/29/2010">
        <Author name="Zingbah" email="noreply@gmail.com" />
        <Description text="An interactive combat and healing system designed for WARExtDLL." />
		<Dependencies>
			<Dependency name="EA_ChatWindow"/>
			<Dependency name="WarCache"/>
        </Dependencies>
        <Files>
			<File name="Util.lua" />
            <File name="Fear.lua" />
			<File name="GUI.lua" />
			<File name="Ability.lua" />
			<File name="Player.lua" />
			<File name="Target.lua" />
			<File name="Career.lua" />
			<File name="modules/Shaman.lua" />
			<File name="Fear.xml" />
        </Files>
		<SavedVariables>
			<SavedVariable name="ENABLED" />
			<SavedVariable name="TARGETINGMODE" />
			<SavedVariable name="TARGETPREF" />
			<SavedVariable name="SUPPORTMODE" />
			<SavedVariable name="HEALTHTHRESHOLD" />
			<SavedVariable name="SHOWWINDOW" />
			<SavedVariable name="MODULESELECT" />
			<SavedVariable name="STAYONCAST" />
			<SavedVariable name="VERSION" />
			<SavedVariable name="LOS" />
			
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
    </UiMod>
</ModuleFile>
