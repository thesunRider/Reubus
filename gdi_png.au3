#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#Include <WinAPI.au3>
#Include <Math.au3>

;; author: ReFran - autoIt-Forum
;; thread: http://www.autoitscript.com/forum/topic/126194-internet-maps-tiles-viewer-project-study/

#region toDo
; calculate LatLon for map and/or tiles NW/SO
; inetget with timeout
; mapAddress update after move (keep start, forward/backwards button)
; maptype cmb set up from arr
; mapgeo language set, dann Münster und nicht Muenster
; mapgeo ini
; mapmove by pixel (keys/mouse)
#endregion toDo

;; app related (mt = map tiles, arrays mostly 1 based
DIM $mtSize = 256 ;tile size in pixel
DIM $mtiRows = 3, $mtiCols = 3 ;other values not correctly support at time
DIM $mtFileNo = $mtiRows*$mtiCols+1, $mtFile[$mtFileNo], $mtImg[$mtFileNo]
DIM $tileNoActiv, $zoom = 13

DIM $cachePath = @scriptdir&"\cache\"
DIM $cacheState = 2  ; 0=not installed 1= don't cache maptiles; 2=use cache (should be standard)

DIM $geoBase = "Deutschland" ;take this if address is blank
DIM $geoURL = "http://maps.google.com/maps/geo?q={A}&output=csv"
    ;; {A} = placeholder for Address (real post/geo-addr. or GeoPoint(Lat,Lon) for reverse geocoding

                ;"MapPvId||MapPvName||MapPvUrl" &@lf _ ;|| because at least one URL contains "|"
DIM $mapPv_str= "OC||Osm Cycle map||http://andy.sandbox.cloudmade.com/tiles/cycle/{Z}/{X}/{Y}.png"  &@lf _
            &   "OM||Osm Mapnik map||http://tile.openstreetmap.org/{Z}/{X}/{Y}.png"                 &@lf _
            &   "OO||Osm Osmarender||http://tah.openstreetmap.org/Tiles/tile/{Z}/{X}/{Y}.png"       &@lf _
            &   "OV||Osm VPN B&B map (NotAll)||http://tile.xn--pnvkarte-m4a.de/tilegen/{Z}/{X}/{Y}.png"         &@lf _
            &   "--||--------------||http://tah.openstreetmap.org/Tiles/tile/{Z}/{X}/{Y}.png"       &@lf _
            &   "GR||Google Roadmap||http://mt3.google.com/vt/x={X}&y={Y}&z={Z}"                    &@lf _
            &   "GT||Google Terrain||http://khm.google.com/vt/lbw/lyrs=p&x={X}&y={Y}&z={Z}"         &@lf _
            &   "GH||Google Hybrid||http://mt1.google.com/vt/lyrs=y&x={X}&y={Y}&z={Z}"              &@lf _
            &   "GS||Google Satelite||http://khm1.google.com/kh/v=49&x={X}&y={Y}&z={Z}"             &@lf _
            &   "GN||Google Night||http://mt1.google.com/vt/lyrs=h@130&hl=de&src=api&x={X}&y={Y}&z={Z}";&@lf _
            ;&  "--||--------------||http://tah.openstreetmap.org/Tiles/tile/{Z}/{X}/{Y}.png"       &@lf _
            ;&  "YR||Yahoo Roadmap||http://maps1.yimg.com/hx/tl?v=4.2&x={X}&y={Y}&z={Z}"


    ;; placeholders: {Z} zoom based on GMAP-zoom, {X} tileNoX calc'ed from Lon; {Y} tileNoY calc'ed from Lat;
    ;; defined as string for later use with ini
DIM $mapPv_arr= stringSplit($mapPv_str,@lf)
DIM $mapPvIdDefault = "OM" ;set preferred maptype
DIM $mapPvId, $mapPvName, $mapPvURL
DIM $autoRedraw = 1 ;used to switch out autoredraw

DIM $pi = 3.14159265358979

;; GUI related
Dim $mainGUI, $MainGuiTitle = "IMap-TileViewer_v0.2",$mTileGui, $mtileCanvas, $Inp_Addr, $dino
Dim $mgw = 774, $mgh = 800, $mgt , $mgtDelta
DIM $lab_cache,$chb_cache,$inp_mtMoveStep,$cmb_mapType

#region MainMenuLoop
mainGui()
Func MainGui()

    $mainGUI = GUICreate($MainGuiTitle, $mgw, $mgh, 20, -1, _
        $WS_OVERLAPPEDWINDOW +$WS_CLIPCHILDREN + $WS_CLIPSIBLINGS)
        GUISetStyle(BitOR($WS_MINIMIZEBOX, $WS_MAXIMIZEBOX, $WS_CAPTION, $WS_SIZEBOX, $WS_SYSMENU))
    ;GUISetIcon("shell32.dll", 44) ;225)
    ;TraySetIcon("shell32.dll", 44) ; 225)
    GuiCtrlCreateLabel("", 49,  $mgh-160+2,$mgw-52, 28)
    GUISetBkColor(0x808080)
    $dino = GUICtrlCreateIcon(@WindowsDir & "\cursors\dinosaur.ani",-1, 50,  $mgh-160,28, 28)
    GUICtrlSetBkColor(-1,0x808080)
    ;; definition of tabs
    $mainTab = GUICtrlCreateTab(2, $mgh-150,$mgw-4,$mgh-655)
        GUICtrlSetResizing(-1, $GUI_DOCKHCENTER)
        $mainTab1 = GUICtrlCreateTabItem("View")
        $Inp_Addr = GuiCtrlCreateCombo("Wesel,de",5,$mgh-150+30,220,18)
            GuiCtrlsetdata(-1,"Bocholt,de|Venlo,nl|Taverne on the Green, New York, US|Hofbraeuhaus, Muenchen, DE|Zum Frosch, Prag, cz")
        $cmb_Zoom = GUICtrlCreateCombo("",230, $mgh-150+30,40,18)
            GuiCtrlsetdata(-1,"16|15|14|13|12|11|10","13")
        $inp_zoom = GUICtrlCreateInput(0,272,$mgh-150+30,19,22)
        $udn_zoom = GUICtrlCreateUpdown($inp_zoom)
        $btn_go =GUICtrlCreateButton("go",305,$mgh-150+30,30,20)
        $cmb_mapType = GuiCtrlCreateCombo("",5,$mgh-150+30+30,220,18)
            ;GuiCtrlsetdata(-1,"[OM] Osm Mapnik|[OC] Osm Cycle map|[OO] Osm Osmarender","[OM] Osm Mapnik")
        $btn_dnl = "";GUICtrlCreateButton("dnl",230,$mgh-150+30+30,30,30)

        $btn_mUp =GUICtrlCreateButton("Up",$mgw-100,$mgh-150+30,20,20)
        $btn_mDown =GUICtrlCreateButton("Dn",$mgw-100,$mgh-150+30+30,20,20)

        $btn_mleft =GUICtrlCreateButton("<-",$mgw-125,$mgh-150+30+15,20,20)
        $btn_mRight =GUICtrlCreateButton("->",$mgw-75,$mgh-150+30+15,20,20)
        $inp_mtMoveStep = GUICtrlCreateInput("1",$mgw-100,$mgh-30, 35, 20)
        $udn_mtMoveStep = GUICtrlCreateUpdown($inp_mtMoveStep)

        $lab_cache = GUICtrlCreateLabel("Cache",5,$mgh-30,220,18,$SS_SUNKEN)
        $chb_cache = GUICtrlCreateCheckbox("",230, $mgh-30,40,18)
        GUICtrlSetState ( -1, $GUI_CHECKED )
        GUICtrlSetTip(-1, "Switch cache on/off")

    GUICtrlCreateTabItem("")
    GUISetState()

    $mtileGUI = GUICreate("", $mgw-4, $mgh-160-2, 2, 2, $WS_CHILD, -1, $mainGUI)
    GUISetBkColor(0x808080)
    GUICtrlSetResizing(-1, $GUI_DOCKTOP)

    GUISetState()

    _GDIPlus_Startup()
    $mtileCanvas = _GDIPlus_GraphicsCreateFromHWND($mtileGUI)

    cacheCheck()
    MapPvSet($mapPvIdDefault)

    GUISetState()

    GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
    $a = 50
    While 1
        $Msg = GUIGetMsg()
        ;; dino run
        ;$a += +0.1
        ;if $a > 700 then $a=50
        ;GUICtrlSetPos($dino, $a,$mgh-160)
        ;; msg loop
        Switch $Msg
            Case $GUI_EVENT_CLOSE
                _GDIPlus_Shutdown()
                Exit
            ;case $GUI_EVENT_RESTORE
            ;   mapDraw()

            case $udn_zoom
                $x=guictrlread($cmb_zoom)
                $i=guictrlread($inp_zoom)
                $s = $x+$i
                if $s < 1 then $s = 1
                if $s > 16 Then $s = 16
                guictrlsetData($inp_zoom,0)
                guictrlsetData($cmb_zoom,$s)
                if stringlen($tileNoActiv) > 1 then MapDownload($mapPvId,$tileNoActiv,$s)
            case $btn_go
                $x = GUICtrlRead($chb_cache)
                if $x = 1 Then
                    if $cacheState = 0 then dirCreate($cachePath)
                    $cacheState = 2
                else
                    $cacheState = 1
                    if not Fileexists($cachePath) then $cachState=0
                EndIf
                $Zoom = GuiCtrlRead($Cmb_Zoom)
                $inp = GuiCtrlRead($Inp_Addr)
                if $inp = "" then $inp = $geoBase
                $xs = GuiCtrlRead($cmb_mapType)
                $xid = stringmid($xs,2,2)
                mapPvSet($xid)
                $xa = stringreplace($geoUrl,"{A}",$inp)
                consolewrite("geoURL:"&$xa&@lf)
                $xa = InetGet($xa,@tempdir&"Temp.tmp")
                $geoGet = Fileread(@tempdir&"Temp.tmp")
                consolewrite("geoCSV:"&$geoGet&@lf)
                if not stringInstr($geoGet,'"') Then
                    $geoGet_arr = stringsplit($geoGet,",")
                    $tileNoActiv = LatLonToTileNumber($geoGet_arr[3],$geoGet_arr[4], $Zoom)
                    ;msgbox(0,"",$rc)
                    MapDownload($mapPvId,$tileNoActiv,$Zoom)
                endif
            ;; move by tile-steps
            case $btn_mUp
                MapTilesMove("u")
            case $btn_mDown
                MapTilesMove("d")
            case $btn_mleft
                MapTilesMove("l")
            case $btn_mRight
                MapTilesMove("r")

            case $udn_mtMoveStep , $inp_mtMoveStep
                $x = guictrlread($inp_mtMoveStep)
                if $x < 1 then guictrlsetdata($inp_mtMoveStep,1)

        EndSwitch
    WEnd
