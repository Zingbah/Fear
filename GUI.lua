FearGUI = {	
	info={
		program = Fear.info.program,        
		name = "GUI",
		version = 0.1,
		author = "Zingbah"
	}
}

--##############################################################
-- Local Variables and Functions
local info = FearGUI.info.name..", "..FearGUI.info.version
local program = FearGUI.info.program
local function say(str) Fear.Say(str) end
local function alert(str) Fear.Alert(str) end
local function verbose(str) Fear.Verbose(str) end
local function addToLog(str) Fear.Log(str) end
local function addToDebug(str) Fear.Debug(str) end

--##############################################################
-- Variables
FearGUI.LockStatus = false
--##############################################################
-- Functions
function FearGUI.OnInitialize()
	if(FearGUI.Create()) then
		verbose(info.. " loaded succesfully")
		
	else
		verbose(info.. " failed to load")
	end
end

function FearGUI.LClick(disable) -- Toggle Fear
	local msg = ""
	if ENABLED then
		DynamicImageSetTexture( "FearRoot",  "M1", 0, 0 )
		ENABLED = false
		msg = program .. " has been disabled"
	else
		DynamicImageSetTexture( "FearRoot",  "M2", 0, 0 )
		ENABLED = true
		msg = program .. " has been enabled"
        
	end
	addToLog(msg)
	alert(msg)
end

function FearGUI.RClick() -- Toggle Fear settings window
	if (SHOWWINDOW) then SHOWWINDOW = false
	else SHOWWINDOW = true  end
		
	WindowSetShowing("FearSettings",SHOWWINDOW)
end

function FearGUI.Lock()
	FearGUI.LockStatus = true
	WindowSetMovable( "FearSettings", false)
end

function Fear.Unlock()
	FearGUI.LockStatus = false
	WindowSetMovable( "FearSettings", true)
end

function FearGUI.Create()
	-- create GUI-Button 
	CreateWindow("Fear", true)
	WindowSetDimensions("Fear", 70, 70)
	WindowSetShowing("Fear", true)
	
	-- Settings Window
	CreateWindow("FearSettings", true)
	WindowSetShowing("FearSettings", false)
	WindowSetHandleInput("FearSettings", true)
	LabelSetText("FearSettingsTitleBarText", L"FEAR")
	ButtonSetText("FearSettingsButton1", L"Apply")
	ButtonSetText("FearSettingsButton2", L"Close")
	

	-- log window
	TextLogCreate("FearLog", 256) 
	LogDisplayAddLog("FearSettingsText", "FearLog", true)
    LogDisplaySetShowTimestamp("FearSettingsText", true)
    TextLogDisplayShowScrollbar("FearSettingsText", true)
	TextLogClear("FearLog")
	
	-- status label
	FearGUI.CreateLabel("FearLabel0", "status", 225, "FearSettings")
	WindowAddAnchor("FearLabel0", "topleft", "FearSettings", "topleft", 175, 318)
	
	-- Label1 SelectModule
	FearGUI.CreateLabel("FearLabel1", "Select  Careeer Module:", 250, "FearSettings")
	WindowAddAnchor("FearLabel1", "topleft", "FearSettings", "topleft", 15, 163)
	LabelSetTextColor("FearLabel1", 255, 125, 0)
	
	--ComboBox1 SelectModule
	CreateWindowFromTemplate("Combobox1", "EA_ComboBox_DefaultResizable", "FearSettings")
	WindowAddAnchor("Combobox1", "topleft", "FearSettings", "topleft", 15, 178)
	if(FearCareer.module_names) then
		for k,v in pairs(FearCareer.module_names) do 
			ComboBoxAddMenuItem("Combobox1", v)
		end
	else
		ComboBoxAddMenuItem("Combobox1", towstring("No available modules"))
	end
	
	-- Label2 Select FearMode
	FearGUI.CreateLabel("FearLabel2", "Select Fear Mode:", 250, "FearSettings")
	WindowAddAnchor("FearLabel2", "topleft", "FearSettings", "topleft", 15, 208)
	LabelSetTextColor("FearLabel2", 255, 125, 0)
	
	--ComboBox2 Select FearMode
	CreateWindowFromTemplate("Combobox2", "EA_ComboBox_DefaultResizable", "FearSettings")
	WindowAddAnchor("Combobox2", "topleft", "FearSettings", "topleft", 15, 223)
	ComboBoxAddMenuItem("Combobox2", L"PvP")
	ComboBoxAddMenuItem("Combobox2", L"PvE")
	ComboBoxAddMenuItem("Combobox2", L"PvP + Scenarios")
	ComboBoxAddMenuItem("Combobox2", L"RecordNavP.Mode")
	ComboBoxAddMenuItem("Combobox2", L"KillBoss")
