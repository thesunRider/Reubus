#region SCITE_CallTipsForFunctions
;BGe_IEGetDOMObjByXPathWithAttributes($oIEObj, $sXPath, [$iMaxWait=2000]) Return array of objects on browser matching callers xpath
#endregion SCITE_CallTipsForFunctions
#include <ie.au3>
#include <array.au3>
#region GLOBALVariables
Global $gbBGe_PerformConsoleWrites = True
; The XPath array to work with will be 2d, with the following
Global Enum $giBGe_XPath_Dim2_sRawNode, _
    $giBGe_XPath_Dim2_sNodeName, _
    $giBGe_XPath_Dim2_bNodeIsRelative, _
    $giBGe_XPath_Dim2_sRawNodeConstraints, _
    $giBGe_XPath_Dim2_bIsConstrainted, _
    $giBGe_XPath_Dim2_aNodeConstraints, _
    $giBGe_XPath_Dim2_UBound
; $giBGe_XPath_Dim2_aNodeConstraints will contain a 2d, with the following
Global Enum $giBGe_Constraint_Dim2_sNodeName, _
    $giBGe_Constraint_Dim2_bIsAttribute, _
    $giBGe_Constraint_Dim2_bIsSelf, _
    $giBGe_Constraint_Dim2_sNodeValue, _
    $giBGe_Constraint_Dim2_bIsContains, _
    $giBGe_Constraint_Dim2_UBound
; Regexp to split xpath
Global $gsBGe_RegExpNodeSplit = "(?U)(.*(?:['""].*['""].*){0,})(?:\/)" ; Split Xpath into nodes...split by / where it is part of x-path
Global $gsBGe_RegExpNodeAndCondSplit = "([^\[\]]+)\[(.*)\]" ; Get node name and conditions...conditions can be empty
Global $gsBGe_RegExpOrSplit = "(?i)(?U)(.*['""].*['""\)])(?:\sor\s)|.{1,}?" ; Split Or statements inside []
Global $gsBGe_RegExpAndSplit = "(?i)(?U)(.*['""].*['""\)])(?:\sand\s)|.{1,}?" ; Split And statements inside []
Global $gsBGe_RegExpSplitContains = "(?i)contains\s*\(\s*(.+)\s*,\s*['""](.+)['""]\s*\)" ; Split contains, remove spaces that are not needed
Global $gsBGe_RegExpSplitNonContains = "(.*)\s*\=\s*['""](.*)['""]" ; Split constraint that is not a contains, remove spaces that are not needed
#endregion GLOBALVariables

#region SAMPLE

; Using multiple levels as an example...made comples on purpose to demonstrate...:
$xpathForumLink = "//div[@id='top-menu']/ul[contains(@class,'WONT BE FOUND') or @id='menu-mainmenu']//a[contains(@href,'forum')]"
$xpathGeneralHelpSuprt = "//table[contains(@class,'table') and @summary='Forums within the category 'AutoIt v3'']//h4/a[@title='General Help and Support']"

$xpathGeneralHelpUsers = "//div[@id='forum_active_users']//span[@itemprop='name']"

; Create/navigate to page
$oIE = _IECreate("http://www.autoitscript.com/site/",True,True)
If IsObj($oIE) Then
    ConsoleWrite("Able to _IECreate('http://www.autoitscript.com/site/')" & @CRLF)
Else
    ConsoleWrite("UNable to _IECreate('http://www.autoitscript.com/site/')" & @CRLF)
    Exit 1
EndIf

; Get Forum Link
$aForumLink = BGe_IEGetDOMObjByXPathWithAttributes($oIE,$xpathForumLink)
If IsArray($aForumLink) Then
    ConsoleWrite("Able to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathForumLink & ")" & @CRLF)
    For $i = 0 To UBound($aForumLink)-1
        ConsoleWrite("   " & $aForumLink[$i].outerhtml )
    Next
Else
    ConsoleWrite("UNable to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathForumLink & ")" & @CRLF)
    Exit 2
EndIf

