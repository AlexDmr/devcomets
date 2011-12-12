if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

set CU [CPool get_singleton CometUPNP]

toplevel ._PIPO_PresenceZones
canvas   ._PIPO_PresenceZones.canvas; pack ._PIPO_PresenceZones.canvas -fill both -expand 1
._PIPO_PresenceZones.canvas create polygon 0 0 1215 0 1215 550 0 550 -fill black

after 15000 {
# Presence Zones :
Pipo_UPNP_PresenceZones Pipo_Zone_Bureau    7200 ._PIPO_PresenceZones.canvas "830 15 1200 15 1200 535 830 535" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=office"                                Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Chambre   7200 ._PIPO_PresenceZones.canvas "455 15 830 15 830 225 540 225 540 420 820 420 820 535 455 535" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bedroom" Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_SalleBain 7200 ._PIPO_PresenceZones.canvas "255 205 455 205 455 535 255 535" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bathroom"                              Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Cuisine   7200 ._PIPO_PresenceZones.canvas "15 15 455 15 455 195 245 195 245 535 15 535" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=kitchen"                   Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Bed       7200 ._PIPO_PresenceZones.canvas "820 225 540 225 540 420 820 420" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bed"                                   Simulation
._PIPO_PresenceZones.canvas create rect 405 305 455 420 -fill white
Pipo_UPNP_PresenceZones Pipo_serviette      7200 ._PIPO_PresenceZones.canvas "410 310 455 310 455 415 410 415" "virtual=true&type=drying&location=towel"


._PIPO_PresenceZones.canvas create polygon 450 415 450 125 460 125 460 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 415 820 125 830 125 830 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 225 540 225 540 420 820 420 820 415 545 415 545 230 820 230 -fill white

# SONOS :
Proxy_Pipo_Sonos Pipo_Sonos 7200 "type=audioAlarm&virtual=true" ._PIPO_PresenceZones.canvas 460 325

# Lights :
Pipo_UPNP_Light LightSdB      7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bathroom&virtual=true" ._PIPO_PresenceZones.canvas 310 450
Pipo_UPNP_Light LightCuisine  7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=kitchen&virtual=true" ._PIPO_PresenceZones.canvas 200 400
Pipo_UPNP_Light LightCuisine2 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=kitchen&virtual=true" ._PIPO_PresenceZones.canvas 300 100
Pipo_UPNP_Light LightChambre1 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bedroom&virtual=true" ._PIPO_PresenceZones.canvas 650 100
Pipo_UPNP_Light LightChambre2 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bedroom&virtual=true" ._PIPO_PresenceZones.canvas 650 450

# Buttons :
Pipo_UPNP_Button StartButton 7200 "type=button&virtual=true" ._PIPO_PresenceZones.canvas 815 215 15

# Shutters
Pipo_UPNP_Volet VoletSalon   7200 "type=opennable,closable&location=office&virtual=true"   ._PIPO_PresenceZones.canvas 830 530 1200 550
Pipo_UPNP_Volet VoletChambre 7200 "type=opennable,closable&location=bedroom&virtual=true"  ._PIPO_PresenceZones.canvas 455 530 820 550
Pipo_UPNP_Volet VoletSdB     7200 "type=opennable,closable&location=bathroom&virtual=true" ._PIPO_PresenceZones.canvas 255 530 445 550
Pipo_UPNP_Volet VoletCuisine 7200 "type=opennable,closable&location=kitchen&virtual=true"  ._PIPO_PresenceZones.canvas 15 530 245 550

# Temperature Display and Manager
Pipo_UPNP_TemperatureDisplay TempDisplay 7200 "type=temperatureDisplay&virtual=true" ._PIPO_PresenceZones.canvas 250 425
Pipo_UPNP_TemperatureManager TempManager 7200 "type=heatAble,temperatureObservable&virtual=true"

image create photo photo_of_BONHOMME -file $::env(ROOT_COMETS)Comets/UPNP/homer-simpson.gif
._PIPO_PresenceZones.canvas create image 100 100 -image photo_of_BONHOMME -tags [list BONHOMME]

bind ._PIPO_PresenceZones.canvas <Motion> "Move %x %y"
._PIPO_PresenceZones.canvas bind BONHOMME <ButtonPress-1>   "dict set D_BONHOMME last_x %x ; dict set D_BONHOMME last_y %y ; dict set D_BONHOMME is_dragging 1"
._PIPO_PresenceZones.canvas bind BONHOMME <ButtonRelease-1> "dict set D_BONHOMME is_dragging 0"

set D_BONHOMME [dict create is_dragging 0 last_x 0 last_y 0 L_zones [gmlObject info objects Pipo_UPNP_PresenceZones]]

proc Move {x y} {
	global D_BONHOMME
	if {[dict get $D_BONHOMME is_dragging]} {
		 set dx [expr $x - [dict get $D_BONHOMME last_x]]; set dy [expr $y - [dict get $D_BONHOMME last_y]]
		 dict set D_BONHOMME last_x $x; dict set D_BONHOMME last_y $y
		 ._PIPO_PresenceZones.canvas move BONHOMME $dx $dy
		 lassign [._PIPO_PresenceZones.canvas bbox BONHOMME] x1 y1 x2 y2
		 set cx [expr int( ($x1 + $x2)/2 )]; set cy [expr int( ($y1 + $y2)/2 )]
		 foreach z [dict get $D_BONHOMME L_zones] {
			 $z Simulation_OccupancyState_at $cx $cy
			}
		}
}
}


proc CB_for_UPNP_MSEARCH {dt} {
	global CU
	$CU M-SEARCH "upnp:rootdevice"
	after $dt "CB_for_UPNP_MSEARCH $dt"
}
after [expr 1000 * 60 * 10] "CB_for_UPNP_MSEARCH [expr 1000 * 60 * 10]"