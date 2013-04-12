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
	if {[llength $L]} {
		 set L [lassign $L e]
		 dict set this(D_tokens) $Tclass $L
		} else {incr this(id)
				set e token_$this(id)
				$Tclass $e
			   }
	
	eval [concat [list $e init ""] $args]
	return $e
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:TokenPool get_copy_of_token {token} {
	set Tclass [$token get_class]
	set e [this get_token $Tclass]
	$e init $token
	return $e
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:TokenPool release_tokens {tokens} {
	set L_tokens [list]
	foreach token $tokens {
		 set L [dict get $this(D_tokens) [$token get_class]]
		 if {[lsearch $L $token] == -1} {
			 lappend $L $token
			 dict set this(D_tokens) [$token get_class] $L
			}
		}
}

#___________________________________________________________________________________________________________________________________________
if {![gmlObject info exists object TokenPool]} {
	PetriNet:_:TokenPool TokenPool
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Select_min_max_age {L} {
	if {[llength $L]} {
		 set L [lassign $L first]
		 set min [$first get_time]; set max $min; set t_min $first; set t_max $first
		 foreach e $L {
			 set v [$e get_time]
			 if {$v < $min} {
				 set min $v; set t_min $e
				} else {if {$v > $max} {set max $v; set t_max $e}}
			}
		 set L_res [list $t_min $t_max]
		} else {set L_res [list "" ""]}
	return $L_res
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token constructor {} {
	set this(class_name)	[lindex [gmlObject info classes $objName] 0]
	set this(all_classes)	[gmlObject info classes $objName]
	this init ""
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors PetriNet:_:Token [list time]

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token init {token args} {
	this update_time
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token update_time {} {set this(time) [clock milliseconds]}
method PetriNet:_:Token get_time    {} {return $this(time)}
method PetriNet:_:Token get_age     {} {return [expr [clock milliseconds] - $this(time)]}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Token get_class   { } {return $this(class_name)}
method PetriNet:_:Token is_a		{C} {return [expr [lsearch $this(all_classes) $C] >= 0]}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
source token_types.tcl

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place constructor {name {nesting_place {}}} {
	set this(name)		$name
	set this(L_errors)	[list]
	
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
	set this(pipo_event) [dict create]
	# __________________________________________________________________________________________
	# Events managing __________________________________________________________________________
	#              name : key    _______________________________________________________________
	#     L_transitions : List   _______________________________________________________________
	#     cmd_subscribe : string _______________________________________________________________
	#   cmd_unsubscribe : string _______________________________________________________________
	# __________________________________________________________________________________________
	set this(D_events) 				[dict create]
	
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
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit PetriNet:_:EndPlace PetriNet:_:Place

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:EndPlace constructor {name nesting_place} {
	this inherited $name $nesting_place
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:EndPlace set_L_tokens {L} {
	set rep [this inherited $L]
	if {[llength $this(L_tokens)]} {
		 TokenPool release_tokens [$this(nesting_place) get_L_tokens]
		 $this(nesting_place) set_L_tokens [list]
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:EndPlace Add_L_tokens {L} {
	set rep [this inherited $L]
	TokenPool release_tokens [$this(nesting_place) get_L_tokens]
	$this(nesting_place) set_L_tokens [list]
}


#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
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
		 $t set_item_of_D_targets $place [PetriNet:_:[dict get $D_place type] $place [dict get $D_place D_weight]]
		}
	set L_targets [this get_L_targets]
	foreach t $L_targets {
		 $place Add_L_targets [list $t]
		 set D_place [$t get_item_of_D_sources $objName]
		 $t set_item_of_D_sources $place [PetriNet:_:[dict get $D_place type] $place [dict get $D_place D_weight]]
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
Generate_List_accessor  PetriNet:_:Place L_errors 			  L_errors
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
		 if {[$t get_nesting_place] != $objName} {
			 $this(nesting_place) Update_triggerability $t
			 $this(nesting_place) Update_triggerable_transitions_from_place $objName
			 continue
			}
		 if {[$t get_id_test] != $this(last_test)} {
		     $t set_id_test $this(last_test)
			 this Update_triggerability $t
			}
		}
}
# Trace PetriNet:_:Place Update_triggerable_transitions_from_place

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Add_a_token {{id {}}} {
	if {$id == ""} {set id [TokenPool get_token]}
	return [this Add_L_tokens [list $id]]
}

#___________________________________________________________________________________________________________________________________________
# Semantic of the nesting for a place :
#...| Poser un jeton sur la place d'entrée, qu'est ce que ça implique pour la place mère ?
#...|   => ajout d'un jeton référent? Comment le lien est-il maintenu avec les jetons du graphe?
#...| Poser/Enlever un jeton sur la place de sortie, que faire du jeton référent?
#...| Poser/Enlever un jeton sur la place mère...?
#___________________________________________________________________________________________________________________________________________
Inject_code PetriNet:_:Place Add_L_tokens {} {
	set nested_start [this get_nested_start_place]
	if {$nested_start != ""} {
		 set token_found 0
		 # foreach place $this(L_nested_places) {
			 # if {[$place llength_L_tokens] > 0 && [this get_nested_end_place] != $place} {
				 # set token_found 1; break
				# }
			# }
		 if {$token_found == 0} {
			 set new_L [list]
			 foreach t $L {lappend new_L [TokenPool get_copy_of_token $t]}
			 $nested_start Add_L_tokens $new_L
			 # puts "Add_L_tokens qui passe dans $nested_start"
			 this incr_last_test
			 this Update_triggerable_transitions_from_place $nested_start
			}
		 foreach transition [this get_L_nested_transitions] {
			 this Update_triggerability $transition
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
# Filter solutions based on the constraints expressed on each individual variable
method PetriNet:_:Place Mono_Filter_solutions_with_event {transition D_event_name} {
	upvar $D_event_name D_event
	set ok 0; set D_solution [dict create]
	dict for {place L_solutions} [dict get $this(D_triggerable_transitions) $transition D_res] {
		 foreach solution $L_solutions {
			 # If this solution is good enough, we return it!
			 set solution_ok 1
			 foreach {var_name D_var} [dict get $solution D_vars] {
				 if {[dict get $D_var var_depend_on_event]} {
					 # puts "Filter $var_name !"
					 set filter [$transition get_item_of_D_sources [list $place D_weight $var_name event_filter]]
					 foreach t [dict get $D_var L_tokens] {
						 if {![eval $filter]} {
							 # puts stderr "\tElimination of current solution with $t to code"
							 set solution_ok 0
							 break
							}
						}
					 if {!$solution_ok} {break}
					}
				}
			 # Check transition event dependant condition
			 if {$solution_ok} {
				 if {![dict exists $D_solution $place]} {
					 dict set D_solution $place [list $solution]
					} else {dict lappend $place $solution}
				}
			}
		 # Did we found a solution for place ? If not we abort !
		 if {![dict exists $D_solution $place]} {set D_solution [dict create]; break}
		}
		
	# There was no good enough solution
	return $D_solution
}
# Trace PetriNet:_:Place Filter_solutions_with_event

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Multi_Filter_solutions_with_event {transition D_event_name filter_name} {
	upvar $D_event_name D_event
	upvar $filter_name  filter
	
	set L_combi [list [dict create]]
	set new_combi [list]
	dict for {place L_solutions} [dict get $this(D_triggerable_transitions) $transition D_res] {
		 set new_L_combi [list]
		 foreach D_combi $L_combi {
			 foreach solution $L_solutions {
				 lappend new_L_combi [dict merge $D_combi [dict get $solution D_vars]]
				}
			}
		 set L_combi $new_L_combi
		}
		
	# puts "Liste des combinaisons variables multiples :"
	# foreach combi $L_combi {puts "\t* $combi"}
	# puts "_______________________________________________________________"
	set D_vars ""; set new_L_combi [list]
	foreach combi $L_combi {
		 if {[this Eval $filter combi D_vars]} {
			 lappend new_L_combi [dict create D_vars $combi]
			}
		}
	
	return [dict create $objName $new_L_combi]
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place TriggerEvent {name D_event L_transitions} {
	set L [list]
	if {[llength $L_transitions] == 0} {set L_transitions [dict get $this(D_events) $name L_transitions]}
	foreach transition $L_transitions {
		 if { [dict get $this(D_triggerable_transitions) $transition triggerable] } {
			 # Should we recompute triggerability because it depends on the event?
			 if {[dict get $this(D_triggerable_transitions) $transition depends_on_event]} {
				 # error "To be implemented : filter solutions so that only the ones compatibles with the event are selected"
				 set D_solutions [this Mono_Filter_solutions_with_event $transition D_event]
				 if {[dict size $D_solutions] == 0} {
					 set can_be_triggered 0
					} else {set can_be_triggered 1
						    dict set this(D_triggerable_transitions) $transition D_res $D_solutions
						   }
				 # this Update_triggerability $transition D_event
				 # if { [dict get $this(D_triggerable_transitions) $transition triggerable] } {set can_be_triggered 1} else {set can_be_triggered 0}
				} else {set can_be_triggered 1}
				
			 # puts "before :\n"
			 # dict for {k v} [dict get $this(D_triggerable_transitions) $transition D_res] {puts "\t$k $v"}
			 # Check if there is a constraints on multiples variables based on event
			 set multi_var_filter [$transition get_item_of_D_cond_triggerable event]
			 if {$multi_var_filter != ""} {
				 set D_solutions [this Multi_Filter_solutions_with_event $transition D_event multi_var_filter]
				 if {[dict size $D_solutions] == 0} {
					set can_be_triggered 0
					} else {set can_be_triggered 1
						    dict set this(D_triggerable_transitions) $transition D_res $D_solutions
						   }
				}
			 # puts "after :\n[dict get $this(D_triggerable_transitions) $transition D_res]"
			 if {$can_be_triggered} {lappend L $transition}
			}
		}
		
	# puts "Event $name triggers transitions [join $L {, }]"
	set D_tmp {}
	foreach transition [lsort -command "$objName random_comp" $L] {
		 $transition Trigger D_event
		 this Update_triggerability $transition
		}
}
# Trace PetriNet:_:Place TriggerEvent
Manage_CallbackList PetriNet:_:Place [list TriggerEvent] end

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place get_var {name      } {return [dict get $this(D_vars) $name]}
method PetriNet:_:Place set_var {name value} {dict set this(D_vars) $name $value}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place Eval {cmd D_pool_name D_vars_name args} {
	upvar $D_vars_name 	D_vars
	upvar $D_pool_name	D_pool
	foreach a $args {upvar $a $a}
	
	dict for {k v} $this(D_vars) {set $k $v}
	dict for {k v} $D_pool 		 {set $k [dict get $v L_tokens]}
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
#XXX gestion du temps
method PetriNet:_:Place Update_triggerability {t {D_event_name {}} {mark {}}} {
	set force 0
	if {$mark == ""} {
		 set mark [dict get $this(D_triggerable_transitions) $t mark]
		 incr mark; set force 1
		} else {if {$mark < [dict get $this(D_triggerable_transitions) $t mark]} {
					 # puts stderr "\tOld message, we quit because $mark < [dict get $this(D_triggerable_transitions) $t mark]"
					 return
					}
			   }

	if {$D_event_name != ""} {upvar $D_event_name D_event} else {set D_event $this(pipo_event)}

	lassign [$t Triggerable D_event 0] b D_res ms depends_on_event
	set time_reeval [dict get $this(D_triggerable_transitions) $t time_reeval]
		 if { $ms > 0 
		    && ($force || $time_reeval == 0 || $ms > $time_reeval) } {
			 set time_reeval $ms
			 set delta_ms [expr $time_reeval - [clock milliseconds]]
			 after $delta_ms [list $objName Update_triggerability $t {} $mark]
			} else {
					# puts stderr "\tno reevaluation cause :\n\t\tms : $ms\n\t\ttime_reeval : $time_reeval\n\t\t"
				   }

	dict set this(D_triggerable_transitions) $t [dict create triggerable $b D_res $D_res time_reeval $time_reeval mark $mark depends_on_event $depends_on_event]
}
# Trace PetriNet:_:Place Update_triggerability
Manage_CallbackList PetriNet:_:Place [list Update_triggerability] end

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
	dict set this(D_triggerable_transitions) $t [dict create triggerable 0 D_res "" time_reeval 0 mark 0 depends_on_event 0]
	this Update_triggerability $t this(pipo_event)
	this Subscribe_to_event    $event $t 
	
	# Manage callbacks for arcs modifications
	$t Subscribe_to_set_event $objName "$objName Update_event_related_to $t \$v" 
	foreach mtd [list 	set_D_sources set_item_of_D_sources remove_item_of_D_sources \
						set_D_targets set_item_of_D_targets remove_item_of_D_targets \
				] {
		 $t Subscribe_to_$mtd $objName [list $objName Update_triggerability $t] UNIQUE
		}
	
	# Update triggerability
	this Update_triggerability $t
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
	set this(triggering) 0
	set this(name)		 $name
	set this(L_errors)	 [list]

	set this(D_sources) $D_sources; dict for {place D_place} $D_sources {$place Add_L_targets [list $objName]}
	set this(D_targets) $D_targets; dict for {place D_place} $D_targets {$place Add_L_sources [list $objName]}
	set this(event)		$event

	set this(nesting_place)    ""
	set this(D_cond_triggerable) [dict create static {} event {}]
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
	$copy_name set_D_cond_triggerable [this get_D_cond_triggerable]
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
	foreach a [list name D_cond_triggerable event cmd_trigger] {
		 $node_text nodeValue $this($a)
		 puts $stream "${dec}\t<attribute type=\"$a\">[$node_text asXML]</attribute>"
		}
	
	set D [dict create]; 
		dict for {k v} $this(D_sources) {dict set D $k [list [dict get $v type] $k [dict get $v D_weight]]}
		$node_text nodeValue $D; puts $stream "${dec}\t<attribute type=\"D_sources\">[$node_text asXML]</attribute>"
	set D [dict create]; 
		dict for {k v} $this(D_targets) {dict set D $k [list [dict get $v type] $k [dict get $v D_weight]]}
		$node_text nodeValue $D; puts $stream "${dec}\t<attribute type=\"D_targets\">[$node_text asXML]</attribute>"
	puts $stream "${dec}</transition>"
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors 		PetriNet:_:Transition [list name nesting_place event cmd_trigger id_test]
Generate_List_accessor	PetriNet:_:Transition L_errors	L_errors
Generate_dict_accessors PetriNet:_:Transition D_sources
Generate_dict_accessors PetriNet:_:Transition D_targets
Generate_dict_accessors PetriNet:_:Transition D_cond_triggerable

#___________________________________________________________________________________________________________________________________________
Manage_CallbackList PetriNet:_:Transition [list set_D_sources set_item_of_D_sources remove_item_of_D_sources \
												set_D_targets set_item_of_D_targets remove_item_of_D_targets \
											] end

Manage_CallbackList PetriNet:_:Transition [list set_event] begin

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Triggerable {D_event_name {in_nesting_context 1}} {
	if {$in_nesting_context && $this(nesting_place) != ""} {
		 if {[$this(nesting_place) llength_L_tokens] == 0} {return [list 0 "" 0 0]}
		}
	upvar $D_event_name D_event
	set D_res [dict create]; set L_ms [list]; set depends_on_event 0
	dict for {place D_edge} $this(D_sources) {
		 set D_weight   		[dict get $D_edge D_weight]
		 set cond_select		[dict get $D_edge cond]
		 lassign				[eval $cond_select] res L_solutions ms depends_on_event
		 if {$depends_on_event == ""} {error "NULL with :\ncond_select : $cond_select"}
		 if {!$res} {return [list 0 "" $ms $depends_on_event]} else {if {$ms >= 0} {lappend L_ms $ms}}
		 # arc is triggerable, so merge the set of possibilities
		 dict set D_res $place $L_solutions
		}

	# If there is a static condition on the transition (involving several arcs), then filter using it
	set multi_var_filter [this get_item_of_D_cond_triggerable static]
	# puts "D_res:\n$D_res\n_________________________________"
	if {$multi_var_filter != ""} {
		 # puts "static multi-arc filter"
		 set place [this get_nesting_place]
		 set D_res [$place Multi_Filter_solutions_with_event $objName D_event multi_var_filter]
		 # puts "D_solutions:\n$D_solutions\n_________________________________"
		 # error "If there is a static condition on the transition (involving several arcs), then filter using it"
		}

	# Finalize...
	if {[llength $L_ms]} {set ms [lindex [lsort -real $L_ms] 0]} else {set ms -1}
	# puts "\t[this get_name] is triggerable"
	return [list 1 $D_res $ms $depends_on_event]
}
# Trace PetriNet:_:Transition Triggerable
#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition Trigger {D_event_name} {
	if {!$this(triggering) && [$this(nesting_place) get_item_of_D_triggerable_transitions [list $objName triggerable]]} {
		 upvar $D_event_name D_event
		 set D_vars [dict create event [dict create name $this(event) D_event $D_event]]
		 
		 set this(triggering) 1
		 set L_tokens [list]
		 # XXX
		 # set D_pool [$this(nesting_place) get_item_of_D_triggerable_transitions [list $objName D_res]]
		 set D_solutions [$this(nesting_place) get_item_of_D_triggerable_transitions [list $objName D_res]]
		 # puts "$D_event\nD_solutions = $D_solutions"
		 set D_pool [dict create]
		 dict for {place L_solutions} $D_solutions {
			 if {[llength $L_solutions]} {
				 set D_pool [dict merge $D_pool [dict get [lindex $L_solutions 0] D_vars]]
				}
			}
		 # /XXX
		 
		 dict for {place D_edge} $this(D_sources) {
			 set L_tokens_source [list]
			 dict for {var_name D_var} $D_pool {
				 if {[dict get $D_var place] == $place} {set L_tokens_source [concat $L_tokens_source [dict get $D_var L_tokens]]}
				}
			 # eval	[dict get $D_edge cmd_remove_tokens_source]
			 dict set D_vars place $place
			 dict set D_vars L_tokens_source $L_tokens_source
			 $this(nesting_place) Eval [dict get $D_edge cmd_remove_tokens_source] D_pool D_vars 
			}
		 
		 # Add tokens to target places
		 set D_used [dict create]
		 dict for {place D_edge} $this(D_targets) {
			 set D_weight   [dict get $D_edge D_weight]
			 # eval [dict get $D_edge cmd_puts_tokens_target]
			 dict set D_vars place 	  $place
			 dict set D_vars D_weight $D_weight
			 $this(nesting_place) Eval [dict get $D_edge cmd_puts_tokens_target] D_pool D_vars D_used
			}
		 
		 # Release unused tokens
		 dict for {var_name D_var} $D_pool {
			 if {![dict exists $D_used $var_name]} {TokenPool release_tokens [dict get $D_var L_tokens]}
			}
		 
		 # Eval the trigger command
		 dict set D_vars place $place
		 $this(nesting_place) Eval $this(cmd_trigger) D_pool D_vars 

		 # Update triggerable transitions
		 $this(nesting_place) incr_last_test; 
		 dict for {place D_edge} $this(D_sources) {$this(nesting_place) Update_triggerable_transitions_from_place $place}
		 dict for {place D_edge} $this(D_targets) {$this(nesting_place) Update_triggerable_transitions_from_place $place}
		 
		 # puts "\t[this get_name] => [$this(nesting_place) get_item_of_D_triggerable_transitions [list $objName triggerable]]"
		 set this(triggering) 0
		}
}
# Trace PetriNet:_:Transition Trigger
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Create_arc {D canvas source target x1 y1 x2 y2 L_tags} {
	if {[lsearch [gmlObject info classes $source] PetriNet:_:Transition] >= 0} {set transition $source} else {set transition $target}
	lappend L_tags arc arc_${source}_$target arc_related_to_$transition source:$source target:$target
	
	set cmd [list $canvas create line $x1 $y1 $x2 $y2 -smooth bezier -tags $L_tags]
	set cmd [concat $cmd [dict get $D preso_style_line_config]]
	eval $cmd
	
	# set txt ""
	# dict for {k v} [dict get $D D_weight] {append txt "$k : $v\n"}
	set L_txt [list]
	dict for {k v} [dict get $D D_weight] {
		 # lappend L_txt "[dict get $v w] [dict get $v t]"
		 set w 	 [dict get $v w]
		 set str $k; if {$w != 1} {append str "(${w})"}
		 lappend L_txt $str
		}
	set txt [join $L_txt "\n"]
	
	$canvas create text 0 0 -text $txt -tags [concat $L_tags weight_arc_${source}_$target]
	
	lappend L_tags end_point_${source}_$target
	eval [dict get $D preso_create_end_line]
}

#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Update_arc {D canvas source target x1 y1 mx my x2 y2} {
	$canvas coords arc_${source}_$target $x1 $y1 $mx $my $x2 $y2
	eval [dict get $D preso_update_end_line]
	set sign_x [expr ($x2-$x1)<0?-1:1]; set sign_y [expr ($y2-$y1)<0?-1:1]
	
	if {$sign_x == 1  && $sign_y ==  1} {set anchor sw}
	if {$sign_x == 1  && $sign_y == -1} {set anchor se}
	if {$sign_x == -1 && $sign_y ==  1} {set anchor nw}
	if {$sign_x == -1 && $sign_y == -1} {set anchor ne}

	$canvas itemconfigure	weight_arc_${source}_$target -anchor $anchor
	$canvas coords 			weight_arc_${source}_$target  $mx $my
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:StandardEdge {place D_weight} {
	dict for {idT D} $D_weight {
		 if {![dict exists $D w   ]} {dict set D_weight $idT w 1}
		 if {![dict exists $D t   ]} {dict set D_weight $idT t Token}
		 if {![dict exists $D cond]} {dict set D_weight $idT cond {subst 1}}
		 if {![dict exists $D time]} {dict set D_weight $idT time {subst -1}}
		 if {![dict exists $D event_filter]} {dict set D_weight $idT event_filter {}}
		}
		
	# this SelectTokens $place D_event D_weight	 
	set D 	[dict create	type						StandardEdge					\
							D_weight					$D_weight						\
							cond						{this SuperSelectTokens $place D_weight}	\
							cmd_remove_tokens_source	{$place Sub_L_tokens $L_tokens_source} \
							cmd_puts_tokens_target		{this PutsTokens $place D_event D_weight D_pool D_used} \
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
		dict set D cond						"lassign \[[dict get $D cond]\] b_tmp D_tmp ms_tmp dep; list \[expr !\$b_tmp\] \$D_tmp \$ms_tmp \$dep"
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
method PetriNet:_:Transition SuperSelectTokens {place D_weight_name} {
	upvar $D_weight_name D_weight

	set D_super_res [dict create]; 
	set arc_depends_on_event 0; set L_ms_ok [list]; set L_ms_ko [list]; set b_res 1
	set must_contains_all_tokens 0;

	# Compute every possible tokens set having max weight as its size
	dict for {var_name D} $D_weight {
		 # puts "variable $var_name :"
		 # For variable var_name
		 set cond			[dict get $D cond]
		 set time			[dict get $D time]
		 set type  			[dict get $D t]; 
		 set weight [dict get $D w]; 
		 set event_filter	[dict get $D event_filter]; if {$event_filter != ""} {set var_depend_on_event 1} else {set var_depend_on_event 0}
		 set arc_depends_on_event [expr $arc_depends_on_event || $var_depend_on_event]
				# if {$weight == "*"} {set weight [expr max(1, [llength $L_tokens])]}
		 set L_affectations_for_var_name [list]
		 if {[string equal -length 1 $cond "="]} {
			 # The condition directly selects the right value, no combination to be done for this variable
			 set L_affectations_for_var_name [eval [string range $cond 1 end]]
			} else { # General case, we have to compute all possibilities...
					 foreach t [$place get_L_tokens] {
						 # Can token be part of var_name?
						 set ms [eval $time]
						 if { [$t is_a PetriNet:_:$type] 
							&&[eval $cond] } {
							 # The situation is not going to change for this token?
							 if {$ms != -1} {lappend L_ms_ok $ms}
							 # Add the token to possible affectations of var_name
							 # puts "\ttoken $t !"
							 set new_L_affectations_for_var_name $L_affectations_for_var_name
							 foreach affectation $L_affectations_for_var_name {lappend new_L_affectations_for_var_name [concat $affectation [list $t]]}
							 set L_affectations_for_var_name $new_L_affectations_for_var_name
							 lappend L_affectations_for_var_name [list $t]
							 # puts "\tL_affectations_for_var_name : $L_affectations_for_var_name"
							} else 	{if {$ms != -1} {lappend L_ms_ko $ms}
									}
						}
					}
		 # Filter the results so that var_name is affected with the right numbers of tokens
		 if {$weight != "*"} {
			 set new_L_affectations_for_var_name [list]
			 foreach affectation $L_affectations_for_var_name {
				 if {[llength $affectation] == $weight} {lappend new_L_affectations_for_var_name $affectation}
				}
			} else {set new_L_affectations_for_var_name $L_affectations_for_var_name
					set must_contains_all_tokens 1
				   }
			
		 # If no affectations possible, quit!
		 # puts "\t$new_L_affectations_for_var_name"
		 if {[llength $new_L_affectations_for_var_name] == 0} {set b_res 0; break;}
		 
		 # Register possible affectations for var_name
		 dict set D_super_res $var_name [dict create L_solutions $new_L_affectations_for_var_name \
													 var_depend_on_event $var_depend_on_event]
		}
	
	if {$b_res} {
		 # Now compute all combinations so that variables does not share common tokens
		 set L_solutions [list [dict create L_tokens [list] D_vars [dict create]]]
		 dict for {var_name D} $D_weight {
			 set new_L_solutions [list]
			 foreach var_val [dict get $D_super_res $var_name L_solutions] {
				 foreach solution $L_solutions {
					 # Try to add var name affected to value var_val
					 set L_tokens [dict get $solution L_tokens]
					 if {[llength [Liste_Intersection $var_val $L_tokens]] == 0} {
						 set D_vars [dict get $solution D_vars]
						 dict set D_vars $var_name [dict create L_tokens $var_val place $place var_depend_on_event [dict get $D_super_res $var_name var_depend_on_event]]
						 lappend new_L_solutions [dict create L_tokens	[concat $L_tokens $var_val] \
															  D_vars 	$D_vars ]
						}
					}
				}
			 set L_solutions $new_L_solutions
			}
		} else {set L_solutions [list]}
	
	# if a weigth was *, filter solutions so that only the ones having all tokens from the place are selected
	if {$must_contains_all_tokens} {
		 set new_L_solutions [list]; set size [llength [$place get_L_tokens]]
		 foreach solution $L_solutions {
			 if {[llength [dict get $solution L_tokens]] == $size} {lappend new_L_solutions $solution}
			}
		 set L_solutions $new_L_solutions
		}
		
	# Return
	set ms -1
	if { $b_res && [llength $L_ms_ok]} {set ms [lindex [lsort -real $L_ms_ok] 0]}
	if {!$b_res && [llength $L_ms_ko]} {set ms [lindex [lsort -real $L_ms_ko] 0]}

	return [list $b_res $L_solutions $ms $arc_depends_on_event]
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Transition SelectTokens {place D_event_name D_weight_name args} {
	upvar $D_weight_name D_weight
	upvar $D_event_name  D_event
	
	set L_tokens [$place get_L_tokens]
	set b_res 1; set D_res [dict create]; set ms -1; 
	set is_event [expr [dict size $D_event]>0]
	set clock [clock milliseconds]
		set L_ms_ok [list]; set L_ms_ko [list]
		set arc_depends_on_event 0; 
	
	dict for {var_name D} $D_weight {
		 # Look for [dict get $D w] tokens of type
		 set cond			[dict get $D cond]
		 set time			[dict get $D time]
		 set type  			[dict get $D t]
		 set event_filter	[dict get $D event_filter]; if {$event_filter != ""} {set var_depend_on_event 1} else {set var_depend_on_event 0}
		 set arc_depends_on_event [expr $arc_depends_on_event || $var_depend_on_event]
		 set weight [dict get $D w]; if {$weight == "*"} {set weight [expr max(1, [llength $L_tokens])]}

		 set L_tokens_type [list]; 
		 foreach t $L_tokens {
			 set ms [eval $time]
			 if { [$t is_a PetriNet:_:$type] 
			    &&[eval $cond]
				&&(!$is_event || !$var_depend_on_event || ($var_depend_on_event && [eval $event_filter])) } {
				 # The situation is not going to change for this token?
				 if {$ms != -1} {lappend L_ms_ok $ms}
				 lappend L_tokens_type $t
				 if {$weight != "*" && [llength $L_tokens_type] >= $weight} {break}
				} else 	{if {$ms != -1} {lappend L_ms_ko $ms}
						}
			}
		 if { ($weight == "*" && [llength $L_tokens_type])
		    ||[llength $L_tokens_type] >= $weight} {
			 set L_tokens [lremove $L_tokens $L_tokens_type]
			 dict set D_res $var_name [dict create L_tokens $L_tokens_type place $place]
			} else {set b_res 0; set D_res ""; break}
		}
	
	set ms -1
	if { $b_res && [llength $L_ms_ok]} {set ms [lindex [lsort -real $L_ms_ok] 0]}
	if {!$b_res && [llength $L_ms_ko]} {set ms [lindex [lsort -real $L_ms_ko] 0]}

	return [list $b_res $D_res $ms $arc_depends_on_event]
}

#___________________________________________________________________________________________________________________________________________
method PetriNet:_:Place PutsTokens {place D_event_name D_weight_name D_pool_name D_used_name} {
	upvar $D_weight_name D_weight
	upvar $D_pool_name   D_pool
	upvar $D_used_name   D_used
	upvar $D_event_name	 D_event
	
	dict for {var_name D} $D_weight {
		 if {[dict exists $D_pool $var_name]} {
			 # puts -nonewline "variable $var_name has been declared"
			 if {![dict exists $D_used $var_name]} {
				  # puts " and has not been used previously"
				  $place Add_L_tokens [dict get $D_pool $var_name L_tokens]
				  dict set D_used $var_name 1
				 } else {set L_tmp [list]
						 # puts " but has been used, so we create a copy"
						 foreach token [dict get $D_pool $var_name L_tokens] {lappend L_tmp [TokenPool get_copy_of_token $token]}
						 $place Add_L_tokens $L_tmp
						}
			} else {
					# puts "variable $var_name is unknown in sources"
					# Look for [dict get $D w] tokens of type
					set type  	[dict get $D t]
					set weight	[dict get $D w]
					# Is it a specialization of Token class?
					set L_tokens_classes [concat [list PetriNet:_:Token] [gmlObject info specializations PetriNet:_:Token]]
					if {[lsearch $L_tokens_classes PetriNet:_:$type] >= 0} {
						 # puts "\ttype is $type"
						 set L_tmp [list]
						 for {set i 0} {$i < $weight} {incr i} {lappend L_tokens [TokenPool get_token PetriNet:_:$type]}
						} else {
								# puts "\tcombination is $type"
								# Else it it is combination
								# set L_tokens [eval [concat $type $weight D_pool]]
								set D_vars [dict create]
								# puts [concat $type $weight D_pool]
								set L_tokens [this Eval [concat $type $weight D_pool] D_pool D_vars]
							   }
					# Register variable and puts token in the place
					$place Add_L_tokens $L_tokens
					dict set D_pool $var_name [dict create L_tokens $L_tokens]
					dict set D_used $var_name 1
				   }
		}
	
}

#___________________________________________________________________________________________________________________________________________
proc PetriNet:_:Combinate {a b c weight D_pool_name} {
	upvar $D_pool_name D_pool
	
	puts "Combinate $a $b $c $weight $D_pool"
	
	return [list [TokenPool get_token PetriNet:_:Token]]
}

