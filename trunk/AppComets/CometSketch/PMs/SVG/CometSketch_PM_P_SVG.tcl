#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometSketch_PM_P_SVG PM_SVG

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_SVG constructor {name descr args} {
	this inherited $name $descr
	this set_GDD_id CT_Sketch_AUI_CUI_basic_SVG

	set this(primitives_handle) [B_noeud]

	this set_prim_handle        $this(primitives_handle)
	this set_root_for_daughters $this(primitives_handle)

	# this Add_MetaData PRIM_STYLE_CLASS [list $this(primitives_handle) "PARAM RESULT OUT image IMAGE"]
 
	 eval "$objName configure $args"
	 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometSketch_PM_P_SVG [P_L_methodes_set_Sketch] {} {}
Methodes_get_LC CometSketch_PM_P_SVG [P_L_methodes_get_Sketch] {$this(FC)}

Generate_PM_setters CometSketch_PM_P_SVG [P_L_methodes_set_Sketch_COMET_LP_RE]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_SVG Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
 set img_path   [this get_img_file_name]
 set comet_path [Comet_files_root]
 set length [string length $comet_path]
 if {[string equal -nocase -length $length $comet_path $img_path]} {
   set img_path [string range $img_path $length end]
  }
 
 append strm $dec "<g [this Style_class] ><image id=\"core_$objName\" x=\"0\" y=\"0\" width=\"320px\" height=\"200px\" xlink:href=\"" $img_path "\" />\n"
 this Render_daughters strm "$dec  "
 append strm $dec "</g>"
 
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_SVG Draggable {} {
	this inherited $objName [list core_$objName]
}

#___________________________________________________________________________________________________________________________________________
method CometSketch_PM_P_SVG RotoZoomable {} {
	this inherited $objName [list core_$objName]
}
