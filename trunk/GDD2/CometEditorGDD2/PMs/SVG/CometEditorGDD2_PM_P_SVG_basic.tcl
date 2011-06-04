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
 
 this Add_MetaData PRIM_STYLE_CLASS [list $objName "ROOT GDD SVG"]
 
 set this(svg_x) ""
 set this(svg_y) ""
 set this(mode) "edition"
 
 package require http
 package require tdom
 package require uuid
 
 set this(C_UPNP) [CPool get_singleton CometUPNP]
 # Subscribe to the apparition/disparition of a service converting dot graphs into SVG files
 $this(C_UPNP) Subscribe_to_set_item_of_dict_devices    $objName [list $objName New_UPNP_device_appears \$keys \$val]
 $this(C_UPNP) Subscribe_to_remove_item_of_dict_devices $objName [list $objName New_UPNP_device_disappears \$UDN]

 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_set_CometEditorGDD2] {} {}
Methodes_get_LC CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometEditorGDD2_PM_P_SVG_basic [P_L_methodes_set_CometEditorGDD2_COMET_RE_P]

#___________________________________________________________________________________________________________________________________________
#________________________________________________________________ UPNP services ____________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic New_UPNP_device_appears {keys val} {

}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic New_UPNP_device_disappears {UDN} {

}

