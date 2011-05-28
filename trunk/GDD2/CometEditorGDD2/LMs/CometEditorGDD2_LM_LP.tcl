inherit CometEditorGDD2_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_LM_LP constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this Add_PM_factories [Generate_factories_for_PM_type [list {CometEditorGDD2_PM_P_SVG_basic Ptf_SVG}  \
                                                       ] $objName]
 Add_U_fine_tuned_factory_for_encaps $objName Ptf_HTML Ptf_SVG CometEditorGDD2_PM_P_SVG_basic {Container_CUI_bridge_HTML_to_SVG_frame(,$obj())}
 
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2_LM_LP [P_L_methodes_set_CometEditorGDD2] {} {$this(L_actives_PM)}
Methodes_get_LC CometEditorGDD2_LM_LP [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometEditorGDD2_COMET_RE_P {} {return [concat [P_L_methodes_set_CometEditorGDD2] [list]]}
Generate_LM_setters CometEditorGDD2_LM_LP [P_L_methodes_set_CometEditorGDD2_COMET_RE_P]

#___________________________________________________________________________________________________________________________________________


