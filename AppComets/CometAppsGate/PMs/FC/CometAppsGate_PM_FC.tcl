inherit CometAppsGate_PM_FC Physical_model
package require json
source [Comet_files_root]efr-tools/til/websocket/websocket.tcl

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometAppsGate_PM_FC constructor {name descr args} {
 this inherited $name $descr
	set this(comet_UPNP) [CPool get_singleton CometUPNP]
	set this(Box_UDN) ""; set this(ws_address) ""
	$this(comet_UPNP) Subscribe_to_set_item_of_dict_devices 	$objName [list $objName UPNP_device_appeared	keys val] UNIQUE
	$this(comet_UPNP) Subscribe_to_remove_item_of_dict_devices	$objName [list $objName UPNP_device_disappeared	keys	] UNIQUE
 eval "$objName configure $args"
 return $objName
}
Trace CometAppsGate_PM_FC constructor
#___________________________________________________________________________________________________________________________________________
method CometAppsGate_PM_FC dispose {} {this inherited}

#___________________________________________________________________________________________________________________________________________
Generate_accessors CometAppsGate_PM_FC [list ws_address]

Inject_code CometAppsGate_PM_FC set_ws_address {} {
	# Try to establish a connection at this adress
	set t [::websocket::open $v [list $objName ws_incoming]]

	puts "\tcoucou $v"
}
Trace CometAppsGate_PM_FC set_ws_address

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometAppsGate_PM_FC [P_L_methodes_set_CometAppsGate] {} {}
Methodes_get_LC CometAppsGate_PM_FC [P_L_methodes_get_CometAppsGate] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometAppsGate_PM_FC [P_L_methodes_set_CometAppsGate_COMET_RE_FC]

#___________________________________________________________________________________________________________________________________________
# Define technical methods _________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometAppsGate_PM_FC UPNP_device_appeared {keys_name val_name} {
	upvar $keys_name	keys
	upvar $val_name		D_val
	
	# puts "\t$keys"
	if {[dict get $D_val friendlyName] == "AppsGate set-top box"} {
		 set this(Box_UDN) $keys
		 set L_rep [$this(comet_UPNP) Search_UDN_service_action [list {UDN} "\$UDN == \"$this(Box_UDN)\""] "" [list "" {$D_name == "getWebsocket"}]]
		 lassign [lindex $L_rep 0] UDN service action
		 $this(comet_UPNP) soap_call $UDN  $service $action [list] "$objName set_ws_address \[dict get \$UPNP_res serverWebsocket\]"
		}
}
# Trace CometAppsGate_PM_FC UPNP_device_appeared

#___________________________________________________________________________________________________________________________________________
method CometAppsGate_PM_FC UPNP_device_disappeared {keys_name} {
	upvar $keys_name	keys
	puts "\t$keys"
}
Trace CometAppsGate_PM_FC UPNP_device_disappeared

#___________________________________________________________________________________________________________________________________________
method CometAppsGate_PM_FC ws_incoming {sock type msg } {
    switch -glob -nocase -- $type {
        co* {
            set this(websocket) $sock
			::websocket::send $this(websocket) text "{ commandName : getDevices, targetType:0 }"
        }
        cl* {
        }
        t* {
            # Implementation du protocol websocket
			set D_msg [::json::json2dict $msg]
			# New device  : { newDevice : { id, name, type, status, locationId }, targetType:0 }
			# update      : { objectId : id,  varName:"...", value: "..." }
			# device list : { listDevices: [ devices ], targetType:0 }
        }
    }
}
Trace CometAppsGate_PM_FC ws_incoming

#___________________________________________________________________________________________________________________________________________
# Redefine semantic methods ________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________



