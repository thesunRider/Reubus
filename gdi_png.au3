#include <Array.au3>

Local $ary[1][2]
$ary[0][1] ='hi'
_ArrayDisplay($ary)
ConsoleWrite(UBound($ary))