#___________________________________________________________________________________________________________________________________________
#______________________________________________________________ Graph dot and SVG __________________________________________________________
#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic Query_GDD {} {
	# Params : str
	
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic set_Query_GDD_result {} {
	# Params : str res
		set this(URL_graph) $str
		set doc  $res
		set root [$doc documentElement]
		
		set str_dot ""
		this Render_[$root nodeName]_to_dot $str $doc $root str_dot
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic get_UID {URL root id} {
	# If the id identify one node of the document then it is local to this document, elsewhere it has to be a UID pointing to another one
	if {[llength [$root selectNodes "//*\[@id='${id}'\]"]]} {
		 return ${URL}?id=$id
		} else {return $id}
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render_kasanayan:Graph_to_dot {URL doc root str_dot_name} {
	upvar $str_dot_name str_dot
	
	# Define some array to store node and edges presentations depending on their attributes
	set Color [dict create CT lightgray AUI lightpink CUI yellow FUI yellowgreen]
	set Shape [dict create Sketch invtriangle Prototype oval Code box]
	
	# We get the GDD description here, it can be translated in terms of a dot description in order to generate a SVG file
	   set str_dot "digraph {\n"
	   # Write information relative to the graph itself (authors, name, accessRead accessWrite, ...?)
	   
	   
	   # Write nodes and edges
	   foreach node [$root child all] {
			 switch [$node nodeName] {
				 kasanayan:Edge       {set id_src    [this get_UID $URL $root [$node getAttribute src]]
									   set id_dst    [this get_UID $URL $root [$node getAttribute dst]]
									   set relations [join [$node getAttribute kasanayan:Relation] "\\n"]
									   append str_dot "\t\"$id_src\" -> \"$id_dst\" \[label=\"R:\\n$relations\"\];\n"
									  }
				 kasanayan:Node       {set id [this get_UID $URL $root [$node getAttribute id]]
									   append str_dot "\t\"$id\" \[style=filled, shape=[dict get $Shape [$node getAttribute precision]], fillcolor=[dict get $Color [$node getAttribute abstraction]], label=\"[$node getAttribute name]\"\];\n"
									  }
				 kasanayan:Annotation {
									  }
				 kasanayan:Graph      {
									  }
				}
			}
	   
	append str_dot "}\n"
	
	this get_SVG_from_dot dot str_dot [list $objName Update_SVG $URL]
}
#Trace CometEditorGDD2_PM_P_SVG_basic set_Query_GDD_result

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic get_SVG_from_dot {type str_dot_name CB} {
	upvar $str_dot_name str_dot
	set pg "C:/Program Files/Graphviz2.26/bin/$type"
	set f_name [CPool get_a_unique_name].dot; set f [open $f_name w]; puts $f $str_dot; close $f;
	set str_svg [exec $pg -Tsvg $f_name]
	
	eval [concat $CB [list $str_svg]]
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Update_SVG {URL_graph str_svg} {
	set str_svg [string range $str_svg [string first "<svg " $str_svg] end]
	
	set doc  [dom parse $str_svg]
	set root [$doc documentElement]
	set L_nodes [$root selectNodes "//*\[@id\]"]
	foreach node $L_nodes {$node setAttribute id "${URL_graph}?id=[$node getAttribute id]"}
	
	set str_svg [$doc asXML]
	$doc delete
	
	set    str_load "Load_SVG('${objName}_docs', true, false, \""
	append str_load [string map [list "\"" {\"} "\n" {\n}] $str_svg] "\", true)\[0\]"
	
	set C_html_to_SVG [CSS++ $objName "#$objName <--< Container_PM_P_HTML_to_SVG"]
	set    msg "Clear_descendants_of(document.getElementById('${objName}_links')); Process_SVG_dot_to_add_interaction('${URL_graph}', '${C_html_to_SVG}', '${objName}', $str_load );\n"
	#Load_SVG(id_root, clear_descendants, add_svg_tag, SVG_descr, is_string)
	this send_jquery_message Update_SVG $msg
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic unset_Query_GDD_result {} {
	# Params : str
	
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic exist_Query_GDD_result {} {
	# Params : str
	
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic Add_graph_elements {} {
	# Params : URL_graph L_elements
	this set_Query_GDD_result $URL_graph [this get_Query_GDD_result $URL_graph]
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_P_SVG_basic Sub_graph_elements {} {
	# Params : URL_graph L_elements
	this set_Query_GDD_result $URL_graph [this get_Query_GDD_result $URL_graph]
}


#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_Sub_graph_elements {e} {
	set length [string length $this(URL_graph)?id=]
	if {[string equal -length $length "$this(URL_graph)?id=" $e]} {set e [string range $e $length end]}
	this prim_Sub_graph_elements $this(URL_graph) [list $e]
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_Sub_graph_edge {GDD_edge} {
	regexp {^(.*)\?id=(.*)->(.*)\?id=(.*)$} $GDD_edge reco URL_graph_1 id_1 URL_graph_2 id_2

	set doc  [this get_Query_GDD_result $URL_graph_1]
	set root [$doc documentElement]
	set kasanayan [$root namespaceURI]

	foreach e [$root selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Edge\[@src='${id_1}' and @dst='${id_2}'\]"] {
		 set id [$e getAttribute id]
		 this prim_Sub_graph_elements $URL_graph_1 $id
		 if {$URL_graph_1 != $URL_graph_2} {this prim_Sub_graph_elements $URL_graph_2 $id}
		}
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_Add_a_new_node {URL_graph} {
	this prim_Add_graph_elements $URL_graph [list [list kasanayan:Node [list precision Sketch name "A new concept and tasks sketch" abstraction "CT" id [uuid::uuid generate] edges ""]]]
	return 
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_Edit_node {GDD_id} {
	if {![regexp {^(.*)\?id=(.*)$} $GDD_id reco URL_graph id]} {error "Unknown GDD identifier $GDD_id"}
	
	# Generate a dialog window to add a new node, parameters will depend on the XML schema
	set doc       [this get_Query_GDD_result $URL_graph]
	set root      [$doc documentElement]
	set kasanayan [$root namespaceURI]
	
	set node      [$root selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id='${id}'\]"]
	
	set xs_doc  [this get_dom_XML_schema]
	set xs_root [$xs_doc documentElement]
	
	set L_JS_update [list]
	set xs_node [$xs_root selectNodes "//xs:element\[@name = 'Node'\]"]; 
	   set str "<div title=\"Node edition\" id=\"dialog_Edit_node\">"
	append str "<div id=\"dialog_Edit_node_Tabs\">"
		append str "<ul><li><a href=\"#${objName}_tab_1\">Attributes</a></li><li><a href=\"#${objName}_tab_2\">SVG</a></li></ul>"
		append str "<div id=\"${objName}_tab_1\">"
		foreach n [$xs_node selectNodes "./xs:complexType/*"] {
			 this Generate_dialog_for_[$n nodeName] $node $n str L_JS_update
			}
		append str "<div><input type=\"button\" value=\"OK\" onclick=\"ALX_send_node_update('${objName}', '${URL_graph}', '${id}', new Array([join $L_JS_update {, }]) );\"/></div>"
		append str "</div>"
		append str "<div id=\"${objName}_tab_2\">"
		append str "<input type=\"button\" value=\"Toggle node display\" onclick=\"\"/>"
		append str "</div>"
		
	append str "</div>"	
	append str "</div>"
	
	   set msg {$('#dialog_Edit_node').remove(); $('body').append(}
	append msg [this Encode_param_for_JS $str]
	append msg "); \$('#dialog_Edit_node').dialog(); \$('#dialog_Edit_node_Tabs').tabs();"
	
	# If a href is given, open a node viewer
	set name_frame_node "Frame_$GDD_id"
	append msg "\$('${name_frame_node}').remove();"
	
	# Create node
	if {[$node hasAttribute href]} {set href [$node getAttribute href]} else {set href ""}
	if {$href != ""} {
		 lassign [this Load_GDD_node $href "" 0] str_svg str_js
		 set str_svg [this Encode_param_for_JS "<g id=\"$name_frame_node\">${str_svg}</g>"]
		 append msg "Load_SVG('${objName}_docs', false, true, " $str_svg ", true);"
		 append msg $str_js
		}


	this send_jquery_message HTML_Edit_node $msg
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Generate_dialog_for_xs:documentation {edited_node node str_name L_JS_update_name} {
	upvar $str_name str; upvar $L_JS_update_name L_JS_update
	
	append str "<p>" [string trim [$node text]] "</p>"
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Generate_dialog_for_xs:attribute {edited_node node str_name L_JS_update_name} {
	upvar $str_name str; upvar $L_JS_update_name L_JS_update
		
	set name [$node getAttribute name]
	if {[$edited_node hasAttribute $name]} {
		 set val [$edited_node getAttribute $name]
		} else {set val ""}

	set id   "CometEditorGDD2_PM_P_SVG_basic__$name"
	append str "<div><label for=\"$id\">$name </label><input type=\"text\" name=\"$id\" id=\"$id\" value=\"${val}\"/></div>"
	
	lappend L_JS_update "'${name}'" "function() {return document.getElementById('${id}').value;}"
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Generate_dialog_for_xs:attributeGroup {edited_node node str_name L_JS_update_name} {
	upvar $str_name str; upvar $L_JS_update_name L_JS_update
	set xs_doc  [this get_dom_XML_schema]
	set xs_root [$xs_doc documentElement]

	set name [lindex [split [$node getAttribute ref] ":"] end]
	set gp [$xs_root selectNodes -namespace [list xs "http://www.w3.org/2001/XMLSchema"] "//xs:attributeGroup\[@name='${name}'\]"]
	append str "<hr/><div><div class=\"title\">${name}</div>"
	foreach n [$gp childNodes] {
		 this Generate_dialog_for_[$n nodeName] $edited_node $n str L_JS_update
		}
	append str "</div><hr/>"

}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_Edit_edge {GDD_id__rel_type} {
	lassign $GDD_id__rel_type GDD_id rel_type
	
	regexp {^(.*)\?id=(.*)->(.*)\?id=(.*)$} $GDD_id reco URL_graph_1 id_1 URL_graph_2 id_2
	
	# set length [string length $this(URL_graph)?id=]
	# if {[string equal -length $length "$this(URL_graph)?id=" $GDD_id]} {set GDD_id [string range $GDD_id $length end]}
	
	set doc  [this get_Query_GDD_result $URL_graph_1]
	set root [$doc documentElement]
	set kasanayan [$root namespaceURI]
	
	foreach n [$root selectNodes -namespaces [list kasanayan $kasanayan] "//*\[@src='${id_1}' and @dst='${id_2}'\]"] {
		 set L_rel [$n getAttribute kasanayan:Relation]
		 
		 set L_all_rels [list {Sharpens Blurs} {Specializes Generalizes} {Abstracts Concretizes}]
		 if {[lsearch $L_rel $rel_type] >= 0} {
			 Sub_list L_rel $rel_type
			} else  {foreach couple $L_all_rels {
						 set pos [lsearch $couple $rel_type]
						 if {$pos >= 0} {
							 Sub_list L_rel [lindex $couple [expr 1 - $pos]]
							 break
							}
						}
					 if {$rel_type == "ComposedOf"} {set L_rel $rel_type} else {Sub_list L_rel "ComposedOf"; Add_list L_rel $rel_type}
					}
		 
		 $n setAttributeNS $kasanayan kasanayan:Relation $L_rel
		}
}
# Trace CometEditorGDD2_PM_P_SVG_basic HTML_Edit_edge

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_update_edge {src_dest} {
	regexp {^(.*)\?id=(.*)->(.*)\?id=(.*)$} $src_dest reco URL_graph_1 id_1 URL_graph_2 id_2
	
	set doc_1  [this get_Query_GDD_result $URL_graph_1]; set doc_2  [this get_Query_GDD_result $URL_graph_2]
	set root_1 [$doc_1 documentElement]                ; set root_2 [$doc_2 documentElement]
	set kasanayan [$root_1 namespaceURI]

	if {$URL_graph_1 == $URL_graph_2} {
		 set edge [$root_1 selectNodes -namespaces [list kasanayan $kasanayan] "//*\[@src='${id_1}' and @dst='${id_2}'\]"]
		 if {$edge != ""} {set msg "An edge still exists between nodes $id_1 and $id_2"
						   this send_jquery_message HTML_update_edge "alert('${msg}');"
						  } else {set node_1 [$root_1 selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id='${id_1}'\]"]
						          set node_2 [$root_2 selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id='${id_2}'\]"]
								  set relations [list]
								  # XXX Propose relations here depending on the abstraction and presicion of nodes
								  this prim_Add_graph_elements $URL_graph_1 [list [list kasanayan:Edge [list kasanayan:Relation $relations src $id_1 dst $id_2 id [uuid::uuid generate]]]]
								 }
		} else  {set msg "Edges between graphs currently not supported"
				 this send_jquery_message HTML_update_edge "alert('${msg}');"
				 error $msg
				}
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic HTML_update_node {params_update} {
	lassign $params_update URL_graph node_id L_update
	
	set doc       [this get_Query_GDD_result $URL_graph]
	set root      [$doc documentElement]
	set kasanayan [$root namespaceURI]
	
	set node [$doc selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id='${node_id}'\]"]
	foreach {att val} $L_update {$node setAttribute $att $val}
	
	set str_dot ""
	this Render_kasanayan:Graph_to_dot $URL_graph $doc $root str_dot
	
}
# Trace CometEditorGDD2_PM_P_SVG_basic HTML_update_node


#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic set_PM_root {PM} {
	this inherited $PM
	if {$PM != ""} {$PM Add_L_js_files_link "./GDD2/CometEditorGDD2/PMs/SVG/utils.js"}
}

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
method CometEditorGDD2_PM_P_SVG_basic Load_GDD_node {GDD_node_url {svg_root_id {}} {send_to_client 1}} {
	if {$svg_root_id == ""} {set svg_root_id ${objName}_docs}
	set str_js  ""
	set str_svg ""
	if {$send_to_client} {
		 append str_svg {<?xml version="1.0" encoding="UTF-8"?>}
		 append str_svg "\n<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">\n"
		}
	
	# Get ressource
	set str_xml [this get_ressource $GDD_node_url]
	
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
			 Add_list L_animated_id [list ${GDD_node_url}_#_$related_id]
			 
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
			 append str_js "\tvar tmp_node = document.getElementById(T_tmp\[i\]);\n"
			 append str_js "\tif(tmp_node == null) {console.log('Alert no element identified by ' + T_tmp\[i\]); continue;}\n"
			 append str_js "\tvar tmp_str =  tmp_node.getAttribute('annotations_CB');\n"
			 append str_js "\tif(tmp_str == '') {tmp_node.setAttribute('annotations_CB', '$L_id_segments');} else {tmp_node.setAttribute('annotations_CB', tmp_str + ' $L_id_segments');}\n"
			 append str_js "}\n"
			}
		 set id_doc ${GDD_node_url}_#_$annotation_id
		 append str_js "Draggable('$id_doc', \['$id_doc'\], null, function(n, e) {update_annotations_related_to('${GDD_node_url}_#_${annotation_id}');}, null);\n"
		}

	$doc delete
	if {$send_to_client} {append str_svg "</svg>\n"}
	
	if {$send_to_client} {
		 set    msg "Load_SVG('${svg_root_id}', true, false, \""
		 append msg [string map [list "\"" {\"} "\n" {\n}] $str_svg] "\", true);\n; Load_SVG('${objName}_links', true, false, '', true);\n$str_js"
		 this send_jquery_message Display__$GDD_node_url $msg
		}
	
	return [list $str_svg $str_js]
}

#___________________________________________________________________________________________________________________________________________
#_____________________________________________ View of the design process (path/pb/solutions) ______________________________________________
#___________________________________________________________________________________________________________________________________________

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_P_SVG_basic Render {strm_name {dec {}}} {
 upvar $strm_name strm
 
  append strm $dec "<g id=\"${objName}\" transform=\"\">\n"
  append strm $dec "<rect id=\"${objName}_BG_rect\" x=\"-10000000\" y=\"-10000000\" width=\"20000000\" height=\"20000000\" transform=\"\" style=\"fill:rgb(0,0,255);stroke-width:1;\"/>\n"
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
 append strm "document.getElementById('${objName}_BG_rect').addEventListener('mousedown', CB_GDD_on_right_click);\n"
 
 set C_html_to_SVG [CSS++ $objName "#$objName <--< Container_PM_P_HTML_to_SVG"]
 append strm "document.getElementById('${objName}_BG_rect').setAttribute('PM', '${objName}');\n"
 append strm "document.getElementById('${objName}_BG_rect').setAttribute('PM_HTML_to_SVG', '${C_html_to_SVG}');\n"
 append strm "document.getElementById('${objName}_BG_rect').addEventListener('mousedown', CB_GDD_on_right_click);\n"
 
 this Render_daughters_post_JS strm $dec
}