; Click the link
_IEAction($aForumLink[0], "focus")
If _IEAction($aForumLink[0], "click") Then
    ConsoleWrite("Able to _IEAction($aForumLink[0], 'click')" & @CRLF)
    _IELoadWait($oIE)
Else
    ConsoleWrite("UNable to _IEAction($aForumLink[0], 'click')" & @CRLF)
    Exit 3
EndIf

; Get General help link
$aGenHelpLink = BGe_IEGetDOMObjByXPathWithAttributes($oIE,$xpathGeneralHelpSuprt)
If IsArray($aGenHelpLink) Then
    ConsoleWrite("Able to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathGeneralHelpSuprt & ")" & @CRLF)
    For $i = 0 To UBound($aGenHelpLink)-1
        ConsoleWrite("   " & $aGenHelpLink[$i].outerhtml )
    Next
Else
    ConsoleWrite("UNable to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathGeneralHelpSuprt & ")" & @CRLF)
    Exit 4
EndIf

; Click the link
_IEAction($aGenHelpLink[0], "focus")
If _IEAction($aGenHelpLink[0], "click") Then
    ConsoleWrite("Able to _IEAction($aGenHelpLink[0], 'click')" & @CRLF)
    _IELoadWait($oIE)
Else
    ConsoleWrite("UNable to _IEAction($aGenHelpLink[0], 'click')" & @CRLF)
    Exit 5
EndIf

; Get current users on page
$aGenHelpUsers = BGe_IEGetDOMObjByXPathWithAttributes($oIE,$xpathGeneralHelpUsers)
If IsArray($aGenHelpUsers) Then
    ConsoleWrite("Able to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathGeneralHelpSuprt & ")" & @CRLF)
    For $i = 0 To UBound($aGenHelpUsers)-1
        ConsoleWrite("   " & $aGenHelpUsers[$i].outerhtml & @CRLF )
        ConsoleWrite("   " & $aGenHelpUsers[$i].innertext & @CRLF )
    Next
Else
    ConsoleWrite("UNable to BGe_IEGetDOMObjByXPathWithAttributes($oIE, " & $xpathGeneralHelpSuprt & ")" & @CRLF)
    Exit 6
EndIf

#endregion SAMPLE

#region ExternalFunctions
Func BGe_IEGetDOMObjByXPathWithAttributes($oIEObject, $sXPath, $iMaxWait=2000) ; Get dom object by XPath
    If $gbBGe_PerformConsoleWrites Then ConsoleWrite("Start Function=[BGe_IEGetDOMObjByXPathWithAttributes] with $sXPath=[" & $sXPath & "]." & @CRLF)
    Local $aReturnObjects = ""

    Local $aSplitXpath = BGe_ParseXPath($sXPath)
    If Not IsArray($aSplitXpath) Then
        ConsoleWrite("BGe_IEGetDOMObjByXPathWithAttributes: Callers XPath/Node/Conditions not well formed=[" & $sXPath & "]" & @CRLF)
        Return SetError(1,0,False)
    EndIf

    Local $iTimer = TimerInit()
    While TimerDiff($iTimer)<$iMaxWait And Not IsArray($aReturnObjects)
        $aReturnObjects = BGe_RecursiveGetObjWithAttributes($oIEObject,$aSplitXpath)
    WEnd

    Return $aReturnObjects
