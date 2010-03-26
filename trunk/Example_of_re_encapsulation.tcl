CometContainer cont n d
set pos 0; set L_marks [list EVEN ODD]
foreach e [list 0 1 2 3 4 5] {CometText TXT_$e $e "" -set_text $e -Add_style_class [lindex $L_marks $pos]; set pos [expr 1 - $pos]; cont Add_daughters_R TXT_$e}

 cr Add_daughters_R cont
 
set PM_cont [CSS++ cr "#cr->PMs.PM_TK cont"]; puts "Original cont PM was $PM_cont"
U_encapsulator_PM $PM_cont {$obj(, "EVEN", CometContainer(-Add_style_class TOTO), "ODD", CometContainer(-Add_style_class TITI), "REST", CometContainer(-Add_style_class REST))} [list "TOTO EVEN" "TITI ODD" "REST *"]
set PM_cont [CSS++ cr "#cr->PMs.PM_TK cont"]; puts "After re-encapsulation, PM is $PM_cont"


puts "TRY : $PM_cont set_L_display_order \[list TXT_3 TXT_4\]"


proc Delete_all {} {
 foreach e [list 0 1 2 3 4 5] {TXT_$e dispose}
 cont dispose
}
