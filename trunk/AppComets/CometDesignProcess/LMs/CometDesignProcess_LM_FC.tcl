inherit CometDesignProcess_LM_FC Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_LM_FC constructor {name descr args} {
 this inherited $name $descr
# Adding some physical presentations 


 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometDesignProcess_LM_FC [P_L_methodes_set_CometDesignProcess] {} {$this(L_actives_PM)}
Methodes_get_LC CometDesignProcess_LM_FC [P_L_methodes_get_CometDesignProcess] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometGraphBuilder_COMET_RE_FC {} {return [list]}
Generate_LM_setters CometDesignProcess_LM_FC [P_L_methodes_set_CometGraphBuilder_COMET_RE_FC]