--[[	
	-- Label3 Select XP/m label
	FearGUI.CreateLabel("FearLabel3", "XP/m: ", 50, "FearSettings")
	WindowAddAnchor("FearLabel3", "topleft", "FearSettings", "topleft", 25, 12)
	
	-- Label4 Select XP/m 
	FearGUI.CreateLabel("FearLabel4", "0", 70, "FearSettings")
	WindowAddAnchor("FearLabel4", "topleft", "FearSettings", "topleft", 75, 12)
	
	-- Label5 Select Gold /m
	FearGUI.CreateLabel("FearLabel5", "Gold/m: ", 70, "FearSettings")
	WindowAddAnchor("FearLabel5", "topleft", "FearSettings", "topleft", 320, 12)
	
	-- Label6 Select Gold 
	FearGUI.CreateLabel("FearLabel6", "0", 50, "FearSettings")
	WindowAddAnchor("FearLabel6", "topleft", "FearSettings", "topleft", 385, 12)
	
	-- Label7 Select Rp label
	FearGUI.CreateLabel("FearLabel7", "RP/m: ", 50, "FearSettings")
	WindowAddAnchor("FearLabel7", "topleft", "FearSettings", "topleft", 135, 12)
	
	-- Label8 Select Rp/m 
	FearGUI.CreateLabel("FearLabel8", "0", 50, "FearSettings")
	WindowAddAnchor("FearLabel8", "topleft", "FearSettings", "topleft", 185, 12)
--]]	
	--Debug Path recorder
	FearGUI.CreateButton("FearButton7", "Rec.Path", 125, "FearSettings", "Fear.ToggleRecNav")
	WindowAddAnchor("FearButton7", "topleft", "FearSettings", "left", 265, 210)
	
	--Debug Path recorder
	FearGUI.CreateButton("FearButton2", "Movement", 125, "FearSettings", "Fear.TogglePath")
	WindowAddAnchor("FearButton2", "topleft", "FearSettings", "left", 265, 180)
	
	--Debug Path BiConnect On/off
	FearGUI.CreateButton("FearButton6", "BiConnect", 125, "FearSettings", "Fear.ToggleBiConnect")
	WindowAddAnchor("FearButton6", "topleft", "FearSettings", "left", 265, 240)
	
	--Debug HotSpot savenavi
	FearGUI.CreateButton("FearButton4", "TEST", 125, "FearSettings", "Fear.Test")
	WindowAddAnchor("FearButton4", "topleft", "FearSettings", "left", 390, 270)
	
	--Debug HotSpot creator
	FearGUI.CreateButton("FearButton1", "ReAbility", 125, "FearSettings", "FearAbility.Collect")
	WindowAddAnchor("FearButton1", "topleft", "FearSettings", "left", 390, 180)
	
	--Debug HotSpot walking forward
	FearGUI.CreateButton("FearButton3", "SetHotspot", 125, "FearSettings", "Fear.SetHotspot2")
	WindowAddAnchor("FearButton3", "topleft", "FearSettings", "left", 390, 210)
 	
	--Debug HotSpot deleting
	FearGUI.CreateButton("FearButton5", "Reset", 125, "FearSettings", "Fear.ResetEnvironment")
	WindowAddAnchor("FearButton5", "topleft", "FearSettings", "left", 390, 240)

	--Debug HealAll Targets / Just Group button
	FearGUI.CreateButton("FearButton8", "HealAll/Grp", 125, "FearSettings", "Fear.Healall")
	WindowAddAnchor("FearButton8", "topleft", "FearSettings", "left", 265, 270)
	
	return true
end

function FearGUI.CreateButton(ButtonName, ButtonText, ButtonWidth, ButtonParent, Function)
	CreateWindowFromTemplate(ButtonName, "EA_Button_ListSort", ButtonParent)
	WindowSetDimensions(ButtonName, ButtonWidth, 34)
	ButtonSetText(ButtonName, towstring(ButtonText))
	WindowRegisterCoreEventHandler(ButtonName, "OnLButtonUp", Function)
end

function FearGUI.CreateLabel(LabelName, LabelText, LabelWidth, LabelParent)
	CreateWindowFromTemplate(LabelName, "EA_Label_DefaultText", LabelParent)
	--LabelSetTextColor(LabelName, 255, 23, 255)
	LabelSetFont(LabelName,"font_clear_small_bold",25) 
	LabelSetTextAlign(LabelName, "left")
	WindowSetDimensions(LabelName, LabelWidth, 30)
	LabelSetText(LabelName, towstring(LabelText))
end	
