CometInterleaving MSN_ROOT "Utiliser messagerie\n|||" "" -Add_style_class "ROOT"
  CometInterleaving MSN_CONVERSER "Converser" "" -Add_style_class "CONVERSER"
    MSN_CONVERSER Add_daughters_R [list [CPool get_a_comet CometText -Add_style_class BOB -set_text "Salut Bob, comment ça va?"] \
	                                    [CPool get_a_comet CometText -Add_style_class GAELLE -set_text "Salut Gaelle, la forme et toi?"] \
										[CPool get_a_comet CometText -Add_style_class BOB -set_text "Quoi de neuf Bob?"] \
	                                    [CPool get_a_comet CometText -Add_style_class GAELLE -set_text "Je bosse sur la créativité..."] \
										[CPool get_a_comet CometText -Add_style_class BOB -set_text "C'est bien Bob, continue comme ça"] \
										[CPool get_a_comet CometContainer -Add_style_class [list MESSAGE] \
										                                  -Add_daughters_R [list [CPool get_a_comet CometSpecifyer -Add_style_class "SPECIFY SPECIFYER MESSAGE"] \
																		                         [CPool get_a_comet CometActivator -Add_style_class "ACTIVATOR SEND MESSAGE" -set_text "Envoyer"] \
																		                   ] \
										] \
										
	                              ]
  CometContainer    MSN_L_CONTACTS "Liste de contacts" "" -Add_style_class [list LIST CONTACT] \
                                                          -Add_daughters_R [list [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M MOMO]    -set_text "Momo"] \
														                         [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M ROCO]    -set_text "Roco"] \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT M DIMITRI] -set_text "Dimitri"] \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F NADINE]  -set_text "Nadine"] \
																				 [CPool get_a_comet CometText -Add_style_class [list NAME CONTACT F AMELIE]  -set_text "Amélie"] \
																				 [CPool get_a_comet CometInterleaving \
																				    -Add_style_class [list CONTACT GESTION] \
																					-Add_daughters_R [list [CPool get_a_comet CometActivator -set_text "Add"] \
																					                       [CPool get_a_comet CometActivator -set_text "Sub"]
																					                 ] \
																				 ] \
																		   ]
  CometContainer    MSN_PROFIL "Gérer mon profil" "" \
    -Add_style_class [list MANAGE PROFIL] \
	-Add_daughters_R [list [CPool get_a_comet CometImage -Add_style_class PHOTO  -load_img "gaelle.calvary.jpg"] \
	                       [CPool get_a_comet CometText  -Add_style_class NAME   -set_text "Gaelle Calvary"] \
						   [CPool get_a_comet CometText  -Add_style_class STATUT -set_text "Disponible"] \
	                 ]
  MSN_ROOT Add_daughters_R [list MSN_CONVERSER MSN_L_CONTACTS MSN_PROFIL]
  
  