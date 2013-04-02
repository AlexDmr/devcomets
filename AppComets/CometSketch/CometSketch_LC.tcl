#___________________________________________________________________________________________________________________________________________
inherit CometSketch Logical_consistency

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometSketch constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id CT_Video
# CFC
 set CFC_name "${objName}_CFC"
   CometSketch_CFC $CFC_name
   this set_Common_FC $CFC_name
   
# LMs
 set this(LM_FC) "${objName}_LM_FC";
   LogicalSketch_FC $this(LM_FC) $this(LM_FC) "The functionnal manager of $objName";
   this Add_LM $this(LM_FC)

   set this(LM_LP) "${objName}_LM_LP";
   LogicalSketch_LP $this(LM_LP) $this(LM_LP) "The logical presentation of $objName";
   this Add_LM $this(LM_LP)

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method CometSketch dispose {} {this inherited}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometSketch [P_L_methodes_set_Sketch] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometSketch [P_L_methodes_get_Sketch] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch New_seq {} {
	return [this get_last_added_seq]
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch New_image {} {
	return [this get_last_added_image]
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometSketch New_layer {} {
	return [this get_last_added_layer]
}
