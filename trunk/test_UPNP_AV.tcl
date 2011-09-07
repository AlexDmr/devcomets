if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

cr set_daughters_R [list [CPool get_singleton CometUPNP] [CometChoice CC n d]]

[CSS++ cr "#cr->PMs.PM_TK CC"] Substitute_by_PM_type CometChoice_PM_P_UPNP_AV_tree