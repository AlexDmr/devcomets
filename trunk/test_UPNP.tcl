if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

set CU [CPool get_singleton CometUPNP]
cr set_daughters_R [list $CU]

# cr set_daughters_R [list $CU [CometVideo CV n d]]
# [CSS++ cr "#cr->PMs.PM_TK CV"] set_cmd_placement {pack $p}
# [CSS++ cr "#cr->PMs.PM_TK CV"] Play_audio_stream_locally 1
# cr set_daughters_R [list $CU CV]


# UPNP_device UD 20
# UD Generate_device_description_for_comets [CSS++ cr *]
# UD send_heartbeat 1

source $::env(ROOT_COMETS)/Comets/UPNP/UPNP_Pipo_WComp.tcl  
source $::env(ROOT_COMETS)/Comets/UPNP/UPNP_Pipo_PresenceZones.tcl  

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
toplevel ._PIPO_PresenceZones
canvas   ._PIPO_PresenceZones.canvas; pack ._PIPO_PresenceZones.canvas -fill both -expand 1
._PIPO_PresenceZones.canvas create polygon 0 0 1215 0 1215 550 0 550 -fill black

after 5000 {
# Presence Zones :
Pipo_UPNP_PresenceZones Pipo_Zone_Bureau    [list "friendlyName" "Proxy Zone bureau"] 7200 ._PIPO_PresenceZones.canvas "830 15 1200 15 1200 535 830 535" "virtual=false&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=office"                                Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Chambre   [list "friendlyName" "Proxy Zone Chambre"] 7200 ._PIPO_PresenceZones.canvas "455 15 830 15 830 535 455 535" "virtual=false&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bedroom" Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_SalleBain [list "friendlyName" "Proxy Zone Salle de bain"] 7200 ._PIPO_PresenceZones.canvas "255 205 455 205 455 535 255 535" "virtual=false&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bathroom"                              Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Cuisine   [list "friendlyName" "Proxy Zone Cuisine"] 7200 ._PIPO_PresenceZones.canvas "15 15 455 15 455 195 245 195 245 535 15 535" "virtual=false&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=kitchen"                   Simulation
Pipo_UPNP_PresenceZones Pipo_Zone_Bed       [list "friendlyName" "Proxy Zone Lit"] 7200 ._PIPO_PresenceZones.canvas "820 225 540 225 540 420 820 420" "virtual=false&type=presenceDetectorIn,presenceDetectorOut,presenceDetectorInstIn,presenceDetectorInstOut&location=bed"                                   Simulation
._PIPO_PresenceZones.canvas create rect 405 305 455 420 -fill white
._PIPO_PresenceZones.canvas create rect 820 535 830 400 -fill black
Pipo_UPNP_PresenceZones Pipo_serviette      [list "friendlyName" "Proxy Zone serviette"] 7200 ._PIPO_PresenceZones.canvas "410 310 455 310 455 415 410 415" "virtual=false&type=drying&location=towel"
._PIPO_PresenceZones.canvas create polygon 450 415 450 125 460 125 460 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 415 820 125 830 125 830 415 -fill black
._PIPO_PresenceZones.canvas create polygon 820 225 540 225 540 420 820 420 820 415 545 415 545 230 820 230 -fill white

# SONOS proxy :
Proxy_UPNP_Sonos Pipo_SONOS_proxy [list "friendlyName" "Proxy SONOS"] 7200 RINCON_000E5823924C01400 "type=audioAlarm,switchOffAbleAudio&virtual=false"

# Buttons :
Pipo_UPNP_Button PipoStartButton [list "friendlyName" "Proxy Start button"] 7200 "type=button&virtual=false" ._PIPO_PresenceZones.canvas 815 215 15






# Proxy_UPNP_Sonos Pipo_SONOS_1 60 RINCON_000E583223C401400 "virtual=true&type=audioAlarm"
# Proxy_UPNP_Sonos Pipo_SONOS_2 60 RINCON_000E5823924C01400 "virtual=false&type=switchOffAbleAudio,switchOnAbleAudio"
# Proxy_UPNP_Sonos Pipo_SONOS_3 60 RINCON_000E58249C7E01400 "virtual=true&type=audioAlarm"

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

button .b_virtual -text "Reset Virtual Domus" -font "Arial 50" -command [list Reset true]; pack .b_virtual -expand 1 -fill both
button .breal -text "Reset Real Domus" -font "Arial 50" -command [list Reset false]; pack .breal -expand 1 -fill both

proc Reset {virtual} {
	foreach dev [PIPO_UPNP_WCOMP get_L_UDN_having_metadata type=opennable,closable&virtual=$virtual] {
		PIPO_UPNP_WCOMP soap_call $dev Close
		puts "Close $dev"		
	}

	foreach dev [PIPO_UPNP_WCOMP get_L_UDN_having_metadata type=lightAlarm,switchOnAbleLight,switchOffAbleLight&virtual=$virtual] {
		PIPO_UPNP_WCOMP soap_call $dev SetTarget [list 0] 
		PIPO_UPNP_WCOMP soap_call $dev SetLoadLevelTarget [list 0] 
		puts "Switch off $dev"		
	}
	
	# SONOS
	foreach dev [PIPO_UPNP_WCOMP get_L_UDN_having_metadata type=audioAlarm,switchOffAbleAudio&virtual=$virtual] {
		 PIPO_UPNP_WCOMP soap_call $dev SetMute [list 0 Master 1]
		}
			
	# CAFFE
	foreach dev [PIPO_UPNP_WCOMP get_L_UDN_having_metadata type=switchOnAbleCoffe,switchOffAbleCoffe&virtual=$virtual] {
		 PIPO_UPNP_WCOMP soap_call $dev SetTarget [list 0]
		}
		
	# Chauffe eau � 12
	foreach dev [PIPO_UPNP_WCOMP get_L_UDN_having_metadata type=temperatureDisplay&virtual=$virtual] {
		 PIPO_UPNP_WCOMP soap_call $dev SetValue [list 12]
		}
		
}


proc CB_for_UPNP_MSEARCH {dt} {
	global CU
	$CU Do_a_SSDP_M-SEARCH
	after $dt "CB_for_UPNP_MSEARCH $dt"
}
after [expr 1000 * 60 * 10] "CB_for_UPNP_MSEARCH [expr 1000 * 60 * 10]"

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Pipo_WComp PIPO_UPNP_WCOMP 7200
}

return