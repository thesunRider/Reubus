#include <GUIConstantsEx.au3>
#include <FileConstants.au3>

Example()

Func Example()
    Local $sPDF_path
    Local $Gui = GUICreate("PDF Viewer", 900, 600)
    GUISetBkColor(0xa0d0a0)

    Local $oIE_Obj = ObjCreate("Shell.Explorer.2") ; Instantiate a BrowserControl
    GUICtrlCreateObj($oIE_Obj, 5, 5, 780, 590); Place the BrowserControl on the GUI
    $oIE_Obj.navigate('about:blank')

    Local $hButtonLoad = GUICtrlCreateButton("Load pdf", 795, 5, 100, 295)
    Local $hButtonExit = GUICtrlCreateButton("Exit", 795, 300, 100, 295)
    GUISetState()
    While 1
        $idMsg = GUIGetMsg()
        Select
            Case $idMsg = $GUI_EVENT_CLOSE
                ExitLoop
            Case $idMsg = $hButtonLoad
                ; Display an open dialog to select a pdf document.
                $sPDF_path = FileOpenDialog("select a pdf document", @ScriptDir & "\", "pdf (*.pdf)", $FD_FILEMUSTEXIST)
                If Not @error Then
                    $oIE_Obj.Stop() ; stop loadinh (if any in progress)
                    $oIE_Obj.document.Write(MakeHTML($sPDF_path)) ; inject lising directly to the HTML document
                    $oIE_Obj.document.execCommand("Refresh")
                EndIf

            Case $idMsg = $hButtonExit
                ExitLoop

        EndSelect
    WEnd
    GUIDelete()
EndFunc   ;==>Example

Func MakeHTML($sPdfPath = '')
    Local $sHTML = '<html>' & @CRLF & _
            '<head>' & @CRLF & _
            '<meta http-equiv="X-UA-Compatible" content="IE=edge" />' & @CRLF & _
            '</head>' & @CRLF & _
            '<body>' & @CRLF & _
            '<div class="container">' & @CRLF & _
            '  <div class="pdf">' & @CRLF & _
            '   <object data="' & $sPdfPath & '" type="application/pdf" width="100%" height="100%">' & @CRLF & _
            '    <iframe src="' & $sPdfPath & '" width="100%"    height="100%" style="border: none;">' & @CRLF & _
            '     This browser does not support PDFs. Please download the PDF to view it: ' & @CRLF & _
            '     <a href="' & $sPdfPath & '">Download PDF</a>' & @CRLF & _
            '    </iframe>' & @CRLF & _
            '   </object>' & @CRLF & _
            '  </div>' & @CRLF & _
            '</div>' & @CRLF & _
            '</body>' & @CRLF & _
            '</html>'
    Return $sHTML
EndFunc   ;==>MakeHTML