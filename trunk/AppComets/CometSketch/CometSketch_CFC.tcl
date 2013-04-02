#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometSketch_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
# D_image contains a list of layers reference ______________________________________________________________________________________________
# D_seq   contains a list of images terminated by a choice _________________________________________________________________________________
# images and seq have markers that can be used for annotation or alternative purpose _______________________________________________________
#____ markers are to be used for select/unselect calques, images and sequences and show them to users ______________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC constructor {} {
	set this(D_layer) [dict create]; set this(last_added_layer) ""
	set this(D_image) [dict create]; set this(last_added_image) ""
	set this(D_seq)   [dict create]; set this(last_added_seq)   ""

	set this(id)			0
}

#___________________________________________________________________________________________________________________________________________
Generate_dict_accessors CometSketch_CFC [list D_layer          D_image          D_seq]
Generate_accessors      CometSketch_CFC [list last_added_layer last_added_image last_added_seq]

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC get_a_new_id {prefix} {
	incr this(id)
	return ${prefix}_$this(id)
}

#___________________________________________________________________________________________________________________________________________
# Semantic API ?
#___________________________________________________________________________________________________________________________________________

#___________________________________________________________________________________________________________________________________________
# Sequences ________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC New_seq {previous_seq_id {seq {}}} {
	 # If previous_seq_id == "" then create a brand new seq
	 # else branch it to the previous_seq_id
	 set seq_id [this get_a_new_id Seq]
	 if {$seq == ""} {set seq [dict create D_images [list] L_choices [list] L_markers [list]]}
	 dict set this(D_seq) $seq_id $seq
	 if {[dict exists $this(D_seq) $previous_seq_id]} {
		 dict set this(D_seq) $previous_seq_id L_choices [concat [dict get $this(D_seq) $previous_seq_id L_choices] [list $id]]
		}
	
	set this(last_added_seq) $seq_id
	return $seq_id
}

#___________________________________________________________________________________________________________________________________________
# Images ___________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC New_image {seq_id time {image {}}} {
	if {[dict exists $this(D_seq) $seq_id]} {
		 if {$image == ""} {
			 set image    [dict create L_layers [list] L_markers [list]]
			 set image_id [this get_a_new_id Img]
			} else 	{
					 # Is it an image id or an image value?
					 if {[dict exists $this(D_image) $image]} {
						 set image_id $image
						 set image    [dict get $this(D_image) $image]
						} else {set image_id [this get_a_new_id Lay]}
					}
		 
		 dict set this(D_image) $image_id $image
		 dict set this(D_seq)   $seq_id D_images $image_id $time
		}
	set this(last_added_image) $image_id
	return $image_id
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC Delete_image {seq_id image_id} {
	# If previous_layer == "" then insert layer at the begginning of the image
	if {  [dict exists $this(D_seq)   $seq_id] 
	   && [dict exists $this(D_image) $image_id] } {
		dict unset this(D_seq) $seq_id D_images $image_id
	   }
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC Move_image {image_id seq_source_id seq_target_id target_time} {
	# previous_image_id in the context of image_target
	if {  [dict exists $this(D_seq) $seq_source_id] 
	   && [dict exists $this(D_seq) $seq_target_id]
	   && [dict exists $this(D_image) $image_id] } {
		 # Insert layer in   seq_target_id
		 this New_image    $seq_target_id $target_time $image_id
		 # Delete layer from image_source
		 this Delete_image $seq_source_id $image_id
		}
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC Make_a_full_copy_of_image {seq_id ref_image_id} {
	# previous_image_id in the context of image_target
	if {[dict exists $this(D_image) $image_id] } {
		 set image_id [this New_image $seq_id ""]
		 # Make a copy of all layers
		 set layer_id ""
		 foreach ref_layer_id [dict get $this(D_image) $ref_image_id Layers] {
			 set layer_id [this New_layer $image_id $layer_id [dict get $this(D_layer) $ref_layer_id]]
			}
		}
}

#___________________________________________________________________________________________________________________________________________
# Layers ___________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC New_layer {image_id previous_layer_id {layer {}}} {
	# If previous_layer_id == "" then insert layer at the begginning of the image
	# If layer == "" then create a new one
	#   else if layer is an id of a pre-existing layer then add a new reference
	#          else layer is the value of a layer, let's copy it to the new layer
	if {[dict exists $this(D_image) $image_id]} {
		 set L_layers [dict get $this(D_image) $image_id L_layers]
		 set pos_layer [lsearch $L_layers $previous_layer_id]
		 if {layer == ""} {
			 set layer [dict create URL "" color_mask [list 1 1 1 1] L_markers [list]]
			 set layer_id [this get_a_new_id Lay]
			} else 	{
					 # Is layer an id or a layer value?
					 if {[dict exists $this(D_layer) $layer]} {
						 set layer_id $layer
						 set layer    [dict get $this(D_layer) $layer]
						} else {set layer_id [this get_a_new_id Lay]}
					}
		 dict set this(D_layer) $layer_id $layer
		 dict set this(D_image) $image_id L_layers [linsert $L_layers [expr $pos_layer - 1] $layer_id]
		}
	
	set this(last_added_layer) $layer_id
	return $layer_id
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC Delete_layer {image_id layer_id} {
	# If layer_id == "" then insert layer at the begginning of the image
	if {  [dict exists $this(D_image) $image_id] 
	   && [dict exists $this(D_layer) $layer_id] } {
	    set L_layers [dict get $this(D_image) $image_id L_layers]
		set pos_layer [lsearch $L_layers $layer_id]
		dict set this(D_image) $image_id L_layers [lreplace $L_layers $pos_layer $pos_layer]
	   }
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_CFC Move_layer {layer_id image_id_source image_id_target previous_layer_id} {
	# previous_layer_id in the context of image_id_target
	if {  [dict exists $this(D_image) $image_id_source] 
	   && [dict exists $this(D_image) $image_id_target]
	   && [dict exists $this(D_layer) $layer_id] } {
		 # Insert layer in   image_id_target
		 this New_layer    $image_id_target $previous_layer_id $layer_id
		 # Delete layer from image_id_source
		 this Delete_layer $image_id_source $layer_id
		}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_Sketch {} {return [list {get_D_image {}} \
											  {get_item_of_D_image {keys}} \
											  {has_item_D_image {keys}} \
											  {get_D_seq {}} \
											  {get_item_of_D_seq {keys}} \
											  {has_item_D_seq {keys}} \
											  {get_last_added_layer {}} \
											  {get_last_added_image {}} \
											  {get_last_added_seq {}} \
											 ]}
proc P_L_methodes_set_Sketch {} {return [list {set_D_image {v}} \
											  {set_item_of_D_image {keys val}} \
											  {remove_item_of_D_image {keys val}} \
											  {set_D_seq {v}} \
											  {set_item_of_D_seq {keys val}} \
											  {remove_item_of_D_seq {keys val}} \
											  {Move_layer {layer_id image_id_source image_id_target previous_layer_id}} \
											  {Delete_layer {image_id layer_id}} \
											  {New_layer {image_id previous_layer_id {layer {}}}} \
											  {Make_a_full_copy_of_image {seq_id ref_image_id}} \
											  {Move_image {image_id seq_source_id seq_target_id previous_image_id}} \
											  {Delete_image {seq_id image_id}} \
											  {New_image {seq_id previous_image_id {image {}}}} \
											  {New_seq {previous_seq_id {seq {}}}} \
											 ]}
