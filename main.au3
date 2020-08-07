#Region Initializing

#include <IE.au3>
#include <ColorConstants.au3>
#include <Process.au3>
#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include <Math.au3>
#include "MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <GuiTab.au3>
#include <Xml.au3>
#include <GDIPlus.au3>
#include <String.au3>
#include <Misc.au3>
#include <DateTimeConstants.au3>
#include <Json.au3>
#include <GuiDateTimePicker.au3>
#include <WindowsConstants.au3>
#include <SQLite.au3>

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
_SQLite_Startup()
$store_db = _SQLite_Open("store.db")
$node_db = _SQLite_Open(@ScriptDir &"\nodes\node_data\node_reg.db")
_GDIPlus_Startup()

;enable activeX
Local $regValue = "0x2AF8"
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)

;delete cache
$ClearID = "8"
RunWait("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $ClearID)


Global $mapaddress = "http://localhost:8843/map_test.html"
Global $lastid = 0,$currentlatln

Global $drop_array

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

$GUI_CLOSE_BUTTON = $Control_Buttons[0]
$GUI_MAXIMIZE_BUTTON = $Control_Buttons[1]
$GUI_RESTORE_BUTTON = $Control_Buttons[2]
$GUI_MINIMIZE_BUTTON = $Control_Buttons[3]
$GUI_FULLSCREEN_BUTTON = $Control_Buttons[4]
$GUI_FSRestore_BUTTON = $Control_Buttons[5]
$GUI_MENU_BUTTON = $Control_Buttons[6]

$ui_w = @DesktopWidth
$ui_h = @DesktopHeight

$maintab = GUICtrlCreateTab(-600,-100)
Global $mainmap = _IECreateEmbedded()

GUICtrlCreateTabItem("tab1")
#Region Tab1

;GUI BACKGROUND
Global $grph_hndl = _IECreateEmbedded()

$list_nodeedit = GUICtrlCreateEdit("Description",$ui_w*0.74,$ui_h*.68,$ui_w*.09, $ui_h*.20,$ES_READONLY)
$list_nodeclass = GUICtrlCreateListView("Folder|Node|Number of Inputs",$ui_w*0.55, $ui_h*.68, $ui_w*.18, $ui_h*.25)

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

GUICtrlCreateLabel("", 0, $ui_h*.65, $ui_w, 2) ;upper border of status bar
GUICtrlSetState(-1, 128); $GUI_DISABLE
GUICtrlSetBkColor(-1, 0x5e5e5e)


$show_fir = GUICtrlCreateButton("LOAD FIR",$ui_w*.65+8, $ui_h*.1+5, 80, 25)          ;show fir button
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($show_fir, 0x7f7f7f)

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

$trn_scene = GUICtrlCreateButton("Train model set using current Scene", $ui_w*0.21+20,  $ui_h*.73, 250, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER , "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("NODE CATEGORIES:", $ui_w*0.43+25, $ui_h*.9, 115, 28, 0x0200)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)


GUICtrlCreateLabel("CURRENT NODE INFO:", $ui_w*0.84+10,$ui_h*.655, 125, 28, 0x0200)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

$browse_model = GUICtrlCreateButton(" . . . ",$ui_w*0.21+125,$ui_h*.686,50,18)

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

$delete_node = GUICtrlCreateButton("DELETE NODE MODEL", $ui_w*0.43+25, $ui_h*.72, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($delete_node, 0x7f7f7f)

$clear_nodes = GUICtrlCreateButton("CLEAR-RELOAD GRAPH", $ui_w*0.43+25, $ui_h*.77, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

$get_nodes_description = GUICtrlCreateButton("GET NODE DESCP", $ui_w*0.74, $ui_h*.90, 130, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

$load_node_connection = GUICtrlCreateButton("LOAD JSON GRAPH", $ui_w*0.43+25, $ui_h*.82, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

$export_node_connection = GUICtrlCreateButton("EXPORT JSON GRAPH", $ui_w*0.43+25, $ui_h*.86, 140, 25)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

Local $pdf_view = ObjCreate("Shell.Explorer.2") ; Instantiate a BrowserControl
GUICtrlCreateObj($pdf_view,  $ui_w*.65+35, $ui_h*.15, 470, 405); Place the BrowserControl on the GUI
$pdf_view.navigate('about:blank')


GUICtrlCreateLabel("", $ui_w*.44, $ui_h*.665, $ui_w*.395, $ui_h*.283, $WS_BORDER) ; border to node section


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

$search_id = GUICtrlCreateInput("", $ui_w*.061, $ui_h*.105, 200, 22) ; search id input box


$Delete_currentloc = GUICtrlCreateButton("DELETE CURRENT SELECTION",$ui_w*.01+210, $ui_h*.6,220,30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

GUICtrlCreateLabel("SEARCH  :", $ui_w*.01, $ui_h*.10, 80, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)


GUICtrlCreateLabel("LATITUDE:", $ui_w*.01, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LONGITUDE:", $ui_w*.01, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$latvar = GUICtrlCreateLabel("0.0", $ui_w*.055, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$longvar = GUICtrlCreateLabel("0.0", $ui_w*.055, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$goto_selection = GUICtrlCreateButton("GOTO SELECTION", $ui_w*.01, $ui_h*.6, 200, 28)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

GUICtrlCreateLabel("TIME:", $ui_w*.15, $ui_h*.57, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("NEAREST CRIME ID:", $ui_w*.15, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$nearid = GUICtrlCreateLabel("<ID>", $ui_w*.23, $ui_h*.545, 140, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)


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

$browse_model = GUICtrlCreateButton(" O O O ",$ui_w*0.21+125,$ui_h*.686,50,18)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($browse_model,0xbcbcbc)

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

GUICtrlCreateLabel("Use model set:", $ui_w*0.21+20, $ui_h*.68, 100, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Include changes to dataset and redraw", $ui_w*0.21+20,  $ui_h*.73, 260, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER , "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel("Calculate and Draw predicted Target based on pattern", $ui_w*0.21+20, $ui_h*.77, 198, 50)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

GUICtrlCreateLabel(":",$ui_w*0.21+230, $ui_h*.77, 5, 28, 0x0200)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)



;LABELS AND BUTTON IN 3RD STATUS BAR

GUICtrlCreateLabel("LOAD MAP PATTERN BASED ON SQL QUERY:", $ui_w*0.45+20, $ui_h*.67, 250, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, $GUI_FONTUNDER, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xd5d5d5)

$sql_filterquery = GUICtrlCreateEdit("SELECT * FROM map", $ui_w*0.45+25, $ui_h*.71, 280, 140)

$exec_query = GUICtrlCreateButton("Execute query", $ui_w*0.45+40, $ui_h*.90, 120, 30)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

$view_mapdb = GUICtrlCreateButton("View map db", $ui_w*0.45+170, $ui_h*.90, 120, 30)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)

;LABELS AND BUTTON IN 4TH STATUS BAR

$GOTO_BUTTON = GUICtrlCreateButton("GO TO", $ui_w*.68, $ui_h*.68, 80, 65)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($GOTO_BUTTON, 0x7f7f7f)

$LAT_IN = GUICtrlCreateInput("", $ui_w*.74+35, $ui_h*.675+3, 145, 22) ; LAT input box

$LONG_IN = GUICtrlCreateInput("", $ui_w*.87+40, $ui_h*.675+3, 145, 22) ; LAT input box

$ADDRESS_IN = GUICtrlCreateInput("", $ui_w*.74+70, $ui_h*.725+3, 180, 22) ; LAT input box

$rangcirc = GUICtrlCreateInput("10", $ui_w*.80, $ui_h*.835,100,25)
$opacirc = GUICtrlCreateInput("0.5", $ui_w*.95, $ui_h*.835,50,25)
$titlcirc = GUICtrlCreateInput("",$ui_w*.80, $ui_h*.880,270)

$crimidcirc = GUICtrlCreateInput("",$ui_w*.91, $ui_h*.80,70,25)
GUICtrlCreateUpdown(-1)

$crmtyp = GUICtrlCreateCombo("Unknown",$ui_w*.68, $ui_h*.92, 120,95)
GUICtrlSetData(-1,"Theft|Accident|Rape|Murder","Unknown")

$timecirc =  GUICtrlCreateDate("",$ui_w*.83, $ui_h*.92 ,190,20)
GUICtrlSendMsg(-1, $DTM_SETFORMATW, 0, "yyyy/MM/dd HH:mm:ss")

$DROP_CIRCLE = GUICtrlCreateButton("DROP CIRCLE", $ui_w*.68, $ui_h*.81, 120,45)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($DROP_CIRCLE, 0x7f7f7f)

$browse_COLOUR = GUICtrlCreateButton(" O O O ",$ui_w*.77+53, $ui_h*.802,40,16)
GUICtrlSetFont(-1, 6, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor($browse_COLOUR,0xbcbcbc)

$color_selected = GUICtrlCreateLabel("0xFF0000",$ui_w*.80+53,$ui_h*.802,100,16)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xFF0000)

GUICtrlCreateLabel("Theft type:",$ui_w*.68, $ui_h*.89, 120,95)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("Meter",$ui_w*.87, $ui_h*.835,100,25)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("CRMID:",$ui_w*.875, $ui_h*.80,100)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("Select Time:",$ui_w*.765, $ui_h*.92,100)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LAT:", $ui_w*.74, $ui_h*.675, 30, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("LONG:", $ui_w*.87, $ui_h*.675, 35, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("ADDRESS:", $ui_w*.74, $ui_h*.725, 65, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("COLOUR:", $ui_w*.77, $ui_h*.795, 48, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("RANGE:", $ui_w*.77, $ui_h*.835, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("Title:", $ui_w*.77, $ui_h*.880, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

GUICtrlCreateLabel("OPACITY:", $ui_w*.91, $ui_h*.835, 160, 28, 0x0200)
GUICtrlSetFont(-1, 10, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)



GUICtrlCreateLabel("CIRCLE", $ui_w*.961, $ui_h*.79, 160, 28, 0x0200)
GUICtrlSetFont(-1, 11, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)

$map_hndl = GUICtrlCreateObj($mainmap,$ui_w*.3, $ui_h*.1, $ui_w*.4, $ui_h*.55)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)

_IENavigate($mainmap,"http://localhost:8843/map_test.html")

$crimlst = GUICtrlCreateListView("Crime ID|latitude|Longitude|Title",$ui_w*.01, $ui_h*.14, $ui_w*.28, $ui_h*.38)

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

;This should be here due to some unknown error in autoit
Global $grph = GUICtrlCreateObj($grph_hndl, 0, $ui_h*.1, $ui_w*.65, $ui_h*.55)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
_IENavigate($grph_hndl, "http://localhost:8843")
ConsoleWrite("Passed all functions")
_updatelistnodeclass()
_loadlatlonglist()
GUICtrlSetBkColor($scene, 0x323232)
GUISetState(@SW_SHOW)
GUICtrlSetData($list_nodeedit,"Description goes here..")
_redrawmap()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $GUI_CLOSE_BUTTON
			_Metro_GUIDelete($gui) ;Delete GUI/release resources, make sure you use this when working with multiple GUIs!
			_GDIPlus_Shutdown()
			_SQLite_Close()
			_SQLite_Shutdown()
			Exit

		Case $GUI_MINIMIZE_BUTTON
			GUISetState(@SW_MINIMIZE, $gui)

		;GUI Response for tabs

		Case $map
			ConsoleWrite("clicked map "&@CRLF)
			GUICtrlSetState($grph,$GUI_HIDE)
			_GUICtrlTab_ActivateTab($maintab,1)

		Case $scene
			ConsoleWrite("clicked scne "&@CRLF)
			GUICtrlSetState($grph,$GUI_SHOW)
			_GUICtrlTab_ActivateTab($maintab,0)

		;GUI Response for Scene
		Case $trn_scene
			$redval = _readcmd('python json_parser.py -m sukubro -f %cd%\json\main3.json -i 22')
			MsgBox(Default,Default,$redval)


		Case $add_node
			_nodeaddnode()
			_GUICtrlListView_DeleteAllItems($list_nodeclass)
			_updatelistnodeclass()

		Case $export_node_connection
			$nodeserial = _execjavascript($grph_hndl,"JSON.stringify(graph.serialize(),null,2);")
			$path = FileSaveDialog("Save Json As",@ScriptDir &"\Json\","Jsons (*.json)",$FD_PATHMUSTEXIST)
			FileWrite($path,$nodeserial)


		Case $clear_nodes
			_IEAction($grph_hndl,"refresh")

		Case $get_nodes_description
				$clmn_selc = (StringStripWS(_GUICtrlListView_GetSelectedIndices($list_nodeclass),8)-1)+1 ;added -1 + 1 I Dont know some error maybe
				$rd_fle = FileReadToArray(@ScriptDir &"\nodes\customnode_ref.js")
				;MsgBox(Default,Default,$clmn_selc)
				For $i = 0 To UBound($rd_fle)-1
					;MsgBox(Default,Default,_StringBetween($rd_fle[$i],_StringBetween($rd_fle[$i],'.wrapFunctionAsNode("','/')[0] &'/','",')[0] &@CRLF &_GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,1)[3])
					If _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,0)[3] == 'Parent' Then
						$kamal = ""
					Else
						$kamal = _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,0)[3] &"/"
					EndIf
					If _StringBetween($rd_fle[$i],'.wrapFunctionAsNode("','",')[0] == $kamal & _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,1)[3] Then
						GUICtrlSetData($list_nodeedit,StringReplace(_StringBetween($rd_fle[$i],"//Description:","")[0],"\n",@CRLF))
					EndIf
				Next

		Case $delete_node
			$clmn_selc = (StringStripWS(_GUICtrlListView_GetSelectedIndices($list_nodeclass),8)-1)+1 ;added -1 + 1 I Dont know some error maybe
				$rd_fle = FileReadToArray(@ScriptDir &"\nodes\customnode_ref.js")
				;MsgBox(Default,Default,$clmn_selc)
				For $i = 0 To UBound($rd_fle)-1
					If _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,0)[3] == 'Parent' Then
						$kamal = ""
					Else
						$kamal = _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,0)[3] &"/"
					EndIf
					If _StringBetween($rd_fle[$i],'.wrapFunctionAsNode("','",')[0] == $kamal & _GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,1)[3] Then
						_GUIDisable($gui, 0, 30) ;For better visibility of the MsgBox on top of the first GUI.
						$yno = _Metro_MsgBox(4, "Delete node", "Do you wish to Delete the following nodes: " &@CRLF &_GUICtrlListView_GetItem($list_nodeclass,$clmn_selc,1)[3], 350, 11, $gui)
						_GUIDisable($gui)
						If $yno == 'Yes' Then
							_ArrayDelete($rd_fle,$i)
							_FileWriteFromArray(@ScriptDir &"\nodes\customnode_ref.js",$rd_fle)
							_updatelistnodeclass()
						EndIf
						ExitLoop
					EndIf
				Next

		Case $show_fir
			$pdf_path = FileOpenDialog("Open FIR pdf",@ScriptDir,"pdf (*.pdf)")
			If Not @error Then
                    $pdf_view.Stop() ; stop loadinh (if any in progress)
                    $pdf_view.document.Write(MakeHTML($pdf_path)) ; inject lising directly to the HTML document
                    $pdf_view.document.execCommand("Refresh")
			EndIf

		Case $load_node_connection
			$jsonpath = FileOpenDialog("Select Graph to import",@ScriptDir,"Json (*.json)")
			$jsread = "graph.configure(JSON.parse('" &StringReplace(FileRead($jsonpath),@LF,"") &"'));"
			$grph_hndl.document.parentwindow.eval($jsread)



		;Gui response for map
		Case $GOTO_BUTTON
			$latn = guictrlread($LAT_IN)
			$longn = GUICtrlRead($LONG_IN)
			$query = GUICtrlRead($ADDRESS_IN)
			If Not StringIsSpace($latn) And Not StringIsSpace($longn) Then
				_zoomtoaddress($latn,$longn)
			ElseIf Not StringIsSpace($query) Then
				$mapkom = _getlatlong($query)
				If IsArray($mapkom) Then _zoomtoaddress($mapkom[2],$mapkom[3])
			EndIf

		Case $browse_COLOUR
			$chosn = _ChooseColor(2,$COLOR_RED,2)
			GUICtrlSetData($color_selected,$chosn)
			GUICtrlSetColor($color_selected,$chosn)

		Case $DROP_CIRCLE
			Local $curdrop[] = [$currentlatln[0],$currentlatln[1],GUICtrlRead($rangcirc),GUICtrlRead($color_selected),GUICtrlRead($crimidcirc),GUICtrlRead($opacirc),GUICtrlRead($timecirc),GUICtrlRead($titlcirc),GUICtrlRead($crmtyp)]
			_ArrayAdd($drop_array,$curdrop)
			_drawcircle($curdrop[7]&":"&$curdrop[4],$curdrop[0],$curdrop[1],$curdrop[2],$curdrop[3],$curdrop[5])
			_writetodb($curdrop)

		Case $view_mapdb
			Local $arysql,$aryrowsql,$aryclmnsql
			_SQLite_GetTable2d($store_db,"Select * FROM map;",$arysql,$aryrowsql,$aryclmnsql)
			_ArrayDisplay($arysql,"Map database")

		Case $Delete_currentloc
			$seleccrim = _GUICtrlListView_GetItemTextArray($crimlst)
			If Not @error Then
				_SQLite_Exec ( $store_db, "DELETE FROM map WHERE latitude like " &$seleccrim[2]   &" AND longitude like " &$seleccrim[3] &";")
				_loadlatlonglist()
			EndIf

		Case $search_id
			$iI = _GUICtrlListView_FindInText($crimlst, GUICtrlRead($search_id), -1)
			_GUICtrlListView_EnsureVisible($crimlst, $iI)

		Case $REDRAW_MAP
			_redrawmap()

		Case $goto_selection
			$seleccrim = _GUICtrlListView_GetItemTextArray($crimlst)
			_zoomtoaddress($seleccrim[2],$seleccrim[3])

		Case $exec_query
			_redrawbasedonquery(GUICtrlRead($sql_filterquery))

		Case $CLEAR_MAP
			_IENavigate($mainmap,"refresh")


	EndSwitch

$curlatln = _getcurlatln()
If $curlatln <> '' Then
	$currentlatln = StringSplit(StringTrimRight(StringTrimLeft($curlatln,1),1),",", $STR_NOCOUNT )
	GUICtrlSetData($latvar,$currentlatln[0])
	GUICtrlSetData($longvar,$currentlatln[1])
	Local $hQuery,$aRow
	_SQLite_Query($store_db, 'SELECT * FROM map ORDER BY ABS(latitude - '&$currentlatln[0]&') + ABS(longitude - ' &$currentlatln[1] &') ASC;', $hQuery)
	_SQLite_FetchData($hQuery, $aRow, False, False)
	$crmid_near = $aRow[5]
	GUICtrlSetData($nearid,$crmid_near)
EndIf

WEnd

#EndRegion

#Region Functions



Func _readcmd($cmd)
Local $iPID = Run(@ComSpec & " /c "&$cmd, @ScriptDir, @SW_HIDE, BitOR($STDERR_CHILD, $STDOUT_CHILD))
$sOutput = ''
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ; Exit the loop if the process closes or StderrRead returns an error.
            ExitLoop
        EndIf
    WEnd
Return $sOutput
EndFunc

Func MakeHTML($sPdfPath = '')
    Local $sHTML = '<html>' & @CRLF & _
            '<head>' & @CRLF & _
            '<meta http-equiv="X-UA-Compatible" content="IE=edge" />' & @CRLF & _
            '</head>' & @CRLF & _
            '<body>' & @CRLF & _
            '<div class="container">' & @CRLF & _
            '  <div class="pdf">' & @CRLF & _
            '   <object data="' & $sPdfPath & '" type="application/pdf" width="100%" height="100%">' & @CRLF & _
            '    <iframe src="' & $sPdfPath & '" width="100%"    height="100%" style="border: none;">' & @CRLF & _
            '     This browser does not support PDFs. Please download the PDF to view it: ' & @CRLF & _
            '     <a href="' & $sPdfPath & '">Download PDF</a>' & @CRLF & _
            '    </iframe>' & @CRLF & _
            '   </object>' & @CRLF & _
            '  </div>' & @CRLF & _
            '</div>' & @CRLF & _
            '</body>' & @CRLF & _
            '</html>'
    Return $sHTML
EndFunc   ;==>MakeHTML

Func _redrawbasedonquery($querypass)
Local $arysql,$aryrowsql,$aryclmnsql
$ret = _SQLite_GetTable2d($store_db,$querypass,$arysql,$aryrowsql,$aryclmnsql)
If Not @error Then
_IEAction($mainmap,"refresh")
For $i = 1 to UBound($arysql)-1
	_drawcircle($arysql[$i][8]&":"&$arysql[$i][5],$arysql[$i][1],$arysql[$i][2],$arysql[$i][3],$arysql[$i][4],$arysql[$i][6])
Next
Else
MsgBox($MB_ICONERROR,"Error Query","Error in sql query " &@CRLF &_SQLite_ErrMsg() &@CRLF &"Please validate your query")
EndIf
EndFunc

Func _redrawmap()
Local $arysql,$aryrowsql,$aryclmnsql
_SQLite_GetTable2d($store_db,"Select * FROM map;",$arysql,$aryrowsql,$aryclmnsql)
_IEAction($mainmap,"refresh")
For $i = 1 to UBound($arysql)-1
	_drawcircle($arysql[$i][8]&":"&$arysql[$i][5],$arysql[$i][1],$arysql[$i][2],$arysql[$i][3],$arysql[$i][4],$arysql[$i][6])
Next
EndFunc

Func distancebtwnlatlongMeters($lat1, $lon1, $lat2, $lon2)
  $x = _Radian( $lon1 - $lon2 ) * cos( _Radian( ($lat1+$lat2) /2 ) )
  $y = _Radian( $lat1 - $lat2 )
  $dist = 6371000.0 * sqrt( $x*$x + $y*$y )

  return $dist
EndFunc

Func _writetodb($curdrops)
_SQLite_Exec(-1, "INSERT INTO map (latitude,longitude,radius,color,crimeid,opacity,time,title,type) VALUES ('" &_ArrayToString($curdrops,"','") &"');")
_loadlatlonglist()
EndFunc

Func _loadlatlonglist()
_GUICtrlListView_DeleteAllItems($crimlst)
Local $hQuery,$aRow
_SQLite_Query(-1, "SELECT * FROM map ;", $hQuery)
While _SQLite_FetchData($hQuery, $aRow, False, False) = $SQLITE_OK
	GUICtrlCreateListViewItem($aRow[5]&"|"&$aRow[1]&"|"&$aRow[2]&"|"&$aRow[8],$crimlst)
WEnd
_SQLite_QueryFinalize($hQuery)
EndFunc

Func _updatelistnodeclass()
_GUICtrlListView_DeleteAllItems($list_nodeclass)
$nodeclasses = FileReadToArray(@ScriptDir &"\nodes\customnode_ref.js")
For $i = 0 To UBound($nodeclasses) - 1
	If Not StringIsSpace($nodeclasses[$i]) Then
		$nam = _StringBetween($nodeclasses[$i],'.wrapFunctionAsNode("','",')
		If StringInStr($nam[0],"/") Then
		$kam = StringReplace($nam[0],"/","|",1)
		Else
		$kam = "Parent|"&$nam[0]
		EndIf
		$ind = _StringBetween($nodeclasses[$i],",node",",")
		GUICtrlCreateListViewItem($kam&"|" &$ind[0],$list_nodeclass)
	EndIf
Next


EndFunc

Func _nodeaddnode()
_GUIDisable($gui, 0, 30)
$nodeadd = _Metro_CreateGUI("Add Node Model", $ui_w*.3, $ui_h*.50)
ConsoleWrite($ui_w*.3&"-" & $ui_h*.55)
$Control_Buttons1 = _Metro_AddControlButtons(True, False, True, False, False)
$GUI_CLOSE_BUTTON1 = $Control_Buttons1[0]
$GUI_MINIMIZE_BUTTON1 = $Control_Buttons1[3]

GUICtrlCreateLabel("Node Title:", 32, 24, 56, 17)
GUICtrlSetColor(-1, 0xd5d5d5)
$nod_title = GUICtrlCreateInput("nod_title", 104, 24, 129, 21)
GUICtrlCreateLabel("Add inputs:", 24, 64, 73, 25)
GUICtrlSetColor(-1, 0xd5d5d5)
$inputs = GUICtrlCreateInput("0", 104, 64, 129, 21)
GUICtrlCreateUpdown(-1)
GUICtrlCreateLabel("Outputs Add", 24, 104, 73, 25)
GUICtrlSetColor(-1, 0xd5d5d5)
$listadd = GUICtrlCreateListView("Node Title|Node Type input|Node Type output|Node Inputs|Node description", 24, 136, 257, 214)
$remcur = GUICtrlCreateButton("Remove Current Selection", 296, 192, 145, 33)
$adddb = GUICtrlCreateButton("Add to Database", 24, 368, 129, 33)
$ldjs = GUICtrlCreateButton("Load from js", 176, 368, 97, 33)
GUICtrlCreateLabel("Type:", 248, 72, 31, 17)
GUICtrlSetColor(-1, 0xd5d5d5)
GUICtrlCreateLabel("Type:", 147, 105, 31, 17)

GUICtrlSetColor(-1, 0xd5d5d5)
$typinp = GUICtrlCreateCombo("", 288, 64, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "*|boolean|number|string", "*")
$typout = GUICtrlCreateCombo("", 188, 100, 105, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "*|boolean|number|string", "*")
$add_nodem = GUICtrlCreateButton("Add node",296,144,145,33)
GUICtrlCreateLabel("Add Description:",296,230,100)
GUICtrlSetColor(-1, 0xd5d5d5)
$node_descp = GUICtrlCreateEdit("Type your node description here.",296,250,145,150)



GUISetState(@SW_SHOW,$nodeadd)
While 1
$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_CLOSE_BUTTON1,$GUI_EVENT_CLOSE
			_Metro_GUIDelete($nodeadd)
			ExitLoop

		Case $GUI_MINIMIZE_BUTTON1
			GUISetState(@SW_MINIMIZE, $nodeadd)

		Case $add_nodem
			;Node Title|Node Type input|Node Type output|Node Outputs|Node Inputs
			GUICtrlCreateListViewItem(GUICtrlRead($nod_title) &"|" &GUICtrlRead($typinp) &"|" &GUICtrlRead($typout)  &"|" & GUICtrlRead($inputs)&"|" & GUICtrlRead($node_descp),$listadd)

		Case $remcur
			_GUICtrlListView_DeleteItemsSelected($listadd)

		Case $adddb
			$nodetits = ''
			If _GUICtrlListView_GetItemCount($listadd) > 0 Then
				For $i = 0 To _GUICtrlListView_GetItemCount($listadd) - 1
					$nodetits &= _GUICtrlListView_GetItem($listadd,$i,0)[3] &@CRLF
				Next
				ConsoleWrite($nodetits)
				_GUIDisable($nodeadd, 0, 30) ;For better visibility of the MsgBox on top of the first GUI.
				$yno = _Metro_MsgBox(4, "Add node", "Do you wish to add the following nodes: " &@CRLF &$nodetits, 350, 11, $nodeadd)
				_GUIDisable($nodeadd)
				If $yno == 'Yes' Then
					For $i = 0 To _GUICtrlListView_GetItemCount($listadd) - 1
						;MsgBox(Default,Default,_GUICtrlListView_GetItemTextArray($listadd, $i))
						_addnodetodb(_GUICtrlListView_GetItemTextArray($listadd, $i))
					Next
					_GUICtrlListView_DeleteAllItems ($listadd)
					GUISetState(@SW_RESTORE,$nodeadd)
				EndIf
			EndIf

	EndSwitch
_GUIDisable($gui)
WEnd

EndFunc

Func _addnodetodb($node)
$inp = StringTrimRight(_StringRepeat('"' &$node[2] &'",',$node[4]),1)
;'Node Title|Node Type input|Node Type output|Node Outputs|Node Inputs'
$fnc = 'LiteGraph.wrapFunctionAsNode("' &$node[1] &'",node' &$node[4] &',"['&$inp&']","'&$node[3]&'");//Description:'&StringReplace($node[5],@CRLF,"\n") &@CRLF
FileWriteLine(@ScriptDir &"\nodes\customnode_ref.js",$fnc)
$nodeserial = _execjavascript($grph_hndl,"JSON.stringify(graph.serialize(),null,2);")
_IEAction($grph_hndl, "refresh")
$jsread = "graph.configure(JSON.parse('" &StringReplace($nodeserial,@LF,"") &"'));"
$grph_hndl.document.parentwindow.eval($jsread)
EndFunc

Func _hovermethod($id)
;make current button to another color on click
Switch $id
	Case $scene,$map,$DB
		GUICtrlSetBkColor($id, 0x323232)
		Local $lf[] = [$scene,$map,$DB]
		_setelse($lf,$id,0x191919)

	Case $file_button,$save_button,$settings_button
		GUICtrlSetBkColor($id, 0x7f7f7f)
		Local $lf[] = [$file_button,$save_button,$settings_button]
		_setelse($lf,$id,0x323232)

EndSwitch

EndFunc

Func _setelse($ary,$selec,$corl)
For $i = 0 To UBound($ary)-1
	If $ary[$i] <> $selec Then GUICtrlSetBkColor($ary[$i],$corl)
Next
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $nNotifyCode = _WinAPI_HiWord($wParam)
	Local $iId = _WinAPI_LoWord($wParam)
	Local $hCtrl = $lParam

	If $iId <> 2 And $nNotifyCode = 0 Then ; Check for IDCANCEL - 2
		_hovermethod($iId)
	EndIf

	ConsoleWrite($iId)


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
$exec = "drawcircle('" &$title &"'," &$lat &"," &$long &"," &$radius*0.621371 &",'#" &StringTrimLeft($color,2) &"'," &$opac &");"
ConsoleWrite($exec)
$mainmap.document.parentwindow.eval($exec)
EndFunc

Func _zoomtoaddress($lat,$long)
$mainmap.document.parentwindow.eval("zoomtolocation(" &$lat &"," &$long &");")
EndFunc

Func _getlatlong($query)
$whergui = _Metro_CreateGUI("Address finder", 382, 424, 289, 194)
$Control_Buttons2 = _Metro_AddControlButtons(True, False, True, False, False)
$GUI_CLOSE_BUTTON2 = $Control_Buttons2[0]
$GUI_MINIMIZE_BUTTON2 = $Control_Buttons2[3]

GUICtrlCreateLabel("Where do you wish to go", 16, 16, 122, 17)
GUICtrlSetColor(-1, 0xd5d5d5)
GUICtrlCreateLabel("Query:", 16, 40, 35, 17)
GUICtrlSetColor(-1, 0xd5d5d5)
$qurinp = GUICtrlCreateInput($query, 56, 40, 145, 21)
GUICtrlCreateLabel("Possible Hits:", 16, 80, 67, 17)
GUICtrlSetColor(-1, 0xd5d5d5)
$Listbar = GUICtrlCreateListView("display_name|latitude|longitude", 16, 104, 345, 227)
$gotoloc = GUICtrlCreateButton("Goto location", 96, 352, 193, 33)
$findloc = GUICtrlCreateButton("Find", 216, 40, 65, 25)
_getlatlongquery($query,$Listbar)
GUISetState(@SW_SHOW,$whergui)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_CLOSE_BUTTON2,$GUI_EVENT_CLOSE
			$ret = ''
			ExitLoop

		Case $findloc
			$query = GUICtrlRead($qurinp)
			_getlatlongquery($query,$Listbar)

		Case $gotoloc
			$clmn_selc = (StringStripWS(_GUICtrlListView_GetSelectedIndices($Listbar),8)-1)+1
			$ret = _GUICtrlListView_GetItemTextArray($Listbar,$clmn_selc)
			;_ArrayDisplay($ret)
			ExitLoop

	EndSwitch
WEnd
_Metro_GUIDelete($whergui)
Return $ret
EndFunc

Func _getlatlongquery($query,$Listbar)
$urlqur = "https://nominatim.openstreetmap.org/search?q="&$query&"&format=xml"
$xmlpars = BinaryToString(InetRead($urlqur))

$oXMLDoc = _XML_CreateDOMDocument(Default)
_XML_LoadXml($oXMLDoc, $xmlpars)
$oNodesColl = _XML_SelectNodes($oXMLDoc, "//place")
$aNodesColl = _XML_Array_GetNodesProperties($oNodesColl)

For $i = 0 To UBound($aNodesColl)-2
$oAttriubtes = _XML_GetAllAttribIndex($oXMLDoc, '//place', $i)
$attrl = _XML_Array_GetAttributesProperties($oAttriubtes)
GUICtrlCreateListViewItem($attrl[_ArraySearch($attrl,"display_name",0,0,0,1,1,0)][3]&"|"&$attrl[_ArraySearch($attrl,"lat",0,0,0,1,1,0)][3]&"|"&$attrl[_ArraySearch($attrl,"lon",0,0,0,1,1,0)][3],$Listbar)
Next

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