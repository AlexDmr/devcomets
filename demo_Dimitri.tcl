if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl

Init_HTML

#_____________________________________________________________________________________
Do_rec_source $::env(MAGELLAN)
  set CCE      [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out N"] -set_name "MUTATIONS" -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/mutation_1.core"  -set_L_param [list "pSelector 0.01" "pCoefficient 0.01" "pAttribut 0.01"]]
  set CCE2     [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out X"] -set_name "CROSSING"  -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/crossing_1.core"  -set_L_param [list "KeepParents 0" "{Nb childrens} N"]]
  set CC_START [CPool get_a_comet CometCompo_evolution -set_L_inputs [list ]       -set_L_outputs [list "out N"] -set_name "START"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Start.core" -set_L_param [list "NB 16" "XHTML_to_process ZenGarden/zen_garden.xhtml"] -set_nb_max_process 1]
  set CC_SCRATCH_START [CPool get_a_comet CometCompo_evolution -set_L_inputs [list ]       -set_L_outputs [list "out N"] -set_name "SCRATCH START"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/ScratchStart.core" -set_L_param [list "NB 16" "XHTML_to_process ZenGarden/zen_garden.xhtml"] -set_nb_max_process 1]
  
  set CC_UNION [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in_1 *" "in_2 *"]       -set_L_outputs [list "out N"] -set_name "UNION"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Union.core"]
  set CC_MERGE [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in_1 *" "in_2 *"]       -set_L_outputs [list "out N"] -set_name "MERGE"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Merge.core" -set_L_param [list "NB_1 8" "NB_2 8"]]

  set CC_FILTER [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in *"] \
                                                        -set_L_outputs [list "true *" "false *"] \
														-set_name "FILTER" \
														-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Filtre.core" \
														-set_L_param [list "condition {\$score > 0.5}"]]

  set CC_EVAL  [CPool get_a_comet CometCompo_evolution -set_L_inputs  [list "in N"]  \
                                                       -set_L_outputs [list "out N"] \
													   -set_name "USER EVAL" \
													   -Add_MetaData    HTML_SPECIAL_VIEW CometCompo_evolution_visu_html_2 \
													   -Add_style_class HTML_SPECIAL_VIEW \
													   ];


set CC_SAVE      [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out N"] -set_name "SAVE" -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Save.core"]
set CC_RUSSIAN [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "RUSSIAN ROULETTE" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/RussianRoulette.core"  \
		-set_L_param [list "output_length 16"]]
set CC_CROSSING [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in1 N" "in2 N"] \
		-set_L_outputs [list "out N"] \
		-set_name "CROSSING" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/crossing_1.core" ]
set CC_ROULETTE [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "STOCHASTIC ROULETTE" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Cores/Roulette.core"  ]

cr Add_daughters_R [CometDimitri C_Dim "Editeur d'�volution" "G�re l'�volution d'IHMs" -set_L_class_compo [list $CC_START $CC_SCRATCH_START $CC_CROSSING $CCE $CC_EVAL $CC_FILTER $CC_MERGE $CC_ROULETTE $CC_UNION $CC_RUSSIAN $CC_SAVE]]

 
 # Chrono CometDimitri Add_L_instance_compo
 # puts "C_Dim Add_L_connexions \[list {{$CCE out} {$CCE2 in2}}\]"