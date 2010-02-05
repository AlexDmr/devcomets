if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

Init_B207
Init_HTML

CometSWL swl "StarWar Light" "A great game..."
cr Add_daughters_R swl

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc SWL_mode_is {swl m} {
 #puts "SWL_mode_is $swl $m"
 if {[gmlObject info exists object $m]} {set m [$m get_name]}
 set cont_game [CSS++ $swl "#$swl\(CometContainer \\>>!CometContainer/>> \CONT.GAME/\)"]
 set cont_edit [CSS++ $swl "#$swl\(CometContainer \\>>!CometContainer/>> CONT.EDITION/\)"]
 if {$m == "Edition"} {
   $cont_game Hide_Elements *
   $cont_edit Hide_Elements
  } else {$cont_game Hide_Elements
          $cont_edit Hide_Elements *
         }
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc SWL_Is_a {L_marks n} {
 #puts "SWL_Is_a {$L_marks} $n"
 if {$n == ""} {return}
 set PM [$n Val_MetaData CometPM]
 #puts "  PM = $PM"
 if {$PM != ""} {set rep [$PM Has_for_styles $L_marks]} else {set rep 0}
 return $rep
}

#___________________________________________________________________________________________________________________________________________
proc SWL_Destroy_dropped_element {PM_act_to_trigger param_name n_zone infos} {
 #puts "SWL_Destroy_dropped_element $n_zone $infos"
 set ptr       [$infos Ptr]
 set n_dragged [$ptr Val_MetaData Dragging] 
 set PM [$n_dragged Val_MetaData CometPM]
 $PM_act_to_trigger Add_Params "$param_name [$PM get_LC]"
 $PM_act_to_trigger Trigger_prim_activate
 #puts "  DONE"
}

#___________________________________________________________________________________________________________________________________________
proc SWL_Drop_planet {n_zone infos} {
 #puts "SWL_Drop_planet"
 set n_drop [$infos NOEUD]
 set ptr    [$infos Ptr]
 set n_drag [$ptr Val_MetaData Noeud_placement_drag]
 
 puts "Add_element_to_zone\n     n_zone : $n_zone\n     infos : $infos\n       ptr : [$infos Ptr]\n     NOEUD : [$infos NOEUD]"
 puts "     n_drop : $n_drop"
 set x [$infos X_au_contact]; set y [$infos Y_au_contact]
 
 set n_dragged [$ptr Val_MetaData Dragging] 
 set PM [$n_dragged Val_MetaData CometPM]
   $PM Trigger_prim_activate
   
 set planet [$PM Val_Param planet]
 set ray    [$PM Val_Param ray]
 $planet    set_R $ray
 
 set original_node [$n_drag Val_MetaData Original_node_position]
 set x_ctc [$n_drag Val_MetaData X_au_contact]; set y_ctc [$n_drag Val_MetaData Y_au_contact]
 

 set container_PM [$n_drop Val CometPM]
 set prim_PM      [$container_PM get_prim_handle]

	# Modify contact point
	 set pt_ctc [B_point $x_ctc $y_ctc]

	 $pt_ctc Etirer  [expr 1/[$prim_PM Ex]] [expr 1/[$prim_PM Ey]]
	 $pt_ctc Pivoter [expr -[$prim_PM Rotation]]
	 
	 $planet set_X [expr $x  - [$pt_ctc X]]
	 $planet set_Y [expr $y  - [$pt_ctc Y]]
	 $planet set_R [expr [$planet get_R] / [$prim_PM Ex]]

	 Detruire $pt_ctc
 
 #puts "set container_PM \[$n_drop Val CometPM\] = $container_PM"
 set L_PM [CSS++ cr "#${planet}->PMs.PM_BIGre \\<--< $container_PM/"]
 set L_nodes ""
 #puts "L_PM = {$L_PM}"
 foreach PM $L_PM {lappend L_nodes [$PM get_prim_handle]}
 #puts "----- L_nodes : {$L_nodes}"
 # Pb : [lindex $L_PM 0] n'est pas forcément ce que l'on cherche !
 Drag_nodes $L_nodes "\[Is_a_poly_translation_of \[\$infos NOEUD\] {$L_PM}\]" "puts \[\$infos NOEUD\]" "puts STOP"
 set L_cmd [list Drag_nodes $L_nodes "\[Real_class \[\$infos NOEUD\]\] == \[[lindex $L_PM 0] get_poly_translation\]" "puts \[\$infos NOEUD\]" "puts STOP"]
 puts $L_cmd
 #puts "  \[Real_class \[\$infos NOEUD\]\]"
# puts "----- L_nodes : {$L_nodes}"
}

#___________________________________________________________________________________________________________________________________________
proc Is_a_poly_translation_of {n L_PM} {
 puts "Is_a_poly_translation_of $n {$L_PM}"
 set n [Real_class $n]
 foreach PM $L_PM {
   if {$n == [$PM get_poly_translation]} {return 1}
  }
 return 0
}


#___________________________________________________________________________________________________________________________________________
proc SWL_Drop_ship {n_zone infos} {
 set ptr [$infos Ptr]
# puts "Add_element_to_zone\n     n_zone : $n_zone\n     infos : $infos\n       ptr : [$infos Ptr]\n     NOEUD : [$infos NOEUD]"
 set x [$infos X_au_contact]; set y [$infos Y_au_contact]
 
 set n_dragged [$ptr Val_MetaData Dragging] 
 set PM [$n_dragged Val_MetaData CometPM]
# puts "Do $PM Trigger_prim_activate ..."
   $PM Trigger_prim_activate
# puts "...done"
 set ship [$PM Val_Param ship]
# puts "ship : $ship at $x $y"
 $ship set_X [expr $x ]
 $ship set_Y [expr $y ]

 set L_PM [CSS++ cr "#${ship}->PMs.PM_BIGre \\<--< CONT.EDITION/"]
 set L_nodes ""
 foreach PM $L_PM {lappend L_nodes [$PM get_prim_handle]}

 Drag_nodes $L_nodes "1" "puts \[\$infos NOEUD\]" "puts STOP"
}


