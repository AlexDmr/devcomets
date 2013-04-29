inherit CometAppsGate_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometAppsGate_LM_LP constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this Add_PM_factories [Generate_factories_for_PM_type [list {CometAppsGate_PM_P_TK Ptf_TK} 
                                                       ] $objName]
 # Add_U_fine_tuned_factory_for_encaps $objName Ptf_TK Ptf_TK_CANVAS CometGraphBuilder_PM_P_TK_CANVAS_basic {Container_FUI_bridge_TK_to_CANVAS_frame(,$obj())}

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometAppsGate_LM_LP [P_L_methodes_set_CometAppsGate] {} {$this(L_actives_PM)}
Methodes_get_LC CometAppsGate_LM_LP [P_L_methodes_get_CometAppsGate] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_AppsGate_COMET_RE {} {return [list  \
													]}
Generate_LM_setters CometAppsGate_LM_LP [P_L_methodes_set_AppsGate_COMET_RE]


