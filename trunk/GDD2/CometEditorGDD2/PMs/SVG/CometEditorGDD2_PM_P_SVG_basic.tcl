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
 
 package require http
 package require tdom

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
method CometEditorGDD2_PM_P_SVG_basic GDD_doc_to_SVG {n_document str_svg_name str_js_name id X_name Y_name} {
 upvar $str_svg_name str_svg; upvar $str_js_name str_js
 upvar $X_name X
 upvar $Y_name Y
 
 switch [$n_document getAttribute "type"] {
	 image   {set width  [$n_document getAttribute "width" ]
			  set height [$n_document getAttribute "height"]
			  set href   [$n_document getAttribute "href"]
			  set id     "${id}_#_[$n_document getAttribute id]"
			  append str_svg "<g id=\"$id\" annotations_CB=\"\" transform=\"translate($X , $Y)\"><image width=\"$width\" height=\"$height\" xlink:href=\"$href\" />"
			  append str_svg "<ellipse id=\"${id}_centroid_ellipse\" class=\"centroid\" cx=\"[expr $width / 2]\" cy=\"[expr $height / 2]\" rx=\"[expr $width / 4]\" ry=\"[expr $height / 4]\" style =\"fill:none; stroke:none; stroke-width:1\" />"
			  append str_svg "</g>\n"
			  set X [expr $X + $width + 10]
			 }
        html {set width  [$n_document getAttribute "width" ]; set height [$n_document getAttribute "height"]; set href   [$n_document getAttribute "href"]
		      set id     "${id}_#_[$n_document getAttribute id]"
			  append str_svg "<g id=\"$id\" annotations_CB=\"\" transform=\"translate($X , $Y)\">"
			  append str_svg "<ellipse id=\"${id}_centroid_ellipse\" class=\"centroid\" cx=\"[expr $width / 2]\" cy=\"[expr $height / 2]\" rx=\"[expr $width / 2]\" ry=\"[expr $height / 2]\" style =\"fill:none; stroke:none; stroke-width:1\" />"
			  append str_svg "<rect x=\"-30\" y=\"-30\" width=\"[expr 60+$width]\" height=\"[expr 60+$height]\" style=\"fill:rgb(99,99,99); stroke:rgb(0,0,0);\"/>\n"
			  append str_svg "<foreignObject id=\"${id}_foreign_html\" width=\"$width\" height=\"$height\">\n"
			  append str_svg "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
			  append str_svg "    <iframe src=\"$href\" style=\"width:${width}px;height:${height}px\"></iframe>\n"
			  # append str_svg "  <h1>Titre 1</h1><p>coucou c'est un bien joli paragraphe que vous avez là madame...</p>\n"
			  append str_svg "  </body>\n"
			  append str_svg "</foreignObject>\n"
			  append str_svg "</g>\n"
			  
			  append str_js "Add_events_blocking_bubbling('${id}_foreign_html');\n"
			  set X [expr $X + $width + 10]
			 }
	 default {
			 }
	}
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic GDD_image_zone_to_SVG {id id_ellipse_doc str} {
	set str_svg ""; set str_js ""
	foreach {type params} $str {
		switch $type {
			 ellipse {append str_svg "<ellipse id=\"$id\" class=\"annotation\" "
					  foreach {p v} $params {append str_svg "$p = \"$v\" "}
					  append str_svg "/>"
					  set svg_canvas_id [[this get_HTML_to_SVG_bridge] get_svg_canvas_id]
					  append str_js "Load_SVG('${objName}_links', false, true, " [this Encode_param_for_JS "<line id=\"${id}_line\" x1=\"0\" y1=\"0\" x2=\"200\" y2=\"100\" style=\"stroke:rgb(99,99,99);stroke-width:4\" />"] ", true);\n"
					  append str_js "Tab_anim_${objName}\['${id}'\] = function() {var svg_line = document.getElementById('${id}_line');"
					  append str_js "var T = Line_joining_ellipses ('${svg_canvas_id}', '${objName}', '${id}', '${id_ellipse_doc}');"
					  append str_js "svg_line.x1.baseVal.value = T\[0\];"
					  append str_js "svg_line.y1.baseVal.value = T\[1\];"
					  append str_js "svg_line.x2.baseVal.value = T\[2\];"
					  append str_js "svg_line.y2.baseVal.value = T\[3\];"
					  append str_js "};\nTab_anim_${objName}\['${id}'\]();\n"
					 }
			}
		}
	return [list $str_svg $str_js]
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Load_GDD_node {GDD_node_url} {
	set str_js ""
	set    str_svg  {<?xml version="1.0" encoding="UTF-8"?>}
	append str_svg "\n<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
	
	# Get from http
	set token   [::http::geturl $GDD_node_url]
	set str_xml [::http::data $token]
	::http::cleanup $token
	
	# Parse GDD node and produce SVG description
	 if {[catch {set doc [dom parse $str_xml]} err]} {
		send_msg_to_comet  "ERROR parsing xml in $objName Load_GDD_node {$GDD_node_url}"
		return
	   }
	  
	 set root [$doc documentElement]
	 set ns   [$root namespaceURI]
	 
	 set X 0
	 set Y 0
	 foreach n_document [$root selectNodes "/node/document"] {
		 this GDD_doc_to_SVG $n_document str_svg str_js $GDD_node_url X Y
		 set id_doc ${GDD_node_url}_#_[$n_document getAttribute id]
		 append str_js "Draggable('$id_doc', \['$id_doc'\], null, function(n, e) {update_annotations_related_to('${id_doc}');}, null);\n"
		 append str_js "Register_node_id_SVG_zoom_onwheel('$id_doc');\n"
		 append str_js "Register_CB_onwheel_with_id('$id_doc', function(e) {update_annotations_related_to('${id_doc}');});\n"
		}

	 foreach n_annotation [$root selectNodes "/node/annotation"] {
	     set str ""; set str_js_tmp ""; set X 0; set Y 0
		 # Get the document of the annotation
		 set n_doc [$n_annotation selectNodes "./document"];
		 set annotation_id [$n_doc getAttribute id]
		 this GDD_doc_to_SVG $n_doc str str_js_tmp $GDD_node_url X Y
		 
		 # For each binding, place the annotation
		 set annotation_added 0; set L_id_segments [list]; set L_animated_id [list ${GDD_node_url}_#_${annotation_id}]; 
		 foreach n_bind [$n_annotation selectNodes "./binding"] {
			 set n__related_doc    [$n_bind selectNodes "./document"]
			 set related_id        [$n__related_doc getAttribute ref]
			 Add_list L_animated_id "${GDD_node_url}_#_$related_id"
			 
			 set n__related_anchor [$n_bind selectNodes "./anchor"]
			 if {[$n__related_anchor getAttribute "type"] == "image_mapping" && !$annotation_added} {
				 set annotation_added 1
				 append str_js "Load_SVG('" ${GDD_node_url}_#_$related_id "', false, true, " [this Encode_param_for_JS $str] ", true);\n"
				 append str_js "document.getElementById('" ${GDD_node_url}_#_$annotation_id "').setAttribute('transform', '"
					foreach {att val} [$n__related_anchor asText] {append str_js $att "(" $val ") "}
				 append str_js "');\n"
				} else { if {[$n__related_anchor getAttribute "type"] == "image_zone"} {
							 # Create a SVG description of the zone, plug it into the related image
							 set id_e [CPool get_a_unique_name]; lappend L_id_segments $id_e
							 lassign [this GDD_image_zone_to_SVG $id_e "${GDD_node_url}_#_${annotation_id}_centroid_ellipse" [$n__related_anchor asText]] annotation_svg annotation_js
							 append str_js "Load_SVG('" ${GDD_node_url}_#_$related_id "', false, true, " [this Encode_param_for_JS $annotation_svg] ", true);\n$annotation_js"
							}
					   }
			}
			
		 if {!$annotation_added} {append str_svg $str}
		 append str_js $str_js_tmp
		 
		 if {[llength $L_id_segments] > 0} {
			 # Add to each node the index of the animation to maintain
			 append str_js "T_tmp = \['" [join $L_animated_id "','"] "'\];\n"
			 append str_js "for(var i in T_tmp) {\n"
			 append str_js "\tvar tmp_node = document.getElementById(T_tmp\[i\]); var tmp_str =  tmp_node.getAttribute('annotations_CB');\n"
			 append str_js "\tif(tmp_str == '') {tmp_node.setAttribute('annotations_CB', '$L_id_segments');} else {tmp_node.setAttribute('annotations_CB', tmp_str + ' $L_id_segments');}\n"
			 append str_js "}\n"
			}
		 set id_doc ${GDD_node_url}_#_$annotation_id
		 append str_js "Draggable('$id_doc', \['$id_doc'\], null, function(n, e) {update_annotations_related_to('${GDD_node_url}_#_${annotation_id}');}, null);\n"
		}

	$doc delete
	append str_svg "</svg>\n"
	
	set    msg "Load_SVG('${objName}_docs', true, false, \""
	append msg [string map [list "\"" {\"} "\n" {\n}] $str_svg] "\", true);\n; Load_SVG('${objName}_links', true, false, '', true);\n$str_js"
	this send_jquery_message Display__$GDD_node_url $msg
	
	return "$str_svg\n_____\n$str_js"
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
  append strm $dec "<g id=\"${objName}\" transform=\"\">\n"
  append strm $dec "<rect id=\"${objName}_BG_rect\" x=\"-100000\" y=\"-100000\" width=\"200000\" height=\"200000\" transform=\"\" style=\"fill:rgb(0,0,255);stroke-width:1;\"/>\n"
  append strm $dec "<g id=\"${objName}_docs\"  transform=\"\"></g>\n"
  append strm $dec "<g id=\"${objName}_links\" transform=\"\"></g>\n"
  append strm $dec "</g>\n"
  
  append strm $dec "<script>Tab_anim_$objName = new Array();\n"
  append strm $dec "function update_annotations_related_to (id) {\n"
  append strm $dec "var node = document.getElementById(id);\nvar T_CB = node.getAttribute('annotations_CB').split(' ');\nfor(i in T_CB) {if(T_CB\[i\] != '') {Tab_anim_$objName\[T_CB\[i\]\]();}}}</script>\n"

  this Render_daughters strm "$dec  "
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render_post_JS {strm_name {dec ""}} {
 upvar $strm_name strm
 this inherited strm
 if {$this(mode) == "edition"} {
   # append strm "test_dd('${objName}', '${objName}_drag', '${objName}_drop_circle', '${objName}_pipo_circle', '${objName}_pipo_line');\n"
  }
 append strm "Draggable('$objName', \['${objName}_BG_rect'\], null, null, null);\n"
 append strm "Register_node_id_SVG_zoom_onwheel('$objName');\n"
 
 this Render_daughters_post_JS strm $dec
}
