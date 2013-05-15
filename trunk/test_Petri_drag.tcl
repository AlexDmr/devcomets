cd c:/These/devComets/Comets/
source gml_Object.tcl
cd ..
source Comets/models/lists_functions.tcl
source Comets/models/model_comet.tcl

source PetriNet.tcl
source PetriNetView.tcl

PetriNetView:_:Place preso_ToplevelPlace ""
# return
preso_ToplevelPlace Load_from_file PetriNets/drag.xml
	set root_place [preso_ToplevelPlace get_place]
	$root_place Add_a_token

canvas .c -background blue; pack .c -expand 1 -fill both
	.c create oval 50 50 200 100 -fill yellow -tags [list toto]

# $root_place OnTransition tripleClick += [list puts TRIPLE!!!]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
$root_place TriggerEvent init [dict create] [list]
$root_place TriggerEvent init [dict create] [list]
set init {
	 set coords [dict get $event D_event]; 
	 $P init_coordinate [dict get $coords id] [dict get $coords x] [dict get $coords y]
	}
$root_place OnTransition press		+= $init
$root_place OnTransition enter		+= $init
$root_place OnTransition move	+= {
	 set coords [dict get $event D_event]; set x [dict get $coords x]; set y [dict get $coords y]
	 lassign [$idT update_coordinate $x $y] dx dy
	 .c move toto $dx $dy
	}
$root_place OnTransition move2	+= {
	 set coords [dict get $event D_event]; set x [dict get $coords x]; set y [dict get $coords y]
	 lassign [$P2 update_coordinate $x $y] dx dy
	 set min_x [expr min([$P1 attribute x], [$P2 attribute x])]; set min_y [expr min([$P1 attribute y], [$P2 attribute y])]
	 set max_x [expr max([$P1 attribute x], [$P2 attribute x])]; set max_y [expr max([$P1 attribute y], [$P2 attribute y])]
	 set cx [expr ($min_x + $max_x) / 2]; set cy [expr ($min_y + $max_y) / 2]
	 set dx [expr $max_x - $min_x]; set dy [expr $max_y - $min_y]
	 .c coords toto [expr $cx-$dx-10] [expr $cy-$dy-10] [expr $cx+$dx+10] [expr $cy+$dy+10]
	}
$root_place OnTransition press2	+= {
	set coords [dict get $event D_event];
	 $P1 init_coordinate [dict get $coords id] [dict get $coords x] [dict get $coords y]
	}
	
source simPointerCanvas.tcl
SimPointerCanvas sim .c $root_place

# Bouton 
# .c bind toto <Motion>			[list $root_place TriggerEvent move		[dict create x %x y %y]]
# .c bind toto <ButtonPress>	[list $root_place TriggerEvent press	[dict create x %x y %y]]
# .c bind toto <ButtonRelease>	[list $root_place TriggerEvent release	]
# .c bind toto <Enter>			[list $root_place TriggerEvent enter	]
# .c bind toto <Leave>			[list $root_place TriggerEvent leave	]
