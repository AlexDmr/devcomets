inherit CometAppsGate Logical_consistency

#___________________________________________________________________________________________________________________________________________
method CometAppsGate constructor {name descr args} {
 this inherited $name $descr
 this set_GDD_id CT_CometAppsGate

 set CFC ${objName}_CFC; CometAppsGate_CFC $CFC; this set_Common_FC $CFC

 set this(LM_FC) ${objName}_LM_FC
 CometAppsGate_LM_FC $this(LM_FC) $this(LM_FC) "The LM FC of $name"
   this Add_LM $this(LM_FC)
 set this(LM_LP) ${objName}_LM_LP
 CometAppsGate_LM_LP $this(LM_LP) $this(LM_LP) "The LM LP of $name"
   this Add_LM $this(LM_LP)
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method CometAppsGate dispose {} {this inherited}
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometAppsGate [P_L_methodes_set_CometAppsGate] {$this(FC)} {$this(L_LM)}
Methodes_get_LC CometAppsGate [P_L_methodes_get_CometAppsGate] {$this(FC)}

