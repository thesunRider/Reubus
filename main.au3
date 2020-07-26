#Region Initializing

#include <IE.au3>
#include <ColorConstants.au3>
#include <Process.au3>
#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include "MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <GUIConstants.au3>
#include <GuiTab.au3>
#include <GDIPlus.au3>
#include <Json.au3>
#include <WindowsConstants.au3>


;!Highly recommended for improved overall performance and responsiveness of the GUI effects etc.! (after compiling):
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm /pe

;YOU NEED TO EXCLUDE FOLLOWING FUNCTIONS FROM AU3STRIPPER, OTHERWISE IT WON'T WORK:
#Au3Stripper_Ignore_Funcs=_iHoverOn,_iHoverOff,_iFullscreenToggleBtn,_cHvr_CSCP_X64,_cHvr_CSCP_X86,_iControlDelete
;Please not that Au3Stripper will show errors. You can ignore them as long as you use the above Au3Stripper_Ignore_Funcs parameters.

;Required if you want High DPI scaling enabled. (Also requries _Metro_EnableHighDPIScaling())
#AutoIt3Wrapper_Res_HiDpi=y
; ===============================================================================================================================


_Metro_EnableHighDPIScaling()
_SetTheme("DarkTeal")
_GDIPlus_Startup()

;enable activeX
Local $regValue = "0x2AF8"
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)

;delete cache
$ClearID = "8"
Run("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $ClearID)


Global $mapaddress = "http://localhost:8843/map_test.html"
Global $lastid = 0

#EndRegion

#Region Welcome screen

;welcome-screen

Global $welcomegui = _Metro_CreateGUI("Welcome Screen", 600, 500,-1,-1)
$Control_Buttons_welcome = _Metro_AddControlButtons(True, False, True, False, False)

$welabl = GUICtrlCreateLabel("Welcome",230,300,170,40)
GUIctrlSetFont(-1,30,100,0,"Arial")
GUICtrlSetColor (-1,$COLOR_WHITE)

GUICtrlCreatePic("logo.jpg",80,130,440,150)
$start_home = _Metro_CreateButtonEx2("Start", 225, 395, 185, 30)


$GUI_CLOSE_BUTTON = $Control_Buttons_welcome[0]
$GUI_MAXIMIZE_BUTTON = $Control_Buttons_welcome[1]
$GUI_RESTORE_BUTTON = $Control_Buttons_welcome[2]
$GUI_MINIMIZE_BUTTON = $Control_Buttons_welcome[3]
$GUI_FULLSCREEN_BUTTON = $Control_Buttons_welcome[4]
$GUI_FSRestore_BUTTON = $Control_Buttons_welcome[5]
$GUI_MENU_BUTTON = $Control_Buttons_welcome[6]

GUISetState(@SW_SHOW,$welcomegui)
While 1
	Sleep(50)
	_CheckHover($welcomegui,$welabl)
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			_Metro_GUIDelete($welcomegui) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
			Exit

		Case $GUI_MINIMIZE_BUTTON
			GUISetState(@SW_MINIMIZE, $welcomegui)

		Case $start_home
			ConsoleWrite("starting main app")
			_Metro_GUIDelete($welcomegui)
			ExitLoop

	EndSwitch
WEnd

#EndRegion


#Region main-screen

;Sleep(2000) ;Loading........

Global $gui = _Metro_CreateGUI("Reubus", @DesktopWidth , @DesktopHeight, 0, 0,True)
$Control_Buttons = _Metro_AddControlButtons(True, False, True, False, False)

$GUI_CLOSE_BUTTON = $Control_Buttons_welcome[0]
$GUI_MAXIMIZE_BUTTON = $Control_Buttons[1]
$GUI_RESTORE_BUTTON = $Control_Buttons[2]
$GUI_MINIMIZE_BUTTON = $Control_Buttons[3]
$GUI_FULLSCREEN_BUTTON = $Control_Buttons[4]
$GUI_FSRestore_BUTTON = $Control_Buttons[5]
$GUI_MENU_BUTTON = $Control_Buttons[6]

$ui_w = @DesktopWidth
$ui_h = @DesktopHeight

$maintab = GUICtrlCreateTab(-600,-100)

Global $grph_hndl = _IECreateEmbedded()
Global $mainmap = _IECreateEmbedded()


GUICtrlCreateTabItem("tab1")
#Region Tab1

;GUI BACKGROUND

GUICtrlCreateLabel("", 0, $ui_h*.65, $ui_w, $ui_h*.31) ;statusbar
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x333333)

