#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

$Form1 = GUICreate("Test Webbrowser", 400,300,400,300, _
         BitOr($GUI_SS_DEFAULT_GUI, $WS_SYSMENU ,$WS_SIZEBOX, $WS_MAXIMIZEBOX))

$Obj = ObjCreate("Shell.Explorer.2")
$browser = GUICtrlCreateObj($Obj, 0, 0, 400, 300)
GUICtrlSetResizing ( -1, $GUI_DOCKRIGHT )

$Obj.Navigate(@ScriptDir&'\FIR\alex.pdf')
GUISetState(@SW_SHOW)


While 1
    $msg = GuiGetMsg()
    Select
    Case $msg = $GUI_EVENT_CLOSE
        ExitLoop
    Case Else
;;;;;;;
    EndSelect
WEnd
Exit