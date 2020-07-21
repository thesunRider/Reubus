#include <IE.au3>
$oIE = _IECreate ("https://www.mapdevelopers.com/draw-circle-tool.php")
Sleep(5000)

$oCorrectObj = ""

$tags = $oIE.document.GetElementsByTagName("button")
For $tag in $tags
$class_value = $tag.GetAttribute("title")
If string($class_value) = "Toggle fullscreen view" Then
    $oCorrectObj = $tag
    ExitLoop

EndIf
Next

If IsObj ( $oCorrectObj ) Then

_IEAction ($oCorrectObj, "click")


EndIF
