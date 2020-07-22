
#include <Winapi.au3>

#include <ButtonConstants.au3>
#include <GDIPlus.au3>
#include <windowsConstants.au3>
#include <AutoitConstants.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>

_GDIPlus_Startup()
Opt("GUICoordMode", 2)
Global Const $hGUI = GUICreate("Test", 300, 200,-1,-1, $WS_SYSMENU)
;GUISetBkColor(0x404040)
Global $iPic = GUICtrlCreatePic("", 10, 10, 143, 180)
GUICtrlSetResizing(-1,$GUI_DOCKAUTO)
_loadpic($iPic,@ScriptDir & "\gui_components\png\scene_in_focus_layout.png")
GUISetState()

Do
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            _Exit()
        Case $iPic
            MsgBox($MB_APPLMODAL, "Test", "Button was pressed")
    EndSwitch
Until False

Func _Exit()
    _WinAPI_DeleteObject($hHBitmap)
    _GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()
    GUIDelete()
    Exit
EndFunc