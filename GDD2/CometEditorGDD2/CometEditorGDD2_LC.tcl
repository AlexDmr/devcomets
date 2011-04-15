inherit CometEditorGDD2 Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2 constructor {name descr args} {
 this inherited $name $descr
 this set_GDD_id CT_CometEditorGDD2

 set CFC ${objName}_CFC; CometEditorGDD2_CFC $CFC; this set_Common_FC $CFC

 set this(LM_FC) ${objName}_LM_FC
 CometEditorGDD2_LM_FC $this(LM_FC) $this(LM_FC) "The LM FC of $name"
   this Add_LM $this(LM_FC)
 set this(LM_LP) ${objName}_LM_LP
 CometEditorGDD2_LM_LP $this(LM_LP) $this(LM_LP) "The LM LP of $name"
   this Add_LM $this(LM_LP)
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2 dispose {} {this inherited}
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2 [P_L_methodes_set_CometEditorGDD2] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometEditorGDD2 [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

