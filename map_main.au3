; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>
#include <array.au3>
#include <string.au3>
#include <Process.au3>

$mapaddress = "http://localhost:8843/map_test.html"


Local $regValue = "0x2AF8"
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
$ClearID = "8"
RunWait("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $ClearID)

Local $lat = "8.8932",$long = "76.6141"

Local $mainmap = _IECreateEmbedded()
GUICreate("Maptest",1000,700)
GUICtrlCreateObj($mainmap, 10, 40, 598, 410)
$btn = GUICtrlCreateButton("goto",800,100,100,100)

GUISetState(@SW_SHOW) ;Show GUI
_IENavigate($mainmap,"http://localhost:8843/map_test.html")
Do
Sleep(50)
Until $mainmap.document.getElementById("debug").value == "1256"

; Waiting for user to close the window
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            ExitLoop

		Case $btn
			_zoomtoaddress($lat,$long)
			_drawcircle("first crime",$lat,$long,1000,'#AA0000',0.5)

    EndSwitch
WEnd

GUIDelete()

Exit

Func _getcurlatln()
$curlatlong = $mainmap.document.getElementById("latlong").value
$mainmap.document.getElementById("latlong").value = ""
Return $curlatlong
EndFunc

Func _drawcircle($title,$lat,$long,$radius,$color,$opac)
$exec = "drawcircle('" &$title &"'," &$lat &"," &$long &"," &$radius*0.621371 &",'" &$color &"'," &$opac &");"
ConsoleWrite($exec)
$mainmap.document.parentwindow.eval($exec)
EndFunc

Func _execjavascript($web,$js)
$gvData = $web.document.parentwindow.eval("document.getElementById('debug').value = " &$js)
Return $web.document.getElementById("debug").value
EndFunc

Func _zoomtoaddress($lat,$long)
$mainmap.document.parentwindow.eval("zoomtolocation(" &$lat &"," &$long &");")
EndFunc


Func _URIEncode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(BinaryToString(StringToBinary($sData,4),1),"")
    Local $nChar
    $sData=""
    For $i = 1 To $aData[0]
        ; ConsoleWrite($aData[$i] & @CRLF)
        $nChar = Asc($aData[$i])
        Switch $nChar
            Case 45, 46, 48 To 57, 65 To 90, 95, 97 To 122, 126
                $sData &= $aData[$i]
            Case 32
                $sData &= "+"
            Case Else
                $sData &= "%" & Hex($nChar,2)
        EndSwitch
    Next
    Return $sData
EndFunc

Func _URIDecode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(StringReplace($sData,"+"," ",0,1),"%")
    $sData = ""
    For $i = 2 To $aData[0]
        $aData[1] &= Chr(Dec(StringLeft($aData[$i],2))) & StringTrimLeft($aData[$i],2)
    Next
    Return BinaryToString(StringToBinary($aData[1],1),4)
EndFunc