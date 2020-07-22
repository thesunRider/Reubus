; Trap COM errors so that 'Back' and 'Forward'
; outside of history bounds does not abort script
; (expect COM errors to be sent to the console)

#include <GUIConstantsEx.au3>
#include <IE.au3>
#include <WindowsConstants.au3>
#include <array.au3>
#include <string.au3>
#include <Process.au3>

$mapurl = "https://www.mapdevelopers.com/draw-circle-tool.php?circles="
$latlongurl = "https://www.latlong.net/"
$opnurl = FileOpen("map_latlong.html",2)

Local $latlong

Local $regValue = "0x2AF8"
RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION", _ProcessGetName(@AutoItPID), "REG_DWORD", $regValue)
$ClearID = "8"
Run("RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess " & $ClearID)

;$latlong = _IECreate($latlongurl,0,0,1)
;$zip = _gelatlong("691505")

Local $mainmap = _IECreateEmbedded()
GUICreate("Maptest",1000,700)
GUICtrlCreateObj($mainmap, 10, 40, 598, 410)

GUISetState(@SW_SHOW) ;Show GUI
_zoomtoaddress($mainmap,"691505")

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

Func _zoomtoaddress($map,$address)
$inp = _URIEncode('[[16093.4,8.8892501,76.5927044,"#AAAAAA","#000000",0.4]]')
FileWrite($opnurl,_srcode($inp))
_IENavigate($map, "http://localhost:8843/map_latlong.html")
ConsoleWrite("munji")
EndFunc

Func _srcode($data)
$html = '<html>' &@CRLF & _
		'<body>'&@CRLF & _
		'<div style="position: absolute; overflow: hidden; left: 0px; top: 0px; width:594px; height:400px;">'&@CRLF & _
		'<div style="overflow: hidden; margin-top: -90px; margin-left: -25px;">'&@CRLF & _
		'</div>'&@CRLF & _
		'<iframe id="ifra" src="https://www.mapdevelopers.com/draw-circle-tool.php?circles='&$data &'" scrolling="no" style="height: 640px; border: 0px none; width: 619px; margin-top: -150px; margin-left: -15px; ">'&@CRLF & _
		'</iframe>'&@CRLF & _
		'</div>'&@CRLF & _
		'</div>'&@CRLF & _
		'</body>'&@CRLF & _
		'</html>'
Return $html
EndFunc

Func _gelatlong($zipcode)

$frm = _IEGetObjById($latlong,"frmPlace")
$elmnt = _IEFormElementGetObjByName ($frm,"place")
_IEFormElementSetValue($elmnt,$zipcode)
Sleep(1000);this delay is make the website believe we are not bot
_IEFormSubmit($frm)
$frm = _IEGetObjById($latlong,"frmPlace")
$elmnt = _IEFormElementGetObjByName ($frm,"place")
$lat = _IEFormGetObjByName($frm,"lat")
$long = _IEFormGetObjByName($frm,"lng")
Local $ary[] = [_IEFormElementGetValue($lat),_IEFormElementGetValue($long)]
Return $ary
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