EndFunc   ;==>MainGui

Func MY_WM_PAINT($hWnd, $Msg, $wParam, $lParam)
    ;_WinAPI_RedrawWindow($mtileGUI, 0, 0, $RDW_UPDATENOW)
    if $autoRedraw = 1 then mapDraw()
    ;_WinAPI_RedrawWindow($mtileGUI, 0, 0, $RDW_VALIDATE)
    Return $GUI_RUNDEFMSG
EndFunc
#endregion MainMenuLoop

#Region Calc
func LatLonToTileNumber($lat,$lon,$zoom)
    $tileX= int(($lon+180)/360 *2^$zoom)

    $lat_rad = $lat*($pi/180)
    $tileY = int((1 - log(tan($lat_rad) + (1 / cos($lat_rad))) / $pi) / 2*2^$zoom)
    ;ytile = int((1.0 - log(tan(lat_rad) + (1 / cos(lat_rad))) / pi) / 2 * n)
    $tileNoActiv = $tileX&"|"&$tileY
    ;consolewrite("tileNO: "&$tileNumber&@crlf)
    return $tileNoActiv
endfunc



func TileNumberToLonLat($tileX,$tileY,$zoom)

    $lon = $tileX / 2^$zoom * 360.0 - 180.0
    $lat_rad = atan(_sinh($pi * (1 - 2 * $tileY / 2^$zoom)))
    $lat = _degree($lat_rad)
    $LatLonNW = $lon&","&$lat
    return $LatLonNW
