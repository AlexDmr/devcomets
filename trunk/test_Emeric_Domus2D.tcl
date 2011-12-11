if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

set CU [CPool get_singleton CometUPNP]

toplevel ._PIPO_PresenceZones
canvas   ._PIPO_PresenceZones.canvas; pack ._PIPO_PresenceZones.canvas -fill both -expand 1
Pipo_UPNP_PresenceZones Pipo_Zone_Bureau    7200 ._PIPO_PresenceZones.canvas "0 0 200 0 200 400 0 400" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=office"                                    Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Chambre   7200 ._PIPO_PresenceZones.canvas "205 0 405 0 405 400 205 400 205 205 305 205 305 95 205 95" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bedroom" Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_SalleBain 7200 ._PIPO_PresenceZones.canvas "410 0 505 0 505 95 410 95" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bathroom"                                Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Cuisine   7200 ._PIPO_PresenceZones.canvas "510 0 700 0 700 400 410 400 410 100 510 100" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=kitchen"               Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Bed       7200 ._PIPO_PresenceZones.canvas "205 100 300 100 300 200 205 200" "virtual=true&type=presenceDetectorOut,presenceDetectorIn&location=bed"                               Simulation

Proxy_Pipo_Sonos Pipo_Sonos 7200 "virtual=true" ._PIPO_PresenceZones.canvas 400 250




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
