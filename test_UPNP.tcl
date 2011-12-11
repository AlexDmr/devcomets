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

toplevel ._PIPO_PresenceZones
canvas   ._PIPO_PresenceZones.canvas; pack ._PIPO_PresenceZones.canvas -fill both -expand 1
Pipo_UPNP_PresenceZones Pipo_Zone_Bureau    7200 ._PIPO_PresenceZones.canvas "0 0 200 0 200 400 0 400" "virtual=false&type=presenceDetectorOut,presenceDetectorIn&location=office"
Pipo_UPNP_PresenceZones Pipo_Zone_Chambre   7200 ._PIPO_PresenceZones.canvas "205 0 405 0 405 400 205 400 205 205 305 205 305 95 205 95" "virtual=false&type=presenceDetectorOut,presenceDetectorIn&location=bedroom"
Pipo_UPNP_PresenceZones Pipo_serviette      7200 ._PIPO_PresenceZones.canvas "410 30 440 30 440 80 410 80" "virtual=false&type=drying&location=towel"
Pipo_UPNP_PresenceZones Pipo_Zone_SalleBain 7200 ._PIPO_PresenceZones.canvas "410 0 505 0 505 95 410 95 410 85 445 85 445 25 410 25" "virtual=false&type=presenceDetectorOut,presenceDetectorIn&location=bathroom"
Pipo_UPNP_PresenceZones Pipo_Zone_Cuisine   7200 ._PIPO_PresenceZones.canvas "510 0 700 0 700 400 410 400 410 100 510 100" "virtual=false&type=presenceDetectorOut,presenceDetectorIn&location=kitchen"
Pipo_UPNP_PresenceZones Pipo_Zone_Bed       7200 ._PIPO_PresenceZones.canvas "205 100 300 100 300 200 205 200" "virtual=false&type=presenceDetectorOut,presenceDetectorIn&location=bed"

# Proxy_UPNP_Sonos Pipo_SONOS_1 60 RINCON_000E583223C401400 "virtual=true&type=audioAlarm"
# Proxy_UPNP_Sonos Pipo_SONOS_2 60 RINCON_000E5823924C01400 "virtual=false&type=switchOffAbleAudio,switchOnAbleAudio"
# Proxy_UPNP_Sonos Pipo_SONOS_3 60 RINCON_000E58249C7E01400 "virtual=true&type=audioAlarm"

proc CB_for_UPNP_MSEARCH {dt} {
	global CU
	$CU M-SEARCH "upnp:rootdevice"
	after $dt "CB_for_UPNP_MSEARCH $dt"
}
after [expr 1000 * 60 * 10] "CB_for_UPNP_MSEARCH [expr 1000 * 60 * 10]"
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Pipo_WComp PIPO_UPNP_WCOMP 7200

return
