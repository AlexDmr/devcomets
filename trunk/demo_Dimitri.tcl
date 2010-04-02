if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)} else {puts "Please define an environment variable nammed ROOT_COMETS valuated with the Comets root path."; return}
source minimal_load.tcl
GDD_Edit Load_GDD GDD_Magellan.gdd

Init_HTML

#_____________________________________________________________________________________
Do_rec_source $::env(MAGELLAN)
  set CCE      [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out N"] -set_name "MUTATIONS" -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/mutation_1.core"  -set_L_param [list "nb rand() *5" "pMutation 0.3"]]
  set CCE2     [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out X"] -set_name "CROSSING"  -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/crossing_1.core"  -set_L_param [list "KeepParents 0" "{Nb childrens} N"]]
  set CC_START [CPool get_a_comet CometCompo_evolution -set_L_inputs [list ]       -set_L_outputs [list "out N"] -set_name "START"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Start.core" -set_L_param [list "NB 16" "XHTML_to_process ZenGarden/zen_garden.xhtml"] -set_nb_max_process 1]
  set CC_SCRATCH_START [CPool get_a_comet CometCompo_evolution -set_L_inputs [list ]       -set_L_outputs [list "out N"] -set_name "SCRATCH START"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/ScratchStart.core" -set_L_param [list "NB 16" "XHTML_to_process ZenGarden/zen_garden.xhtml"] -set_nb_max_process 1]
  
  set CC_UNION [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in_1 *" "in_2 *"]       -set_L_outputs [list "out N"] -set_name "UNION"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Union.core"]
  set CC_MERGE [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in_1 *" "in_2 *"]       -set_L_outputs [list "out N"] -set_name "MERGE"     -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Merge.core" -set_L_param [list "NB_1 8" "NB_2 8"]]

  set CC_FILTER [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in *"] \
                                                        -set_L_outputs [list "true *" "false *"] \
														-set_name "FILTER" \
														-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Filtre.core" \
														-set_L_param [list "condition {\$score > 0.5}"]]

  set CC_EVAL  [CPool get_a_comet CometCompo_evolution -set_L_inputs  [list "in N"]  \
                                                       -set_L_outputs [list "out N"] \
													   -set_name "USER EVAL" \
													   -Add_MetaData    MAGELLAN_SPECIAL_VIEW CometCompo_evolution_PM_P_U_basic_user_eval \
													   -Add_style_class MAGELLAN_SPECIAL_VIEW \
													   ];


set CC_SAVE      [CPool get_a_comet CometCompo_evolution -set_L_inputs [list "in N"] -set_L_outputs [list "out N"] -set_name "SAVE" -load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Save.core"]
set CC_ELITE     [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "best N" "worst N"] \
		-set_name "ELITIST SELECTION" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/elite.core"  \
		-set_L_param [list "nb_best 8"]]

set CC_RUSSIAN [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "RUSSIAN ROULETTE" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/RussianRoulette.core"  \
		-set_L_param [list "output_length 16"]]
		
set CC_EXPAND   [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "EXPAND" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/expandAndComplete.core"  \
		-set_L_param [list "output_length 16"]]

set CC_CROSSING [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in1 N" "in2 N"] \
		-set_L_outputs [list "out N"] \
		-set_name "CROSSING" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/crossing_1.core" ]
set CC_ROULETTE [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "STOCHASTIC ROULETTE" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/Roulette.core"  ]

set CC_VISUALISTEUR [CPool get_a_comet CometCompo_evolution \
		-set_L_inputs [list "in N"] \
		-set_L_outputs [list "out N"] \
		-set_name "VISUALISATEUR INDIVIDU" \
		-load_core "[Root_of_CometDimitri]CometCompo_evolution/PMs/FC/Core_css++/individuVisu.core"  ]
		
		
cr Add_daughters_R [CometDimitri C_Dim "Editeur d'�volution" "G�re l'�volution d'IHMs" -set_L_class_compo [list $CC_START $CC_SCRATCH_START $CC_CROSSING $CC_ELITE $CC_EVAL $CC_EXPAND $CC_FILTER $CC_MERGE $CCE $CC_ROULETTE $CC_UNION $CC_RUSSIAN $CC_SAVE $CC_VISUALISTEUR]]

 
 # Chrono CometDimitri Add_L_instance_compo
 # puts "C_Dim Add_L_connexions \[list {{$CCE out} {$CCE2 in2}}\]"
puts "Building a pipo MSN for test purpose !"
source expe_magellan_2.tcl
C_Dim set_comet_root_to_be_transformed MSN_ROOT

puts "loading the evolution network"
C_Dim Load_network_from_file Net_convergent_divergent_2.miga
source [Root_of_CometDimitri]get_marks_and_type.alx
source [Root_of_CometDimitri]running_case_study.dim