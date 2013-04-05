#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometSketch_PM_P_B207 PM_BIGre

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 constructor {name descr args} {
	this inherited $name $descr
	this set_GDD_id CT_Sketch_AUI_CUI_basic_B207

	set this(primitives_handle) [B_noeud]

	this set_prim_handle        $this(primitives_handle)
	this set_root_for_daughters $this(primitives_handle)

	# this Add_MetaData PRIM_STYLE_CLASS [list $this(primitives_handle) "PARAM RESULT OUT image IMAGE"]
 
	# Data related to B207 presentations
	set this(id)      0
	set this(arrow_L) 600
	set this(arrow_H) 200
	
	# Links to B207 structures
	set this(D_seq)   [dict create]
	set this(D_image) [dict create]
	
	# Finish construction
	eval "$objName configure $args"
	return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometSketch_PM_P_B207 [P_L_methodes_set_Sketch] {} {}
Methodes_get_LC CometSketch_PM_P_B207 [P_L_methodes_get_Sketch] {$this(FC)}

Generate_PM_setters CometSketch_PM_P_B207 [P_L_methodes_set_Sketch_COMET_LP_RE]

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 get_a_new_id {prefix} {
	incr this(id)
	return ${prefix}_$this(id)
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 New_seq {previous_seq_id {seq {}}} {
	set seq_id [this get_last_added_seq]
	set root   [this get_a_new_B207_seq $seq_id]
	
	$this(primitives_handle) Ajouter_fils $root
}

#___________________________________________________________________________________________________________________________________________
# Images ___________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 New_image {} {
	# seq_id time
	set image_id [this get_last_added_image]
	set root   	 [this get_a_new_B207_image $seq_id $image_id]
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 Delete_image {} {
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 Move_image {} {
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 Make_a_full_copy_of_image {} {
}

#___________________________________________________________________________________________________________________________________________
# Layers ___________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 New_layer {} {
	set layer_id [this get_last_added_layer]
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 Delete_layer {} {
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch_PM_P_B207 Move_layer {} {
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#__________________________________________________________ B207 structures ________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 get_a_new_B207_seq {seq_id} {
	set L_nodes [list]
	
	# Construct a B207 structures
	set root [B_noeud]; lappend L_nodes $root
		set poly_bg [B_polygone]; lappend L_nodes $poly_bg
		$root Ajouter_fils $poly_bg
		# Draw an arrow, representing the time and/or sequence of images
		set L $this(arrow_L); set H $this(arrow_H)
		$poly_bg Ajouter_contour [ProcTabDouble [list 0 0 $L 0 $L [expr -$H*0.2] [expr $L + $H/2] [expr $H/2] $L [expr $H*1.2] $L $H 0 $H]]
		$poly_bg Couleur 0.2 0.5 0.8 1
		
	set ctc [this get_a_new_id ctc_seq_$objName]
	B_contact $ctc [list $root 0] -add [list $poly_bg 1]
	dict set this(D_seq) $seq_id [dict create root $root poly_bg $poly_bg L_nodes $L_nodes ctc $ctc duration 10]
	
	puts "Sequence $seq_id :\n\tpoly_bg : $poly_bg"
	# $poly_bg abonner_a_detection_pointeur [ALX_pointeur_enfonce]
	
	return $root
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 get_a_new_B207_image {seq_id image_id} {
	set L_nodes  [list]
	set time     [this get_item_of_D_seq [list $seq_id D_images $image_id]]
	set duration [dict get $this(D_seq) $seq_id duration]
	
	# Construct a B207 structure
	set root [B_noeud]; lappend L_nodes $root
		set poly_bg [B_polygone]; lappend L_nodes $poly_bg
		$root Ajouter_fils $poly_bg
		$poly_bg Ajouter_contour [ProcRect 0 0 100 100]
		$poly_bg Origine [expr $this(arrow_L) * double($time)/$duration] 0
		
	set ctc [this get_a_new_id ctc_seq_$objName]
	B_contact $ctc [list $root 0] -add [list $poly_bg 1]
	dict set this(D_image) $image_id [dict create root $root L_nodes $L_nodes ctc $ctc]
	
	# Get info from the B207 presentations elements of seq_id
	set seq_bg [dict get $this(D_seq) $seq_id poly_bg]
	$seq_bg Ajouter_fils $root


	return $root
}

#___________________________________________________________________________________________________________________________________________
#_________________________________________________ Image in seq edition, layers etc. _______________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_B207 get_a_new_B207_image_editor {seq_id} {
	# Enable users to
	#   - Add/Edit/... images in the sequence
	#   - Add/Edit/... layers in the image
	# Left menu with edition of layers, markers,
	# Top menu with edition of images in the sequence seq_id... display also the relationships of layers amon images ?	
	set L_nodes  [list]
	set L [N_i_mere Largeur]; set H [N_i_mere Hauteur]
	set L_left 200; set H_left $H
	set L_top  [expr $L - $L_left]; set H_top $L_left
	
	# Construct a B207 structure
	set root [B_noeud]; lappend L_nodes $root
		set poly_bg_left [B_polygone]; lappend L_nodes $poly_bg_left
		$root Ajouter_fils $poly_bg_left
		B_configure $poly_bg_left -Ajouter_contour [ProcRect 0 0 $L_left $H_left] \
								  -Couleur 0.4 0.55 0.4 1
		set poly_bg_top [B_polygone]; lappend L_nodes $poly_bg_top
		$root Ajouter_fils $poly_bg_top
		B_configure $poly_bg_top  -Ajouter_contour [ProcRect 0 0 $L_top $H_top] \
								  -Couleur 0.2 0.5 0.8 1
		set poly_central [B_polygone]; lappend L_nodes $poly_central
		$root Ajouter_fils $poly_central
		B_configure $poly_central -Ajouter_contour [ProcRect $L_left 0 [expr $H - $H_left]] \
								  -Couleur 1 1 1 1
	
	# B207 structure for layer management
	
}






