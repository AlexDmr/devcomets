if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

cd AppComets/CometAppsGate
eval [source_recusrif]
cd ../..

CometAppsGate C_Apps "AppsGate" "Interface for AppsGate done with COMETs"

set CU [CPool get_singleton CometUPNP]
cr set_daughters_R [list C_Apps $CU]