EndFunc   ;==>BGe_IEGetDOMObjByXPathWithAttributes
#endregion ExternalFunctions
#region InternalFunctions
Func BGe_RecursiveGetObjWithAttributes($oParent, $aCallersSplitXPath, $asHolder="", $Level=0)

    $asObjects = $asHolder
    Local $sNodeName            = $aCallersSplitXPath[$Level][$giBGe_XPath_Dim2_sNodeName]
    Local $bNodeIsRelative      = $aCallersSplitXPath[$Level][$giBGe_XPath_Dim2_bNodeIsRelative]    ; true=relative false=absolute
    Local $bIsConstrainted      = $aCallersSplitXPath[$Level][$giBGe_XPath_Dim2_bIsConstrainted]    ; array[OR] of arrays[AND]; all constraints on the node
    Local $aNodeOrConstraints   = $aCallersSplitXPath[$Level][$giBGe_XPath_Dim2_aNodeConstraints]   ; array[OR] of arrays[AND]; all constraints on the node
    Local $aPossibleNodeMatch   = ""

    If $gbBGe_PerformConsoleWrites Then ConsoleWrite("Start Function=[BGe_RecursiveGetObjWithAttributes] level=[" & $Level & "]: $sNodeName=[" & $sNodeName & "], $bNodeIsRelative=[" & $bNodeIsRelative & "] $bIsConstrainted=[" & $bIsConstrainted & "]."& @CRLF)

    If Not IsObj($oParent) Then Return $asObjects

    ; Get nodes that match
    If $bNodeIsRelative Then
        If $sNodeName = "*" Then
            $oPossibleNodes = _IETagNameAllGetCollection($oParent)
        Else
            $oPossibleNodes = _IETagNameGetCollection($oParent, $sNodeName)
        EndIf
        For $oPossibleNode In $oPossibleNodes
            If $oPossibleNode.NodeType == 1 Then ; only add nodes
                If IsArray($aPossibleNodeMatch) Then
                    _ArrayAdd($aPossibleNodeMatch,$oPossibleNode)
                Else
                    Local $aPossibleNodeMatch[1] = [$oPossibleNode]
                EndIf
            EndIf
        Next
    Else
        $oPossibleNodes = $oParent.childnodes
        For $oPossibleNode In $oPossibleNodes
            If String($oPossibleNode.NodeName) = $sNodeName Or $sNodeName = "*" Then
                If IsArray($aPossibleNodeMatch) Then
                    _ArrayAdd($aPossibleNodeMatch,$oPossibleNode)
                Else
                    Local $aPossibleNodeMatch[1] = [$oPossibleNode]
                EndIf
            EndIf
        Next
    EndIf

    ; Loop through nodes against restraints
    If IsArray($aPossibleNodeMatch) Then

        For $iChild = 0 To UBound($aPossibleNodeMatch) - 1
            Local $oChild = $aPossibleNodeMatch[$iChild]

            ; Find matching conditions, when necessary
            If $bIsConstrainted Then

                ; Loop through OR Conditions
                For $i = 0 To UBound($aNodeOrConstraints) - 1
                    Local $aNodeAndConstraints = $aNodeOrConstraints[$i]
                    Local $bAndConditionsMet = True

                    ; Loop through And Conditions, or conditions are outside of this loop, and will go if current and's are not met
                    For $j = 0 To UBound($aNodeAndConstraints) - 1

                        ; Remove the @...
                        Local $sConstraintName      = StringReplace($aNodeAndConstraints[$j][$giBGe_Constraint_Dim2_sNodeName],"@","")
                        Local $bConstraintIsAtt     = $aNodeAndConstraints[$j][$giBGe_Constraint_Dim2_bIsAttribute]
                        Local $bConstraintIsNode    = $aNodeAndConstraints[$j][$giBGe_Constraint_Dim2_bIsSelf]
                        Local $sConstraintValue     = $aNodeAndConstraints[$j][$giBGe_Constraint_Dim2_sNodeValue]
                        Local $bConstraintIsContains= $aNodeAndConstraints[$j][$giBGe_Constraint_Dim2_bIsContains]

                        If $bConstraintIsNode Then
                            If $bConstraintIsContains Then
                                If Not StringInStr(String($oChild.innertext), $sConstraintValue) Then $bAndConditionsMet = False
                            Else
                                If String($oChild.innertext) <> $sConstraintValue Then $bAndConditionsMet = False
                            EndIf

                        ElseIf $bConstraintIsAtt Then
                            Local $sAttributeValue = ""
                            Switch $sConstraintName
                                Case "class"
                                    $sAttributeValue = $oChild.className()
                                Case "style"
                                    $sAttributeValue = $oChild.style.csstext
                                Case "onclick"
                                    $sAttributeValue = $oChild.getAttributeNode($sConstraintName).value
                                Case Else
                                    $sAttributeValue = $oChild.getAttribute($sConstraintName)
                            EndSwitch

                            If $bConstraintIsContains Then
                                If Not StringInStr(String($sAttributeValue), $sConstraintValue) Then $bAndConditionsMet = False
                            Else
                                If String($sAttributeValue) <> $sConstraintValue Then $bAndConditionsMet = False
                            EndIf
                        Else
                            ; failure
                        EndIf
                        ; Skip looping if a condition of the And array was not met
                        If Not $bAndConditionsMet Then ExitLoop
                    Next

                    If $bAndConditionsMet Then
                        ; If last level, add the object

                        If $Level = UBound($aCallersSplitXPath) - 1 Then
                            If Not IsArray($asObjects) Then
                                Local $asObjects[1]=[$oChild]
                            Else
                                $bUnique = True
                                ; Only add if not present in the array
                                For $iObject = 0 To UBound($asObjects)-1
                                    If $oChild = $asObjects[$iObject] Then
                                        $bUnique=False
                                        ExitLoop
                                    EndIf
                                Next
                                If $bUnique Then _ArrayAdd($asObjects, $oChild)
                            EndIf
                        Else
                            $asObjects = BGe_RecursiveGetObjWithAttributes($oChild, $aCallersSplitXPath, $asObjects, $Level + 1)
                        EndIf
                    EndIf
                    ; No need to loop additional or if already found one and
                    If $bAndConditionsMet Then ExitLoop
                Next
            Else
                ; No constraints, match is implied
                If $Level = UBound($aCallersSplitXPath) - 1 Then
                    ; Final xpath level, so add to final array
                    If Not IsArray($asObjects) Then
                        Local $asObjects[1]=[$oChild]
                    Else
                        Local $bUnique=True
                        ; Only add if not present in the array
                        For $iObject = 0 To UBound($asObjects)-1
                            If $oChild = $asObjects[$iObject] Then
                                $bUnique=False
                                ExitLoop
                            EndIf
                        Next
                        If $bUnique Then _ArrayAdd($asObjects, $oChild)
                    EndIf
                Else
                    ; Continue Recurssion
                    $asObjects = BGe_RecursiveGetObjWithAttributes($oChild, $aCallersSplitXPath, $asObjects, $Level + 1)
                EndIf
            EndIf
        Next
    EndIf
    Return $asObjects