endfunc

Func _Sinh(Const $nX)
    ;;  written by trancexx - autoIt-Forum
    If Not IsNumber($nX) Then
        Return SetError(1, 0, 0)
    EndIf

    Local $aResult
    Local $h_DLL = DllOpen("msvcrt.dll")
    If $h_DLL <> -1 Then $aResult = DllCall($h_DLL, "double:cdecl", "sinh", "double", $nX)
    If @error Then
        DllClose($h_DLL)
        Return SetError(2, 0, 0)
    EndIf
    DllClose($h_DLL)
    Return SetError(0, 0, $aResult[0])
EndFunc   ;==>_Sinh
#endRegion Calc

func cacheCheck()
    if Fileexists($cachePath) Then
        $ax = dirGetSize($cachePath,1)
        If IsArray($ax) Then
            GUICtrlsetdata($lab_cache,"Cache; "&int($ax[0]/1024)&" KB / "&$ax[1] &" Fls")
        endif
    Else
        dirCreate($cachePath)
        GUICtrlsetdata($lab_cache,"No Cache")
        GUICtrlSetState ($chb_cache, $GUI_UNCHECKED )
        $catcheState=0
    endif

endfunc


func MapPvSet($xmId = "OC")
    local $sname = ""
    for $i =1 to ubound($mapPv_arr)-1
        $x = stringsplit(stringreplace($mapPv_arr[$i],"||",@lf),@lf)
        if stringleft($mapPv_arr[$i],2) = $xmId Then
            $mapPvId = $x[1]
            $mapPvName = $x[2]
            $mapPvURL = $x[3]
            $mapPvIdDefault =  "[" &$x[1] &"] " &$x[2]
        endif
        $sName &= "["&$x[1]&"] "&$x[2]&"|"
    next
    $x = GuiCtrlRead($cmb_mapType)
    if $x = "" then GuiCtrlsetdata($cmb_mapType,$sName,$mapPvIdDefault)
