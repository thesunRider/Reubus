#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <File.au3>
#include <ButtonConstants.au3>


Global $Fill = @ScriptDir & "\sample.ini"

IniWriteSection(@ScriptDir & "\sample.ini", "ITEM1", "1=2")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM2", "1=3")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM3", "1=4")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM4", "1=5")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM5", "1=6")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM6", "1=7")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM7", "1=8")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM8", "1=9")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM9", "1=10")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM10", "1=11")
IniWriteSection(@ScriptDir & "\sample.ini", "ITEM11", "1=12")

$Gui = GUICreate("Gui", 300, 250)
$LV = GUICtrlCreateListView("Item|Value", 18, 40, 260, 200)
_GUICtrlListView_SetExtendedListViewStyle($LV, BitOR($LVS_EX_FULLROWSELECT, $LVS_EX_GRIDLINES))
GUICtrlSendMsg(-1, 0x101E, 0, 130)
GUICtrlSendMsg(-1, 0x101E, 1, 125)
;GUICtrlCreateTabItem("") ; This ends the tab item creation
$Button2 = GUICtrlCreateButton("Search", 180, 10, 100, 22, 0)
$Input = GUICtrlCreateInput("Enter Search Term...", 20, 10, 150, 22)

Populate()
GUISetState(@SW_SHOW)

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            FileDelete($Fill)
            Exit
        Case $Button2
            Search()
    EndSwitch
WEnd


Func Populate()
    Local $aArray = IniReadSectionNames($Fill)
    If Not @error Then
        ; Enumerate through the array displaying the section names.
        For $i = 1 To $aArray[0]
        $Value = IniRead($Fill, $aArray[$i], "1", "")
        GUICtrlCreateListViewItem($aArray[$i] & "|" & $Value, $LV)
        ;_GUICtrlListView_SimpleSort($ListView1, $Sort, 0, False) ;<<<<<<<<<<<<<< Works but slows down load time.
        Next
    EndIf
EndFunc


Func Search()
    $value = GUICtrlRead($Input)
    $iI = _GUICtrlListView_FindInText($LV, $value, -1)
    _GUICtrlListView_EnsureVisible($LV, $iI)
EndFunc