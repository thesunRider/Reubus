#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include <Math.au3>
#include "MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <Constants.au3>

#include <GUIConstants.au3>

;=======================================================================Creating the GUI===============================================================================
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe

;Set Theme
_SetTheme("DarkTeal") ;See MetroThemes.au3 for selectable themes or to add more

;Create resizable Metro GUI
$hGUI = _Metro_CreateGUI("Example", 500, 300, -1, -1, True)

GUICtrlCreateLabel("some buttons here", 10, 10)

GUIRegisterMsg($WM_SIZE, "WM_SIZE")
GUIRegisterMsg($WM_EXITSIZEMOVE, "WM_EXITSIZEMOVE")
GUIRegisterMsg($WM_ACTIVATE, "WM_ACTIVATE")

Local $hCmd = GUICreate("sukumon",300,100,-1,-1 ,$WS_POPUPWINDOW, $WS_EX_MDICHILD,$hGUI)
GUICtrlCreateLabel("kollam mone",200,50)
GUISetState(@SW_SHOW,$hCmd)

Local $aOriPos = WinGetPos($hCmd)



GUISetState(@SW_SHOW, $hGUI)




Local $hOriParent = _WinAPI_SetParent($hCmd, $hGUI)

Local $iStyle = _WinAPI_GetWindowLong($hCmd, $GWL_STYLE)
_WinAPI_SetWindowLong($hCmd, $GWL_STYLE, BitXOR($iStyle, $WS_OVERLAPPEDWINDOW))

_WinAPI_SetWindowPos($hCmd, 0, 200, 200, 200, 200, BitOR($SWP_FRAMECHANGED, $SWP_NOACTIVATE, $SWP_NOZORDER, $SWP_NOSIZE))
_WinAPI_RedrawWindow($hCmd)
_WinAPI_RedrawWindow($hGUI)

Local $iMsg = 0

While 1
    $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

;restore the cmd window
_WinAPI_SetParent($hCmd, $hOriParent)

_WinAPI_SetWindowLong($hCmd, $GWL_STYLE, $iStyle)
_WinAPI_SetWindowPos($hCmd, 0, $aOriPos[0], $aOriPos[1], $aOriPos[2], $aOriPos[3], BitOR($SWP_FRAMECHANGED, $SWP_NOACTIVATE, $SWP_NOZORDER))

GUIDelete($hGUI)

;when the cmd window is closed the gui is activated, so check if this one has been closed
Func WM_ACTIVATE($hWnd, $iMsg, $wParam, $lParam)
    If Number($wParam) = 1 And WinExists($hCmd) = 0 Then
        GUIDelete($hGUI)
        Exit
    EndIf

    Return $GUI_RUNDEFMSG
EndFunc

;otherwise the menu is not redrawn
Func WM_EXITSIZEMOVE($hWnd, $iMsg, $wParam, $lParam)
    _WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_INVALIDATE)

    Return $GUI_RUNDEFMSG
EndFunc

;resize the cmd window according to the gui
Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
    Local $iWidth = BitAND($lParam, 0xFFFF)
    Local $iHeight = BitShift($lParam, 16)

    WinMove($hCmd, "", 0, 0, $iWidth, $iHeight)

    Return $GUI_RUNDEFMSG
EndFunc