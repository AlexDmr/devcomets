inherit CometDesignProcess_LM_LP Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_LM_LP constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 
 this Add_PM_factories [Generate_factories_for_PM_type [list {CometDesignProcess_PM_P_B207_basic Ptf_BIGre} 
                                                       ] $objName]
 # Add_U_fine_tuned_factory_for_encaps $objName Ptf_TK Ptf_TK_CANVAS CometGraphBuilder_PM_P_TK_CANVAS_basic {Container_FUI_bridge_TK_to_CANVAS_frame(,$obj())}

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometDesignProcess_LM_LP [P_L_methodes_set_CometDesignProcess] {} {$this(L_actives_PM)}
Methodes_get_LC CometDesignProcess_LM_LP [P_L_methodes_get_CometDesignProcess] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometGraphBuilder_COMET_RE {} {return [list {set_handle_root {id}} {set_handle_daughters {id}} \
                                                                  {Add_node_type {id name}} {Add_node_instance {id name}} \
																  {Sub_node {id}} {Add_rel {id_m id_d}} {Sub_rel {id_n id_d}} \
																  {set_marks_for {id L_marks}} \
															]}
Generate_LM_setters CometDesignProcess_LM_LP [P_L_methodes_set_CometGraphBuilder_COMET_RE]


