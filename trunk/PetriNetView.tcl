package require Tk
package require tdom

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place constructor {place} {
	if {![info exists class(id)]} {set class(id) 0}
	
	# Data
	set this(place) $place
	
	# Nested presentations
	set this(D_nested_presentations) [dict create]
	set this(L_elements_clipboard) [list]
	set this(L_selected_elements)  [list]
	
	# Nesting PetriNetView
	set this(nesting_PetriNetView) ""
	
	# Presentation
	set this(D_dettached_presentations) [dict create]
	this recreate_canvas
	this Draw_place
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors PetriNetView:_:Place [list nesting_PetriNetView]

Generate_dict_accessors	PetriNetView:_:Place D_nested_presentations
Generate_dict_accessors	PetriNetView:_:Place D_preso

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_place {} {return $this(place)}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place detach_place {} {
	if {$this(place) != ""} {
		 foreach place [$this(place) get_L_nested_places] {
			 $place UnSubscribe_to_Add_L_tokens $objName
			 $place UnSubscribe_to_Sub_L_tokens $objName
			 # $place UnSubscribe_to_set_L_tokens $objName
			}
		 $this(place) UnSubscribe_to_Update_triggerability $objName
		}
	dict set this(D_dettached_presentations) $this(place) $this(D_nested_presentations)
	set this(place) ""
	this New_net 
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place attach_place {place} {
	this detach_place
	set this(place) $place
	if {[dict exists $this(D_dettached_presentations) $this(place)]} {
		 set this(D_nested_presentations) [dict get $this(D_dettached_presentations) $this(place)]
		}
	this recreate_and_redraw
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Copy {L_elements} {
	set this(L_elements_clipboard) $L_elements
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Replicate_presentation_information_for_nesting_place {keys place} {
	set cmd [list ]
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Paste {x y} {
	if {[llength $this(L_elements_clipboard)] == 0} {return}
	
	# Compute barycentre of clipboard elements
	lassign [$this(canvas) bbox [lindex $this(L_elements_clipboard) 0]] X1 Y1 X2 Y2
	foreach e $this(L_elements_clipboard) {
		 lassign [$this(canvas) bbox $e] x1 y1 x2 y2
		 if {$x1 < $X1} {set X1 $x1}; if {$y1 < $Y1} {set Y1 $y1}
		 if {$x2 > $X2} {set X2 $x2}; if {$y2 > $Y2} {set Y2 $y2}
		}
	set X [expr ($X1+$X2)/2]; set Y [expr ($Y1+$Y2)/2]
	set dx [expr $x - $X]; set dy [expr $y - $Y]
	
	# Replicate clipboard elements and set up presentation information
	set D_mapping [dict create]
	foreach e $this(L_elements_clipboard) {
		 set copy_e [$e Replicate_core [this get_unique_id copy_of_${e}] $this(place) $objName]
		 dict set D_mapping $e $copy_e
		 # set up presentation information
		 lassign [$this(canvas) bbox $e] x1 y1 x2 y2
		 dict set this(D_nested_presentations) $this(place) D_presentations $copy_e [dict create x [expr $x1 + $dx] y [expr $y1 + $dy]]
		 if { [lsearch [gmlObject info classes $copy_e] PetriNet:_:Place] >= 0
			&&[$copy_e get_nested_start_place] != ""} {
			 this Replicate_presentation_information_for_nesting_place [list $this(place) $place]
			}
		}
	foreach e $this(L_elements_clipboard) {
		 $e Replicate_links [dict get $D_mapping $e] $D_mapping
		}
		
	this recreate_and_redraw
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place recreate_canvas {} {
	if {![winfo exists ._$objName]} {
		 toplevel ._$objName
		 set this(frame_debug) ._$objName.fdebug
			frame $this(frame_debug) -background yellow
			pack $this(frame_debug) -side top -fill x -expand 1
			button $this(frame_debug).bt -background yellow -text Update -command [list $objName update_debug]
			pack $this(frame_debug).bt -side left -expand 0 -fill y
			label $this(frame_debug).lab -background yellow
			pack $this(frame_debug).lab -side left -anchor w
		 set this(frame_edit) ._$objName.fedit
			 frame $this(frame_edit) -background white
			 pack $this(frame_edit) -side right -expand 0 -fill y
		 
		 set menu_name ._$objName.menu
		 menu $menu_name 
		 menu $menu_name.file -tearoff 0
		 $menu_name add cascade -menu $menu_name.file -label "File"
		 $menu_name.file add command -command [list $objName New_net		] -label "New"
		 $menu_name.file add command -command [list $objName Load_from_file ] -label "Open"
		 $menu_name.file add command -command [list $objName Save_to_file   ] -label "Save"
		 
		 ._$objName configure -menu $menu_name
		}

	set this(canvas) ._$objName.canvas
	if {[winfo exists $this(canvas)]} {
		 # Save positions of elements
		 # puts "Save positions of elements"
		 foreach element [concat [$this(place) get_L_nested_places] [$this(place) get_L_nested_transitions]] {
			 # puts "\t$element"
			 lassign [$this(canvas) bbox $element] x1 y1
			 if {$x1 == ""} {continue}
			 set x $x1; set y $y1
			 dict set this(D_nested_presentations) $this(place) D_presentations $element [dict create x $x y $y]
			}
		}
	
	destroy $this(canvas)
	canvas  $this(canvas)
	pack    $this(canvas) -fill both -expand 1
	
	# Presentation elements
	set this(D_preso) [dict create $objName [dict create type PetriNetView]]
	set this(cmd_deselect) ""
	
	# Interaction
	set this(contextual_source) [list]
	set this(last_x) 0; set this(last_y) 0
	set this(dragged_element) ""
	set this(last_release)    ""
	bind $this(canvas) <ButtonPress-1> 	 [list $objName inter_Press   $objName %x %y]
	bind $this(canvas) <Motion> 	 	 [list $objName inter_Move    %x %y]
	bind $this(canvas) <ButtonRelease-1> [list $objName inter_Release %x %y]
	
	set this(L_selected_elements) [list]
	bind $this(canvas) <ButtonPress-2> 	 [list $objName Contextual_Press_on_canvas   %x %y]
	bind $this(canvas) <ButtonPress-3> 	 [list $objName Contextual_Press_on_canvas   %x %y]
	bind $this(canvas) <ButtonRelease-2> [list $objName Contextual_Release_on_canvas %x %y]
	bind $this(canvas) <ButtonRelease-3> [list $objName Contextual_Release_on_canvas %x %y]
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place New_net {} {
	if {$this(place) != ""} {
		if {[$this(place) get_nesting_place] == ""} {
			 $this(place) dispose
			 set this(place) [this get_unique_id P]
			 PetriNet:_:Place $this(place) $this(place) ""
			} else {$this(place) dispose_nested_graph}
		} else {set this(place) [this get_unique_id P]
				PetriNet:_:Place $this(place) $this(place) ""
			   }
			   
	set this(D_nested_presentations) [dict create $this(place) [dict create D_presentations [dict create] D_nested_places [dict create]]]
	this Create_hierarchy_for_place $this(place)
	
	this recreate_and_redraw
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Open_place {place} {
	set PetriNetView ""
	if {[catch {set PetriNetView [dict get $this(D_nested_presentations) $this(place) D_nested_places $place PetriNetView]} err]} {
		 dict set this(D_nested_presentations) $this(place) D_nested_places $place [dict create PetriNetView "" D_presentations [dict create]]
		}
	if {$PetriNetView == ""} {
		 set PetriNetView [this get_unique_id PetriNetView]
		 PetriNetView:_:Place $PetriNetView $place
		 $PetriNetView set_nesting_PetriNetView $objName
		 
		 dict set this(D_nested_presentations) $this(place) D_nested_places $place PetriNetView $PetriNetView
		 if {![dict exists $this(D_nested_presentations) $this(place) D_nested_places $place D_presentations]} {
			 dict set this(D_nested_presentations) $this(place) D_nested_places $place D_presentations [dict create]
			}
		 $PetriNetView set_D_nested_presentations [dict create $place [dict get $this(D_nested_presentations) $this(place) D_nested_places $place]]
		} else  {$PetriNetView recreate_canvas
				 $PetriNetView Draw_place
				}
	# puts "Editing PetriNetView $PetriNetView"
	$PetriNetView Update_positions_from_D_presentations
}
# Trace PetriNetView:_:Place Open_place
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Create_hierarchy_for_place {place} {
	# puts stderr "TODO PetriNetView:_:Place Create_hierarchy_for_place"
	set start [this get_unique_id P]
	set end   [this get_unique_id P]
	PetriNet:_:Place    $start $start $place
	PetriNet:_:EndPlace $end   $end   $place
	
	$place set_nested_start_place $start; dict set this(D_nested_presentations) $this(place) D_nested_places $start [dict create PetriNetView ""]
	$place set_nested_end_place   $end  ; dict set this(D_nested_presentations) $this(place) D_nested_places $end   [dict create PetriNetView ""]
	
	this recreate_and_redraw
	
	if {$place != $this(place)} {this Open_place $place}
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place recreate_and_redraw {} {
	this recreate_canvas
	this Draw_place
	this Update_positions_from_D_presentations
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_coords {element} {
	set D [dict get $this(D_nested_presentations) $this(place) D_presentations $element]
	return [list [dict get $D x] [dict get $D y]]
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Add_new_place {x y {place {}}} {
	if {$place == ""} {
		 set place [this get_unique_id P]
		 PetriNet:_:Place $place $place $this(place) 
		}
	dict set this(D_nested_presentations) $this(place) D_presentations $place [dict create x $x y $y]
	dict set this(D_nested_presentations) $this(place) D_nested_places $place [dict create PetriNetView ""]
	
	this recreate_and_redraw
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Add_new_transition {x y} {
	set transition [this get_unique_id T]
	PetriNet:_:Transition $transition $transition $this(place) event "" [list] [list]
	dict set this(D_nested_presentations) $this(place) D_presentations $transition [dict create x $x y $y]
	
	this recreate_and_redraw
	
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Delete_elements {L_elements} {
	foreach e $L_elements {
		puts "\tDelete $e"
		$e dispose
		dict unset this(D_nested_presentations) $this(place) D_presentations $e
		dict unset this(D_nested_presentations) $this(place) D_nested_places $e
		}
	this recreate_and_redraw
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Delete_or_create_arc {source target} {
	set C_source [lindex [gmlObject info classes $source] 0]
	if {[catch {set C_target [lindex [gmlObject info classes $target] 0]} err]} {puts stderr $err; return}
	if {$C_source != $C_target} {
		 if {$C_source == "PetriNet:_:Transition"} {
			 if {[$source has_item_D_targets $target]} {
				 $source remove_item_of_D_targets $target
				 $target Sub_L_sources $source
				} else	{$source set_item_of_D_targets $target [PetriNet:_:StandardEdge $target [dict create idT [dict create w 1 t Token]]]
						 $target Add_L_sources $source
						}
			} else	{if {[$target has_item_D_sources $source]} {
						 $target remove_item_of_D_sources $source
						 $source Sub_L_targets $target
						} else	{$target set_item_of_D_sources $source [PetriNet:_:StandardEdge $source [dict create idT [dict create w 1 t Token]]]
								 $source Add_L_targets $target
								}
					}
		 # Redraw
		 this recreate_and_redraw
		 return 1
		}
	return 0
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place set_D_vars_for_with {place txt} {
	set txt [string trim $txt]; if {[lindex $txt end] == "\\"} {set txt [string range $txt 0 end-1]}
	if {[catch {$place set_D_vars [eval [concat "dict create" $txt]]} err]} {
		 $place set_L_errors [list $err "Command was [concat "dict create" $txt]"]
		 $this(frame_edit).f_err.ent delete 0.0 end
		 $this(frame_edit).f_err.ent insert 0.0 [join [$place get_L_errors] "\n"]
		 $this(frame_edit).f_err.ent configure -background red
		} else {$place set_L_errors [list]
				$this(frame_edit).f_err.ent delete 0.0 end
				$this(frame_edit).f_err.ent configure -background green
				set txt ""; dict for {var val} [$place get_D_vars] {append txt "[list $var] [list $val] \\\n"}
				$this(frame_edit).f_nes.ent delete 0.0 end
				$this(frame_edit).f_nes.ent insert 0.0 $txt
			   }
}
Trace PetriNetView:_:Place set_D_vars_for_with
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Edit_element {type args} {
	foreach w [winfo children $this(frame_edit)] {destroy $w}
	eval $this(cmd_deselect)
	switch $type {
		 nesting_place {
			 set place $args
			 frame $this(frame_edit).f_nes
				label $this(frame_edit).f_nes.lab -text "Variables : "; pack $this(frame_edit).f_nes.lab -side top -anchor w
				text $this(frame_edit).f_nes.ent -width 60 -height 8 -background white; pack $this(frame_edit).f_nes.ent -side left -fill x
				set txt ""; dict for {var val} [$place get_D_vars] {append txt "[list $var] [list $val] \\\n"}
				# set txt [$place get_D_vars]
				$this(frame_edit).f_nes.ent insert 0.0 $txt
			 frame $this(frame_edit).f_err
				label $this(frame_edit).f_err.lab -text "Errors : "; pack $this(frame_edit).f_err.lab -side top -anchor w
				text $this(frame_edit).f_err.ent -width 60 -height 6 -background red; pack $this(frame_edit).f_err.ent -side left -fill x
				$this(frame_edit).f_err.ent insert 0.0 [join [$place get_L_errors] "\n"]
				if {[llength [$place get_L_errors]]} {
					 $this(frame_edit).f_err.ent configure -background red
					} else {$this(frame_edit).f_err.ent configure -background green}
			 frame $this(frame_edit).f_val
				button $this(frame_edit).f_val.ok -text "  OK  " -command  "$objName set_D_vars_for_with $place \[$this(frame_edit).f_nes.ent get 0.0 end\]"
				pack $this(frame_edit).f_val.ok -side right
			}
		 place		{
			 set place $args; $this(canvas) itemconfigure oval_$place -fill magenta
							  set this(cmd_deselect) [list $this(canvas) itemconfigure oval_$place -fill white]
			 frame $this(frame_edit).f_name
				label $this(frame_edit).f_name.lab -text "Name : "; pack $this(frame_edit).f_name.lab -side left
				entry $this(frame_edit).f_name.ent; pack $this(frame_edit).f_name.ent -side left -fill x
				$this(frame_edit).f_name.ent insert 0 [$place get_name]
			 frame $this(frame_edit).f_cmd
				button $this(frame_edit).f_cmd.ok -text "  OK  " -command 	"$place set_name \[$this(frame_edit).f_name.ent get\]
																			 $objName recreate_and_redraw
																			"
				pack $this(frame_edit).f_cmd.ok -side right
			}
		 transition	{
			 set transition $args; $this(canvas) itemconfigure rectangle_$transition -fill magenta
								   set this(cmd_deselect) [list $this(canvas) itemconfigure rectangle_$transition -fill white]
			 frame $this(frame_edit).f_name
				label $this(frame_edit).f_name.lab -text "Name : "; pack $this(frame_edit).f_name.lab -side left
				entry $this(frame_edit).f_name.ent; pack $this(frame_edit).f_name.ent -side left -fill x
				$this(frame_edit).f_name.ent insert 0 [$transition get_name]
			 frame $this(frame_edit).f_event
				label $this(frame_edit).f_event.lab -text "Event : "; pack $this(frame_edit).f_event.lab -side left
				entry $this(frame_edit).f_event.ent; pack $this(frame_edit).f_event.ent -side left -fill x
				$this(frame_edit).f_event.ent insert 0 [$transition get_event]
			 frame $this(frame_edit).f_cond
				label $this(frame_edit).f_cond.lab -text "Guard condition : "; pack $this(frame_edit).f_cond.lab -side top -anchor w
				text $this(frame_edit).f_cond.ent -width 60 -height 3; pack $this(frame_edit).f_cond.ent -side left -fill x
				$this(frame_edit).f_cond.ent insert 0.0 [$transition get_D_cond_triggerable]
			 frame $this(frame_edit).f_cmd
				label $this(frame_edit).f_cmd.lab -text "Command : "; pack $this(frame_edit).f_cmd.lab -side top -anchor w
				text $this(frame_edit).f_cmd.ent -width 60 -height 10; pack $this(frame_edit).f_cmd.ent -side left -fill x
				$this(frame_edit).f_cmd.ent insert 0.0 [$transition get_cmd_trigger]
			 frame $this(frame_edit).f_err
				label $this(frame_edit).f_err.lab -text "Errors : "; pack $this(frame_edit).f_err.lab -side top -anchor w
				text $this(frame_edit).f_err.ent -width 60 -height 6 -background red; pack $this(frame_edit).f_err.ent -side left -fill x
				$this(frame_edit).f_err.ent insert 0.0 [join [$transition get_L_errors] "\n"]
			 frame $this(frame_edit).f_val
				button $this(frame_edit).f_val.ok -text "  OK  " -command  "$transition set_name \[$this(frame_edit).f_name.ent get\]
																			$transition set_event \[$this(frame_edit).f_event.ent get\];
																		    $transition set_cmd_trigger \[string trim \[$this(frame_edit).f_cmd.ent get 0.0 end\]\]
																			$transition set_D_cond_triggerable \[string trim \[$this(frame_edit).f_cond.ent get 0.0 end\]\]
																			$objName recreate_and_redraw
																		   "
				pack $this(frame_edit).f_val.ok -side right
			}
		 arc		{
			 lassign $args source target; $this(canvas) itemconfigure arc_${source}_$target -fill magenta
										  set this(cmd_deselect) [list $this(canvas) itemconfigure arc_${source}_$target -fill black]
			 if {[lsearch [gmlObject info classes $source] PetriNet:_:Transition] >= 0} {
				 set transition $source; set D_name D_targets; set place $target
				} else {set transition $target; set D_name D_sources; set place $source}
			 frame $this(frame_edit).f_name
				label $this(frame_edit).f_name.name   -text "Arc"; pack $this(frame_edit).f_name.name -side top -anchor w
				label $this(frame_edit).f_name.source -text "  source : [$source get_name]($source)"; pack $this(frame_edit).f_name.source -side top -anchor w
				label $this(frame_edit).f_name.target -text "  target : [$target get_name]($target)"; pack $this(frame_edit).f_name.target -side top -anchor w
			 global PetriNetView:_:Place__menu_type_arc
			 tk_optionMenu $this(frame_edit).f_name.type PetriNetView:_:Place__menu_type_arc StandardEdge ConditionnaldEdge inhibitordEdge
				pack $this(frame_edit).f_name.type -side top -fill x -expand 1
				set PetriNetView:_:Place__menu_type_arc [$transition get_item_of_$D_name [list $place type]]
			 frame $this(frame_edit).f_weight
				label $this(frame_edit).f_weight.lab -text "Weight : "; pack $this(frame_edit).f_weight.lab -side top -anchor w
				text  $this(frame_edit).f_weight.txt -width 60 -height 10; pack $this(frame_edit).f_weight.txt -side left -fill x
				$this(frame_edit).f_weight.txt insert 0.0 [$transition get_item_of_$D_name [list $place D_weight]]
			 frame $this(frame_edit).f_event
				set cmd "$transition set_item_of_$D_name \[list $place\] \[PetriNet:_:\${PetriNetView:_:Place__menu_type_arc} $place \[string trim \[$this(frame_edit).f_weight.txt get 0.0 end\]\]\];
						 $objName recreate_and_redraw
						"
				button $this(frame_edit).f_event.ok -text "  OK  " -command $cmd
				pack $this(frame_edit).f_event.ok -side right
			}
		}
	foreach w [winfo children $this(frame_edit)] {
		 pack $w -side top -fill x
		}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_place_representing {place} {
	if {[dict exists $this(D_preso) $place]} {return [list $place 0]}
	set nesting_place [$place get_nesting_place]
	if {$nesting_place != ""} {
		 lassign [this get_place_representing $nesting_place] nesting_place 
		 return  [list $nesting_place 1]
		}
	puts stderr "In $objName : There is no place representing $place ..."
	return ""
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Draw_place {{L_places {}} {L_transitions {}}} {
	if {$this(place) == ""} {return}
	if { [llength $L_places] == 0
	   &&[llength $L_transitions] == 0 } {set L_places [$this(place) get_L_nested_places]}

	# Draw places
	foreach place $L_places {
		 $this(canvas) delete $place
		 if {![dict exists $this(D_preso) $place]} {
			 # Text
			 $this(canvas) create text 0 0 -text [$place get_name] -anchor nw -tags [list $objName $place text_$place in_$place place_text just_$place]
			 lassign [$this(canvas) bbox $place] x1 y1 x2 y2; set X [expr ($x1+$x2)/2]; set Y [expr ($y1+$y2)/2]
			 incr x1 -3; incr x2 3
				# is this place nesting other places ?
				if {[$place get_nested_start_place] != ""} {
					 # Add representation for nested start place
					 set nested_start_place [$place get_nested_start_place]
					 $this(canvas) create oval 	[expr $x1 - 4] [expr $y2 - 2]	\
												[expr $x1 - 0] [expr $y2 + 2]	\
												-fill black -tags [list $objName $nested_start_place $place start_in_$place in_$place]
					 dict set this(D_preso) $nested_start_place [dict create type place oval start_in_$place]
					 $this(canvas) bind start_in_$place <ButtonPress-2> [list $objName Contextual_Press_on $nested_start_place %x %y]
					 $this(canvas) bind start_in_$place <ButtonPress-3> [list $objName Contextual_Press_on $nested_start_place %x %y]
					 # Add representation for nested end   place
					 set nested_end_place [$place get_nested_end_place]
					 $this(canvas) create oval 	[expr $x2 + 2] [expr $y2 - 2]	\
												[expr $x2 + 6] [expr $y2 + 2]	\
												-fill black -tags [list $objName $nested_end_place $place end_in_$place in_$place]
					 $this(canvas) create oval 	[expr $x2 + 0] [expr $y2 - 4]	\
												[expr $x2 + 8] [expr $y2 + 4]	\
												-tags [list $objName $nested_end_place $place end_in_$place in_$place]
					 dict set this(D_preso) $nested_end_place [dict create type place oval end_in_$place]
					 $this(canvas) bind end_in_$place <ButtonPress-2> [list $objName Contextual_Press_on $nested_end_place %x %y]
					 $this(canvas) bind end_in_$place <ButtonPress-3> [list $objName Contextual_Press_on $nested_end_place %x %y]
					}
					
			 lassign [$this(canvas) bbox $place] x1 y1 x2 y2

			 # Text for token
			 set txt_token ""
			 set nb_tokens [$place llength_L_tokens]
			 if {$nb_tokens > 0} {set txt_token $nb_tokens}
			 $this(canvas) create text  [expr ($x1+$x2)/2.0] [expr $y2 + 3] -fill red -font "Arial 6" -text $txt_token -tags [list $objName $place in_$place text_nb_token_of_$place just_$place]
				# Subscribe for token changes
				$place Subscribe_to_Add_L_tokens $objName [list $objName Update_preso_nb_tokens_of $place] UNIQUE
				$place Subscribe_to_Sub_L_tokens $objName [list $objName Update_preso_nb_tokens_of $place] UNIQUE
				# $place Subscribe_to_set_L_tokens $objName [list $objName Update_preso_nb_tokens_of $place] UNIQUE

			 # Ellipse
			 set nesting_place [$place get_nesting_place]
			 if {$place == [$nesting_place get_nested_end_place]} { 
				 $this(canvas) create oval [expr $x1 - 8] [expr $y1 - 8] [expr $x2 + 8] [expr $y2 + 15] -fill white -tags [list $objName $place end_oval_$place bg_$place id:$place just_$place]
				}
			 $this(canvas) create oval [expr $x1 - 3] [expr $y1 - 3] [expr $x2 + 3] [expr $y2 + 10] -fill white -tags [list $objName $place oval_$place place_oval bg_$place id:$place just_$place]
			 $this(canvas) raise  in_$place
			 if { $place == [$nesting_place get_nested_end_place]
			    ||$place == [$nesting_place get_nested_start_place] } {
				 $this(canvas) itemconfigure oval_$place -width 3
				}
			 
			 # Interaction
			 $this(canvas) bind $place <ButtonPress-1> [list $objName inter_Press 		  $place %x %y]
			 $this(canvas) bind just_$place <ButtonPress-2> [list $objName Contextual_Press_on $place %x %y]
			 $this(canvas) bind just_$place <ButtonPress-3> [list $objName Contextual_Press_on $place %x %y]
			 
			 # Register
			 $this(canvas) bind $place <ButtonRelease-2> [list $objName Contextual_Release_on place $place %x %y]
			 $this(canvas) bind $place <ButtonRelease-3> [list $objName Contextual_Release_on place $place %x %y]
			 dict set this(D_preso) $place [dict create type place text text_$place oval oval_$place]
			 # puts "Create place $place"
			}
		}

	# Draw transitions
	if { [llength $L_transitions] == 0 } {set L_transitions [$this(place) get_L_nested_transitions]}
	foreach transition $L_transitions {
		 $this(canvas) delete $transition
		 $this(canvas) delete arc_related_to_$transition
		 if {![dict exists $this(D_preso) $transition]} {
			 # Text
			 $this(canvas) create text 0 0 -text [$transition get_name] -anchor nw -tags [list $objName $transition text_$transition transition_text]
			 lassign [$this(canvas) bbox $transition] x1 y1 x2 y2
			 
			 # Rectangle
			 $this(canvas) create rectangle [expr $x1 - 3] [expr $y1 - 3] [expr $x2 + 3] [expr $y2 + 3] -fill white -tags [list $objName $transition rectangle_$transition transition_rectangle bg_$transition id:$transition]
			 $this(canvas) raise  text_$transition
				# Chack if input/output variables are consistent
				# Input variables must be unique for all input arcs
				set D_input_var_names [dict create]; set L_errors [list]
				dict for {place D_place} [$transition get_D_sources] {
					 dict for {var_name D_weight} [dict get $D_place D_weight] {
						 if {[dict exists $D_input_var_names $var_name]} {
							 lappend L_errors "Input variable \"$var_name\" still exists, please rename it (arc from place $place : [$place get_name])"
							} else {dict set D_input_var_names $var_name [dict create weight [dict get $D_weight w] place $place]
								   }
						}
					}
				# Output variable must be unique in its output arc
				dict for {place D_place} [$transition get_D_targets] {
					 set L_output_var_names [list]
					 dict for {var_name D_weight} [dict get $D_place D_weight] {
						 if {[lsearch $L_output_var_names $var_name] >= 0} {
							 lappend L_errors "Output variable \"$var_name\" still exists, please rename it (arc to $place : [$place get_name])"
							} else {lappend L_output_var_names $var_name
									# Chack wether weight are the same in the input variables
									if { [dict exists $D_input_var_names $var_name]
									   &&[dict get $D_input_var_names $var_name weight] != [dict get $D_weight w]} {
									    set in_place [dict get $D_input_var_names $var_name place]
										lappend L_errors "Output variable $var_name (to place $place : [$place get_name] has weight different from input from $in_place : [$in_place get_name]"
									   }
								   }
						}
					}
					
				# If there are some errors, change rectangle background
				$transition set_L_errors $L_errors
				if {[llength $L_errors]} {
					 $this(canvas) itemconfigure rectangle_$transition -fill red
					}
			 
			 # Interaction
			 $this(canvas) bind $transition <ButtonPress-1> [list $objName inter_Press 			$transition %x %y]
			 $this(canvas) bind $transition <ButtonPress-2> [list $objName Contextual_Press_on	$transition %x %y]
			 $this(canvas) bind $transition <ButtonPress-3> [list $objName Contextual_Press_on	$transition %x %y]
			 
			 # Register
			 dict set this(D_preso) $transition [dict create type transition text text_$transition oval rectangle_$transition]
			 # puts "Create transition $transition"
			 
			 # Draw arcs
			 dict for {place D_place} [$transition get_D_sources] {
				 lassign [this get_place_representing $place] place nested
				 if {[catch {PetriNet:_:Create_arc $D_place $this(canvas) $place $transition 0 0 0 0 [list $objName]} err]} {puts stderr "Error creating arc from $place to $transition :\n$err"}
				}
			 dict for {place D_place} [$transition get_D_targets] {
				 lassign [this get_place_representing $place] place nested
				 if {[catch {PetriNet:_:Create_arc $D_place $this(canvas) $transition $place 0 0 0 0 [list $objName]} err]} {puts stderr "Error creating arc from $transition to $place :\n$err"}
				}
			 $this(canvas) bind $transition <ButtonRelease-2> [list $objName Contextual_Release_on transition $transition %x %y]
			 $this(canvas) bind $transition <ButtonRelease-3> [list $objName Contextual_Release_on transition $transition %x %y]
			}
		}
	$this(canvas) raise transition
	$this(canvas) raise place
	
	# Subscribe to nested transitions changes
	# set cmd "$this(canvas) itemconfigure rectangle_\$t -fill \[lindex \[list white green\] \$b\]"
	set cmd "$objName Update_color_of_transition \$t"
	$this(place) Subscribe_to_Update_triggerability $objName $cmd UNIQUE
	
	foreach transition [$this(place) get_L_nested_transitions] {$this(place) Update_triggerability $transition}
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Update_color_of_transition {transition} {
	set triggerable [[$transition get_nesting_place] get_item_of_D_triggerable_transitions [list $transition triggerable]]
	if {[llength [[$transition get_nesting_place] get_L_tokens]] == 0} {set triggerable 0}
	if {[llength [$transition get_L_errors]]} {
		 set color red
		} else {set color [lindex [list white green] $triggerable]}
	$this(canvas) itemconfigure rectangle_$transition -fill $color
}
# Trace PetriNetView:_:Place Update_color_of_transition
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place inter_Press {element x y} {
	if {$this(dragged_element) == ""} {
		 set this(dragged_element) $element
		 set this(last_x) $x; set this(last_y) $y
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place inter_Release {x y} {
	set this(dragged_element) 	""
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Update_selected_elements_in {x1 y1 x2 y2} {
	set L [list ]
	
	# Compute selected places and transitions
	foreach canvas_id [$this(canvas) find overlapping $x1 $y1 $x2 $y2] {
		 set L_tags [$this(canvas) gettags $canvas_id]
		 foreach tag $L_tags {
			 if {[string equal -length 3 "id:" $tag]} {
				 set element [string range $tag 3 end]
				 if {[lsearch $L $element] == -1} {lappend L $element}
				}
			}
		}
		
	# For each newly selected element, turn outline to blue
	foreach e $L {
		 if {[lsearch $this(L_selected_elements) $e] == -1} {$this(canvas) itemconfigure bg_$e -outline magenta}
		}
		
	# For each no more selected element, turn outline to black
	foreach e $this(L_selected_elements) {
		 if {[lsearch $L $e] == -1} {$this(canvas) itemconfigure bg_$e -outline black}
		}
	
	# Update selected elements
	set this(L_selected_elements) $L
}

#___________________________________________________________________________________________________________________________________________
# Move selected elements if dragged_element is part of it, take care of infinite loop
method PetriNetView:_:Place inter_Move {x y {dragged_element {}}} {
	# puts "move : {$this(contextual_source)}"
	if {[llength $this(contextual_source)]} {
		 lassign $this(contextual_source) e x1 y1
		 $this(canvas) coords feedback $x1 $y1 $x $y
		 if {$e == $objName} {this Update_selected_elements_in $x1 $y1 $x $y}
		}

	if {$dragged_element == ""} {set dragged_element $this(dragged_element)}
	if {$dragged_element != ""} {
		 # Is the dragged element part of the selection?
		 if {[lsearch $this(L_selected_elements) $dragged_element] >= 0} {
			 set L_temp $this(L_selected_elements); set this(L_selected_elements) [list]
			 set last_x $this(last_x); set last_y $this(last_y); set dragged_element $this(dragged_element)
			 foreach e $L_temp {
				 set this(last_x) $last_x; set this(last_y) $last_y; set this(dragged_element) $e
				 this inter_Move $x $y $e
				}
			 
			 set this(L_selected_elements) $L_temp
			 set this(last_x) $x; set this(last_y) $y; set this(dragged_element) $dragged_element
			 return
			}
		 
		 # Just drag
		 if {$dragged_element == $this(dragged_element)} {
			 $this(canvas) move $dragged_element [expr $x - $this(last_x)] [expr $y - $this(last_y)]
			 set this(last_x) $x; set this(last_y) $y
			}
		 # puts "moving $dragged_element"
		 switch [dict get $this(D_preso) $dragged_element type] {
			 place		{set place $dragged_element
				 foreach transition [$place get_L_sources] {
					 if {![dict exists $this(D_preso) $transition]} {continue}
					 lassign [this get_place_representing $place] place nested
					 lassign [this compute_edge $place $transition -1] ax1 ay1 mx my ax2 ay2
					 PetriNet:_:Update_arc [$transition get_item_of_D_targets $place] $this(canvas) $transition $place $ax2 $ay2 $mx $my $ax1 $ay1
					}
				 foreach transition [$place get_L_targets] {
					 if {![dict exists $this(D_preso) $transition]} {continue}
					 lassign [this get_place_representing $place] place nested
					 lassign [this compute_edge $place $transition 1] ax1 ay1 mx my ax2 ay2
					 PetriNet:_:Update_arc [$transition get_item_of_D_sources $place] $this(canvas) $place $transition $ax1 $ay1 $mx $my $ax2 $ay2
					}
				 if {[$place get_nested_start_place] != ""} {this inter_Move $x $y [$place get_nested_start_place]}
				 if {[$place get_nested_end_place  ] != ""} {this inter_Move $x $y [$place get_nested_end_place  ]}
				}
			 transition	{set transition $dragged_element
				 dict for {place D_place} [$transition get_D_sources] {
					 lassign [this get_place_representing $place] place nested
					 lassign [this compute_edge $place $transition 1] ax1 ay1 mx my ax2 ay2
					 PetriNet:_:Update_arc $D_place $this(canvas) $place $transition $ax1 $ay1 $mx $my $ax2 $ay2
					}
				 dict for {place D_place} [$transition get_D_targets] {
					 lassign [this get_place_representing $place] place nested
					 lassign [this compute_edge $place $transition -1] ax1 ay1 mx my ax2 ay2
					 PetriNet:_:Update_arc $D_place $this(canvas) $transition $place $ax2 $ay2 $mx $my $ax1 $ay1
					}
				}
			}
		}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Save_to_file {{file_name {}}} {
	if {$file_name == ""} {
		 set file_name [tk_getSaveFile -initialdir [pwd]]
		 if {$file_name == ""} {return}
		}
	set doc 		[dom createDocument PetriNetView]
	set node_text 	[$doc createTextNode ""]
	set f [open $file_name w]
		this Save_to_stream $node_text $f "" 1
	close $f
	$doc delete
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Save_to_stream {node_text f dec save_fc} {
		fconfigure $f -encoding utf-8
		puts $f "${dec}<PetriNetView place=\"$this(place)\">"
			if {$save_fc} {$this(place) Save_to_stream $node_text $f "\t"}
			this recreate_and_redraw
			this Save_D_presentation_to_stream $f "\t$dec" $this(D_nested_presentations)
			# foreach preso $this(L_views) {$preso Save_to_stream $node_text $f $dec\t 0}
		puts $f "${dec}</PetriNetView>"
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Save_D_presentation_to_stream {stream dec D_descr} {
	dict for {p D} $D_descr {
		 if {[dict exists $D D_presentations]} {
			 dict for {e D_preso} [dict get $D D_presentations] {
				 if {[lsearch [gmlObject info classes $e] PetriNet:_:Transition] >= 0} {set type transition} else {set type place}
				 puts $stream "${dec}<presentation type=\"$type\" represents=\"$e\" x=\"[dict get $D_preso x]\" y=\"[dict get $D_preso y]\" />"
				}
			}
		 if {[dict exists $D D_nested_places]} {
			 dict for {e D_nested} [dict get $D D_nested_places] {
				 puts $stream "${dec}<PetriNetView place=\"$e\">"
				 set PNV [dict get $D_nested PetriNetView]
				 if {$PNV == ""} {
					 this Save_D_presentation_to_stream $stream \t$dec [dict create $e $D_nested]
					} else {$PNV Save_D_presentation_to_stream $stream \t$dec [$PNV get_D_nested_presentations]}
				 
				 puts $stream "${dec}</PetriNetView>"
				}
			}
		}
}
# Trace PetriNetView:_:Place Save_D_presentation_to_stream
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Load_from_file {{file_name {}}} {
	if {$file_name == ""} {
		 set file_name [tk_getOpenFile -initialdir [pwd]]
		 if {$file_name == ""} {return}
		}
	set f [open $file_name r]
		fconfigure $f -encoding utf-8
		set doc [dom parse [read $f]]
		close $f
		set root [$doc documentElement]
			set this(D_mapping_name) 			[dict create "" ""]
			set this(D_nested_presentations) 	[dict create]
			
			set place_node [$root selectNodes "./place"]
			set nesting_place $this(place)
			set this(place) [this Create_net_recursivly $place_node ""]
			
			# Create representations
			set this(D_nested_presentations) [dict create]
			this recreate_canvas
			this Draw_place
			
			# Move representations
			foreach preso [$root selectNodes "./presentation"] {
				 foreach att [list represents x y] {set $att [$preso getAttribute $att]}
				 set this(dragged_element) [dict get $this(D_mapping_name) $represents]
				 set this(last_x) 0; set this(last_y) 0
				 this inter_Move $x $y
				}
			set this(dragged_element) ""
			
			# Load nested presentations information
			this Recursive_load_of_PetriNetView $root [list]
			dict set this(D_nested_presentations) $this(place) PetriNetView $objName
			
			# Do we load inside an other place?
			if {$nesting_place != ""} {
				 # Substitution of arcs
				 if {[$nesting_place get_nesting_place] != ""} {
					 [$nesting_place get_nesting_place] Nest_place $this(place)
					}
				 $nesting_place Substitute_by $this(place)
				 $this(place) set_name [$nesting_place get_name]
				
				 # PNV containing the place
				 set PNV [this get_nesting_PetriNetView]
				 if {$PNV != ""} {
					  # Deletion of the previous nesting place
					  lassign [$PNV get_coords $nesting_place] x y
					  puts "Adding new place $this(place) at $x $y"
					  $PNV Add_new_place $x $y $this(place)
					  puts "Deletion of $nesting_place after substitution by $this(place)"
					  $PNV Delete_elements [list $nesting_place]
					  # this(D_preso)
					 }
				}
		$doc delete
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Update_positions_from_D_presentations {} {
	dict for {place D} [dict get $this(D_nested_presentations) $this(place) D_presentations] {
		 set this(dragged_element) $place
		 lassign [$this(canvas) bbox $place] x1 y1
		 if {$x1 == ""} {
			 puts stderr "Problem in Update_positions_from_D_presentations :\\t$place is not represented"
			 continue
			}
		 $this(canvas) move $place [expr -$x1] [expr -$y1]
		 set this(last_x) 0; set this(last_y) 0
		 this inter_Move [dict get $D x] [dict get $D y]
		}
	set this(dragged_element) ""
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Recursive_load_of_PetriNetView {root_node L_nesting_places} {
	set cmd [list dict set this(D_nested_presentations) $this(place)]
		foreach place $L_nesting_places {lappend cmd D_nested_places $place}
	eval [concat $cmd [list PetriNetView ""]]
	eval [concat $cmd [list D_nested_places [dict create]]]
	foreach preso [$root_node selectNodes "./presentation"] {
		 foreach att [list represents x y] {set $att [$preso getAttribute $att]}
		 set represented_element [dict get $this(D_mapping_name) $represents]
		 eval [concat $cmd [list D_presentations $represented_element [dict create x $x y $y]]]
		}
	foreach preso [$root_node selectNodes "./PetriNetView"] {
		 set represents [$preso getAttribute place]
		 set represented_element [dict get $this(D_mapping_name) $represents]
		 this Recursive_load_of_PetriNetView $preso [concat $L_nesting_places [list $represented_element]]
		}
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_unique_id {prefix} {
	incr class(id)
	return ${prefix}_$class(id)
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Create_net_recursivly {place_node nesting_place {L_nesting_places {}}} {
	# Get attributes
	foreach att_node [$place_node selectNodes "./attribute"] {
		 set [$att_node getAttribute type] [$att_node asText]
		}
		
	# Create places recursivly
	set place_name [this get_unique_id place]
	dict set this(D_mapping_name) $tclid $place_name
	PetriNet:_:Place $place_name $name $nesting_place
	foreach nested_place [$place_node selectNodes "./place"] {
		 this Create_net_recursivly $nested_place $place_name [concat $L_nesting_places [list $place_name]]
		 }
	# Save information about the nested elements
	set start_place [dict get $this(D_mapping_name) $nested_start_place	]
	if {$start_place != ""} {
		 set start_place_name [$start_place get_name]
		 $start_place dispose
		 PetriNet:_:StartPlace $start_place $start_place_name $place_name
		}
	$place_name set_nested_start_place $start_place
	
	set end_place [dict get $this(D_mapping_name) $nested_end_place	]
	if {$end_place != ""} {
		 set end_place_name [$end_place get_name]
		 $end_place dispose
		 PetriNet:_:EndPlace $end_place $end_place_name $place_name
		}
	$place_name set_nested_end_place $end_place
	
	if {[$place_name get_nested_start_place] != ""} {
		 set cmd [list dict set this(D_nested_presentations)]
			foreach place $L_nesting_places {lappend cmd $place D_nested_places}
			lappend cmd $place_name
		 eval [concat $cmd [list D_presentations [dict create]]]
		 eval [concat $cmd [list D_nested_places [dict create]]]
		 eval [concat $cmd [list PetriNetView 	 ""			  ]]
		}
	
	# Save information about the events
	set new_D_events [dict create]
		dict for {e D} $D_events {
			 dict set D L_transitions [list]
			 dict set new_D_events $e $D
			}
		$place_name set_D_events $new_D_events
	
	# Create transitions
	foreach transition [$place_node selectNodes "./transition"] {
		 foreach att_node [$transition selectNodes "./attribute"] {
			 set [$att_node getAttribute type] [$att_node asText]
			}
		 set D_arc_sources [dict create]; dict for {k v} $D_sources {
			 set place_name_in_xml $k
			 set place_name_in_tcl [dict get $this(D_mapping_name) $place_name_in_xml]
			 dict set D_arc_sources $place_name_in_tcl [eval PetriNet:_:[lreplace $v 1 1 $place_name_in_tcl]]
			}
		 set D_arc_targets [dict create]; dict for {k v} $D_targets {
			 set place_name_in_xml $k
			 set place_name_in_tcl [dict get $this(D_mapping_name) $place_name_in_xml]
			 dict set D_arc_targets $place_name_in_tcl [eval PetriNet:_:[lreplace $v 1 1 $place_name_in_tcl]]
			}
		 set transition_name [this get_unique_id transition]
		 PetriNet:_:Transition $transition_name $name $place_name \
												$event $cmd_trigger \
												$D_arc_sources $D_arc_targets
		 if {[info exists D_cond_triggerable]} {
			 $transition_name set_D_cond_triggerable $D_cond_triggerable
			 unset D_cond_triggerable
			}
		 dict set this(D_mapping_name) $tclid $transition_name
		}
	
	# Return the reference of the newly created place
	return $place_name
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_____________________________________________________________________________________________________________
method PetriNetView:_:Place update_debug {} {
	# Debug
	set txt "D_composite :\n"
	dict for {k v} [$this(place) get_D_composite_tokens] {append txt "\t$k : {$v}\n"}
	append txt "D_composant :\n"
	dict for {k v} [$this(place) get_D_composant_tokens] {append txt "\t$k : {$v}\n"}
	$this(frame_debug).lab configure -text $txt
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Update_preso_nb_tokens_of {place} {
	# Display tokens
	set nb [$place llength_L_tokens]
	if {$nb > 0} {
		 set txt $nb
		 foreach token [$place get_L_tokens] {
			 append txt "\n" $token
			}
		} else {set txt ""}
	$this(canvas) itemconfigure text_nb_token_of_$place -text $txt
}
# Trace PetriNetView:_:Place Update_preso_nb_tokens_of

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_____________________________________________________________________________________________________________
method PetriNetView:_:Place Contextual_Press_on {element x y} {
	set this(contextual_source) [list $element $x $y]
	$this(canvas) create line $x $y $x $y -arrow last -tags [list feedback_arc feedback]
}
# Trace PetriNetView:_:Place Contextual_Press_on

#_____________________________________________________________________________________________________________
method PetriNetView:_:Place Contextual_Press_on_canvas {x y} {
	if {[llength $this(contextual_source)] == 0} {
		 set this(contextual_source) [list $objName $x $y]
		 $this(canvas) create rectangle $x $y $x $y -tags [list feedback_rect feedback]
		 foreach e $this(L_selected_elements) {$this(canvas) itemconfigure -outline black}
		 # set this(L_selected_elements) [list]
		}
}
# Trace PetriNetView:_:Place Contextual_Press_on_canvas

#_____________________________________________________________________________________________________________
method PetriNetView:_:Place Contextual_Release_on_canvas {x y} {
	# puts "Contextual_Release_on_canvas : $this(contextual_source)"
	# Create an arc 
	# puts "contextual_source : $this(contextual_source)"
	if { [llength $this(contextual_source)] } {
		 set start_xy [lrange $this(contextual_source) 1 2]
		 if {[lindex $this(contextual_source) 0] != $objName} {
			 # Who is under the mouse?
			 foreach e [lreverse [$this(canvas) find overlapping $x $y $x $y]] {
				 lassign [$this(canvas) gettags $e] obj target
				 if {$obj == $objName} {
					 lassign $this(contextual_source) source
					 if {[this Delete_or_create_arc $source $target]} {break}
					}
				}
			}
		
		 # Reset 
		 set this(contextual_source) [list]
		 $this(canvas) delete feedback
		 
		 if {"$x $y" != $start_xy} {return}
				 # Contextual click on an arc ?
				 # puts "Contextual click on arc?"
				 foreach e [$this(canvas) find overlapping [expr $x-3] [expr $y-3] [expr $x+3] [expr $y+3]] {
					 set L_tags [lassign [$this(canvas) gettags $e] obj type target]
					 if {$obj == $objName && $type == "arc"} {
						 set source ""; set target ""
						 foreach tag $L_tags {
							 regexp {^source\:(.*)$} $tag reco source
							 regexp {^target\:(.*)$} $tag reco target
							}
						 set m ._${objName}_Contextual_menu
						 if {![winfo exists $m]} {menu $m} else {$m delete 0 end}
						 $m add command -label "Edit arc" -command [list $objName Edit_element arc $source $target]
						 tk_popup $m [expr $x + [winfo rootx $this(canvas)]] [expr $y + [winfo rooty $this(canvas)]]
						 return
						}
					}
				}
				
	# Contextual menu ?
	if {$this(last_release) == "$x $y"} {return}
	set this(last_release) ""
	set m ._${objName}_Contextual_menu
	if {![winfo exists $m]} {menu $m} else {$m delete 0 end}
	$m add command -label "Edit nesting place" -command [list $objName Edit_element nesting_place $this(place)]
	$m add separator
	if {[llength $this(L_elements_clipboard)]} {
		 $m add command -label "Paste"	-command [list $objName Paste $x $y]
		 $m add separator
		}
	
	$m add command -label "add Place" 		-command [list $objName Add_new_place 	   $x $y]
	$m add command -label "add Transition"	-command [list $objName Add_new_transition $x $y]
	$m add separator
	dict for {e D} [$this(place) get_D_events] {
				 $m add command -label "Trigger event $e" -command [list $this(place) TriggerEvent $e {} {}]
				}
	$m add separator
	$m add command -label "add Token"		-command [list $this(place) Add_a_token]
		
	tk_popup $m [expr $x + [winfo rootx $this(canvas)]] [expr $y + [winfo rooty $this(canvas)]]
}
# Trace PetriNetView:_:Place Contextual_Release_on_canvas
#_____________________________________________________________________________________________________________
method PetriNetView:_:Place Contextual_Release_on {type element x y} {
	set this(last_release) "$x $y"
	if {$this(contextual_source) != "$element $x $y"} {return}
	
	set m ._${objName}_Contextual_menu
	if {![winfo exists $m]} {menu $m} else {$m delete 0 end}
	
	# Is element part of the selection?
	if {[lsearch $this(L_selected_elements) $element] >= 0} {
		 # Copy, delete all
		 $m add command -label "Copy selection" -command [list $objName Copy $this(L_selected_elements)]
		 $m add command -label "Delete selection" -command [list $objName Delete_elements $this(L_selected_elements)]
		 $m add separator
		}
	
	
	switch $type {
		 place		{
			 $m add command -label "Edit place" -command [list $objName Edit_element place $element]
			 if {[$element get_nested_start_place] != ""} {
				 $m add command -label "Edit hierarchy" -command [list $objName Open_place $element]
				} else {$m add command -label "Create hierarchy" -command [list $objName Create_hierarchy_for_place $element]}
			 $m add separator
			 dict for {e D} [$element get_D_events] {
				 $m add command -label "Trigger event $e" -command [list $element TriggerEvent $e {} {}]
				}
			 $m add separator
			 set nesting_place	[$element get_nesting_place]
			 if { $element != [$nesting_place get_nested_start_place]
			    &&$element != [$nesting_place get_nested_end_place  ] } { 
				 $m add command -label "Delete place" -command [list $objName Delete_elements [list $element]]
				}
			 $m add separator
			 $m add command -label "add Token" -command [list $element Add_a_token]
			}
		 transition	{
			 $m add command -label "Edit transition"   -command [list $objName Edit_element transition $element]
			 $m add command -label "Delete transition" -command [list $objName Delete_elements [list $element]]
			 $m add separator
			 set D_tmp {}
			 lassign [$element Triggerable D_tmp] triggerable D_res
			 if {$triggerable} {
				 set event 			[$element get_event]
				 set nesting_place	[$element get_nesting_place]
				 $m add command -label "Trigger event $event" -command "[$element get_nesting_place] TriggerEvent $event {} $element"
				}
			}
		 arc		{
		 
			}
		}
		
	tk_popup $m [expr $x + [winfo rootx $this(canvas)]] [expr $y + [winfo rooty $this(canvas)]]
}
# Trace PetriNetView:_:Place Contextual_Release_on

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place compute_edge {oval_id rect_id direction} {
	lassign [$this(canvas) bbox $oval_id] ox1 oy1 ox2 oy2
		set ocx [expr ($ox1+$ox2)/2.0]; set ocy [expr ($oy1+$oy2)/2.0]
		set orx [expr $ocx - $ox1]    ; set ory [expr $ocy - $oy1]
	lassign [$this(canvas) bbox $rect_id] rx1 ry1 rx2 ry2
		set rcx [expr ($rx1+$rx2)/2.0]; set rcy [expr ($ry1+$ry2)/2.0]
	# Compute direction vector v and left perpendicular vecor vp
		set dx [expr $ocx-$rcx]; set dy [expr $ocy-$rcy]
		set vect_size [expr sqrt($dx*$dx+$dy*$dy)]
		set vx [expr $direction*$dx/$vect_size]; set vy [expr $direction*$dy/$vect_size]
		set vpx [expr -$vy]; set vpy [expr $vx]
	# Compute middle point
		set mx [expr 15*$vpx+($ocx+$rcx)/2]; set my [expr 15*$vpy+($ocy+$rcy)/2]
	
	
	lassign [this get_intersections_oval_line      $ocx $ocy $orx $ory $ocx $ocy $rcx $rcy] x1 y1; if {$x1 == ""} {set x1 $ocx; set y1 $ocy}
	# lassign [this get_intersections_rectangle_line $rx1 $ry1 $rx2 $ry2 $ocx $ocy $rcx $rcy] x2 y2; if {$x2 == ""} {set x2 $rcx; set y2 $rcy}
	lassign [this get_intersections_oval_line      $ocx $ocy $orx $ory $ocx $ocy $mx $my  ] x1 y1; if {$x1 == ""} {set x1 $ocx; set y1 $ocy}
	lassign [this get_intersections_rectangle_line $rx1 $ry1 $rx2 $ry2 $mx  $my  $rcx $rcy] x2 y2; if {$x2 == ""} {set x2 $rcx; set y2 $rcy}
	
	# puts "compute_edge $oval_id $rect_id : [join [list $x1 $y1 $x2 $y2] \;]"
	return [list $x1 $y1 $mx $my $x2 $y2]
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place Eq_second_degre {a b c} {
	set rep   [list]
	set delta [expr $b*$b - 4*$a*$c] 
	if {$delta  < 0} {puts stderr "alert : delta = $delta"}
	if {$delta == 0} {lappend rep [expr -$b/(2.0*$a)]}
	if {$delta  > 0} {
		 set d [expr sqrt($delta)]
		 lappend rep [expr (-$b -$d)/(2.0*$a)] [expr (-$b + $d)/(2.0*$a)]
		}

	return $rep
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_intersections_rectangle_line {rx1 ry1 rx2 ry2 x1 y1 x2 y2} {
	# Easy cases where there is no intersection
	if { $x1 < $rx1 && $x2 < $rx1
	   ||$x1 > $rx2 && $x2 > $rx2
	   ||$y1 < $ry1 && $y2 < $ry1
	   ||$y1 > $ry2 && $y2 > $ry2} {return [list]}
	  
	set min_y [expr min($y1, $y2)]; set max_y [expr max($y1, $y2)]; set H [expr $max_y - $min_y]
	set min_x [expr min($x1, $x2)]; set max_x [expr max($x1, $x2)]; set L [expr $max_x - $min_x]
	set L_rep [list];
	
	# Orthogonal intersection?
	if {$x1 == $x2} {
		 if {$min_y < $ry1} {lappend L_rep $x1 $ry1}
		 if {$max_y > $ry2} {lappend L_rep $x1 $ry2}
		}
	if {$y1 == $y2} {
		 if {$min_x < $rx1} {lappend L_rep $rx1 $y1}
		 if {$max_x > $rx2} {lappend L_rep $rx2 $y1}
		}
	# General intersection with left edge?
	if {$min_x <= $rx1 && $L > 0} {
		 set h [expr double($rx1 - $min_x)*$H/$L]
		 if {$x1 == $min_x} {set y $y1} else {set y $y2}
		 if {$y  == $min_y} {set Y [expr $min_y + $h]} else {set Y [expr $max_y - $h]}
		 if {$Y >= $ry1 && $Y <= $ry2} {lappend L_rep $rx1 $Y}
		}
	# General intersection with right edge?
	if {$max_x >= $rx2 && $L > 0} {
		 set h [expr double($max_x - $rx2)*$H/$L]
		 if {$x1 == $max_x} {set y $y1} else {set y $y2}
		 if {$y  == $max_y} {set Y [expr $max_y - $h]} else {set Y [expr $min_y + $h]}
		 if {$Y >= $ry1 && $Y <= $ry2} {lappend L_rep $rx2 $Y}
		}
	# General intersection with bottom edge?
	if {$min_y <= $ry1 && $H > 0} {
		 set l [expr double($ry1 - $min_y)*$L/$H]
		 if {$y1 == $min_y} {set x $x1} else {set x $x2}
		 if {$x  == $min_x} {set X [expr $min_x + $l]} else {set X [expr $max_x - $l]}
		 if {$X >= $rx1 && $X <= $rx2} {lappend L_rep $X $ry1}
		}
	# General intersection with top edge?
	if {$max_y >= $ry2 && $H > 0} {
		 set l [expr double($max_y - $ry2)*$L/$H]
		 if {$y1 == $max_y} {set x $x1} else {set x $x2}
		 if {$x  == $max_x} {set X [expr $max_x - $l]} else {set X [expr $min_x + $l]}
		 if {$X >= $rx1 && $X <= $rx2} {lappend L_rep $X $ry2}
		}

	return $L_rep
}

#___________________________________________________________________________________________________________________________________________
method PetriNetView:_:Place get_intersections_oval_line {cx cy rx ry x1 y1 x2 y2} {
	# Easy cases where there is no intersection
	if { $x1 > $cx+$rx && $x2 > $cx + $rx
	   ||$x1 < $cx-$rx && $x2 < $cx - $rx
	   ||$y1 > $cy+$ry && $y2 > $cy + $ry
	   ||$y1 < $cy-$ry && $y2 < $cy - $ry } {puts stderr "complètement à coté"; return [list]}

	# There may be some intersections ...
	set rep [list]
	set RX  [expr $rx*$rx]
	set RY  [expr $ry*$ry]
	
	# Easy intersections with axe parrallele line
	if {$x1 == $x2} {
		 set alpha [expr double($x1 - $cx)*($x1 - $cx)/$RX];
		 set T_rep [this Eq_second_degre 1 [expr -2*$cy] [expr $cy*$cy + ($alpha - 1)*$RY]]
									
		 foreach r $T_rep {
			 if {$r >= min($y1, $y2) && $r <= max($y1, $y2)} {lappend rep $x1 $r}
			}
		}

	if {$y1 == $y2} {
		 set alpha [expr double($y1 - $cy)*($y1 - $cy)/$RY];
		 set T_rep [this Eq_second_degre 1 [expr -2*$cx] [expr $cx*$cx + ($alpha - 1)*$RX]]
									
		 foreach r $T_rep {
			 if {$r >= min($x1, $x2) && $r <= max($x1, $x2)} {lappend rep $r $y1}
			}
		}
		
	# General case where the line can be expressed as y = ...
	if {$x1!=$x2 && $y1!=$y2} {
		 set X    [expr $x2-$x1]
		 set Y    [expr $y2-$y1]
		 set beta [expr double($x1 - $cx - $y1*$X)/$Y]
		 # Get the y-axis values
		 set T_rep  [this Eq_second_degre [expr $X*$X*$RY/($Y*$Y) + $RX]	\
										  [expr -2*$cy*$RX + 2*$X*$beta*$RY/$Y]	\
										  [expr $beta*$beta*$RY + $cy*$cy*$RX - $RX*$RY]	\
					]
		 foreach r $T_rep {
			 # puts "\tgeneral case $r dans $y1 $y2 ?"
			 if {$r >= min($y1, $y2) && $r <= max($y1, $y2)} {
				 lappend rep [expr ($r - $y1)*$X/$Y + $x1] $r
				}
			}
		}
		
	# return the results as a list of coordinate <x, y, x, y, ...>
	return $rep
}
