#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
if {[info exists ::env(ROOT_COMETS)]} {cd $::env(ROOT_COMETS)/Comets/} else {cd {C:/These/Projet Interface/COMETS/devCOMETS/Comets/}}
  set debug 0
  source source_ordre.tcl_spe
cd ..

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
CometRoot   cr "Comet root" {NO DESCRIPTION} ._COMETS

#___________________________________________________________________________________________________________________________________________
#_____________________________________________________________________________________
# Définition des DSL
  #Style Style_CSSpp -set_comet_root cr; cr set_DSL_CSSpp     Style_CSSpp
  Parser_CSS++  Style_CSSpp cr        ; cr set_DSL_CSSpp     Style_CSSpp
  DSL_GDD_QUERY dsl_q                 ; cr set_DSL_GDD_QUERY dsl_q
  DSL_ECA       dsl_ECA               ; cr set_DSL_ECA       dsl_ECA
  [gmlObject info objects DSL_interface_interpretor] set_dsl_gdd dsl_q
 
#_____________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
if {![gmlObject info exists object GDD_Edit]} {
	C_GDD_Editor   GDD_Edit      "GDD editor" {} -Load_types_from_file  $::env(GDD)/GDD_repository/GDD_types_def.txt
 }
GDD_Edit Load_GDD Comets/CSS_STYLESHEETS/GDD/INRIA.gdd

#___________________________________________________________________________________________________________________________________________
proc Init_B207 {} {
  global editeur_tcl; global noeud_partage; global ::env
  if {[info exists editeur_tcl]} {
    puts ICI
      if {[info exists ::env(B207_LIBRARY)]} {
	     set P [pwd]
		   cd $::env(B207_LIBRARY)
		   if {[info proc etire_fond] != "etire_fond"} {
		     source groupe.tcl
             proc etire_fond args {}
			} else {puts GO}
		 cd $P
		 global noeud_partage; global noeud_editeur_tcl; global f_obs
		 Root_PM_P_BIGre cr_PM_P_BIGre "COMET.BIGre root" "BIGre root node for comet root cr_PM_P_BIGre" -set_root $noeud_partage
         cr_LM_LP set_PM_active cr_PM_P_BIGre
         [N_i_mere Noeud_scene] Retirer_fils $f_obs
         $noeud_partage Retirer_fils $noeud_editeur_tcl
		 N_i_mere Afficher_souris
	 	
		 if {![gmlObject info exists object Liant_mutable]} {
		   source $::env(B207_LIBRARY)/test_mutable.tcl
		   Liant_Mutable_sim_ptr Liant_mutable; Liant_mutable startListening 8910
		  }

	    } else {puts "Please define an environment variable nammed B207_LIBRARY valuated with the B207 root path."}
	}
}

#___________________________________________________________________________________________________________________________________________
proc Init_HTML {} {
 PhysicalHTML_root cr_PM_P_HTML    "HTML root" {NO DESCR}; cr_LM_LP Add_PM cr_PM_P_HTML;    cr_LM_LP set_PM_active cr_PM_P_HTML
}

#___________________________________________________________________________________________________________________________________________
proc Init_S207 {} {
 root_PM_P_ALX_TXT cr_PM_P_ALX_TXT "S207 root" {NO DESCR}; cr_LM_LP Add_PM cr_PM_P_ALX_TXT; cr_LM_LP set_PM_active cr_PM_P_ALX_TXT
 if {[catch "package present Speech_API" res]} {
   if {[catch "load Speech_api.dll" res]} {
     puts "ERROR while loading Speech_api.dll:\n$res"
    }
  } 
}