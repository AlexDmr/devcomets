source minimal_load.tcl

Init_B207

source [get_B207_files_root]test_fisheyes.tcl

CometVideo C_cam cam "" -set_video_source WEBCAM 0
#CometVideo C_cam cam "" -set_video_source {C:/Alexandre/Videos/Mississipi burning (A.Parker, 1988).avi} 0
cr set_daughters_R C_cam

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien constructor {PM_cam} {
 set this(L_Pool_images) [list]
 set this(L_img_temp_svg_for_redo)   [list]
 set this(L_img_temp_svg_for_cancel) [list]
 set this(L_img_svg)                 [list]
 
 set this(PM_cam) $PM_cam
 set this(poly)   [$this(PM_cam) get_prim_handle]; $this(poly) Translucidite 1
 #set this(visu)   [$this(PM_cam) get_visu_cam]
 set this(visu)   [$this(PM_cam) get_visu_cam]; $this(visu) Translucidite 1
 
 $this(visu) Ordre_couleur_texture             [GL_bvra]
 $this(visu) Nb_octets_par_pixels_texture      4
 $this(visu) Mode_traitement_image_transparent 3
 $this(visu) Threaded_mode                     1
 
 this set_ref_color 1 1 1
 this set_param_transparent 0.8 128 128 128
 #this set_param_transparent 0.2 25 25 25
 
 set pere [$this(poly) Pere]; $pere Position_des_fils_changeable 0
 set this(img) [B_image]; if {[$PM_cam get_video_source] != "WEBCAM"} {$this(img) Inverser_y 1}
 $pere Ajouter_fils $this(img)
 
 set this(rap_press_svg_img) [B_rappel [Interp_TCL]];  $this(rap_press_svg_img) Texte "$objName Press_on_svg_image $this(rap_press_svg_img)"
 
 set this(node_root_UI)   [B_noeud]
 set this(node_L_img_svg) [B_noeud]; $this(node_root_UI) Ajouter_fils $this(node_L_img_svg)
 $pere Ajouter_fils $this(node_root_UI)
 
 set this(fisheye) ${objName}_my_fisheye
 FishEye_on_Images $this(fisheye) [list]
 $this(fisheye) set_dims [N_i_mere Largeur] [N_i_mere Hauteur]
 $this(fisheye) set_E_for_daughters 0.3
 set root [$this(fisheye) get_root]; $root Couleur 0 0 0 0.6; $root Translucidite 1
 set pt_tmp [B_point]; set this(pt_tmp) $pt_tmp
 $this(fisheye) set_rap_in_roo_txt "$this(fisheye) set_E_for_daughters 0.3; Change_fish [$this(fisheye) get_rap_in_root] $root $pt_tmp; B207_flow $root; B207_position_fisheye $root 2"
 #"puts {FISHEYE IN !}; $this(fisheye) set_E_for_daughters 0.3; B207_flow $root; B207_position_fisheye $root 4"
 
 $this(node_L_img_svg) Ajouter_fils $root
 $this(img) maj_raw_with_transfo [$this(visu) L] [$this(visu) H] [$this(visu) Ordre_couleur_texture] [$this(visu) Nb_octets_par_pixels_texture] [GL_bvra] 4 NULL

 this Reset
 this Full_screen 1
 
# Init the text zone that will retrieve key pressed
 set this(z_txt) [B_texte 0 0 999999 [fonte_Arial] [B_sim_sds]]
   set this(rap_car) [B_rappel [Interp_TCL] "$objName Char_entered"]
   B_configure $this(z_txt) -Nom_IU $objName -abonner_a_caractere_tape [$this(rap_car) Rappel] -Afficher_boites 0
 
 $PM_cam Redirect_key_events_to_z_txt $this(z_txt)
 Redirect_key_events_from_to $this(img) $this(z_txt)
 puts "--------> Redirect_key_events_from_to $this(img) $this(z_txt)"
 
 return $objName
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Press_on_svg_image {rap} {
 #puts "Press_on_svg_image $rap"
 set infos [$rap Param]
 set infos [Void_vers_info $infos]
 set img   [Real_class [$infos NOEUD]]
 
 this Load $img
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Char_entered {} {
 set c [Void_vers_int [$this(rap_car) Param]]
 set bbox [$this(img) Boite_noeud_et_fils_glob]
 set TX [$bbox Tx]
 puts "\t$c"
 switch $c {
   [SDSK_RIGHT] {B_transfo_rap 500 "$objName set_Px \[expr (1-\$v)*[this get_Px] - \$v * $TY\]"
                }
   [SDSK_LEFT]  {B_transfo_rap 500 "$objName set_Px \[expr (1-\$v)*[this get_Px]\]"
                }
             32 {this Merge
	            }
			 26 {this Cancel
                }
			 25 {this Redo
			    }
			 13 {this Save
			    }
			 27 {this Reset
			    }
  }
 if {$c == [SDSK_LEFT] } {puts "L"; B_transfo_rap 500 "$objName set_Px \[expr (1-\$v)*[this get_Px] - \$v * $TX\]"; puts "OK"} else {
 if {$c == [SDSK_RIGHT]} {puts "R"; B_transfo_rap 500 "$objName set_Px \[expr (1-\$v)*[this get_Px]\]"; puts "OK"} else {
 if {$c == [SDSK_HOME]}  {this prim_go_to_bgn} else {
 if {$c == [SDSK_END]}   {this prim_go_to_end} else {
 if {$c>=48 && $c<=57} {this Chiffre [Void_vers_char [$this(rap_car) Param]]}
   }
  }}}
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien set_Px {v} {
 $this(PM_cam) Px $v
 $this(img) Px $v
 $this(node_root_UI) Px [expr $v + [$this(img) L] * [$this(img) Ex]]
}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien get_Px { } {return [$this(img) Px]}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien get_a_new_image {} {
 if {[llength $this(L_Pool_images)]} {
   set rep [lindex $this(L_Pool_images) 0]
   set this(L_Pool_images) [lrange $this(L_Pool_images) 1 end]
  } else {set rep [B_image]}
  
 return $rep
}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien release_an_image {img} {
 Add_list this(L_Pool_images) $img
 $img Vider_peres
 Sub_list this(L_img_temp_svg_for_cancel) $img
 Sub_list this(L_img_svg)                 $img
 Sub_list this(L_img_temp_svg_for_redo)   $img
}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien pipo {} {$this(PM_cam) Origine 0 0}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Etirement {x y} {
 puts "$objName Etirement $x $y"
 $this(PM_cam) Etirement $x $y;
 $this(img)    Etirement $x $y; 
}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Save_for_cancel {} {
 set this(current_is_new) 1
 set img [this get_a_new_image]
 $img maj_raw [$this(img) L] [$this(img) H] [$this(img) Ordonnancement_couleurs] [$this(img) Nb_octets_par_pixel] [$this(img) Tempon_void]

 lappend this(L_img_temp_svg_for_cancel) $img
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Merge {} {
 this Save_for_cancel
 
 $this(img) Merge_Tempon_void [$this(visu) Tempon_void] [$this(visu) Nb_octets_par_pixel]
 $this(img) maj_tempon
 
 set L $this(L_img_temp_svg_for_redo) ; foreach img $L {this release_an_image $img}
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Reset {} {
 this Save_for_cancel
 
 $this(img) Colorier 255 255 255 255
 $this(img) maj_tempon
 
 $this(img) Vider_peres; $this(node_root_UI) Vider_peres
 set pere [$this(poly) Pere] 
 $pere Ajouter_fils $this(img)
 $pere Ajouter_fils $this(node_root_UI)
 
 $pere Position_des_fils_changeable 0
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien set_ref_color {r g b} {
 set this(ref_R) $r
 set this(ref_G) $g
 set this(ref_B) $b
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien set_param_transparent {seuil min_r min_v min_b} {
 $this(visu) Pixels_transparents_mtd_3_V1 $this(ref_R) $this(ref_G) $this(ref_B) $seuil $min_r $min_v $min_b
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien set_resolution {x y} {
 if {[$this(PM_cam) get_video_source] == "WEBCAM"} {
	 #$this(visu) set_resolution $x $y
	 [$this(PM_cam) get_LC] set_resolution $x $y
	 $this(img) maj_raw [expr int([$this(PM_cam) get_width])] [expr int([$this(PM_cam) get_height])] [GL_bvra] 4 NULL
  } else {$this(img) maj_raw_with_transfo [$this(visu) L] [$this(visu) H] [$this(visu) Ordonnancement_couleurs] [$this(visu) Nb_octets_par_pixel] [GL_bvra] 4 [$this(visu) Tempon_void]
         }
	 
 this Reset
 
# Place the UI
 this Full_screen $this(full_screen)
 $this(node_root_UI) Px [expr [$this(img) Px] + [$this(img) L] * [$this(img) Ex]]
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Full_screen {v} {
 set this(full_screen) $v
 if {$v} {
   set L  [$this(PM_cam) get_width]; set H [$this(PM_cam) get_height]
   set TX [N_i_mere Largeur]; set TY [N_i_mere Hauteur]
   set e [expr double($TX) / $L]
  } else {set e 1}
  
 this Etirement $e $e
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Cancel {} {
 if {[llength $this(L_img_temp_svg_for_cancel)]} {
   if {$this(current_is_new)} {
     set img_new [this get_a_new_image]
	 $img_new maj_raw [$this(img) L] [$this(img) H] [$this(img) Ordonnancement_couleurs] [$this(img) Nb_octets_par_pixel] [$this(img) Tempon_void]
    }
   set img [lindex $this(L_img_temp_svg_for_cancel) end]
   set this(L_img_temp_svg_for_cancel) [lrange $this(L_img_temp_svg_for_cancel) 0 end-1]
   $this(img) maj_raw [$img L] [$img H] [$img Ordonnancement_couleurs] [$img Nb_octets_par_pixel] [$img Tempon_void]

   if {$this(current_is_new)} {
     lappend this(L_img_temp_svg_for_redo) $img_new
	} else {lappend this(L_img_temp_svg_for_redo) $img
	       }
   
   set this(current_is_new) 0
  }
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Redo {} {
 if {[llength $this(L_img_temp_svg_for_redo)]} {
   set img [lindex $this(L_img_temp_svg_for_redo) end]
   set this(L_img_temp_svg_for_redo) [lrange $this(L_img_temp_svg_for_redo) 0 end-1]
   $this(img) maj_raw [$img L] [$img H] [$img Ordonnancement_couleurs] [$img Nb_octets_par_pixel] [$img Tempon_void]
   lappend this(L_img_temp_svg_for_cancel) $img
   set this(current_is_new) 0
  }
}
#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Load {img} {
# Release images for cancel
 set L $this(L_img_temp_svg_for_cancel); foreach i $L {this release_an_image $i}
 set L $this(L_img_temp_svg_for_redo)  ; foreach i $L {this release_an_image $i}

# Load new image 
 $this(img) maj_raw [$img L] [$img H] [GL_bvra] 4 [$img Tempon_void]
 this Save_for_cancel
 B_transfo_rap 500 "$objName set_Px \[expr (1-\$v)*[this get_Px]\]"
 #puts "  Clic on $noeud"
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Save {} {
# Release images for cancel
 set L $this(L_img_temp_svg_for_cancel); foreach img $L {this release_an_image $img}
 set L $this(L_img_temp_svg_for_redo)  ; foreach img $L {this release_an_image $img}
 
# Add a new image to list of good images
 set img [this get_a_new_image]; if {[$this(PM_cam) get_video_source] != "WEBCAM"} {$img Inverser_y 1}
 $img abonner_a_detection_pointeur [$this(rap_press_svg_img) Rappel] [ALX_pointeur_enfonce]
 
 set img_file_name "${objName}_[clock milliseconds].png"
 $img maj_raw [$this(img) L] [$this(img) H] [$this(img) Ordonnancement_couleurs] [$this(img) Nb_octets_par_pixel] [$this(img) Tempon_void]
 
 $img Sauver_dans_fichier $img_file_name
 $img Ajouter_MetaData_T FILE_NAME $img_file_name
 $img Etirement 0.25 0.25
 lappend this(L_img_svg) [list $img $img_file_name]
 
 $this(fisheye) Add_L_images $img
}

#___________________________________________________________________________________________________________________________________________
method Dessin_c_bien Copy {img} {
# Release images for cancel
 set L $this(L_img_temp_svg_for_cancel); foreach img $L {this release_an_image $img}
 set L $this(L_img_temp_svg_for_redo)  ; foreach img $L {this release_an_image $img}
 
# Add a new image to list of good images
 $this(img) maj_raw [$img L] [$img H] [$img Ordonnancement_couleurs] [$img Nb_octets_par_pixel] [$img Tempon_void]
}

#___________________________________________________________________________________________________________________________________________
Generate_accessors Dessin_c_bien [list img poly visu fisheye]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Dessin_c_bien D [CSS++ cr "#cr->PMs.PM_BIGre C_cam"]

after 100 "D Reset"
# after 100 "D set_resolution 640 480\; N_i_mere Volume_musique 0 0"

set p [D get_poly]
set i [D get_img]

#$p Origine 0 780
#N_i_mere Volume_musique 0 0
#set v [D get_visu]
#$p Ajouter_fils $v
#$v Origine 740 0
#$p Etirement 0.5 -0.5
