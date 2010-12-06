cd {C:/These/Projet Interface/COMETS/devCOMETS/Comets/}
  set debug 0
  source source_ordre.tcl_spe
cd ..

if {[catch "package present Speech_API" res]} {
  if {[catch "load Speech_api.dll" res]} {
    puts "ERROR while loading Speech_api.dll:\n$res"
   }
 }
 
CometRoot   cr "Comet root" {NO DESCRIPTION} ._Root1
CometRoot   cr2 "Comet root for inspector" {NO DESCRIPTION} ._Inspector
#  PhysicalHTML_root cr_PM_P_HTML    "HTML root" {NO DESCR}; cr2_LM_LP Add_PM cr_PM_P_HTML;    cr2_LM_LP set_PM_active cr_PM_P_HTML

#___________________________________________________________________
# Définition des DSL
  Style Style_CSSpp -set_comet_root cr; cr set_DSL_CSSpp     Style_CSSpp
  DSL_GDD_QUERY dsl_q                 ; cr set_DSL_GDD_QUERY dsl_q
  DSL_ECA       dsl_ECA               ; cr set_DSL_ECA       dsl_ECA
  [gmlObject info objects DSL_interface_interpretor] set_dsl_gdd dsl_q
  
C_GDD_Editor   GDD_Edit      "GDD editor" {} -Load_types_from_file GDD/GDD_repository/GDD_types_def.txt
GDD_Edit set_GDD_DSL dsl_q

#___________________________________________________________________
#___________________________________________________________________
#___________________________________________________________________
cr set_name "Alex Laptop"
puts "_____ Loadind the semantic network"
  [CSS++ cr {#C_GDD_Editor}] Load_GDD Comets/CSS_STYLESHEETS/GDD/INRIA.gdd
  


#___________________________________________________________________
#___________________________________________________________________
#___________________________________________________________________
source Server_Composition.tcl

set    str ""
append str {<Compose id="SUPERCOMPO" composition="CometInterleaving" redundancy="0" spaces="CC1 has TOTO TITI; CC2 has TITI SUPERSOUSCOMPO" relationships="TOTO.text = TITI.text">}
  append str {<Task comet="CometText" id="TOTO" param="set_text TOTO"/>}
  append str {<Task comet="CometText" id="TITI" param="set_text TITI"/>}
  append str {<Compose id="SUPERSOUSCOMPO" composition="CometSequence" relationships="">}
    append str {<Task comet="CometText"  id="TEXT_IMAGE" param="set_text } "{" {Une belle image} "}" {"/>}
	append str {<Task comet="CometImage" id="IMAGE"      param="load_img terrain.png"/>}
  append str {</Compose>}
append str {</Compose>}

Server_Composition S 8005
  S set_cmd_after_analyse {puts "Composition à l'aide de la COMET $comet_rep"; Compose_PC set_daughters_R $comet_rep; Compose_PDA set_daughters_R $comet_rep}

cr2 set_daughters_R [list [CometContainer Compose_PC Compose_PC "" -Add_style_class PC] [CometContainer Compose_PDA Compose_PDA "" -Add_style_class PDA]]

set f [open Compo_comets.xml r]; set txt_compo [read $f]; close $f
set s [socket 127.0.0.1 8005]
  puts $s "[string length $txt_compo] $txt_compo"
close $s

#set C [S Build_composition $str]
#  CC1 Add_daughter_R $C
#  CC2 Add_daughter_R $C

#cr2 Add_daughter_R [CometInterleaving ci n d]
#  ci Add_daughters_R [list [CometQuestion c_question n d]           \
#                           [CometCall c_call n d]                   \
#						   [CometChoixMedecin c_choix n d]          \
#						   [CometConsultationMedecin c_consult n d] \
#                     ]


after 1000 {
	set C_compose_test [CSS++ cr2 "#cr2 CometComposer"]

	$C_compose_test Apply_default_style
}

#after 1000 {
#set C_seq [CSS++ cr2 "#cr2 CometComposer(>CometSequence)"]
#  $C_seq Subscribe_to_Next     Alex "puts coucouNext; cr2_TK_root Apply_default_style"     UNIQUE
#  $C_seq Subscribe_to_Previous Alex "puts coucouPrevious; cr2_TK_root Apply_default_style" UNIQUE
#  cr2_TK_root Apply_default_style
#}



proc Apply_style {root} {
 set PM_ci          [CSS++ cr "#$root CometInterleaving"]
 set PM_cont_travel [CSS++ cr "#$root CometContainer \\>CometTravel_LC/"]
 set PM_cont_call   [CSS++ cr "#$root CometContainer \\>CometCall/"]
 set PM_cont_text   [CSS++ cr "#$root CometContainer \\>CometText/"]
 set    cmd ""
 append cmd "set prim_cont_travel \[$PM_cont_travel get_prim_handle\]\n"
 append cmd "set prim_cont_call   \[$PM_cont_call   get_prim_handle\]\n"
 append cmd "set prim_cont_text   \[$PM_cont_text   get_prim_handle\]\n"
 append cmd "if {\$prim_cont_travel != \"NULL\" && \$prim_cont_text != \"NULL\" && \$prim_cont_call != \"NULL\"} {\n"
 append cmd "  pack forget \[$PM_cont_travel get_prim_handle\]\n  pack forget \[$PM_cont_call   get_prim_handle\]\n  pack forget \[$PM_cont_text   get_prim_handle\]\n"
 append cmd "pack \$prim_cont_travel -side right -expand 1 -fill y  \n"
 append cmd "pack \$prim_cont_call   -side top   -expand 1 -fill both \n"
 append cmd "pack \$prim_cont_text   -side top   -expand 1 -fill both \n"
 append cmd "}\n"
 if {$PM_ci != ""} {
	 foreach d [$PM_ci get_daughters] {$d set_cmd_placement ""}
	 $PM_ci set_cmd_placement_daughters $cmd
  }
}