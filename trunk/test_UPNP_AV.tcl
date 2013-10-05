if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

cr set_daughters_R [list [CPool get_singleton CometUPNP] [CometChoice CC n d] [CometVideo CV "Lecteur Multimédia" ""]]

CC Subscribe_to_set_currents VIDEO {CV set_video_source [lindex $lc 0] 0} UNIQUE

[CSS++ cr "#cr->PMs.PM_TK CC"] Substitute_by_PM_type CometChoice_PM_P_UPNP_AV_tree
set obj [CSS++ cr "#cr->PMs.PM_TK CV"]
	$obj Play_audio_stream_locally 1
	U_encapsulator_PM $obj \
					  "CometContainer(-set_name CONT_FOR_DAUGHTERS -Add_style_class CONT_FOR_DAUGHTERS, \$obj())"
	[CSS++ cr "#cr->PMs.PM_TK CV(>CometContainer)"] Substitute_by_PM_type PhysicalContainer_TK_window
