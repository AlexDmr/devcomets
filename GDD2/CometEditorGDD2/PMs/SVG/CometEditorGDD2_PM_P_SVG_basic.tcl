#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#_______________________________________________ Définition of the presentations __________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit CometEditorGDD2_PM_P_SVG_basic PM_SVG

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic constructor {name descr args} {
 this inherited $name $descr
   this set_GDD_id FUI_CometSWL_Planet_PM_P_SVG_basic
 
 this Add_MetaData PRIM_STYLE_CLASS [list $objName "PLANET PARAM RESULT IN OUT"]
 
 set this(svg_x) ""
 set this(svg_y) ""
 set this(mode) "edition"
 
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_set_CometEditorGDD2] {} {}
Methodes_get_LC CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_set_CometEditorGDD2_COMET_RE_P]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
  append strm $dec "<g id=\"${objName}\" transform=\"\">\n"
  append strm $dec "  <rect id=\"${objName}_drag\" width=\"300\" height=\"100\" style=\"fill:rgb(0,255,255);stroke-width:1; stroke:rgb(0,0,0)\"/>"
  append strm $dec "  <circle cx=\"100\" cy=\"50\" r=\"40\" stroke=\"black\" stroke-width=\"2\" fill=\"red\"/>"
  append strm $dec "</g>\n"

  append strm $dec "<g id=\"${objName}_drop\" transform=\"translate(300, 300)\">\n"
  append strm $dec "  <rect id=\"${objName}_drop_rect\" width=\"300\" height=\"300\" style=\"fill:rgb(255,0,255);stroke-width:1; stroke:rgb(0,0,0)\"/>"
  append strm $dec "  <circle id=\"${objName}_drop_circle\" cx=\"150\" cy=\"150\" r=\"150\" stroke=\"black\" stroke-width=\"2\" fill=\"green\"/>"
  append strm $dec "</g>\n"

  append strm $dec "  <circle id=\"${objName}_pipo_circle\" cx=\"600\" cy=\"150\" r=\"150\" stroke=\"black\" stroke-width=\"2\" fill=\"blue\"/>"
  append strm $dec "  <line   id=\"${objName}_pipo_line\" x1=\"100\" y1=\"50\" x2=\"600\" y2=\"150\" style=\"stroke:rgb(99,99,99);stroke-width:2\"/>"
  append strm $dec "  <line   id=\"debug_line\" x1=\"0\" y1=\"0\" x2=\"20\" y2=\"20\" style=\"stroke:rgb(0,0,0);stroke-width:2\"/>"

  this Render_daughters strm "$dec  "
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render_post_JS {strm_name {dec ""}} {
 upvar $strm_name strm
 this inherited strm
 if {$this(mode) == "edition"} {
   append strm "test_dd('${objName}', '${objName}_drag', '${objName}_drop_circle', '${objName}_pipo_circle', '${objName}_pipo_line');\n"
  }
 this Render_daughters_post_JS strm $dec
}
