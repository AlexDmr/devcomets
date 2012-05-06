#___________________________________________________________________________________________________________________________________________
#_________________________________________________ Vertice : with sources and targets ______________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice constructor {} {
	set this(D_sources) [dict create]
	set this(D_targets) [dict create]
	
	set this(mark) ""
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice get_mark { } {return $this(mark)}
method Vertice set_mark {v} {set this(mark) $v}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice get_all_sources {} {
	set L [list]
	dict for {t v} $this(D_sources) {lappend L $v}
	return $L
}

#___________________________________________________________________________________________________________________________________________
method Vertice get_all_targets {} {
	set L [list]
	dict for {t v} $this(D_targets) {lappend L $v}
	return $L
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice get_sources_typed {t} {
	if {[dict exists $this(D_sources) $t]} {return [dict get $this(D_sources)]} else {return [list]}
}

#___________________________________________________________________________________________________________________________________________
method Vertice get_targets_typed {t} {
	if {[dict exists $this(D_targets) $t]} {return [dict get $this(D_targets)]} else {return [list]}
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice Add_source_typed {t v} {
	if {[lsearch [dict get $this(D_sources) $t] $v] == -1} {
		 dict lappend this(D_sources) $t $v
		}
}

#___________________________________________________________________________________________________________________________________________
method Vertice Sub_source_typed {t v} {
	set this(D_sources) [dict replace $this(D_sources) $t [lremove [dict get $this(D_sources) $t] $v]]
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
method Vertice Add_target_typed {t v} {
	if {[lsearch [dict get $this(D_targets) $t] $v] == -1} {
		 dict lappend this(D_targets) $t $v
		}
}

#___________________________________________________________________________________________________________________________________________
method Vertice Sub_target_typed {t v} {
	set this(D_targets) [dict replace $this(D_targets) $t [lremove [dict get $this(D_targets) $t] $v]]
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit Node Vertice
method Node constructor {} {
	this inherited
	
	set this(D_descr) [dict create]
	
	set this(level_abstraction) "UNKNOWN"
	set this(level_precision)   "UNKNOWN"
}

#___________________________________________________________________________________________________________________________________________
method get_level_abstraction {} {return $this(level_abstraction)}
foreach m [list C&T AUI CUI FUI] {method Node set_level_abstraction_to_$m {} {set this(level_abstraction) $m}}

#___________________________________________________________________________________________________________________________________________
method get_level_precision {} {return $this(level_precision)}
foreach m [list Sketch Prototype Formal] {method Node set_level_precision_to_$m {} {set this(level_precision) $m}}

#___________________________________________________________________________________________________________________________________________
method Node exists_descr {id} {
	return [dict exists $this(D_descr) $id]
}

#___________________________________________________________________________________________________________________________________________
method Node get_descr {id} {
	return [dict get $this(D_descr) $id]
}

#___________________________________________________________________________________________________________________________________________
method Node set_descr {id v} {
	dict set this(D_descr) $id $v
}

#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
#___________________________________________________________________________________________________________________________________________
inherit Arc Vertice
method Arc constructor {} {
	set this(type) "UNKNOWN"
}

#___________________________________________________________________________________________________________________________________________
method Arc get_type {} {return $this(type)}


