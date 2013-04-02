#___________________________________________ Définition of Logical Model of présentation ___________________________________________________
inherit LogicalSketch_LP Logical_presentation

method LogicalSketch_LP constructor {name descr args} {
 this inherited $name $descr

 this Add_PM_factories [Generate_factories_for_PM_type [list {CometSketch_PM_P_B207     Ptf_BIGre} \
															 {CometSketch_PM_P_SVG      Ptf_SVG} \
                                                       ] $objName]

 eval "$objName configure $args"
 return $objName
}


#___________________________________________________________________________________________________________________________________________
Methodes_set_LC LogicalSketch_LP [P_L_methodes_set_Sketch] {} {$this(L_actives_PM)}
Methodes_get_LC LogicalSketch_LP [P_L_methodes_get_Sketch] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_Sketch_COMET_LP_RE {} {return [concat [P_L_methodes_set_Sketch] \
															[list ] \
											        ]}
Generate_LM_setters LogicalSketch_LP [P_L_methodes_set_Sketch_COMET_LP_RE]

