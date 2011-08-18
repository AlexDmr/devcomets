source c:/These/Projet\ Interface/COMETS/devCOMETS/minimal_load.tcl
Init_HTML

Do_rec_source ./GDD2/CometEditorGDD2/
cr Add_daughters_R [CometEditorGDD2 CE n d]
cr Add_daughters_R [CPool get_singleton CometUPNP]
CE Load_XML_schema "c:/These/Projet\ Interface/COMETS/devCOMETS/Kasanayan/essai_alex/kasanayan-0.2.xsd"

set PM_CE [CSS++ cr "cr->PMs.PM_HTML CE(CORE)"]