endfunc
;GuiCtrlsetdata(-1,"[OM] Osm Mapnik|[OC] Osm Cycle map|[OO] Osm Osmarender","[OM] Osm Mapnik")
#region MapTilesAction
func MapTilesMove($where)
    consolewrite(@lf&"MapTilesMove > tileNo: "&$tileNoActiv &" to:"&$where &@lf)
    $mtmoveStep = guictrlread($inp_mtMoveStep)
    if stringinstr($tileNoActiv,"|") > 0 Then
        $tileNo_arr = stringsplit($tileNoActiv,"|")

        if $where = "l" then $tileNo_arr[1] = $tileNo_arr[1]-$mtMoveStep
        if $where = "r" then $tileNo_arr[1] = $tileNo_arr[1]+$mtMoveStep
        if $where = "u" then $tileNo_arr[2] = $tileNo_arr[2]-$mtMoveStep
        if $where = "d" then $tileNo_arr[2] = $tileNo_arr[2]+$mtMoveStep
        $tileNoActiv = $tileNo_arr[1]&"|"&$tileNo_arr[2]
        consolewrite("movezoom: "&$zoom)
        MapDownload($mapPvId,$TileNoActiv,$zoom)
    EndIf
endfunc

func MapDownload($Map,$TileNo,$zoom)
    $autoRedraw = 0 ;set to 0 because especially GuiCtrlsetdat init a redraw
    GUICtrlSetImage($dino,@WindowsDir& "\cursors\dinosau2.ani")
    consoleWrite(@lf&"MapDownLoad -> M:"&$map&" T:"&$TileNo&" Z:"&$zoom&@lf)
    ;; get tilenumbers
    consolewrite("tileNO: "&$tileNo&@crlf)
    GuiCtrlsetdata($lab_cache,"tileNO: "&$tileNo)
    if stringinstr($tileNo,"|") > 0 Then
        $tileNo_arr = stringsplit($tileNo,"|")
    EndIf
    ;; peprare url
    $ActiveUrl = $mapPvURL
    $mtiCenter = 2 ;5te Kachel wird zentriert bei 9Kachel
    local $iLeft=0, $iTop=0, $iget = ""
    for $i = 1 to $mtFileNo-1
        ;consolewrite("tileArr: "&$tileNo_arr[0]&@crlf)
        $x = $tileNo_arr[1] + $ileft - $mtiCenter+1
        $y = $tileNo_arr[2] + $iTop - $mtiCenter+1
        consolewrite($i&": "&$x&" / " &$y&@lf)
        GuiCtrlsetdata($lab_cache,"Get tile "&$i&": "&$x&" / " &$y&" / " &$zoom)
        $xfn = $cachePath&$map&"_"&$x&"_"&$y&"_"&$zoom&".png"
        if not FileExists($xfn) or $cacheState < 2 then
            $xurl = stringReplace(stringReplace(stringReplace($activeUrl,"{X}",$x),"{Y}",$y),"{Z}",$zoom)
            consolewrite($xurl&@lf)
            inetget($xurl,$xfn)
        endif
        $mtFile[$i] = $xfn
        $ileft +=+1
        if $ileft = $mticols Then
                $ileft = 0
                $itop +=+1
        endif
    next
    if IsHWnd($iget) then inetClose($iget)
    consolewrite("Mapdownload END -> call mapdraw"&@lf)

    MapImageDispose()
    mapDraw()
    consolewrite("MapDraw End")
    GUICtrlSetImage($dino,@WindowsDir& "\cursors\dinosaur.ani")
    cacheCheck()
    $autoRedraw = 1
endfunc


func MapDraw()
    ;; draw the maps on tilecanavas

    _WinAPI_RedrawWindow($mtileGUI, 0, 0, $RDW_UPDATENOW)
    local $ileft=0,$iTop=0
    for $i = 1 to $mtFileNo-1
        if $mtFile[$i] <> "" then
            $mtimg[$i] = _GDIPlus_ImageLoadFromFile($mtFile[$i])
            _GDIPlus_GraphicsDrawImageRect($mtileCanvas, $mtimg[$i], $ileft*$mtSize,$iTop*$mtSize,$mtSize,$mtSize )
        endif
        $ileft +=+1
        if $ileft = $mticols Then
            $ileft = 0
            $itop +=+1
        endif
    next

    _WinAPI_RedrawWindow($mtileGUI, 0, 0, $RDW_VALIDATE)
endfunc

func MapImageDispose()
    for $i = 1 to $mtFileNo-1
        _GDIPlus_ImageDispose($mtFile[$i])
    next
endfunc
#endregion MapTilesAction