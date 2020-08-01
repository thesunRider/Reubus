#include <Array.au3>
#include <MsgBoxConstants.au3>

Local $aArray[20]
For $i = 0 To 19
	$aArray[$i] = $i
Next
_ArrayDisplay($aArray, "1D Array")
MsgBox($MB_SYSTEMMODAL, "Items 1-7", _ArrayToString($aArray,"','"))

