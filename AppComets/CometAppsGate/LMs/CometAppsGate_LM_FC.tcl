inherit CometAppsGate_LM_FC Logical_presentation

#___________________________________________________________________________________________________________________________________________
method CometAppsGate_LM_FC constructor {name descr args} {
 this inherited $name $descr
 
# Adding some physical presentations 
 set this(websocket_FC) ${objName}_ws_PM_FC
	CometAppsGate_PM_FC $this(websocket_FC) "WebSocket PM interface" "Based on the first ws protocol done in AppsGate"
	this Add_PM $this(websocket_FC); this set_PM_active $this(websocket_FC)
	
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometAppsGate_LM_FC [P_L_methodes_set_CometAppsGate] {} {$this(L_actives_PM)}
Methodes_get_LC CometAppsGate_LM_FC [P_L_methodes_get_CometAppsGate] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_CometAppsGate_COMET_RE_FC {} {return [list]}
Generate_LM_setters CometAppsGate_LM_FC [P_L_methodes_set_CometAppsGate_COMET_RE_FC]


