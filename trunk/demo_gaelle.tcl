set IP "127.0.0.1"
foreach str [split [exec ipconfig] "\n"] {
	 if {[regexp {IPv4.*: (.*)$} $str reco IP]} {break}
	 if {[regexp {IP.*: (.*)$}   $str reco IP]} {}
	}

source c:/These/devComets/minimal_load.tcl

CometRoot cr_table  "Root of the table"       "Where the photos can be rotozoomed..."
	Init_B207 cr_table
CometRoot cr_screen "Root of the wall screen" "Where one photo is displayed"
	Init_HTML cr_screen
	cr_screen_PM_P_HTML set_Update_interval 200
CometRoot cr_phone  "Root of the smartphone"  "Where user can navigate among photos to be displayed on the wall screen"
	Init_HTML cr_phone
	cr_phone_PM_P_HTML set_Update_interval 500

CometInterleaving inter_img "Interleaving of images" ""
	set L_photos [glob ./Photos/*]
	set i 0
	foreach img_name $L_photos {
		 CometImage img_$i "Image $i : $img_name" "" -load_img $img_name
		 inter_img Add_daughters_R img_$i
		 incr i
		}
		 
cr_table Add_daughters_R [list inter_img [CometText txt_ad "adress of the webpage" "" -set_text "http://${IP}/index.php?Comet_port=[cr_phone_PM_P_HTML get_server_port]"]]
	cr_table set_default_css_style_file "demo_gaelle.css++"
	cr_table Apply_default_style

cr_phone Add_daughters_R [CometChoiceN telec "Remote controler" "" -set_b_inf 1 -set_b_sup [llength $L_photos] -Subscribe_to_set_val ALEX {if {$v != (1+[lsearch [inter_img get_daughters] [cr_screen get_daughters]])} {cr_screen set_daughters_R [lindex [inter_img get_daughters] [expr $v-1]]}} U]
	cr_phone set_default_css_style_file "demo_gaelle_phone.css++"
	cr_phone Apply_default_style

# Toolglass for the table
source [get_B207_files_root]B_toolglass.tcl
	B_toolglass toolglass {Plug_image_on_screen [$infos NOEUD]}
	$noeud_partage Ajouter_fils_au_debut [toolglass attribute n_meta]
	
proc Plug_image_on_screen {n_B207} {
	set PM [$n_B207 Val CometPM]
	if {$PM != ""} {
		 set pos [lsearch [inter_img get_daughters] [$PM get_LC]]
		 if {$pos >= 0} {telec set_val [expr 1 + $pos]}
		}
}
