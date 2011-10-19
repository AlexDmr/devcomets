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

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Pipo_WComp constructor {} {
	set this(CU) [CPool get_singleton CometUPNP]
	set this(dico_UDN_metadata) [dict create]
	$this(CU) Subscribe_to_set_item_of_dict_devices $objName "$objName New_UPNP_device \$keys \$val"
	dict for {k v} [$this(CU) get_dict_devices] {
		 if {[catch {this New_UPNP_device $k $v} err]} {puts stderr "Problem adding a device registered in the CometUPNP (UDN is $k):\n$err"}
		}
}

#___________________________________________________________________________________________________________________________________________
method Pipo_WComp New_UPNP_device {k v} {
	if {[llength $k] == 1} {
		 set rep [$this(CU) Search_UDN_service_action [list {UDN} "\$UDN == \"$k\""] \
											 [list serviceId {$serviceId == "urn:upnp-org:serviceId:Metadata"}] \
											 [list "" {$D_name == "GetMetadata"}]	]
		 if {[llength $rep]} {
			 # Call the GetMetadata action
			 $this(CU) soap_call $k "urn:upnp-org:serviceId:Metadata" "GetMetadata" [list] "$objName Add_device_and_metadata [list $k] \$UPNP_res"
			}
		}
}

#___________________________________________________________________________________________________________________________________________
method Pipo_WComp Add_device_and_metadata {UDN UPNP_res} {
	set metadata [dict get $UPNP_res _ReturnValue]
	puts "$UDN : $metadata"
	set D_metadata [dict create]
	foreach varval [split $metadata "&"] {
		 lassign [split $varval "="] var val
		 dict set D_metadata [string trim $var] [string trim $val]
		}
	dict set this(dico_UDN_metadata) $UDN $D_metadata
}

#___________________________________________________________________________________________________________________________________________
puts "Pipo_WComp PIPO"
