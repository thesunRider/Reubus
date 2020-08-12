; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>

Opt('TrayIconHide',1)
$guihndl = GUICreate("Embedded Web control Test", 640, 580, _
        (@DesktopWidth - 640) / 2, (@DesktopHeight - 580) / 2)
Local $idButton_Back = GUICtrlCreateButton("Back", 10, 420, 100, 30)
Local $idButton_Forward = GUICtrlCreateButton("Forward", 120, 420, 100, 30)
Local $idButton_Home = GUICtrlCreateButton("Home", 230, 420, 100, 30)
Local $idButton_Stop = GUICtrlCreateButton("Stop", 340, 420, 100, 30)

Global $g_idError_Message = GUICtrlCreateLabel("", 100, 500, 500, 30)
GUICtrlSetColor(-1, 0xff0000)
ConsoleWrite($guihndl)

GUISetState(@SW_SHOW) ;Show GUI


While 1
$nm = GUIGetMsg()
Switch $nm

	Case $GUI_EVENT_CLOSE
			GUIDelete()

		Exit
EndSwitch

WEnd

