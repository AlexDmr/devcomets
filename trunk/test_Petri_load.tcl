cd c:/These/devComets/Comets/
source gml_Object.tcl
cd ..
source Comets/models/lists_functions.tcl
source Comets/models/model_comet.tcl

source PetriNet.tcl
source PetriNetView.tcl

PetriNetView:_:Place preso_ToplevelPlace ""
# return
preso_ToplevelPlace Load_from_file PetriNets/bouton.xml
	set root_place [preso_ToplevelPlace get_place]
	$root_place Add_a_token

canvas .c -background blue; pack .c -expand 1 -fill both
	.c create oval 50 50 200 100 -fill yellow -tags [list toto]
	
# Associer TK.clic à clic
# La transition clic ajoute un jeton estampillé temporellement, lève un évennement "too late" dans N ms
# La transition DoubleClic est franchit dès qu'il y a assez de jetons

# Triple clic
$root_place OnTransition tripleClick += [list puts TRIPLE!!!]

$root_place Subscribe_to_Update_triggerability ALEX {
	if {$b && [lsearch [$t get_L_events] "idle"] >= 0} {
		 puts "\tALEX trigger [$t get_name]"
		 set D [dict create]
		 $t Trigger D
		}
} UNIQUE

# Bouton 
.c bind toto <ButtonPress>		+[list $root_place TriggerEvent press "" ""]
# .c bind toto <ButtonRelease>	+[list $root_place TriggerEvent release]
# .c bind toto <Enter>			+[list $root_place TriggerEvent enter]
# .c bind toto <Leave>			+[list $root_place TriggerEvent leave]
# $root_place OnTransition 	releaseOK 	+= ".c itemconfigure toto -fill green; after 200 [list .c itemconfigure toto -fill yellow]"
# $root_place OnTransition 	releaseKO 	+= [list .c itemconfigure toto -fill yellow]
# $root_place OnPlaceEnter 	triggerable	+= [list .c itemconfigure toto -width 5]
# $root_place OnPlaceEnter 	desarmed 	+= [list .c itemconfigure toto -width 1]
# $root_place OnPlaceEnter 	waiting 	+= [list .c itemconfigure toto -width 1]


# $root_place TriggerEvent init

# Count clicks
# .c create rect 100 200 150 250 -fill red -tags carre
# .c bind carre <ButtonPress> +[list $root_place TriggerEvent CPress]
# $root_place OnTransition Display += {puts "Accumulation of [llength $L_tokens] tokens : $L_tokens"}
