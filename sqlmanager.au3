#include <SQLite.au3>
#include <Array.au3>
#include <string.au3>

_SQLite_Startup()
$node_db = _SQLite_Open(@ScriptDir &"\nodes\node_data\node_reg.db")

$redval = _readcmd('python json_parser.py -m sukannan -f .\json\main.json -i 12')
$out = _prepareformlnode($redval)
ConsoleWrite(_readcmd('python ml_test.py "' &_ArrayToString($out,";",-1,-1,"|") &'"'))


;if Not _checkid($redval) Then
;_parseaddheader($redval)
;_writedata($redval)
;EndIf


_SQLite_Close()
_SQLite_Shutdown()


Func _prepareformlnode($redval)
$strbtwn_nodes = _ArrayUnique(_StringExplode(StringStripWS(StringReplace(_StringBetween($redval,"[","]")[0],"'",""),8),","))
$strbtwn_crimid = StringStripWS(_StringBetween($redval,"'crmid':",",")[0],8)
$strbtwn_nonodes = StringStripWS(_StringBetween($redval,"'nonodes':",",")[0],8)
$strbtwn_nolinks = StringStripWS(_StringBetween($redval,"'nolinks':","}")[0],8)
$strbtwn_name = StringTrimRight(StringTrimLeft(StringStripWS(_StringBetween($redval,"'name':",",")[0],8),1),1)
$getary = _returntable()
Local $ark[2][UBound($getary,2)]

For $i = 0 To UBound($ark,2)-1
$ark[0][$i] = $getary[0][$i]
Next
$ark[1][0] = $strbtwn_crimid
$ark[1][1] = $strbtwn_name
$ark[1][2] = $strbtwn_nonodes
$ark[1][3] = $strbtwn_nolinks
;_ArrayDisplay($ark)
;_ArrayDisplay($strbtwn_nodes)
;_ArrayDisplay($getary)

For $i = 4 To UBound($getary,2)-1
	;ConsoleWrite($getary[0][$i])
	For $j = 1 To $strbtwn_nodes[0]
		If $getary[0][$i] == $strbtwn_nodes[$j] Then $ark[1][$i] = 1
		If StringIsSpace($ark[1][$i]) Then $ark[1][$i] = 0
	Next
Next
Return $ark
EndFunc


Func _checkid($redval)
$getary = _returntable()
$strbtwn_crimid = StringStripWS(_StringBetween($redval,"'crmid':",",")[0],8)
For $i = 0 To UBound($getary)-1
	If $strbtwn_crimid == $getary[$i][0] Then Return True
Next
Return False
EndFunc

Func _writedata($redval)
$strbtwn_nodes = _ArrayUnique(_StringExplode(StringStripWS(StringReplace(_StringBetween($redval,"[","]")[0],"'",""),8),","))
$strbtwn_crimid = StringStripWS(_StringBetween($redval,"'crmid':",",")[0],8)
$strbtwn_nonodes = StringStripWS(_StringBetween($redval,"'nonodes':",",")[0],8)
$strbtwn_nolinks = StringStripWS(_StringBetween($redval,"'nolinks':","}")[0],8)
$strbtwn_name = StringTrimRight(StringTrimLeft(StringStripWS(_StringBetween($redval,"'name':",",")[0],8),1),1)
$indx_fnd = _returntable()
_SQLite_Exec($node_db,"INSERT INTO nodes VALUES (" &$strbtwn_crimid &"," &StringTrimRight(_StringRepeat("0,",UBound($indx_fnd,2)-1),1) &");")
For $i = 1 To $strbtwn_nodes[0]
	$insert_node = 'UPDATE nodes SET "' &$strbtwn_nodes[$i] &'" = 1 WHERE crimeid = '&$strbtwn_crimid &';'
	_SQLite_Exec($node_db,$insert_node)
Next
_SQLite_Exec($node_db,'UPDATE nodes SET "nonodes" = '&$strbtwn_nonodes&' WHERE crimeid = '&$strbtwn_crimid &';')
_SQLite_Exec($node_db,'UPDATE nodes SET "nolinks" = '&$strbtwn_nolinks&' WHERE crimeid = '&$strbtwn_crimid &';')
_SQLite_Exec($node_db,'UPDATE nodes SET name = "'&$strbtwn_name&'" WHERE crimeid = '&$strbtwn_crimid &';')
EndFunc

Func _parseaddheader($redval)
$strbtwn_nodes = _ArrayUnique(_StringExplode(StringStripWS(StringReplace(_StringBetween($redval,"[","]")[0],"'",""),8),","))
For $i = 1 To $strbtwn_nodes[0]
If Not _checkcolumnexists($strbtwn_nodes[$i]) Then
	ConsoleWrite(@CRLF &"Adding node to db:" &$strbtwn_nodes[$i])
	_SQLite_Exec($node_db,'ALTER TABLE nodes ADD "' &$strbtwn_nodes[$i] &'" INTEGER;')
EndIf

Next
EndFunc

Func _checkcolumnexists($name_checl)
$getary = _returntable()
For $i = 0 To UBound($getary,2) -1
 _SQLite_Exec($node_db,'UPDATE nodes SET "' &$getary[0][$i] &'" = 0 WHERE "' &$getary[0][$i] &'" IS NULL')
 If $name_checl == $getary[0][$i] Then Return True
Next
Return False
EndFunc

Func _returntable()
Local $arysql,$aryrowsql,$aryclmnsql
_SQLite_GetTable2d($node_db,"Select * FROM nodes;",$arysql,$aryrowsql,$aryclmnsql)
Return $arysql
EndFunc

Func _readcmd($cmd)
Local $iPID = Run(@ComSpec & " /c "&$cmd, @ScriptDir, @SW_HIDE, BitOR($STDERR_CHILD, $STDOUT_CHILD))
$sOutput = ''
    While 1
        $sOutput &= StdoutRead($iPID)
        If @error Then ; Exit the loop if the process closes or StderrRead returns an error.
            ExitLoop
        EndIf
    WEnd
Return $sOutput
EndFunc
