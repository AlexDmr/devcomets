package require tdom

#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
#_________________________________________________________________________________________________________
method AnotoCanvas constructor {C_UPNP} {
	set this(C_UPNP) $C_UPNP
	
	set this(buffer) ""
	
	set this(canvas) ._c_$objName
	canvas $this(canvas); pack $this(canvas) -expand 1 -fill both
	
	set this(win_tools) [toplevel ._w_tools]
		set this(bt_mode_line)  [button $this(win_tools).bt_line  -text "LINE"        -command "$objName set_mode line"]       ; pack $this(bt_mode_line)  -side top -expand 1 -fill x
		set this(bt_mode_poly)  [button $this(win_tools).bt_poly  -text "POLYGON"     -command "$objName set_mode polygon"]    ; pack $this(bt_mode_poly)  -side top -expand 1 -fill x
		set this(bt_mode_inter) [button $this(win_tools).bt_inter -text "INTERACTION" -command "$objName set_mode Interaction"]; pack $this(bt_mode_inter) -side top -expand 1 -fill x
	
	set this(is_connected) 0
	this Try_connect
	
	set this(ex) 0.1
	set this(ey) 0.1
	
	set this(mode) line
	
	set this(poly_id) 0
	set this(D_poly_cmd) [dict create]
	set this(L_lines)    [list]
	
	set this(num_stroke) 0
}

#_________________________________________________________________________________________________________
method AnotoCanvas dispose {} {
	catch {destroy $this(canvas)
		   destroy $this(win_tools)
		  }
	catch {close $this(sock_Anoto_TCP_client)}
	this inherited
}

Generate_accessors AnotoCanvas [list mode ex ey]


#_________________________________________________________________________________________________________
method AnotoCanvas set_mode {m} {
	set this(mode) $m
	set col #EEE
	switch $this(mode) {
		 line        {$this(bt_mode_line) configure -background green; $this(bt_mode_poly) configure -background SystemButtonFace; $this(bt_mode_inter) configure -background SystemButtonFace
					  $this(canvas) itemconfigure polygon -outline black -fill $col
					 }
		 polygon     {$this(bt_mode_line) configure -background SystemButtonFace; $this(bt_mode_poly) configure -background green; $this(bt_mode_inter) configure -background SystemButtonFace
					  $this(canvas) itemconfigure polygon -outline black -fill $col
					 }
		 Interaction {$this(bt_mode_line) configure -background SystemButtonFace; $this(bt_mode_poly) configure -background SystemButtonFace; $this(bt_mode_inter) configure -background green
					  $this(canvas) itemconfigure polygon -outline black -fill $col
					 }
		}
}

#_________________________________________________________________________________________________________
method AnotoCanvas List_polygons {} {
	dict for {id val} $this(D_poly_cmd) {
		 puts "_____________________________\n$id : [dict get $val cmd]\n"
		}
}

#_________________________________________________________________________________________________________
method AnotoCanvas Add_polygon {tk_id L_pt} {
	set id $this(poly_id); incr this(poly_id)
	dict append this(D_poly_cmd) $id [dict create tk_id $tk_id L_pt $L_pt cmd "puts \"Click on polygon $id\""]
	return $id
}

#_________________________________________________________________________________________________________
method AnotoCanvas set_polygon_cmd {id cmd} {
	if {[dict exists $this(D_poly_cmd) $id]} {
		 dict set this(D_poly_cmd) $id cmd $cmd
		} else {puts "\t$objName set_polygon_cmd $id ... : id $id does not exists"}
 return ""
}

#_________________________________________________________________________________________________________
method AnotoCanvas Try_connect {} {
	# Find device named Anoto Bridge
	# Must contains a method getTcpServer
	set rep [$this(C_UPNP) Search_UDN_service_action [list {friendlyName} {$friendlyName == "Anoto Bridge"}] "" [list "" {$D_name == "getTcpServer"}]]
	if {[llength $rep] == 1} {
		 lassign $rep this(anoto_get_TcpServer)
		 lassign $this(anoto_get_TcpServer) UDN SRV ACT
		 $this(C_UPNP) soap_call $UDN $SRV $ACT [list ] "$objName get_CB_rep_getTcpServer \$UPNP_res"
		}
}

method AnotoCanvas get_CB_rep_getTcpServer {UPNP_res} {
	if {[dict exists $UPNP_res a]} {
		 lassign [split [dict get $UPNP_res a] ":"] IP port
		 set this(sock_Anoto_TCP_client) [socket $IP $port]
		 fconfigure $this(sock_Anoto_TCP_client) -blocking 0
		 fileevent  $this(sock_Anoto_TCP_client) readable "$objName Anoto_read_from_TCP $this(sock_Anoto_TCP_client)"
		}
}
Trace AnotoCanvas get_CB_rep_getTcpServer

