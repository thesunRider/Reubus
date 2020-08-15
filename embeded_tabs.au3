#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include <Array.au3>
#include <Math.au3>
#include "MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <Constants.au3>

#include <GUIConstants.au3>

;=======================================================================Creating the GUI===============================================================================
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe
Global $hcmd
;Set Theme
_SetTheme("DarkTeal") ;See MetroThemes.au3 for selectable themes or to add more

;Create resizable Metro GUI
$hGUI = _Metro_CreateGUI("Example", 1000, 800, -1, -1, True)



GUISetState(@SW_SHOW, $hGUI)

$ary = _RunAU3(@ScriptDir &"\Modules\package.au3")
_embedgui($hGUI,$ary,0,0,640,580)
WinWait($ary)
MsgBox(Default,Default,"appeared")
WinSetState($ary,"",@SW_HIDE)
MsgBox(Default,Default,"eitin")
WinSetState($ary,"",@SW_SHOW)

;_ArrayDisplay(WinList())

Func _RunAU3($sFilePath, $sWorkingDir = "", $iShowFlag = @SW_SHOW, $iOptFlag = 0)
	$iPID = Run('"' & @AutoItExe & '" /AutoIt3ExecuteScript "' & $sFilePath & '"', $sWorkingDir, $iShowFlag);, BitOR($STDERR_CHILD, $STDOUT_CHILD))
    Return WinHandFromPID($iPID)
EndFunc   ;==>_RunAU3

Func WinHandFromPID($pid, $winTitle="", $timeout=8)
    Local $secs = 0
    Do
        $wins = WinList($winTitle)
        For $i = 1 To UBound($wins)-1
            If (WinGetProcess($wins[$i][1]) == $pid) And (BitAND(WinGetState($wins[$i][1]), 2)) Then Return $wins[$i][1]
        Next
        Sleep(1000)
        $secs += 1
    Until $secs == $timeout
EndFunc


Func _tabinside()
$hCmd = GUICreate("sukumon",300,100,-1,-1,-1);,BitOR($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX)); ,$WS_POPUPWINDOW, $WS_EX_MDICHILD,$hGUI)
GUICtrlCreateTab(10,10,100,100)
GUICtrlCreateTabItem("poli")
GUICtrlCreateTabItem("mass")
GUICtrlCreateTabItem("podei")
GUISetState(@SW_SHOW,$hCmd)
EndFunc

Func _embedgui($hGUI,$hCmd,$x,$y,$xS,$yS)
Local $hOriParent = _WinAPI_SetParent($hCmd, $hGUI)
Local $iStyle = BitOR(_WinAPI_GetWindowLong($hCmd, $GWL_STYLE) , BitOR($GUI_SS_DEFAULT_GUI,$WS_SIZEBOX,$WS_MAXIMIZEBOX))
_WinAPI_SetWindowLong($hCmd, $GWL_STYLE, BitXOR($iStyle, $WS_OVERLAPPEDWINDOW))
_WinAPI_SetWindowPos($hCmd, 0, $x, $y, $xS, $yS, BitOR($SWP_FRAMECHANGED, $SWP_NOACTIVATE, $SWP_NOZORDER, $SWP_NOSIZE))
_WinAPI_RedrawWindow($hCmd)
_WinAPI_RedrawWindow($hGUI)
EndFunc

Local $iMsg = 0

While 1
    $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

GUIDelete($hGUI)

