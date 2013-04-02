# if {[file exists [get_B207_files_root]]} {
  # source [get_B207_files_root]B_Spline.tcl
  # source [get_B207_files_root]B_canvas.tcl
# }

#_________________________________________________________________________________________________________
inherit CometDesignProcess_PM_P_B207_basic PM_BIGre

#_________________________________________________________________________________________________________
method CometDesignProcess_PM_P_B207_basic constructor {name descr args} {
	this inherited $name $descr
		this set_GDD_id CometDesignProcess_PM_P_B207_basic

	set this(B207_canvas)    [B_polygone]
		set this(B207_rap_canvas) [B_rappel [Interp_TCL];]
			$this(B207_rap_canvas) Texte "$objName B207_Press_canvas"
		B_configure $this(B207_canvas) 	-Ajouter_contour [ProcRect 0 0 640 480] \
										-Couleur 0.2 0.3 0.5 0.7 \
										-abonner_a_detection_pointeur [$this(B207_rap_canvas) Rappel] [ALX_pointeur_ALL]
		set this(ctc_canvas) ctc_$objName
	set this(B207_graph) 	 [B_noeud]
		set pipo [B_polygone]
		$pipo Ajouter_contour [ProcOvale 0 0 30 30 64]
		$this(B207_graph) Ajouter_fils $pipo
	set this(B207_daughters) [B_noeud]
	set this(B207_root)      [B_noeud]
		B_contact $this(ctc_canvas) [list $pipo 1] -pt_trans 50 50 -pt_rot 50 50
		B_contact marf$objName [list $this(B207_graph) 1] -add [list $this(B207_canvas) 9] -pt_trans 50 50 -pt_rot 50 50
		B_configure $this(B207_root) -Ajouter_fils $this(B207_daughters) \
									 -Ajouter_fils $this(B207_graph) \
									 -Ajouter_fils $this(B207_canvas) \
									 -Position_des_fils_changeable 0
									 

	this set_prim_handle        $this(B207_root)
	this set_root_for_daughters $this(B207_daughters)

	set this(D_nodes) [dict create]

	eval "$objName configure $args"
	return $objName
}

#______________________________________________________ Adding the viewer functions _______________________________________________________
Methodes_set_LC CometDesignProcess_PM_P_B207_basic [L_methodes_set_CometViewer] {}          {}
Methodes_get_LC CometDesignProcess_PM_P_B207_basic [L_methodes_get_CometViewer] {$this(FC)}

#_________________________________________________________________________________________________________
Generate_PM_setters CometDesignProcess_PM_P_B207_basic [P_L_methodes_set_CometGraphBuilder_COMET_RE]

#___________________________________________________________________________________________________________________________________________
#____ What to do when semantic calls _______________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_PM_P_B207_basic set_node {id L_ancestors L_descendants content} {
	# Create a B207 representation of the node
	# Stock the position, links etc. in the D_nodes dictionnary
	set root [this get_a_representation_for_node $id]
	this Create_links_for $id
}


#___________________________________________________________________________________________________________________________________________
#____ B207 Callback & co ___________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_PM_P_B207_basic B207_Press_canvas {} {

}
