source c:/These/Projet\ Interface/COMETS/devCOMETS/minimal_load.tcl

set CU [CPool get_singleton CometUPNP]


cr set_daughters_R [list $CU [CometVideo CV n d]]
[CSS++ cr "#cr->PMs.PM_TK CV"] set_cmd_placement {pack $p}
[CSS++ cr "#cr->PMs.PM_TK CV"] Play_audio_stream_locally 1
cr set_daughters_R [list $CU CV]


UPNP_device UD 20
UD Generate_device_description_for_comets [CSS++ cr *]
UD send_heartbeat 1
