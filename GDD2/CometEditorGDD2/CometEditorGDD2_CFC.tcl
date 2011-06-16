inherit CometEditorGDD2_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC constructor {} {
	set this(D_queries)  [dict create]
	set this(dom_XML_schema) ""
}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Query_GDD {str} {}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Load_XML_schema {URL} {}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC get_ressource {URL} {
	set content ""
	if {[string equal -length 9 "kasanayan" [string tolower $URL]]} {
		# set url "http://194.199.23.189/kasanayan/bin/processor2.tcl"
		# set request "GetElementXML"
		# set uid "http://194.199.23.189/kasanayan/bd/d.xml?Graph=Newgraph"
		# 
		set D [lindex $URL 1]
		set QUERY [eval "::http::formatQuery [dict get $D params]"]
		set token   [::http::geturl [dict get $D URL] -query $QUERY]
		set content [::http::data $token]
		::http::cleanup $token
		
	} else {
			if {[string equal -length 7 "http://" [string tolower $URL]]} {
				 # Get the ressource from the net
				 set token   [::http::geturl $URL]
				 set content [::http::data $token]
				 ::http::cleanup $token
				 
				} else {
			if {[string equal -length 3 "c:/" [string tolower $URL]]} {
				 # Get the ressource locally
				 set f [open $URL]; fconfigure $f -encoding utf-8
				 set content [read $f]
				 close $f
				} 
			}
		}
		
	return $content
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Query_GDD {str} {}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC get_Query_GDD_result {str} {return [dict get $this(D_queries) $str]}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC set_Query_GDD_result {str res} {dict set this(D_queries) $str $res}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC unset_Query_GDD_result {str} {dict unset this(D_queries) $str}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC exist_Query_GDD_result {str} {return [dict exists $this(D_queries) $str]}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Add_graph_elements {URL_graph L_elements} {}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Sub_graph_elements {URL_graph L_elements} {}

#___________________________________________________________________________________________________________________________________________
method CometEditorGDD2_CFC Commit_graph {URL_graph} {}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
Generate_accessors CometEditorGDD2_CFC [list dom_XML_schema]

#___________________________________________________________________________________________________________________________________________

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_CometEditorGDD2 {} {return [list {get_ressource {URL}} {get_dom_XML_schema {}} {get_Query_GDD_result {str}} {exist_Query_GDD_result {str}} ]}
proc P_L_methodes_set_CometEditorGDD2 {} {return [list {Load_XML_schema {URL}} {set_dom_XML_schema {v}} {Commit_graph {URL_graph}} {set_Query_GDD_result {str res}} {unset_Query_GDD_result {str}} {Add_graph_elements {URL_graph L_elements}} {Sub_graph_elements {URL_graph L_elements}} {Query_GDD {str}} ]}

