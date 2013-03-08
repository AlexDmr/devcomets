if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

set CU [CPool get_singleton CometUPNP]

toplevel ._PIPO_PresenceZones
canvas   ._PIPO_PresenceZones.canvas; pack ._PIPO_PresenceZones.canvas -fill both -expand 1
._PIPO_PresenceZones.canvas create polygon 0 0 1215 0 1215 550 0 550 -fill black

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

after 15000 {
# Presence Zones :
Pipo_UPNP_PresenceZones Pipo_Zone_Bureau    [list "friendlyName" "Pipo Zone Bureau"] 7200 ._PIPO_PresenceZones.canvas "830 15 1200 15 1200 535 830 535" "virtual=true&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=office"                                Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Chambre   [list "friendlyName" "Pipo Zone Chambre"] 7200 ._PIPO_PresenceZones.canvas "455 15 830 15 830 535 455 535" "virtual=true&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bedroom" Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_SalleBain [list "friendlyName" "Pipo Zone Salle de bain"] 7200 ._PIPO_PresenceZones.canvas "255 205 455 205 455 535 255 535" "virtual=true&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bathroom"                              Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Cuisine   [list "friendlyName" "Pipo Zone Cuisine"]  7200 ._PIPO_PresenceZones.canvas "15 15 455 15 455 195 245 195 245 535 15 535" "virtual=true&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=kitchen"                   Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Bed       [list "friendlyName" "Pipo Zone Lit"] 7200 ._PIPO_PresenceZones.canvas "820 225 540 225 540 420 820 420" "virtual=true&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bed"                                   Simulation
._PIPO_PresenceZones.canvas create rect 405 305 455 420 -fill white
._PIPO_PresenceZones.canvas create rect 820 535 830 400 -fill black
Pipo_UPNP_PresenceZones Pipo_serviette      [list "friendlyName" "Pipo Serviette"] 7200 ._PIPO_PresenceZones.canvas "410 310 455 310 455 415 410 415" "virtual=true&type=drying&location=towel"


._PIPO_PresenceZones.canvas create polygon 450 415 450 125 460 125 460 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 415 820 125 830 125 830 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 225 540 225 540 420 820 420 820 415 545 415 545 230 820 230 -fill white

# SONOS :
Proxy_Pipo_Sonos Pipo_Sonos [list "friendlyName" "Pipo SONOS"] 7200 "type=audioAlarm,switchOffAbleAudio&virtual=true" ._PIPO_PresenceZones.canvas 490 325

# Caffeti�re
Pipo_UPNP_BinaryCaffetiere Caffetiere [list "friendlyName" "Pipo Caffeti�re"] 7200 "type=switchOnAbleCoffe,switchOffAbleCoffe&virtual=true" ._PIPO_PresenceZones.canvas 220 325

# Lights :
Pipo_UPNP_Light LightSdB      [list "friendlyName" "Pipo Light Salle de bain"] 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bathroom&virtual=true" ._PIPO_PresenceZones.canvas 330 400
Pipo_UPNP_Light LightCuisine  [list "friendlyName" "Pipo Light Cuisine 1"] 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=kitchen&virtual=true" ._PIPO_PresenceZones.canvas 200 400
Pipo_UPNP_Light LightCuisine2 [list "friendlyName" "Pipo Light Cuisine 2"] 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=kitchen&virtual=true" ._PIPO_PresenceZones.canvas 300 100
Pipo_UPNP_Light LightChambre1 [list "friendlyName" "Pipo Light Chambre 1"] 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bedroom&virtual=true" ._PIPO_PresenceZones.canvas 650 100
Pipo_UPNP_Light LightChambre2 [list "friendlyName" "Pipo Light Chambre 2"] 7200 "type=lightAlarm,switchOnAbleLight,switchOffAbleLight&location=bedroom&virtual=true" ._PIPO_PresenceZones.canvas 650 450

# Buttons :
Pipo_UPNP_Button StartButton [list "friendlyName" "Pipo Start button"] 7200 "type=button&virtual=true" ._PIPO_PresenceZones.canvas 815 215 15

# Shutters
Pipo_UPNP_Volet VoletSalon   [list "friendlyName" "Pipo Volet Salon"] 7200 "type=opennable,closable&location=office&virtual=true"   ._PIPO_PresenceZones.canvas 830 530 1200 550
Pipo_UPNP_Volet VoletChambre [list "friendlyName" "Pipo Volet Chambre"] 7200 "type=opennable,closable&location=bedroom&virtual=true"  ._PIPO_PresenceZones.canvas 455 530 820 550
Pipo_UPNP_Volet VoletSdB     [list "friendlyName" "Pipo Volet Salle de bain"] 7200 "type=opennable,closable&location=bathroom&virtual=true" ._PIPO_PresenceZones.canvas 255 530 445 550
Pipo_UPNP_Volet VoletCuisine [list "friendlyName" "Pipo Volet Cuisine"] 7200 "type=opennable,closable&location=kitchen&virtual=true"  ._PIPO_PresenceZones.canvas 15 530 245 550

# Temperature Display and Manager
Pipo_UPNP_TemperatureDisplay TempDisplay [list "friendlyName" "Pipo Temperature display"] 7200 "type=temperatureDisplay&virtual=true" ._PIPO_PresenceZones.canvas 250 425
Pipo_UPNP_TemperatureManager TempManager [list "friendlyName" "Pipo Temperature manager"] 7200 "type=heatAble,temperatureObservable&virtual=true"

image create photo photo_of_BONHOMME -file $::env(ROOT_COMETS)Comets/UPNP/homer-simpson.gif
._PIPO_PresenceZones.canvas create image 100 100 -image photo_of_BONHOMME -tags [list BONHOMME]

bind ._PIPO_PresenceZones.canvas <Motion> "Move %x %y"
._PIPO_PresenceZones.canvas bind BONHOMME <ButtonPress-1>   "dict set D_BONHOMME last_x %x ; dict set D_BONHOMME last_y %y ; dict set D_BONHOMME is_dragging 1"
._PIPO_PresenceZones.canvas bind BONHOMME <ButtonRelease-1> "dict set D_BONHOMME is_dragging 0"

set D_BONHOMME [dict create is_dragging 0 last_x 0 last_y 0 L_zones [gmlObject info objects Pipo_UPNP_PresenceZones]]

}


proc CB_for_UPNP_MSEARCH {dt} {
	global CU
	$CU Do_a_SSDP_M-SEARCH
	after $dt "CB_for_UPNP_MSEARCH $dt"
}
after [expr 1000 * 60 * 10] "CB_for_UPNP_MSEARCH [expr 1000 * 60 * 10]"