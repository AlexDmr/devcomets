CometInterleaving MSN_ROOT "Use instant messenger" "" -Add_style_class "ROOT"

CometInterleaving MSN_CONVERSATIONS "Fenetres de conversation" "" -Add_style_class "CONVERSER" 
foreach contact "ALEX DIMITRI" {

	CometInterleaving CHAT_$contact "Conversation avec $contact" ""	-Add_style_class [list CONVERSER $contact] 
	CometContainer LOG_$contact "Historique de conversation $contact" "" -Add_style_class [list CONVERSER $contact] -Add_MAGELLAN_Designer_constraint [list LIST FIXED_ORDER]
	LOG_$contact Add_daughters_R [list   [CPool get_a_comet CometText -Add_style_class $contact    -set_name "$contact    16:54" -set_text "Hello Gaelle, how are you?\n"] \
																[CPool get_a_comet CometText -Add_style_class GAELLE -set_name "GAELLE 16:55" -set_text "Hi $contact, I'm fine, and you?\n"] \
																[CPool get_a_comet CometText -Add_style_class $contact    -set_name "$contact    16:56" -set_text "What's up?\n"] \
																[CPool get_a_comet CometText -Add_style_class GAELLE -set_name "GAELLE 16:59" -set_text "working on a paper...\n"] \
																[CPool get_a_comet CometText -Add_style_class $contact    -set_name "$contact    17:00" -set_text "Nice!\n"] \
													] 
													
	CHAT_$contact Add_daughters_R [list LOG_$contact [CPool get_a_comet CometContainer -Add_style_class [list MESSAGE GAELLE] -set_name "Send message to $contact" \
																				-Add_daughters_R [list [CPool get_a_comet CometSpecifyer -set_name "Specify text message"  -Add_style_class "MESSAGE"] \
																															 [CPool get_a_comet CometActivator -set_name "Send message"          -Add_style_class "MESSAGE" -set_text "Envoyer"] \
																												 ]\
																			]]
}
MSN_CONVERSATIONS Add_daughters_R [list CHAT_ALEX CHAT_DIMITRI]
	                              
CometContainer    MSN_L_CONTACTS "Contacts list" "" -Add_style_class [list LIST CONTACT] \
                                                          -set_name "Contacts" \
														  -Add_daughters_R [list 	[CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M TUX  FRIEND]  -set_name "Tux"    -set_text "Tux"]    \
																											[CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M ALEX    IHM]  -set_name "Alex"    -set_text "Alex"]     \
																											[CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M DIMITRI IHM]  -set_name "Dimitri" -set_text "Dimitri"] \
																											[CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F NADINE  		]  -set_name "Nadine"  -set_text "Nadine"]  \
																											[CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F AMELIE  		]  -set_name "Amelie"  -set_text "Amélie"]  \
																											[CPool get_a_comet CometInterleaving \
																				    -Add_style_class [list CONTACT GESTION] \
																					-set_name "Contacts Management" \
																					-Add_daughters_R [list [CPool get_a_comet CometActivator -set_name "Add" -set_text "Add"] \
																					                       [CPool get_a_comet CometActivator -set_name "Sub" -set_text "Sub"]
																					                 ] \
																				 ] \
																		   ]
  CometContainer    MSN_PROFIL "Gérer mon profil" "" \
    -Add_style_class [list MANAGE PROFIL] \
	-set_name "Manage profil" \
	-Add_daughters_R [list [CPool get_a_comet CometImage -Add_style_class [list PHOTO GAELLE] -set_name "Photo"        -load_img "gaelle.calvary.jpg"] \
	                       [CPool get_a_comet CometText  -Add_style_class [list NAME GAELLE]  -set_name "Name"         -set_text "Gaelle Calvary"] \
						   [CPool get_a_comet CometText  -Add_style_class STATUT -set_name "Availability" -set_text "Available"] \
	                 ]
  MSN_ROOT Add_daughters_R [list MSN_CONVERSATIONS MSN_L_CONTACTS MSN_PROFIL]
  
  