EndFunc   ;==>BGe_RecursiveGetObjWithAttributes
Func BGe_ParseXPath($sCallersXPath)

    ; RegExp require a trailing "/"
    $sCallersXPath &= "/"
    Local $aReturnParsedXPath=False

    ; Parse all the '/' outside of single, or double, quotes
    Local $aNodesWithQualifiers = StringRegExp($sCallersXPath,$gsBGe_RegExpNodeSplit,3)

    ; Loop through, and determine if the node is direct, or relative.../ vs //
    Local $iSlashCount = 0
    For $i = 0 To UBound($aNodesWithQualifiers) - 1
        If StringLen($aNodesWithQualifiers[$i])=0 Then
            $iSlashCount+=1
        Else
            ; Add dimentions to the return array
            If Not IsArray($aReturnParsedXPath) Then
                Local $aReturnParsedXPath[1][$giBGe_XPath_Dim2_UBound]
            Else
                ReDim $aReturnParsedXPath[UBound($aReturnParsedXPath)+1][$giBGe_XPath_Dim2_UBound]
            EndIf

            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_sRawNode]  = $aNodesWithQualifiers[$i]
            ; Split current Node
            Local $aSplitNodeAndCond = StringRegExp($aNodesWithQualifiers[$i],$gsBGe_RegExpNodeAndCondSplit,3)
            If UBound($aSplitNodeAndCond) = 2 Then
                Local $sNodeName = $aSplitNodeAndCond[0]
                Local $sNodeConstraints = $aSplitNodeAndCond[1]
                $aNodeConstraints = BGe_ParseXPathConstraints($sNodeConstraints)
                If Not IsArray($aNodeConstraints) Then
                    ConsoleWrite("ParseXPath: Callers XPath/Node/Conditions not well formed=[" & $aNodesWithQualifiers[$i] & "]" & @CRLF)
                    Return SetError(1,1,False)
                EndIf
            ElseIf UBound($aSplitNodeAndCond) = 0 Then
                Local $sNodeName = $aNodesWithQualifiers[$i]
                Local $sNodeConstraints = ""
                Local $aNodeConstraints = ""
            Else
                ConsoleWrite("ParseXPath: Callers XPath/Node/Conditions not well formed=[" & $aNodesWithQualifiers[$i] & "]" & @CRLF)
                Return SetError(1,2,False)
            EndIf
            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_sNodeName]             = $sNodeName
            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_sRawNodeConstraints]   = $sNodeConstraints
            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_bIsConstrainted]       = (StringLen($sNodeConstraints)>0)
            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_aNodeConstraints]      = $aNodeConstraints
            $aReturnParsedXPath[UBound($aReturnParsedXPath)-1][$giBGe_XPath_Dim2_bNodeIsRelative]       = $iSlashCount>1
            $iSlashCount=1
        EndIf
    Next

    Return $aReturnParsedXPath

