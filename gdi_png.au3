; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>
#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include "MetroGUI-UDF\_GUIDisable.au3"

Local $oIE = _IECreateEmbedded()
Local $oIE2 = _IECreateEmbedded()
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe

;Set Theme
_SetTheme("DarkTeal") ;See MetroThemes.au3 for selectable themes or to add more

;Create resizable Metro GUI
$Form1 = _Metro_CreateGUI("Example", 1700, 600, -1, -1, True)

;Add/create control buttons to the GUI
$Control_Buttons = _Metro_AddControlButtons(True, True, True, True, True)

GUICtrlCreateObj($oIE, 0, 40, 600, 460)
GUICtrlCreateObj($oIE2, 700, 40, 600, 460)
GUISetState(@SW_SHOW) ;Show GUI

_IENavigate($oIE, "http://localhost:8843")
Sleep(4000)
_IENavigate($oIE2, "http://localhost:8843")
; Waiting for user to close the window
While 1
    Local $iMsg = GUIGetMsg()
    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop

    EndSelect
WEnd

GUIDelete()

Exit

