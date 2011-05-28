inherit CometEditorGDD2_LM_FC Logical_model

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_LM_FC constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this set_PM_active [CPool get_a_comet CometEditorGDD2_PM_FC_basic]

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2_LM_FC [P_L_methodes_set_CometEditorGDD2] {} {$this(L_actives_PM)}
Methodes_get_LC CometEditorGDD2_LM_FC [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometEditorGDD2_COMET_RE_FC {} {return [concat [P_L_methodes_set_CometEditorGDD2] [list]]}
Generate_LM_setters CometEditorGDD2_LM_FC [P_L_methodes_set_CometEditorGDD2_COMET_RE_FC]

#___________________________________________________________________________________________________________________________________________


