; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>

Local $oIE = _IECreateEmbedded()
GUICreate("Embedded Web control Test", 900, 980, _
        (@DesktopWidth - 640) / 2, (@DesktopHeight - 580) / 2, _
        $WS_OVERLAPPEDWINDOW + $WS_CLIPSIBLINGS + $WS_CLIPCHILDREN)
GUICtrlCreateObj($oIE, 0, 0, 900, 980)

GUISetState(@SW_SHOW) ;Show GUI

_IENavigate($oIE, "http://localhost:8843/WebScrapper/EventSearch.html")
_IEAction($oIE, "stop")

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