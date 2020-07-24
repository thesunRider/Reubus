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

Global $gui = _Metro_CreateGUI("Reubus", 1024 , 768, -1, -1,True)
$Control_Buttons = _Metro_AddControlButtons(True, False, True, False, False)

$GUI_CLOSE_BUTTON = $Control_Buttons_welcome[0]
$GUI_MAXIMIZE_BUTTON = $Control_Buttons[1]
$GUI_RESTORE_BUTTON = $Control_Buttons[2]
$GUI_MINIMIZE_BUTTON = $Control_Buttons[3]
$GUI_FULLSCREEN_BUTTON = $Control_Buttons[4]
$GUI_FSRestore_BUTTON = $Control_Buttons[5]
$GUI_MENU_BUTTON = $Control_Buttons[6]


$maintab = GUICtrlCreateTab(600,100)

Global $grph_hndl = _IECreateEmbedded()
Global $mainmap = _IECreateEmbedded()


GUICtrlCreateTabItem("tab1")

GUICtrlCreatePic(@ScriptDir &"\gui_components\low_layout.jpg",0,@DesktopHeight-304,1920,304)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlCreatePic(@ScriptDir &"\gui_components\low_status_layout.jpg",0,@DesktopHeight-42,1920,42)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlCreatePic(@ScriptDir &"\gui_components\seperator1_layout.jpg",200,560,3,259)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlCreatePic(@ScriptDir &"\gui_components\seperator1_layout.jpg",475,560,3,259)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlCreatePic(@ScriptDir &"\gui_components\seperator1_layout.jpg",600,78,3,483)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)

$LabelFPS=GUICtrlCreateLabel("FPS RELATED INFO",10,570,200,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($LabelFPS,10,20,0,"Times New Roman")
$LabelCPU=GUICtrlCreateLabel("CPU DRAW",10,610,150,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($LabelCPU,10,20,0,"Times New Roman")
$LabelRAM=GUICtrlCreateLabel("RAM DRAW",10,650,150,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont($LabelRAM,10,20,0,"Times New Roman")


;$sm = GUICtrlCreatePic("logo.jpg",0,1642,1920,42)
;GUICtrlCreatePic(@ScriptDir &"\gui_components\low_status_layout.jpg",0,@DesktopHeight-42,1920,42)

Global $grph = GUICtrlCreateObj($grph_hndl, 0, 79, 600, 481)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)

_IENavigate($grph_hndl, "http://localhost:8843/")




GUICtrlCreateTabItem("tab2")

GUICtrlCreateObj($mainmap, 400, 79, 600, 481)
_IENavigate($mainmap,"http://localhost:8843/map_test.html")

$crimlst = GUICtrlCreateListView("Crime ID|latitude|Longitude",10,100,400,500)


GUICtrlCreateTabItem("")

GUICtrlCreatePic(@ScriptDir &"\gui_components\Layer 2_layout.jpg",0,39,1920,39)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlCreatePic("",10,46,121,24)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
_loadpic(-1,@ScriptDir &"\gui_components\png\Layer 3_layout.png")
GUICtrlCreatePic("",141,46,121,24)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
_loadpic(-1,@ScriptDir &"\gui_components\png\Layer 5_layout.png")
$LabelFile=GUICtrlCreateLabel("file",55,48,50,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont($LabelFile,15,20,0,"Times New Roman")
$LabelSave=GUICtrlCreateLabel("save",185,48,50,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont($LabelSave,15,20,0,"Times New Roman")

GUICtrlCreatePic(@ScriptDir &"\gui_components\low_status_layout.jpg",0,738,1920,42)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
$sc1 = GUICtrlCreatePic("",0,738,155,38)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO )
_loadpic(-1,@ScriptDir &"\gui_components\png\scene_in_focus_layout.png")
$sc2 = GUICtrlCreatePic("",148,738,155,38)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO )
_loadpic(-1,@ScriptDir &"\gui_components\png\scene_out_focus_layout.png")
$sc3 = GUICtrlCreatePic("",296,738,155,38)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO )
_loadpic(-1,@ScriptDir &"\gui_components\png\scene_out_focus_layout.png")


$LabelScene1=GUICtrlCreateLabel("SCENE1",60,745,70,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont($LabelScene1,10,20,0,"Times New Roman")
$LabelScene2=GUICtrlCreateLabel("SCENE2",208,745,70,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont($LabelScene2,10,20,0,"Times New Roman")
$LabelScene3=GUICtrlCreateLabel("SCENE3",356,745,70,50)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont($LabelScene3,10,20,0,"Times New Roman")



Do
Sleep(50)
Until $mainmap.document.getElementById("debug").value == "1256"



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

		Case $LabelScene1
			ConsoleWrite("clicked")
			_GUICtrlTab_ActivateTab($maintab,0)


	EndSwitch
WEnd

#EndRegion

#Region Functions

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