#_________________________________________________________________________________________________________
method AnotoCanvas Clear_TCP_buffer {} {
	set this(buffer) [list]
}

#_________________________________________________________________________________________________________
method AnotoCanvas Anoto_read_from_TCP {s} {
	if {[eof $s]} {
		 close $s
		} else  {append this(buffer) [read $s]
			     this Process_buffer
				}
}

#_________________________________________________________________________________________________________
method AnotoCanvas Process_buffer {} {
	set pos_end [string first ";" $this(buffer)]
	while {$pos_end != -1} {
		 set D [split [string range $this(buffer) 1 [expr $pos_end - 1]] ":"]
		 if {[dict exists $D event]} {set mtd [dict get $D event]} else {set mtd Move}
		 this $mtd [dict get $D serial] $D
		 set this(buffer) [string range $this(buffer) [expr $pos_end + 1] end]
		 set pos_end [string first ";" $this(buffer)]
		}
}

#_________________________________________________________________________________________________________
method AnotoCanvas Undo {} {
	$this(canvas) delete $this(num_stroke)
	if {$this(num_stroke) > 0} {incr this(num_stroke) -1}
}

#_________________________________________________________________________________________________________
method AnotoCanvas Redo {} {

}

#_________________________________________________________________________________________________________
method AnotoCanvas PenConnected {serial D} {

}

#_________________________________________________________________________________________________________
method AnotoCanvas PenDown {serial D} {
	set this(first_move_$serial) 1
	if {$this(mode) != "Interaction"} {
		 incr this(num_stroke)
		 set this(current_path_$serial)    [list]
		 set this(current_polygon_$serial) [$this(canvas) create $this(mode) 0 0 0 0 -tags [list stroke_$this(num_stroke) $this(mode)]]
		 $this(canvas) raise line
		}
}

#_________________________________________________________________________________________________________
method AnotoCanvas Press_at {serial D} {
	if {$this(first_move_$serial)} {
		set x [expr $this(ex) * [dict get $D x]]; set y [expr $this(ey) * [dict get $D y]]
		dict for {id D_poly} $this(D_poly_cmd) {
			 if {[this is_inside $x $y [dict get $D_poly L_pt]]} {
				 eval [dict get $D_poly cmd]
				}
			}
	 set this(first_move_$serial) 0
	}
}

#_________________________________________________________________________________________________________
method AnotoCanvas PenUp {serial D} {
	if {$this(mode) == "polygon"} {
		 puts "New polygon !"
		 if {[catch {this Add_polygon $this(current_polygon_$serial) $this(current_path_$serial)} err]} {
			 puts "\tERROR : $err"
			}
		} else {if {$this(mode) == "line"} {lappend this(L_lines) $this(current_polygon_$serial)}
			   }
	set this(current_path_$serial) [list]
}

#_________________________________________________________________________________________________________
method AnotoCanvas Move {serial D} {
	if {$this(mode) == "Interaction"} {
		 this Press_at $serial $D
		} else {lappend this(current_path_$serial) [expr $this(ex) * [dict get $D x]] [expr $this(ey) * [dict get $D y]]
				catch {$this(canvas) coords $this(current_polygon_$serial) $this(current_path_$serial)}
			   }
}


#_________________________________________________________________________________________________________
method AnotoCanvas is_inside {x y polygon} {
     set inside 0

     set n [llength $polygon]
     set jxp [lindex $polygon [expr {$n-2}]]   ; # take endpoint
     set jyp [lindex $polygon [expr {$n-1}]]

     foreach {ixp iyp} $polygon {

 	if { (($iyp <= $y) && ($y < $jyp)) || (($jyp <= $y) && ($y < $iyp)) } {

 	    set xx [expr {($jxp - $ixp) * ($y - $iyp) / ($jyp - $iyp) + $ixp}]
 	    if { $x < $xx } {
 		set inside [expr {1-$inside}]   ; # inside = not inside
 	    }
 	}

 	set jxp $ixp
 	set jyp $iyp

     }

     return $inside
 }

#_________________________________________________________________________________________________________
method AnotoCanvas Clear_canvas {} {
	foreach line $this(L_lines)            {$this(canvas) delete $line}                   ; set this(L_lines)    [list]
	dict for {id D_poly} $this(D_poly_cmd) {$this(canvas) delete [dict get $D_poly tk_id]}; set this(D_poly_cmd) [dict create]
}
	
