inherit CometAppsGate_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method CometAppsGate_CFC constructor {} {
	set this(D_services) [dict create]
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors CometAppsGate_CFC [list ]
Generate_dict_accessors CometAppsGate_CFC [list D_services]
#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_CometAppsGate {} {return [list {get_D_services {}} {get_item_of_D_services {keys}} {has_item_D_services {keys}} {length_of_D_services {}} \
												]}
proc P_L_methodes_set_CometAppsGate {} {return [list {set_D_services {D}} {set_item_of_D_services {keys val}} {remove_item_of_D_services {keys}} \
												]}

