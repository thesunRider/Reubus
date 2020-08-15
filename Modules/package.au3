; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>

Opt('TrayIconHide',1)
$guihndl = GUICreate("Embedded Web control Test", 640, 580, _
        (@DesktopWidth - 640) / 2, (@DesktopHeight - 580) / 2)
GUISetBkColor(0x191919,$guihndl)

Local $oIE = _IECreateEmbedded()
GUICtrlCreateObj($oIE, 10, 40, 600, 450)

Local $idButton_Back = GUICtrlCreateButton("Back", 10, 520, 100, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)
Local $idButton_Forward = GUICtrlCreateButton("Forward", 120, 520, 100, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)
Local $idButton_Home = GUICtrlCreateButton("Home", 230, 520, 100, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)
Local $idButton_Stop = GUICtrlCreateButton("Stop", 340, 520, 100, 30)
GUICtrlSetFont(-1, 9, Default, Default, "Consolas", 5); 5 = Clear Type
GUICtrlSetColor(-1, 0xffffff)
GUICtrlSetBkColor(-1, 0x7f7f7f)


ConsoleWrite($guihndl)

GUISetState(@SW_SHOW) ;Show GUI

_IENavigate($oIE, "http://www.google.com")
_IEAction($oIE, "stop")

; Waiting for user to close the window
While 1
    Local $iMsg = GUIGetMsg()
    Select
        Case $iMsg = $GUI_EVENT_CLOSE
            ExitLoop
        Case $iMsg = $idButton_Home
            _IENavigate($oIE, "http://www.google.com")
            _IEAction($oIE, "stop")
            _IEAction($oIE, "back")
        Case $iMsg = $idButton_Back
            _IEAction($oIE, "back")
        Case $iMsg = $idButton_Forward
            _IEAction($oIE, "forward")
        Case $iMsg = $idButton_Stop
            _IEAction($oIE, "stop")
    EndSelect
WEnd
