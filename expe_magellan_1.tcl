CometInterleaving MSN_ROOT "Use instant messenger\n|||" "" -Add_style_class "ROOT"
  CometInterleaving MSN_CONVERSER "Chat Gaelle-Bob" "" -Add_style_class "CONVERSER"
    MSN_CONVERSER Add_daughters_R [list [CPool get_a_comet CometText -Add_style_class BOB    -set_name "BOB-1   " -set_text "Hello Gaelle, how are you?"] \
	                                    [CPool get_a_comet CometText -Add_style_class GAELLE -set_name "GAELLE-1" -set_text "Hi Bob, I'm fine, and you?"] \
										[CPool get_a_comet CometText -Add_style_class BOB    -set_name "BOB-2   " -set_text "What's up?"] \
	                                    [CPool get_a_comet CometText -Add_style_class GAELLE -set_name "GAELLE-2" -set_text "working on a paper..."] \
										[CPool get_a_comet CometText -Add_style_class BOB    -set_name "BOB-3   " -set_text "Nice!"] \
										[CPool get_a_comet CometContainer -Add_style_class [list MESSAGE GAELLE] \
										                                  -set_name "Send message" \
																		  -Add_daughters_R [list [CPool get_a_comet CometSpecifyer -set_name "Specify\ntext message" -Add_style_class "SPECIFY SPECIFYER MESSAGE"] \
																		                         [CPool get_a_comet CometActivator -set_name "Send\nmessage"          -Add_style_class "ACTIVATOR SEND MESSAGE" -set_text "Envoyer"] \
																		                   ] \
										] \
										
	                              ]
  CometContainer    MSN_L_CONTACTS "Liste de contacts" "" -Add_style_class [list LIST CONTACT] \
                                                          -set_name "Manage\nContacts" \
														  -Add_daughters_R [list [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M MOMO]    -set_name "Momo"    -set_text "Momo"]    \
														                         [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M BOB]     -set_name "Bob"     -set_text "Bob"]     \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M DIMITRI] -set_name "Dimitri" -set_text "Dimitri"] \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F NADINE]  -set_name "Nadine"  -set_text "Nadine"]  \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F AMELIE]  -set_name "Amelie"  -set_text "Amélie"]  \
																				 [CPool get_a_comet CometInterleaving \
																				    -Add_style_class [list CONTACT GESTION] \
																					-set_name "Add or Sub\nContacts" \
																					-Add_daughters_R [list [CPool get_a_comet CometActivator -set_name "Add" -set_text "Add"] \
																					                       [CPool get_a_comet CometActivator -set_name "Sub" -set_text "Sub"]
																					                 ] \
																				 ] \
																		   ]
  CometContainer    MSN_PROFIL "Gérer mon profil" "" \
    -Add_style_class [list MANAGE PROFIL] \
	-set_name "Manage profil" \
	-Add_daughters_R [list [CPool get_a_comet CometImage -Add_style_class PHOTO  -set_name "Photo"        -load_img "gaelle.calvary.jpg"] \
	                       [CPool get_a_comet CometText  -Add_style_class NAME   -set_name "Name"         -set_text "Gaelle Calvary"] \
						   [CPool get_a_comet CometText  -Add_style_class STATUT -set_name "Availability" -set_text "Available"] \
	                 ]
  MSN_ROOT Add_daughters_R [list MSN_CONVERSER MSN_L_CONTACTS MSN_PROFIL]
  
  