GUICtrlCreateLabel("", $ui_w*.65, $ui_h*.1, 3, $ui_h*.55) ;main seprator
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x999999)

GUICtrlCreateLabel("", $ui_w*.65, $ui_h*.1, 1, $ui_h*.55);main seprator shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("",$ui_w*.65+3, $ui_h*.1, $ui_w*.35, $ui_h*.55) ;FILE REPORT BG
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x191919)

GUICtrlCreateLabel("", $ui_w*0.21, $ui_h*.65, 5,$ui_h*.31 ) ;status seprator1
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("",$ui_w*0.21+5 , $ui_h*.65, 2, $ui_h*.31) ;status seprator1 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", $ui_w*.43, $ui_h*.65, 5, $ui_h*.31) ;status seprator2
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("", $ui_w*.43+5, $ui_h*.65, 2, $ui_h*.31) ;status seprator2 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", $ui_w*.84, $ui_h*.65, 5, $ui_h*.31) ;status seprator3
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("", $ui_w*.84+5, $ui_h*.65, 2, $ui_h*.31) ;status seprator3 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", $ui_w*.44, $ui_h*.665, $ui_w*.395, $ui_h*.283, $WS_BORDER)

GUICtrlCreateLabel("", 0, $ui_h*.65, $ui_w, 2) ;upper border of status bar
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x5e5e5e)


;BUTTON IN SECOND DIVISION

$show_fir = GUICtrlCreateButton("SHOW FIR",$ui_w*.65+8, $ui_h*.1+5, 80, 25)          ;show fir button
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($show_fir, 0x7f7f7f)



;LABELS IN 1ST STATUS BAR

GUICtrlCreateLabel("Scene FPS:", 10, $ui_h*.66, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Database:", 150, $ui_h*.66, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("CPU DRAW:", 10, $ui_h*.68, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("RAM DRAW:", 10, $ui_h*.70, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Current Case:", 10, $ui_h*.72, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Current FIR:", 10, $ui_h*.74, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("No of Sets in Model:", 10, $ui_h*.80, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("categories in Model:", 10, $ui_h*.82, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Installed Packages:", 10, $ui_h*.84, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Ping:", 10, $ui_h*.86, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

; LABELS AND BUTTONS IN SECOND STATUS BAR

GUICtrlCreateLabel("Use model set:", $ui_w*0.21+20, $ui_h*.68, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Train model set using current Scene", $ui_w*0.21+20,  $ui_h*.73, 250, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER , "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("NODE CATEGORIES:", $ui_w*0.43+25, $ui_h*.9, 115, 28, 0x0200)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

$browse_model = GUICtrlCreateButton(" O O O ",$ui_w*0.21+125,$ui_h*.686,50,18)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($browse_model,0xbcbcbc)

$generate_report = GUICtrlCreateButton("GENERATE REPORT", $ui_w*0.21+20, $ui_h*.78, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($generate_report, 0x7f7f7f)

$generate_match = GUICtrlCreateButton("GENERATE MATCH", $ui_w*0.21+150, $ui_h*.78, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($generate_match, 0x7f7f7f)

$personality_todb = GUICtrlCreateButton("WRITE PERSONALITY TO DB", $ui_w*0.21+20, $ui_h*.83, 250, 30)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($personality_todb, 0x7f7f7f)

$predict_movement = GUICtrlCreateButton("PREDICT CONVICTS NEXT MOVEMENT", $ui_w*0.21+30, $ui_h*.88, 230, 40)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($predict_movement, 0x7f7f7f)

;LABELS IN 3RD STATUS BAR

$add_node = GUICtrlCreateButton("ADD NEW NODE MODEL", $ui_w*0.43+25, $ui_h*.675, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($add_node, 0x7f7f7f)

$delete_node = GUICtrlCreateButton("DELETE CURRENT NODE", $ui_w*0.43+25, $ui_h*.72, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($delete_node, 0x7f7f7f)

;LABELS IN 4TH STATUS BAR

GUICtrlCreateLabel("CURRENT NODE INFO:", $ui_w*0.84+10,$ui_h*.655, 125, 28, 0x0200)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)


Global $grph = GUICtrlCreateObj($grph_hndl, 0, $ui_h*.1, $ui_w*.65, $ui_h*.55)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)

_IENavigate($grph_hndl, "http://localhost:8843/")


#EndRegion






GUICtrlCreateTabItem("tab2")
#Region Tab2

;TAB2 DESIGN
GUICtrlCreateLabel("", 0, $ui_h*.65, $ui_w, $ui_h*.31) ;statusbar
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x333333)

GUICtrlCreateLabel("", $ui_w*0.21, $ui_h*.65, 5,$ui_h*.31 ) ;status seprator1
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("",$ui_w*0.21+5 , $ui_h*.65, 2, $ui_h*.31) ;status seprator1 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", $ui_w*.45, $ui_h*.65, 5, $ui_h*.31) ;status seprator2
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("", $ui_w*.45+5, $ui_h*.65, 2, $ui_h*.31) ;status seprator2 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", $ui_w*.67, $ui_h*.65, 5, $ui_h*.31) ;status seprator3
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0xcccccc)

GUICtrlCreateLabel("", $ui_w*.67+5, $ui_h*.65, 2, $ui_h*.31) ;status seprator3 shade
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x00000)

GUICtrlCreateLabel("", 0, $ui_h*.65, $ui_w, 2) ;upper border of status bar
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x5e5e5e)

