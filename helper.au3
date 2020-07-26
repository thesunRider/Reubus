#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBox.au3>
#include <ListViewConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
$hGUI = GUICreate("Sell", 320, 350, -1, -1, BitOR($GUI_SS_DEFAULT_GUI, $WS_MAXIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME, $WS_TABSTOP))
$Input = GUICtrlCreateInput("", 8, 8, 130, 21)
$Input2 = GUICtrlCreateInput("", 8, 55, 130, 21)
$Button_Add = GUICtrlCreateButton("Add", 200, 6, 75, 30)
$Button_Del = GUICtrlCreateButton("Delete", 200, 36, 75, 30)
$Button_Save = GUICtrlCreateButton("Save", 50, 320, 75, 30)
$Button_Load = GUICtrlCreateButton("Load", 200, 320, 75, 30)
$Combo = GUICtrlCreateCombo("", 8, 30, 130, 21, $CBS_DROPDOWNLIST)
For $i = 1 To 10
    GUICtrlSetData($Combo, $i, 1)
Next
$List = GUICtrlCreateListView("Values Added|Amount|Money", 8, 90, 300, 230, _
        BitOR($GUI_SS_DEFAULT_LISTVIEW, $LVS_AUTOARRANGE, $LVS_NOSORTHEADER, $WS_VSCROLL), _
        BitOR($WS_EX_CLIENTEDGE, $LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 150)
GUISetState(@SW_SHOW)
Global $aValues[1][4]
$aValues[0][0] = 0
While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $Button_Add
            Add()
        Case $Button_Del
            ;_GUICtrlListView_DeleteItemsSelected($List)  ; do not use this.
            Local $x
            For $x = $aValues[0][0] To 0 Step -1
                If _GUICtrlListView_GetItemSelected($List, $x) Then
;~                     CW($x & " selected")
                    _ArrayDelete($aValues, $x + 1)
                    $aValues[0][0] = $aValues[0][0] - 1
                    _GUICtrlListView_DeleteItem($List,$x)
                EndIf
            Next
        Case $Button_Save
            Save()
        Case $Button_Load
            Load()
    EndSwitch
WEnd

Func Add()
    Local $vr, $am, $ValueCount
    $value = GUICtrlRead($Input)
    $value2 = GUICtrlRead($Input2)
    $am = GUICtrlRead($Combo)
    $vr = _ArraySearch($aValues, $value, 1)                    ;This adds the name to $aValues[$vr][0]
    If StringStripWS($value, 8) <> "" Then
        If $vr = -1 Then
            $ValueCount = $aValues[0][0] + 1
            _ArrayAdd($aValues, $value)
            $aValues[$ValueCount][3] = GUICtrlCreateListViewItem($value & "|" & $am & "|" & $value2, $List)      ; Save this for later.
            $aValues[$ValueCount][1] = $am
            $aValues[$ValueCount][2] = $value2
            $aValues[0][0] = $ValueCount
        Else
            CW("Value " & $value & " already exists! :adding " & $am & " to " & $aValues[$vr][1])
            $aValues[$vr][1] = $aValues[$vr][1] + $am
            $aValues[$vr][2] = $aValues[$vr][2] + $value2
            _GUICtrlListView_BeginUpdate($List)
            _GUICtrlListView_SetItemText($List, $vr - 1, $aValues[$vr][1], 1)
            _GUICtrlListView_SetItemText($List, $vr - 1, $aValues[$vr][2], 2)
            _GUICtrlListView_EndUpdate($List)
        EndIf
    EndIf
EndFunc   ;==>Add

Func Save()
FileDelete(@ScriptDir&'\item.txt')
    $list_count = _GUICtrlListView_GetItemCount ($List)
    For $i=0 To $list_count-1
        _GUICtrlListView_SetItemSelected($List,$i)
        $Read = _GUICtrlListView_GetItemTextArray($List)
        FileWriteLine(@ScriptDir&'\item.txt',$Read[1]&'|'&$Read[2]&'|'&$Read[3])
    Next
EndFunc

Func Load()
    $file_read = FileReadToArray(@ScriptDir&'\item.txt')
    $Read_line = UBound($file_read)
    For $i=0 To $Read_line-1
        GUICtrlCreateListViewItem($file_read[$i],$List)
    Next
EndFunc