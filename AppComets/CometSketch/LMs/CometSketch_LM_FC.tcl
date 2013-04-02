inherit LogicalSketch_FC Logical_model

#___________________________________________________________________________________________________________________________________________
method LogicalSketch_FC constructor {name descr args} {
 this inherited $name $descr

 # set this(ffmpeg_PM) ${objName}_PM_ffmpeg
 # Video_PM_FC_ffmpeg $this(ffmpeg_PM) "FFMPEG decoder" "This is the default PM of $objName (LogicalSketch_FC)"
 # this Add_PM $this(ffmpeg_PM); this set_PM_active $this(ffmpeg_PM)
 
 eval "$objName configure $args"
 return $objName
}


#___________________________________________________________________________________________________________________________________________
Methodes_set_LC LogicalSketch_FC [P_L_methodes_set_Sketch] {} {$this(L_actives_PM)}
Methodes_get_LC LogicalSketch_FC [P_L_methodes_get_Sketch] {$this(FC)}

#___________________________________________________________________________________________________________________________________________
proc P_L_methodes_set_Sketch_FC_COMET_RE {} {return [list 
														 ]}
Generate_LM_setters LogicalSketch_FC [P_L_methodes_set_Sketch_FC_COMET_RE]

