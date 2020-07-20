#Include <Constants.au3>
#Include <GUIConstantsEx.au3>
#Include <StaticConstants.au3>
#Include <TabConstants.au3>
#Include <WindowsConstants.au3>

Dim $Pic[5]

GUICreate('MyGUI', 705, 369)
GUISetBkColor(0xFFFFFF)
GUICtrlCreatePic('img_bg.bmp', 0, 0, 705, 369)
GUICtrlSetState(-1, $GUI_DISABLE)

For $i = 0 To 4
    $Pic[$i] = GUICtrlCreatePic(@ScriptDir & '\img_black.bmp', 10, 24 + 50 * $i, 162, 49)
    GUICtrlCreateLabel('Tabsheet' & $i, 21, 40 + 50 * $i, 140, 18, $SS_CENTER)
    GUICtrlSetFont(-1, 11, 400, 0, 'Tahoma')
    GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
    GUICtrlSetcolor(-1, 0xFFFFFF)
Next

$Tab = GUICtrlCreateTab(172 + 4, 10 + 4, 523 - 8, 349 - 8)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateTabItem('Tabsheet0')
GUICtrlCreateEdit('', 190, 28, 487, 313)
GUICtrlCreateTabItem('Tabsheet1')
GUICtrlCreateButton('OK', 398, 319, 70, 23)
GUICtrlCreateTabItem('Tabsheet2')
GUICtrlCreateTabItem('Tabsheet3')
GUICtrlCreateTabItem('Tabsheet4')
GUICtrlCreateTabItem('')

GUISetState()

$Item = -1
$Over = -1

While 1
    $Info = GUIGetCursorInfo()
    If @error Then
        If $Over <> -1 Then
            GUICtrlSetImage($Pic[$Over], @ScriptDir & '\img_black.bmp')
        EndIf
        $Over = -1
    Else
        $Index = _Index($Info[4])
        If $Index <> $Over Then
            If $Over <> -1 Then
                GUICtrlSetImage($Pic[$Over], @ScriptDir & '\img_black.bmp')
            EndIf
            If ($Index <> -1) And ($Index <> $Item) Then
                GUICtrlSetImage($Pic[$Index], @ScriptDir & '\img_over.bmp')
                $Over = $Index
            Else
                $Over = -1
            EndIf
        EndIf
    EndIf
    $Msg = GUIGetMsg()
    If $Item = -1 Then
        $Msg = $Pic[0]
        $Item = 1
    EndIf
    Switch $Msg
        Case 0
            ContinueLoop
        Case $GUI_EVENT_CLOSE
            Exit
        Case $Pic[0] To $Pic[UBound($Pic) - 1]
            If $Msg <> $Pic[$Item] Then
                GUICtrlSetImage($Pic[$Item], @ScriptDir & '\img_black.bmp')
                GUICtrlSetcolor($Pic[$Item] + 1, 0xFFFFFF)
                GUICtrlSetImage($Msg, @ScriptDir & '\img_white.bmp')
                GUICtrlSetcolor($Msg + 1, 0x313A42)
                $Item = _Index($Msg)
                GUICtrlSendMsg($Tab, $TCM_SETCURFOCUS, $Item, 0)
                $Over = -1
            EndIf
    EndSwitch
WEnd

Func _Index($CtrlID)
    For $i = 0 To UBound($Pic) - 1
        If ($CtrlID = $Pic[$i]) Or ($CtrlID = $Pic[$i] + 1) Then
            Return $i
        EndIf
    Next
    Return -1
EndFunc   ;==>_Index