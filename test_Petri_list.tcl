cd c:/These/devComets/Comets/
source gml_Object.tcl
cd ..
source Comets/models/lists_functions.tcl
source Comets/models/model_comet.tcl

source PetriNet.tcl
source PetriNetView.tcl

PetriNetView:_:Place preso_ToplevelPlace ""

preso_ToplevelPlace Load_from_file PetriNets/liste.xml
	set root_place [preso_ToplevelPlace get_place]
	$root_place Add_a_token