#_________________________________________________________________________________________________________
method AnotoCanvas Load_interaction {f_name} {
	this Clear_canvas

	set f [open $f_name r]; set str [read $f]; close $f
	dom parse $str doc
	$doc documentElement root
		lassign [[$root selectNodes "SCALE"] asText] this(ex) this(ey)
		foreach xml_line [$root selectNodes "line"   ] {lappend this(L_lines) [$this(canvas) create line [[$xml_line selectNodes coords] asText] -tags line]}
		foreach xml_poly [$root selectNodes "polygon"] {set tk_id [$this(canvas) create polygon [[$xml_poly selectNodes coords] asText] -tags polygon]
													    set id [this Add_polygon $tk_id [[$xml_poly selectNodes coords] asText]]
														this set_polygon_cmd $id [[$xml_poly selectNodes cmd] asText]
													   }
	$doc delete
	
	this set_mode [this get_mode]
	$this(canvas) raise line
}

#_________________________________________________________________________________________________________
method AnotoCanvas Save_interaction {f_name EPS_f_name} {
	set f [open $f_name w]
		puts $f "<interaction>\n"
		puts $f "\t<EPS>$EPS_f_name</EPS>\n"
		puts $f "<SCALE>$this(ex) $this(ey)</SCALE>"
		foreach id $this(L_lines) {
			 set coords [$this(canvas) coords $id]
			 if {$id != "" && $id != "0.0 0.0 0.0 0.0"} {
				 puts $f "<line><coords>$coords</coords></line>"
				}
			}
		dict for {id D_poly} $this(D_poly_cmd) {
			 set tk_id  [dict get $D_poly tk_id]; puts "tk_id : $tk_id"
			 set coords [$this(canvas) coords $tk_id]
			 set cmd    [dict get $D_poly cmd]
			 if {[llength $coords] >= 6} {
				 puts $f "<polygon><cmd><!\[CDATA\[\n$cmd\n\]\]>\n</cmd><coords>$coords</coords></polygon>"
				}
			}
		puts $f "</interaction>\n"
	close $f
}

#_________________________________________________________________________________________________________
method AnotoCanvas Save_in_PS {f_name EPS_f_name} {
# Empty polygons
 # $this(canvas) itemconfigure polygon -outline #004 -fill ""
 
# Generate PS
 set str [$this(canvas) postscript]
 set pos_deb [string first "%%BoundingBox" $str]


 set f [open $EPS_f_name r]; set EPS [read $f]; close $f
 set X 5669
 set PS_tmp [string map [list "%%EndProlog" "\n
/BeginEPSF { %def
/b4_Inc_state save def % Save state for cleanup  
/dict_count countdictstack def  % Count objects on dict stack
/op_count count 1 sub def % Count objects on operand stack
userdict begin % Push userdict on dict stack
/showpage { } def % Redefine showpage, { } = null proc
0 setgray 0 setlinecap % Prepare graphics state
1 setlinewidth 0 setlinejoin 
10 setmiterlimit \[ \] 0 setdash newpath 
/languagelevel where % If level not equal to 1 then
{pop languagelevel % set strokeadjust and
1 ne % overprint to their defaults.
{false setstrokeadjust false setoverprint
} if
} if
} bind def



/EndEPSF { %def
count op_count sub {pop} repeat % Clean up stacks
countdictstack dict_count sub {end} repeat  
b4_Inc_state restore
} bind def

%%EndProlog
" "grestore
restore showpage" "grestore
restore\n\nBeginEPSF\n%%BeginDocument: ANOTO.EPS\n$EPS\n%%EndDocument\nEndEPSF\n"] [$this(canvas) postscript -pageanchor nw -pageheight 29.7c -pagewidth 21c -pagey 29.55c -pagex 0.13c -height 10000 -width [expr int($this(ex)*$X)] ]]
 
 set    PS [string range $str 0 [expr $pos_deb - 1]]
 append PS "%%BoundingBox: 0 0 595 841\n"
 append PS [string range $PS_tmp [string first "%%Pages:" $PS_tmp] end]

 set f [open $f_name w]
 puts $f $PS
 close $f
}
 
# proc P {s} {
	# if {[eof $s]} {
		 # close $s
		# } else {puts [read $s]
			   # }
# }
# set s [socket 129.88.64.229 3154]
# fconfigure $s -blocking 0
# fileevent $s readable "P $s"


