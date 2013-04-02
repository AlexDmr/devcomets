inherit CometDesignProcess_CFC CommonFC

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_CFC constructor {} {
	set this(D_DesignGraph) [dict create]
}
#___________________________________________________________________________________________________________________________________________
Generate_accessors CometDesignProcess_CFC [list edited_root]

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_CFC DesignGraph_val {op args} {
	return [eval [concat [list dict $op $this(D_DesignGraph)] $args]]
}

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_CFC DesignGraph {op args} {
	return [eval [concat [list dict $op this(D_DesignGraph)] $args]]
}

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_CFC set_node {id L_ancestors L_descendants content} {
	dict set this(D_DesignGraph) $id [dict create L_ancestors $L_ancestors L_descendants $L_descendants content $content]
	set L_rel [list L_ancestors L_descendants]
	for {set i 0} {$i < 1} {incr i} {
		foreach n $[lindex $L_rel $i] {
			 if {![dict exists $this(D_DesignGraph) $n $[lindex $L_rel [expr $i - 1] $id]} {
				 dict lappend this(D_DesignGraph) $n $[lindex $L_rel [expr $i - 1]] $id
				}
			}
		}
}

#___________________________________________________________________________________________________________________________________________
method CometDesignProcess_CFC Load_artefacts_from_node {id} {
	if {![dict exists $this(D_DesignGraph) $id]} {error "There is no node identified by $id"}
}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_get_CometDesignProcess {} {return [list {DesignGraph_val {op args}} ]}
proc P_L_methodes_set_CometDesignProcess {} {return [list {DesignGraph {op args}} {Load_artefacts_from_node {id}} {set_node {id L_ancestors L_descendants}} ]}

