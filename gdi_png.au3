#include <array.au3>
#include <File.au3>
#include "XML.au3"

$pth = "test.xml"
$doc = FileRead($pth)
MsgBox(Default,Default,$doc)
Local $oXMLDoc = _XML_CreateDOMDocument(Default)
_XML_LoadXml($oXMLDoc, $doc)
Local $oNodesColl = _XML_SelectNodes($oXMLDoc, "//place")
Local $aNodesColl = _XML_Array_GetNodesProperties($oNodesColl)


Local $oAttriubtes = _XML_GetAllAttribIndex($oXMLDoc, '//place', 1)
Local $aAttributesList = _XML_Array_GetAttributesProperties($oAttriubtes)

	_ArrayDisplay($aAttributesList, '$aAttributesList')
