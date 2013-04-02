inherit CometDesignProcess Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess constructor {name descr args} {
 this inherited $name $descr
 this set_GDD_id CT_CometEdition_comet

 set CFC ${objName}_CFC; CometEdition_comet_CFC $CFC; this set_Common_FC $CFC

 set this(LM_FC) ${objName}_LM_FC
 CometDesignProcess_LM_FC $this(LM_FC) $this(LM_FC) "The LM FC of $name"
   this Add_LM $this(LM_FC)
 set this(LM_LP) ${objName}_LM_LP
 CometDesignProcess_LM_LP $this(LM_LP) $this(LM_LP) "The LM LP of $name"
   this Add_LM $this(LM_LP)
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess dispose {} {this inherited}
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometDesignProcess [P_L_methodes_set_CometDesignProcess] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometDesignProcess [P_L_methodes_get_CometDesignProcess] {$this(FC)}

