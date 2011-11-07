if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

set CU [CPool get_singleton CometUPNP]


cr set_daughters_R [list $CU [CometVideo CV n d]]
[CSS++ cr "#cr->PMs.PM_TK CV"] set_cmd_placement {pack $p}
[CSS++ cr "#cr->PMs.PM_TK CV"] Play_audio_stream_locally 1
cr set_daughters_R [list $CU CV]


UPNP_device UD 20
UD Generate_device_description_for_comets [CSS++ cr *]
UD send_heartbeat 1

source $::env(ROOT_COMETS)/Comets/UPNP/UPNP_Pipo_WComp.tcl  

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Pipo_WComp PIPO_UPNP_WCOMP 120


PIPO_UPNP_WCOMP AddAA [dict create AlexRule [dict create \
												condition [dict create Zones virtual=true&type=presenceDetector&location=office Lamps virtual=true&type=tableLamp&location=office] \
												action {this OnEvent AlexRule $Zones OccupancyState {if {$OccupancyState == "Occupied"} {set newTarget True} else {set newTarget False}
																														 foreach L $Lamps {
																															 puts "\t=> Light on lamp $L with cause one zone is now $OccupancyState"
																															 this soap_call $L  urn:upnp-org:serviceId:SwitchPower \
																																				SetTarget \
																																				[list $newTarget] \
																																				"puts \"\t\tLight on $newTarget!\""
																															 this soap_call $L  urn:upnp-org:serviceId:Dimming \
																																				SetLoadLevelTarget  \
																																				[list 255] \
																																				"puts \"\t\tIntensity to 255!\""
																															}
																														} $D_vars}
											]]

PIPO_UPNP_WCOMP AddAA [dict create MultiRule [dict create \
												condition [dict create Zones virtual=true&type=presenceDetector&location=office \
																	   Spots virtual=true&type=spotLight&location=office \
																	   Door virtual=true&type=openingDetector&location=office \
														  ] \
												action {this OnEvents AlexMultiRule [list $Zones OccupancyState $Door OpeningState] {
																					 if {$OccupancyState == "Occupied" && $OpeningState == "Closed"} {set newTarget True} else {set newTarget False}
																														 foreach S $Spots {
																															 puts "\t=> Light on spot $S with cause one zone is now $OccupancyState"
																															 this soap_call $S  urn:upnp-org:serviceId:SwitchPower \
																																				SetTarget \
																																				[list $newTarget] \
																																				"puts \"\t\t$S : Light on $newTarget!\""
																															 this soap_call $S  urn:upnp-org:serviceId:Dimming \
																																				SetLoadLevelTarget  \
																																				[list 255] \
																																				"puts \"\t\t$S : Intensity to 255!\""
																															}
																														} $D_vars}
											]]

puts "PIPO_UPNP_WCOMP Apply_rule AlexRule"
# type=tableLamp&location=office
	# urn:upnp-org:serviceId:SwitchPower  SetTarget [list newTargetValue True]
	# urn:upnp-org:serviceId:Dimming      SetLoadLevelTarget [list NewLoadLevelTarget 255]