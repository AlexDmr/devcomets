inherit CometEditorGDD2_PM_FC_basic Physical_model

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_PM_FC_basic constructor {name descr args} {
 this inherited $name $descr

 package require tdom
 package require http
 
 eval "$objName configure $args"
 return $objName
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Methodes_set_LC CometEditorGDD2_PM_FC_basic [P_L_methodes_set_CometEditorGDD2] {} {}
Methodes_get_LC CometEditorGDD2_PM_FC_basic [P_L_methodes_get_CometEditorGDD2] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
Generate_PM_setters CometEditorGDD2_PM_FC_basic [P_L_methodes_set_CometEditorGDD2_COMET_RE_FC]

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_FC_basic Query_GDD {} {
	# Params : str
	# Get the content of the ressource in the variable content
	set content [this get_ressource $str]
	set URL     [this get_URL_from_ressource $str]
	
	# Parse the content
	 if {![catch {set doc [dom parse $content]} err]} {
		 if {[this exist_Query_GDD_result $URL]} {this prim_unset_Query_GDD_result $str}
		 this prim_set_Query_GDD_result $URL $doc
		} else  {this prim_set_Query_GDD_result $URL [list ERROR parsing $str $err]
				}
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_FC_basic Commit_graph {} {
	# Params : URL_graph {URL_write {}}

	if {![this exist_Query_GDD_result $URL_graph]} {error "Graph $URL_graph has not been loaded, it can not be commited"}
	set doc [this get_Query_GDD_result $URL_graph]
	
	if {$URL_write == ""} {set URL_write $URL_graph}
	
	if {[string equal -length 3 "c:/" [string tolower $URL_write]]} {
		 # open the file, write the serialized dom 
		 set f [open $URL_write w]; fconfigure $f -encoding utf-8
		 $doc asXML -channel $f
		 close $f
		}
	
	if {[string equal -length 9 "kasanayan" [string tolower $URL_write]]} {
		 # set url "http://194.199.23.189/kasanayan/bin/processor2.tcl"
		 # request insertRawXML
		 # xml_data $DATA
		 # parentUID $parentUID
		 # 
		 set D [lindex $URL_write 1]
		 set QUERY [eval "::http::formatQuery [dict get $D params] xml_data \[$doc asXML\]"]
		 set token   [::http::geturl [dict get $D URL] -query $QUERY]
		 # set rep [::http::data $token]
		 ::http::cleanup $token
		}
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_FC_basic Add_graph_elements {} {
	# Params : URL_graph L_elements
	if {[this exist_Query_GDD_result $URL_graph]} {
		 # Identify the doc dom to which elements have to be plugged
		 set doc  [this get_Query_GDD_result $URL_graph]
		 set root [$doc documentElement]
		 set kasanayan [$root namespaceURI]
		 
		 # Import elements into the original doc
		 foreach element_description $L_elements {
			 lassign $element_description tag L_att_val
			 # $root appendXML $e
			 set node [$doc createElementNS $kasanayan $tag]
			 foreach {att val} $L_att_val {
				 if {[string first : $att] >= 0} {
					 $node setAttributeNS $kasanayan $att $val
					} else {$node setAttribute $att $val}
				}
			 set id [$node getAttribute id]
			 if {$tag == "kasanayan:Edge"} {
				 # Update related nodes
				 set id_src [$node getAttribute src]; set URL_graph_src $URL_graph; regexp {^(.*)\?id=(.*)$} $id_src reco URL_graph_src id_src
				 set id_dst [$node getAttribute dst]; set URL_graph_dst $URL_graph; regexp {^(.*)\?id=(.*)$} $id_src reco URL_graph_dst id_dst
				 
				 foreach {URL n_id} [list $URL_graph_src $id_src $URL_graph_dst $id_dst] {
					 set n_doc  [this get_Query_GDD_result $URL]
					 set n_root [$n_doc documentElement]
					 set n_node [$n_root selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id='${n_id}'\]"]
					 $n_node setAttribute edges [concat [$n_node getAttribute edges] $id]
					 puts "Mise à jour $n_node : [$n_node asXML]"
					}
				}
			 $root appendChild $node
			}
		} else {error "Graph $URL_graph has not been loaded, no element can be added...\nIn $objName Add_graph_elements URL_graph L_elements\URL_graph : $URL_graph\nL_elements : $L_elements"}
}
# Trace CometEditorGDD2_PM_FC_basic Add_graph_elements
#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_FC_basic Sub_graph_elements {} {
	# Params : URL_graph L_elements
	if {[this exist_Query_GDD_result $URL_graph]} {
		 # Identify the doc dom to which elements have to be plugged
		 set doc       [this get_Query_GDD_result $URL_graph]
		 set kasanayan [[$doc documentElement] namespaceURI]
		 
		 # Import elements into the original doc
		 foreach e $L_elements {
			 set GDD_id $e
			 regexp {^http://.*\?(.*)=(.*)$} $GDD_id reco type id
			 foreach node [$doc selectNodes -namespaces [list kasanayan $kasanayan] "//*\[@id=\"$GDD_id\" or @id=\"$id\"\]"] {
				 puts "Delete [$node nodeName] $node"
				 # If it is a node, delete also related edges
				 # If it is an edge, delete references of related nodes
				 switch [$node nodeName] {
					 "kasanayan:Node" {set L [$node getAttribute edges]
									   $node setAttribute edges ""
									   foreach edge $L {
										   puts "\tDelete related edge $edge"
										   if {![regexp {^(.*)\?id=(.*)$} $edge reco URL_edge id_edge]} {
												set URL_edge $URL_graph
												set id_edge  $edge
											   }
										   this Sub_graph_elements $URL_edge $id_edge
										  }
									  }
					 "kasanayan:Edge" {foreach n_id [list [$node getAttribute src] [$node getAttribute dst]] {
											puts "\tUdpatting related node $n_id"
											if {![regexp {^(.*)\?id=(.*)$} $n_id reco URL_node id_node]} {
												set URL_node $URL_graph
												set id_node  $n_id
											   }
											# Get the dom node from URL_node.id_node
											set doc_node  [this get_Query_GDD_result $URL_node]
											set root_node [$doc_node documentElement]
											
											set related_node [$root_node selectNodes -namespaces [list kasanayan $kasanayan] "//kasanayan:Node\[@id=\"$id_node\"\]"]
											set L_edges [$related_node getAttribute edges]
											Sub_list L_edges $e
											$related_node setAttribute edges $L_edges
										   }
									  }
					}
				 
				 $node delete
				}
			}
		 
		} else {error "Graph $URL_graph has not been loaded, no element can be removed...\nIn $objName Sub_graph_elements URL_graph L_elements\URL_graph : $URL_graph\nL_elements : $L_elements"}
}

#___________________________________________________________________________________________________________________________________________
Inject_code CometEditorGDD2_PM_FC_basic Load_XML_schema {} {
	# Params : URL
	set str_xml [this get_ressource $URL]

	# Parse the content
	 if {![catch {set doc [dom parse $str_xml]} err]} {
		 if {[this get_dom_XML_schema] != ""} {[this get_dom_XML_schema] delete}
		 this prim_set_dom_XML_schema $doc
		} else  {this prim_dom_XML_schema $str [list "ERROR while parsing" $URL $err]
				}
}