EndFunc
Func BGe_ParseXPathConstraints($sCallersXPathConstraints)
    ; Returns array of arrays
    ; Array is split of all 'or' statements, and then includes array of 'and' statements, which are split out into 2d array of name/value/bcontains
    Local $aReturnParsedXPathConstraints[1]

    ; Will always return at least the first condition
    Local $aOrQualifiers = StringRegExp($sCallersXPathConstraints,$gsBGe_RegExpOrSplit,3)
    ReDim $aReturnParsedXPathConstraints[UBound($aOrQualifiers)]
    For $i = 0 To UBound($aReturnParsedXPathConstraints)-1
        Local $aAndQualifiers = StringRegExp($aOrQualifiers[$i],$gsBGe_RegExpAndSplit,3)
        Local $aaSplitQualitfiers = BGe_ParseXPathConstraint($aAndQualifiers)
        If IsArray($aaSplitQualitfiers) Then
            $aReturnParsedXPathConstraints[$i]=$aaSplitQualitfiers
        Else
            ConsoleWrite("ParseXPathConstraints: Callers XPath/Node/Conditions not well formed=[" & $aOrQualifiers[$i] & "]" & @CRLF)
            Return SetError(1,3,False)
        EndIf
    Next

    Return $aReturnParsedXPathConstraints
EndFunc
Func BGe_ParseXPathConstraint($aCallersXPathConstraint)
    Local $aReturnParsedXPathConstraints[UBound($aCallersXPathConstraint)][$giBGe_Constraint_Dim2_UBound]

    For $i = 0 To UBound($aCallersXPathConstraint)-1
        ; Remove leading and trailing spaces
        Local $sCurrentConstraint = StringStripWS($aCallersXPathConstraint[$i], 3)
        ; Check if $sCurrentConstraint makes use of contains()

        Local $aTempContains = StringRegExp($sCurrentConstraint,$gsBGe_RegExpSplitContains,3)
        Local $aTempNonContains = StringRegExp($sCurrentConstraint,$gsBGe_RegExpSplitNonContains,3)

        If UBound($aTempContains)=2 Then
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsContains]  = True
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsSelf]      = ($aTempContains[0]=".")
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_sNodeName]    = $aTempContains[0]
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsAttribute] = (StringLeft($aTempContains[0],1)="@")
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_sNodeValue]   = $aTempContains[1]
        ElseIf UBound($aTempNonContains)=2 And Not StringInStr($aTempNonContains[0],"(") Then
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsContains] = False
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsSelf]      = ($aTempNonContains[0]=".")
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_sNodeName]    = $aTempNonContains[0]
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_bIsAttribute] = (StringLeft($aTempNonContains[0],1)="@")
            $aReturnParsedXPathConstraints[$i][$giBGe_Constraint_Dim2_sNodeValue]   = $aTempNonContains[1]
        Else
            ConsoleWrite("ParseXPathConstraint: Callers XPath/Node/Conditions not well formed=[" & $aCallersXPathConstraint[$i] & "]" & @CRLF)
            Return SetError(1,4,False)
        EndIf
    Next

    Return $aReturnParsedXPathConstraints
EndFunc
#endregion InternalFunctions