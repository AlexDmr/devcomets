package require tdom

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:TokenPool constructor {} {
	set this(D_tokens)  [dict create]
	set this(id)		0
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:TokenPool get_token {{Tclass PetriNet:_:Token} args} {
	if {![dict exists $this(D_tokens) $Tclass]} {dict set this(D_tokens) $Tclass [list]}
	set L [dict get $this(D_tokens) $Tclass]
	if {[llength $L]} {set L [lassign $L e]} else {incr this(id); set e token_$this(id); $Tclass $e}
	$e init
	return $e
}
	
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:TokenPool release_tokens {tokens} {
	eval [concat [list dict lappend this(D_tokens) [$token get_class]] $tokens]
}

#___________________________________________________________________________________________________________________________________________
if {![gmlObject info exists object TokenPool]} {
	PetriNet:_:TokenPool TokenPool
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token constructor {} {
	set this(class_name) [lindex [gmlObject info classes $objName] 0]
	this init
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors PetriNet:_:Token [list time]

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token init {} {
	this update_time
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token update_time {} {set this(time) [clock milliseconds]}
method PetriNet:_:Token get_class   {} {return $this(class_name)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place constructor {name {nesting_place {}}} {
	set this(name)		$name
	set this(L_tokens)  [list]; set this(id_token) 0
	set this(L_sources) [list]
	set this(L_targets) [list]
	
	set this(nesting_place)        	""
	set this(L_nested_places)      	[list]
	set this(L_nested_transitions) 	[list]
	
	set this(nested_start_place)	""
	set this(nested_end_place)		""
	
	set this(D_triggerable_transitions) [dict create]
	set this(last_test) 0
	# __________________________________________________________________________________________
	# Events managing __________________________________________________________________________
	#              name : key    _______________________________________________________________
	#     L_transitions : List   _______________________________________________________________
	#     cmd_subscribe : string _______________________________________________________________
	#   cmd_unsubscribe : string _______________________________________________________________
	# __________________________________________________________________________________________
	set this(D_events) 	[dict create]
	
	# Time and variables
	set this(D_afters) 	[dict create]
	set this(D_vars)	[dict create P $objName]
	
	if {$nesting_place != ""} {
		 $nesting_place Nest_place $objName
		}
}
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place dispose {} {
	# Remove references of the place from sources and targets transitions
	foreach t $this(L_sources) {$t remove_item_of_D_targets $objName}
	foreach t $this(L_targets) {$t remove_item_of_D_sources $objName}
	this dispose_nested_graph
	if {$this(nesting_place) != ""} {$this(nesting_place) Sub_L_nested_places $objName}

	this inherited
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place dispose_nested_graph {} {
	foreach p $this(L_nested_places)      {$p dispose}
	foreach t $this(L_nested_transitions) {$t dispose}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Substitute_by {place {L_related_places {}}} {
	if {[llength $L_related_places] == 0 && $this(nesting_place) != ""} {
		 set L_related_places [$this(nesting_place) get_L_nested_places]
		}
	# Arcs related to the place itself
	set L_sources [this get_L_sources]
	foreach t $L_sources {
		 $place Add_L_sources [list $t]
		 set D_place [$t get_item_of_D_targets $objName]
		 $t set_item_of_D_targets $place [PetriNet:_:[dict get $D_place type] $place [dict get $D_place weight]]
		}
	set L_targets [this get_L_targets]
	foreach t $L_targets {
		 $place Add_L_targets [list $t]
		 set D_place [$t get_item_of_D_sources $objName]
		 $t set_item_of_D_sources $place [PetriNet:_:[dict get $D_place type] $place [dict get $D_place weight]]
		}
		
	# Arcs related to nestes start and and places?
	if {[this get_nested_start_place] != "" && [$place get_nested_start_place] != ""} {
		 [this get_nested_start_place] Substitute_by [$place get_nested_start_place] $L_related_places
		 [this get_nested_end_place  ] Substitute_by [$place get_nested_end_place  ] $L_related_places
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Replicate_core {copy_name nesting_place serv_name} {
	PetriNet:_:Place $copy_name cp:[this get_name] $nesting_place
	$copy_name set_D_vars [this get_D_vars]
	
	# Recursive replication if needed
	set D_mapping [dict create]
	if {[this get_nested_start_place] != ""} {
		 foreach e [$copy_name get_L_nested_places     ] {dict set D_mapping $e [$e Replicate_core [$serv_name get_unique_id copy_of_${e}_] $copy_name $serv_name]}
		 foreach e [$copy_name get_L_nested_transitions] {dict set D_mapping $e [$e Replicate_core [$serv_name get_unique_id copy_of_${e}_] $copy_name $serv_name]
														  $e Replicate_links $D_mapping
														 }
		 $copy_name set_nested_start_place [dict get $D_mapping [this get_nested_start_place]]
		 $copy_name set_nested_end_place   [dict get $D_mapping [this get_nested_end_place  ]]
		}
		
	return $copy_name
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Replicate_links {copy_name D_mapping} {
	# Nothing to do, will be done by the transitions
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors      PetriNet:_:Place [list name nesting_place nested_start_place nested_end_place]
Generate_List_accessor  PetriNet:_:Place L_tokens             L_tokens
Generate_List_accessor  PetriNet:_:Place L_sources            L_sources
Generate_List_accessor  PetriNet:_:Place L_targets            L_targets
Generate_List_accessor  PetriNet:_:Place L_nested_places      L_nested_places
Generate_List_accessor  PetriNet:_:Place L_nested_transitions L_nested_transitions
Generate_dict_accessors PetriNet:_:Place D_triggerable_transitions
Generate_dict_accessors PetriNet:_:Place D_events
Generate_dict_accessors PetriNet:_:Place D_vars

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place incr_last_test {} {incr this(last_test)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Update_triggerable_transitions_from_place {place} {
	foreach t [$place get_L_targets] {
		 if {[$t get_id_test] != $this(last_test)} {
		     $t set_id_test $this(last_test)
			 if {[$t Triggerable]} {dict set this(D_triggerable_transitions) $t 1} else {dict set this(D_triggerable_transitions) $t 0}
			}
		}
}
# Trace PetriNet:_:Place Update_triggerable_transitions_from_place

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Add_a_token {{id {}}} {
	if {$id == ""} {
		 # incr this(id_token)
		 # set id [dict create id token_$this(id_token) type lambda]
		 set id [TokenPool get_token]
		}
	return [this Add_L_tokens [list $id]]
}

#___________________________________________________________________________________________________________________________________________
Inject_code PetriNet:_:Place Add_L_tokens {} {
	set nested_start [this get_nested_start_place]
	if {$nested_start != ""} {
		 set token_found 0
		 foreach place $this(L_nested_places) {
			 if {[$place llength_L_tokens] > 0} {set token_found 1; break}
			}
		 if {$token_found == 0} {
			 $nested_start Add_L_tokens $L
			 # puts "Add_L_tokens qui passe dans $nested_start"
			 this incr_last_test
			 this Update_triggerable_transitions_from_place $nested_start
			}
		}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Manage_CallbackList PetriNet:_:Place [list Add_L_tokens Sub_L_tokens set_L_tokens] end

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Define_event {name cmd_subscribe cmd_unsubscribe} {
	dict set this(D_events) $name 	[dict create	L_transitions	[list]				\
													cmd_subscribe	$cmd_subscribe		\
													cmd_unsubscribe	$cmd_unsubscribe	\
									]
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Subscribe_to_event {name transition} {
	if {![dict exists $this(D_events) $name]} {
		 this Define_event $name "" ""
		}
	set L_transitions [dict get $this(D_events) $name L_transitions]
	if {[lsearch $L_transitions $transition] < 0} {
		 lappend L_transitions $transition
		 dict set this(D_events) $name L_transitions $L_transitions
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place UnSubscribe_to_event {name transition} {
	if {![dict exists $this(D_events) $name]} {
		 this Define_event $name "" ""
		}
	set L_transitions [dict get $this(D_events) $name L_transitions]
	set pos [lsearch $L_transitions $transition]
	if {$pos >= 0} {
		 dict set this(D_events) $name L_transitions [lreplace $L_transitions $pos $pos]
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place random_comp {a b} {return [expr int(rand()+0.5)]}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place after {ms mark command} {
	if {![dict exists $this(D_afters) $mark]} {
		 dict set this(D_afters) $mark [dict create ms $ms command $command]
		 after $ms [list $objName execute_after_command $mark]
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place execute_after_command {mark} {
	set P $objName
	eval [dict get $this(D_afters) $mark command]
	dict unset this(D_afters) $mark
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place OnPlaceEnter {name op cmd} {
	foreach t $this(L_nested_transitions) {
		 dict for {p D} [$t get_D_targets] {
			 if {[$p get_name] == $name} {
				 this OnTransitionRef $t $op $cmd
				}
			}
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place OnPlaceLeave {name op cmd} {
	foreach t $this(L_nested_transitions) {
		 dict for {p D} [$t get_D_sources] {
			 if {[$p get_name] == $name} {
				 this OnTransitionRef $t $op $cmd
				}
			}
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place OnTransitionRef {t op cmd} {
	 switch $op {
		 =	{$t set_cmd_trigger $cmd}
		+=	{set txt [$t get_cmd_trigger]
			 append txt "\n" $cmd
			 $t set_cmd_trigger $txt
			}
		}
}
# Trace PetriNet:_:Place OnTransitionRef

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place OnTransition {name op cmd} {
	foreach t $this(L_nested_transitions) {
		 if {[$t get_name] == $name} {this OnTransitionRef $t $op $cmd}
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place TriggerEvent {name} {
	set L [list]
	foreach transition [dict get $this(D_events) $name L_transitions] {
		 if { [dict get $this(D_triggerable_transitions) $transition] } {lappend L $transition}
		 # if {[$transition Triggerable]} {lappend L $transition}
		}
		
	# puts "Event $name triggers transitions [join $L {, }]"
	foreach transition [lsort -command "$objName random_comp" $L] {$transition Trigger}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place get_var {name      } {return [dict get $this(D_vars) $name]}
method PetriNet:_:Place set_var {name value} {dict set this(D_vars) $name $value}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Eval {cmd D_vars} {
	dict for {k v} $this(D_vars) {set $k $v}
	dict for {k v} $D_vars		 {set $k $v}
	eval $cmd
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Nest_place {p} {
	if {[$p get_nesting_place] != ""} {
		 [$p get_nesting_place] Sub_L_nested_places [list $p]
		}
	$p set_nesting_place $objName
	if {[lsearch $this(L_nested_places) $p]} {
		 lappend this(L_nested_places) $p
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Update_triggerability {t} {
	if {[$t Triggerable 0]} {set triggerable 1} else {set triggerable 0}
	dict set this(D_triggerable_transitions) $t $triggerable
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Update_event_related_to {t new_event} {
	this UnSubscribe_to_event [$t get_event] $t
	this   Subscribe_to_event $new_event     $t
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Nest_transition {t event} {
	if {[$t get_nesting_place] != ""} {
		 [$t get_nesting_place] UnSubscribe_to_event $event $t
		 [$t get_nesting_place] remove_item_of_D_nested_transitions [list $t]
		}
	$t set_nesting_place $objName
	if {[lsearch $this(L_nested_transitions) $t]} {
		 lappend this(L_nested_transitions) $t
		}
	this Update_triggerability $t
	this Subscribe_to_event    $event $t
	
	# Manage callbacks for arcs modifications
	$t Subscribe_to_set_event $objName "$objName Update_event_related_to $t \$v"
	foreach mtd [list 	set_D_sources set_item_of_D_sources remove_item_of_D_sources \
						set_D_targets set_item_of_D_targets remove_item_of_D_targets \
				] {
		 $t Subscribe_to_$mtd $objName [list $objName Update_triggerability $t]
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Save_to_stream {node_text stream dec} {
	puts $stream "${dec}<place>"
	$node_text nodeValue $objName
	puts $stream "${dec}\t<attribute type=\"tclid\">[$node_text asXML]</attribute>"
	foreach a [list name nested_start_place nested_end_place D_events] {
		 $node_text nodeValue $this($a)
		 puts $stream "${dec}\t<attribute type=\"$a\">[$node_text asXML]</attribute>"
		}
	foreach place 		$this(L_nested_places) 		{$place 		Save_to_stream $node_text $stream "$dec\t"}
	foreach transition 	$this(L_nested_transitions) {$transition 	Save_to_stream $node_text $stream "$dec\t"}
	puts $stream "${dec}</place>"
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition constructor {name nesting_place event cmd_trigger D_sources D_targets} {
	set this(name)		$name

	set this(D_sources) $D_sources; dict for {place D_place} $D_sources {$place Add_L_targets [list $objName]}
	set this(D_targets) $D_targets; dict for {place D_place} $D_targets {$place Add_L_sources [list $objName]}
	set this(event)		$event

	set this(nesting_place)    ""
	set this(cond_triggerable) [list subst 1]
	set this(cmd_trigger)      $cmd_trigger
	
	set this(id_test) 0
	
	if {$nesting_place != ""} {
		 $nesting_place Nest_transition $objName $event
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition dispose {} {
	# Remove references of the transition from sources and targets places
	dict for {place D_arc} $this(D_sources) {$place Sub_L_targets $objName}
	dict for {place D_arc} $this(D_targets) {$place Sub_L_sources $objName}
	if {$this(nesting_place) != ""} {$this(nesting_place) Sub_L_nested_transitions $objName}
	
	this inherited
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Replicate_core {copy_name nesting_place serv_name} {
	PetriNet:_:Transition $copy_name cp:[this get_name] $nesting_place [this get_event] [this get_cmd_trigger] [dict create] [dict create]
	$copy_name set_cond_triggerable [this get_cond_triggerable]
	return $copy_name
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Replicate_links {copy_name D_mapping} {
	# puts stderr "TODO PetriNet:_:Transition Replicate_links"
	dict for {place D_place} $this(D_sources) {
		 if {[dict exists $D_mapping $place]} {
			 set copy_place [dict get $D_mapping $place]
			 $copy_name set_item_of_D_sources $copy_place [PetriNet:_:[dict get $D_place type] $copy_place [dict get $D_place weight]]
			 $copy_place Add_L_targets [list $copy_name]
			}
		}
	dict for {place D_place} $this(D_targets) {
		 if {[dict exists $D_mapping $place]} {
			 set copy_place [dict get $D_mapping $place]
			 $copy_name set_item_of_D_targets $copy_place [PetriNet:_:[dict get $D_place type] $copy_place [dict get $D_place weight]]
			 $copy_place Add_L_sources [list $copy_name]
			}
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Save_to_stream {node_text stream dec} {
	puts $stream "${dec}<transition>"
	$node_text nodeValue $objName
	puts $stream "${dec}\t<attribute type=\"tclid\">[$node_text asXML]</attribute>"
	foreach a [list name cond_triggerable event cmd_trigger] {
		 $node_text nodeValue $this($a)
		 puts $stream "${dec}\t<attribute type=\"$a\">[$node_text asXML]</attribute>"
		}
	
	set D [dict create]; 
		dict for {k v} $this(D_sources) {dict set D $k [list [dict get $v type] $k [dict get $v weight]]}
		$node_text nodeValue $D; puts $stream "${dec}\t<attribute type=\"D_sources\">[$node_text asXML]</attribute>"
	set D [dict create]; 
		dict for {k v} $this(D_targets) {dict set D $k [list [dict get $v type] $k [dict get $v weight]]}
		$node_text nodeValue $D; puts $stream "${dec}\t<attribute type=\"D_targets\">[$node_text asXML]</attribute>"
	puts $stream "${dec}</transition>"
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors PetriNet:_:Transition [list name nesting_place event cmd_trigger id_test cond_triggerable]

Generate_dict_accessors PetriNet:_:Transition D_sources
Generate_dict_accessors PetriNet:_:Transition D_targets

#___________________________________________________________________________________________________________________________________________
Manage_CallbackList PetriNet:_:Transition [list set_D_sources set_item_of_D_sources remove_item_of_D_sources \
												set_D_targets set_item_of_D_targets remove_item_of_D_targets \
											] end

Manage_CallbackList PetriNet:_:Transition [list set_event] begin

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Triggerable {{in_nesting_context 1}} {
	if {$in_nesting_context && $this(nesting_place) != ""} {
		 if {[$this(nesting_place) llength_L_tokens] == 0} {return 0}
		}
	set D_res [dict create]
	puts "Transition $objName ([this get_name])"
	dict for {place D_edge} $this(D_sources) {
		 set D_weight   		[dict get $D_edge D_weight]
		 set cond_select		[dict get $D_edge cond]
		 lassign				[eval $cond_select] res D_vars
		 puts "\t$place : $res : $D_vars"
		 if {!$res} {puts "\tAbort"; return 0}
		 # set cmd_select_tokens	[dict get $D_edge cmd_select_tokens_source]
		 # set L_tokens 			[eval $cmd_select_tokens]
		 # if { ![eval $cond] } {return 0}
		}
	
	return 1
	# return [eval $this(cond_triggerable)]
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Trigger {} {
	# if {[this Triggerable]} {
		 set L_tokens [list]
		 
		 # Remove tokens from source places
		 dict for {place D_edge} $this(D_sources) {
			 set weight   			[dict get $D_edge weight]
			 set L_tokens_source 	[eval [dict get $D_edge cmd_select_tokens_source]]
			 set L_tokens 			[concat $L_tokens $L_tokens_source]
			 # puts "Transition $objName ([this get_name]) :\n\tplace : $place\n\tselect L_tokens : {$L_tokens} from $place\n\t[dict get $D_edge cmd_remove_tokens_source]"
			 eval 		  			[dict get $D_edge cmd_remove_tokens_source]
			}
		 
		 # Add tokens to target places
		 dict for {place D_edge} $this(D_targets) {
			 set weight   [dict get $D_edge weight]
			 eval [dict get $D_edge cmd_puts_tokens_target]
			}
		 
		 # Update triggerable transitions
		 $this(nesting_place) incr_last_test
		 dict for {place D_edge} $this(D_sources) {$this(nesting_place) Update_triggerable_transitions_from_place $place}
		 dict for {place D_edge} $this(D_targets) {$this(nesting_place) Update_triggerable_transitions_from_place $place}
		 
		 # Eval the trigger command
		 $this(nesting_place) Eval $this(cmd_trigger) [dict create L_tokens $L_tokens]
		# }
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Create_arc {D canvas source target x1 y1 x2 y2 L_tags} {
	if {[lsearch [gmlObject info classes $source] PetriNet:_:Transition] >= 0} {set transition $source} else {set transition $target}
	lappend L_tags arc arc_${source}_$target arc_related_to_$transition source:$source target:$target
	
	set cmd [list $canvas create line $x1 $y1 $x2 $y2 -tags $L_tags]
	set cmd [concat $cmd [dict get $D preso_style_line_config]]
	eval $cmd
	
	# set txt ""
	# dict for {k v} [dict get $D D_weight] {append txt "$k : $v\n"}
	set L_txt [list]
	dict for {k v} [dict get $D D_weight] {lappend L_txt "[dict get $v w] [dict get $v t]"}
	set txt [join $L_txt "\n"]
	
	$canvas create text 0 0 -text $txt -tags [concat $L_tags weight_arc_${source}_$target]
	
	lappend L_tags end_point_${source}_$target
	eval [dict get $D preso_create_end_line]
}

#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Update_arc {D canvas source target x1 y1 x2 y2} {
	$canvas coords arc_${source}_$target $x1 $y1 $x2 $y2
	eval [dict get $D preso_update_end_line]
	set sign_x [expr ($x2-$x1)<0?-1:1]; set sign_y [expr ($y2-$y1)<0?-1:1]
	if {$sign_x + $sign_y} {
		 set anchor sw
		} else {set anchor nw}
	$canvas itemconfigure	weight_arc_${source}_$target -anchor $anchor
	$canvas coords 			weight_arc_${source}_$target  [expr ($x1+$x2)/2.0] [expr ($y1+$y2)/2.0]
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:StandardEdge {place D_weight} {
	dict for {idT D} $D_weight {
		 if {![dict exists $D cond]} {dict set D_weight $idT cond {SelectTokens $place D_weight}}
		 if {![dict exists $D t   ]} {dict set D_weight $idT t Token}
		 if {![dict exists $D w   ]} {dict set D_weight $idT w {subst 1}}
		}
	set D 	[dict create	type						StandardEdge					\
							D_weight					$D_weight						\
							cond						{PetriNet:_:SelectTokens $place D_weight}	\
							cmd_remove_tokens_source	{TokenPool release_tokens $L_tokens_source; $place Sub_L_tokens $L_tokens_source} \
							cmd_puts_tokens_target		{if {$weight == "*"} {$place Add_L_tokens $L_tokens} else {for {set i 0} {$i < $weight} {incr i} {$place Add_a_token}}} \
							preso_style_line_config		[dict create -fill black -width 1 -arrow last]	\
							preso_create_end_line		""				\
							preso_update_end_line		""				\
			]
	return $D
}

#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:ConditionnaldEdge {place D_weight} {
	set D [PetriNet:_:StandardEdge $place $D_weight]
		dict set D type						ConditionnaldEdge
		dict set D cmd_remove_tokens_source {}
		dict set D preso_style_line_config	-dash 1
	return $D
}

#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:inhibitordEdge {place D_weight} {
	set D [PetriNet:_:StandardEdge $place $D_weight]
		dict set D type						inhibitordEdge
		dict set D cond						{expr [llength $L_tokens] < $weight}
		dict set D cmd_remove_tokens_source {}
		dict set D preso_style_line_config	-dash 1
		dict set D preso_style_line_config	-arrow none
		dict set D preso_create_end_line	{$canvas create oval [expr $x2 - 3] [expr $y2 - 3] [expr $x2 + 3] [expr $y2 + 3] -tags $L_tags -fill black}
		dict set D preso_update_end_line	{$canvas coords end_point_${source}_$target  [expr $x2 - 3] [expr $y2 - 3] [expr $x2 + 3] [expr $y2 + 3]}
	return $D
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:SelectTokens {place D_weight_name} {
	upvar $D_weight_name D_weight
	set L_tokens [$place get_L_tokens]
	set b_res 1; set D_res [dict create]
	
	dict for {var_name D} $D_weight {
		 # Look for [dict get $D w] tokens of type
		 set type  	[dict get $D t]; 
		 set weight [dict get $D w]; if {$weight == "*"} {set weight [llength $L_tokens]}
		 set cond 	[dict get $D cond]
		 set L_tokens_type [list]
		 foreach t $L_tokens {
			 if { "PetriNet:_:$type" == [$t get_class]
			    &&[eval $cond]
				} {
				 lappend L_tokens_type $t
				 if {[llength $L_tokens_type] >= $weight} {break}
				}
			}
		 if {[llength $L_tokens_type] >= $weight} {
			 set L_tokens [lremove $L_tokens $L_tokens_type]
			 dict set D_res $var_name $L_tokens_type
			} else {set b_res 0; set D_res ""; break}
		}
	
	return [list $b_res $D_res]
}