GUICtrlCreateLabel("",0, $ui_h*.1, $ui_w*.3, $ui_h*.55) ;left layout bg
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x191919)

GUICtrlCreateLabel("",$ui_w*.7, $ui_h*.1, $ui_w*.3, $ui_h*.55) ;right layout bg
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x191919)

GUICtrlCreateLabel("",$ui_w*.71, $ui_h*.12, $ui_w*.28, $ui_h*.51, $WS_BORDER)

;LABELS AND BUTTONS IN FIRST DIVISION

GUICtrlCreateLabel("SEARCH ID:", $ui_w*.01, $ui_h*.10, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CRIME ID:", $ui_w*.01, $ui_h*.52, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LATITUDE:", $ui_w*.01, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LONGITUDE:", $ui_w*.01, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("OPEN FIR:", $ui_w*.01, $ui_h*.595, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$OPEN_FIR = GUICtrlCreateButton(" O O O ",$ui_w*.01+70, $ui_h*.595+7,40,15)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($OPEN_FIR,0xbcbcbc)

GUICtrlCreateLabel("TIME:", $ui_w*.15, $ui_h*.52, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("NEAREST CRIME ID:", $ui_w*.15, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$search_id = GUICtrlCreateInput("", $ui_w*.061, $ui_h*.105, 200, 22) ; search id input box

;LABELS AND BUTTON IN 3RD DIVISION

GUICtrlCreateLabel("GRAPHS", $ui_w*.715, $ui_h*.12, 140, 28, 0x0200)
GUICtrlSetFont(-1, 11, Default, $GUI_FONTUNDER, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH TYPE:", $ui_w*.725, $ui_h*.16, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH STYLE:", $ui_w*.86, $ui_h*.16, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH DATE-RANGE:", $ui_w*.725, $ui_h*.185, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH HIGHEST:", $ui_w*.725, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH LOWEST:", $ui_w*.86, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("GRAPH MEAN:", $ui_w*.725, $ui_h*.595, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

;LABELS IN FIRST STATUS BAR

GUICtrlCreateLabel("Scene FPS:", 10, $ui_h*.66, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Database:", 150, $ui_h*.66, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("CPU DRAW:", 10, $ui_h*.68, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("RAM DRAW:", 10, $ui_h*.70, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Current Case:", 10, $ui_h*.72, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Current FIR:", 10, $ui_h*.74, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("No of Sets in Model:", 10, $ui_h*.80, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("categories in Model:", 10, $ui_h*.82, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Installed Packages:", 10, $ui_h*.84, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Ping:", 10, $ui_h*.86, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

;LABELS AND BUTTON IN 2ND STATUS BAR

GUICtrlCreateLabel("Use model set:", $ui_w*0.21+20, $ui_h*.68, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

$browse_model = GUICtrlCreateButton(" O O O ",$ui_w*0.21+125,$ui_h*.686,50,18)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($browse_model,0xbcbcbc)

GUICtrlCreateLabel("Include changes to dataset and redraw", $ui_w*0.21+20,  $ui_h*.73, 260, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER , "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Calculate and Draw predicted Target based on pattern", $ui_w*0.21+20, $ui_h*.77, 200, 100)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel(":",$ui_w*0.21+230, $ui_h*.77, 140, 28, 0x0200)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$START_DRAW = GUICtrlCreateButton("START", $ui_w*0.21+245, $ui_h*.765, 100, 40)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($START_DRAW, 0x7f7f7f)

$generate_report = GUICtrlCreateButton("GENERATE REPORT", $ui_w*0.21+20, $ui_h*.83, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($generate_report, 0x7f7f7f)

$REDRAW_MAP = GUICtrlCreateButton("REDRAW MAP", $ui_w*0.21+200, $ui_h*.83, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($REDRAW_MAP, 0x7f7f7f)

$CLEAR_MAP = GUICtrlCreateButton("CLEAR MAP", $ui_w*0.21+20, $ui_h*.89, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($CLEAR_MAP, 0x7f7f7f)

$generate_MAP = GUICtrlCreateButton("SHOW SUGGESTIONS", $ui_w*0.21+200, $ui_h*.89, 120, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($generate_MAP, 0x7f7f7f)

;LABELS AND BUTTON IN 3RD STATUS BAR

GUICtrlCreateLabel("LOAD PATTERN BASED ON:", $ui_w*0.45+20, $ui_h*.67, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("TIME RANGE:", $ui_w*0.45+25, $ui_h*.73, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LAT/LONG RANGE:", $ui_w*0.45+25, $ui_h*.76, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CONVICT ID:", $ui_w*0.45+25, $ui_h*.79, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CONVICT PARAM:", $ui_w*0.45+25, $ui_h*.82, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CRIME TYPE:", $ui_w*0.45+25, $ui_h*.85, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

;LABELS AND BUTTON IN 4TH STATUS BAR

$GOTO_BUTTON = GUICtrlCreateButton("GO TO", $ui_w*.68, $ui_h*.68, 80, 65)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($GOTO_BUTTON, 0x7f7f7f)

GUICtrlCreateLabel("LAT:", $ui_w*.74, $ui_h*.675, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$LAT_IN = GUICtrlCreateInput("", $ui_w*.74+35, $ui_h*.675+3, 145, 22) ; LAT input box

GUICtrlCreateLabel("LONG:", $ui_w*.87, $ui_h*.675, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$LONG_IN = GUICtrlCreateInput("", $ui_w*.87+40, $ui_h*.675+3, 145, 22) ; LAT input box

GUICtrlCreateLabel("ADDRESS:", $ui_w*.74, $ui_h*.725, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$ADDRESS_IN = GUICtrlCreateInput("", $ui_w*.74+70, $ui_h*.725+3, 180, 22) ; LAT input box

$DROP_CIRCLE = GUICtrlCreateButton("DROP CIRCLE", $ui_w*.68, $ui_h*.81, 120,45)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($DROP_CIRCLE, 0x7f7f7f)

GUICtrlCreateLabel("", $ui_w*.677, $ui_h*.79, $ui_w*.32, $ui_h*.1, $WS_BORDER)

GUICtrlCreateLabel("COLOUR:", $ui_w*.77, $ui_h*.795, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$browse_COLOUR = GUICtrlCreateButton(" O O O ",$ui_w*.77+50, $ui_h*.802,35,15)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($browse_COLOUR,0xbcbcbc)

GUICtrlCreateLabel("RANGE:", $ui_w*.77, $ui_h*.835, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("OPACITY:", $ui_w*.89, $ui_h*.835, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CIRCLE", $ui_w*.961, $ui_h*.79, 160, 28, 0x0200)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)



GUICtrlCreateObj($mainmap,$ui_w*.3, $ui_h*.1, $ui_w*.4, $ui_h*.55)
_IENavigate($mainmap,"http://localhost:8843/map_test.html")

$crimlst = GUICtrlCreateListView("Crime ID|latitude|Longitude",$ui_w*.01, $ui_h*.14, $ui_w*.28, $ui_h*.38)

#EndRegion

GUICtrlCreateTabItem("")


;Stuff that should be always there irrespective of tabs
#Region Persistenet stuff across tabs

GUICtrlCreateLabel("", 0, $ui_h*.05, $ui_w, $ui_h*.05); toppanel
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x666666)

GUICtrlCreatePic("logo.jpg",5,5,88,30) ;logo

GUICtrlCreateLabel("", 0, $ui_h-$ui_h*0.04, $ui_w, $ui_h*0.04) ;bottompannel
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1,  0x191919)

$file_button = GUICtrlCreateButton("FILE", 10, $ui_h*0.06, 80, 25)                  ;file button
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($file_button, 0x323232)

$save_button = GUICtrlCreateButton("SAVE", 100, $ui_h*0.06, 80, 25)          ;save button
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($save_button, 0x323232)

$settings_button = GUICtrlCreateButton("SETTINGS", 190, $ui_h*0.06, 80, 25)          ;save button
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($settings_button, 0x323232)

$scene = GUICtrlCreateButton("SCENE", 0, $ui_h-$ui_h*0.04, 150, $ui_h*0.04);scene tab
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($scene,  0x191919)

$map = GUICtrlCreateButton("MAP", 150, $ui_h-$ui_h*0.04, 150, $ui_h*0.04)  ;map tab
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($map,  0x191919)

$DB = GUICtrlCreateButton("DB", 300,$ui_h-$ui_h*0.04, 150, $ui_h*0.04,-1)   ; DB tab
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($DB, 0x191919)

#EndRegion

Do
Sleep(50)
Until $mainmap.document.getElementById("debug").value == "1256"

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

;$nodeserial = _execjavascript($grph_hndl,"JSON.stringify(graph.serialize());")
ConsoleWrite("Passed all functions")
GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			_Metro_GUIDelete($gui) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
			Exit
		Case $GUI_MINIMIZE_BUTTON
			GUISetState(@SW_MINIMIZE, $gui)

		Case $scene
			ConsoleWrite("clicked scne "&@CRLF)
			_GUICtrlTab_ActivateTab($maintab,0)

		Case $map
			ConsoleWrite("clicked map "&@CRLF)
			_GUICtrlTab_ActivateTab($maintab,1)


	EndSwitch
WEnd

#EndRegion

#Region Functions

Func _hovermethod($id)
;make current button to another color on click
Switch $id
	Case $scene,$map,$DB
		GUICtrlSetBkColor($id, 0x323232)

	Case $file_button,$save_button,$settings_button
		GUICtrlSetBkColor($id, 0x7f7f7f)

EndSwitch

;return the button clicked before this button to its original color
Switch $lastid
	Case $scene,$map,$DB
		GUICtrlSetBkColor($lastid ,  0x191919)

	Case $file_button,$save_button,$settings_button
		GUICtrlSetBkColor($lastid,0x323232)


EndSwitch
$lastid = $id

EndFunc


Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $nNotifyCode = _WinAPI_HiWord($wParam)
	Local $iId = _WinAPI_LoWord($wParam)
	Local $hCtrl = $lParam

	If $iId <> 2 And $nNotifyCode = 0 Then ; Check for IDCANCEL - 2
		_hovermethod($iId)
	EndIf
EndFunc   ;==>WM_COMMAND

Func _loadpic($iPic,$picture)
Global $hImage = _GDIPlus_ImageLoadFromFile($picture)
Global $hHBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
_WinAPI_DeleteObject(GUICtrlSendMsg($iPic, $STM_SETIMAGE, $IMAGE_BITMAP, $hHBitmap))
EndFunc

Func _execjavascript($web,$js)
$gvData = $web.document.parentwindow.eval("document.getElementById('debug').value = " &$js)
Return $web.document.getElementById("debug").value
EndFunc

Func _CheckHover($inpgui,$cntrl)
    Local $Info = GUIGetCursorInfo($inpgui)
    If Not IsArray($Info) Then Return
    If $Info[4] == $cntrl Then
		ConsoleWrite("overlayed")
		GUICtrlSetColor ($cntrl,0x025669 )
	Else
		GUICtrlSetColor ($cntrl,$COLOR_WHITE)
    EndIf
EndFunc   ;==>_CheckHover



Func _getcurlatln()
$curlatlong = $mainmap.document.getElementById("latlong").value
$mainmap.document.getElementById("latlong").value = ""
Return $curlatlong
EndFunc

Func _drawcircle($title,$lat,$long,$radius,$color,$opac)
$exec = "drawcircle('" &$title &"'," &$lat &"," &$long &"," &$radius*0.621371 &",'" &$color &"'," &$opac &");"
ConsoleWrite($exec)
$mainmap.document.parentwindow.eval($exec)
EndFunc

Func _zoomtoaddress($lat,$long)
$mainmap.document.parentwindow.eval("zoomtolocation(" &$lat &"," &$long &");")
EndFunc


Func _URIEncode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(BinaryToString(StringToBinary($sData,4),1),"")
    Local $nChar
    $sData=""
    For $i = 1 To $aData[0]
        ; ConsoleWrite($aData[$i] & @CRLF)
        $nChar = Asc($aData[$i])
        Switch $nChar
            Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
                $sData &= $aData[$i]
            Case 32
                $sData &= "+"
            Case Else
                $sData &= "%" & Hex($nChar,2)
        EndSwitch
    Next
    Return $sData
EndFunc

Func _URIDecode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(StringReplace($sData,"+"," ",0,1),"%")
    $sData = ""
    For $i = 2 To $aData[0]
        $aData[1] &= Chr(Dec(StringLeft($aData[$i],2))) & StringTrimLeft($aData[$i],2)
    Next
    Return BinaryToString(StringToBinary($aData[1],1),4)
EndFunc
#EndRegion