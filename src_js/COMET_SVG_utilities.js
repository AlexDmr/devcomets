// Drop_zone('CPool_COMET_2_drop_circle', '*', null, null, null, null);
// Draggable('CPool_COMET_2', ['CPool_COMET_2_drag'], null, null, function(n, e) {});
// drag_info_obj.svg_rect.x = 0; drag_info_obj.svg_rect.y = 0; drag_info_obj.svg_rect.width = 1; drag_info_obj.svg_rect.height = 1;
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Drag_info_obj() {
	this.infos = "Object to store functions usefull for dragging...";
	this.Tab_drag = new Array();
	this.Tab_drop = new Array();
	
	this.Tab_drop_actives = new Array();
	this.last_drop_zone_hover = null;
}

var drag_info_obj = new Drag_info_obj();

//___________________________________________________________________________________________________________________________________________
//___________________________________________________ Drag nodes _____________________________________________________
//___________________________________________________________________________________________________________________________________________
function COMET_SVG_start_drag(id_grp, id_drag, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unknow id ' + id_grp); return;}
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(evt.pageX, evt.pageY, node_grp.parentNode);
	var x = coord['x'];
	var y = coord['y'];
	var ma_matrice = node_grp.getCTM();
	var dCTM = node_grp.parentNode.getCTM().inverse().multiply(ma_matrice);
	node_grp.setAttribute('transform', "matrix("+dCTM.a+","+dCTM.b+","+dCTM.c+","+dCTM.d+","+dCTM.e+","+dCTM.f+")");
	
	// Save the onmove event of the root in a special attribute of the node_grp
	node_grp.setAttribute('html_onmousemove_save', document.body.getAttribute('onmousemove'));
	node_grp.setAttribute('html_onmouseup_save'  , document.body.getAttribute('onmouseup')  );
	
	// Replace values by the one necessary for a good drag
	document.body.setAttribute('onmousemove', "COMET_SVG_drag     ('"+id_grp+"', '"+id_drag+"', '" + node_grp.getAttribute('transform') + "', " + x + ", " + y + ", event);" );
	document.body.setAttribute('onmouseup'  , "COMET_SVG_stop_drag('"+id_grp+"', '"+id_drag+"', event);" );
	
	if(drag_info_obj.Tab_drag[id_drag][0] != null) {drag_info_obj.Tab_drag[id_drag][0](node_grp, evt);}
	
	// Unplug and replug on top the current node so that it is displayed above its sibling
	var parentNode = node_grp.parentNode;
	parentNode.removeChild( node_grp );
	parentNode.appendChild( node_grp );
	document.getElementById('Ajax_Raw').innerHTML = "document.getElementById('" + id_grp + "')";
	
	// Manage drop zones
	drag_info_obj.svg_canvas = get_svg_canvas_of(node_grp);
	drag_info_obj.svg_rect   = drag_info_obj.svg_canvas.createSVGRect();
	drag_info_obj.svg_rect.width = drag_info_obj.svg_rect.height = 1;
	for(var i in drag_info_obj.Tab_drop) {
		 var L_nodes = $(drag_info_obj.Tab_drop[i][0]);
		 var contains = false;
		 for (var j=0; j < L_nodes.length; j++) {if(L_nodes[j] == node_grp) {contains = true; break;}}
		 if(contains) {
			 // Trigger the start drag function associated to the drop zone
			 var node_drop_zone = document.getElementById(i);
			 if (drag_info_obj.Tab_drop[i][1] != null) {drag_info_obj.Tab_drop[i][1](node_drop_zone, node_grp);}
			 // Register the drop zone a a currently active one
			 drag_info_obj.Tab_drop_actives[node_drop_zone] = drag_info_obj.Tab_drop[i];
			}
		}
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_drag      (id_grp, id_drag, dCTM, dsx, dsy, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unknow id ' + id_grp); return;}
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(evt.pageX, evt.pageY, node_grp.parentNode);
	var dx = coord['x'] - dsx; var dy = coord['y'] - dsy;
	
	node_grp.setAttribute('transform', dCTM + " translate(" + dx + "," + dy + ")");
	
	// Callback during drag
	if(drag_info_obj.Tab_drag[id_drag][1] != null) {drag_info_obj.Tab_drag[id_drag][1](node_grp, evt);}
	
	// Managing the drop zones
	drag_info_obj.svg_rect.x = evt.pageX - drag_info_obj.svg_canvas.offsetLeft - 1;
	drag_info_obj.svg_rect.y = evt.pageY - drag_info_obj.svg_canvas.offsetTop  - 1;
	
	var Tab_SVG_elements = drag_info_obj.svg_canvas.getIntersectionList(drag_info_obj.svg_rect, null);
	var new_drop_zone = null;
	if(Tab_SVG_elements != null) {
		 for (var i = 1; i < Tab_SVG_elements.length; i++) {
			 var drop_zone_tab = drag_info_obj.Tab_drop_actives[ Tab_SVG_elements[i] ];
			 if(drop_zone_tab != null) {
				 new_drop_zone = Tab_SVG_elements[i];
				 break;
				}
			}
		}
	if(new_drop_zone != drag_info_obj.last_drop_zone_hover) {
		 if(drag_info_obj.last_drop_zone_hover != null) {drag_info_obj.Tab_drop_actives[ drag_info_obj.last_drop_zone_hover ][3](drag_info_obj.last_drop_zone_hover, node_grp, evt);}
		 if(                     new_drop_zone != null) {drag_info_obj.Tab_drop_actives[ new_drop_zone                      ][2](new_drop_zone, node_grp, evt);}
		 drag_info_obj.last_drop_zone_hover = new_drop_zone;
		}
	
	//document.getElementById('CPool_COMET_3_PM_P_1_debug_rect').setAttribute('transform', 'translate('+drag_info_obj.svg_rect.x+', '+drag_info_obj.svg_rect.y+')');
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_stop_drag (id_grp, id_drag, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unknow id ' + id_grp); return;}
	
	document.body.setAttribute('onmousemove', node_grp.getAttribute('html_onmousemove_save') );
	document.body.setAttribute('onmouseup'  , node_grp.getAttribute('html_onmouseup_save')   );
	node_grp.setAttribute('html_onmousemove_save', '' );
	node_grp.setAttribute('html_onmouseup_save'  , '' );
	
	if(drag_info_obj.Tab_drag[id_drag][2] != null) {drag_info_obj.Tab_drag[id_drag][2](node_grp, evt);}
	
	// Callbacks
	if(drag_info_obj.last_drop_zone_hover != null) {
		 var fct = drag_info_obj.Tab_drop_actives[ drag_info_obj.last_drop_zone_hover ][4];
		 if(fct != null) {fct(drag_info_obj.last_drop_zone_hover, node_grp, evt);}
		 var fct = drag_info_obj.Tab_drop_actives[ drag_info_obj.last_drop_zone_hover ][6];
		 if(fct != null) {fct(drag_info_obj.last_drop_zone_hover, node_grp, evt);} else {alert(drag_info_obj.Tab_drop_actives.length);}
		}
	
	// Manage/Clear drop zones
	drag_info_obj.Tab_drop_actives     = [];
	drag_info_obj.last_drop_zone_hover = null;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Draggable(id_grp, L_id_drag, fct_start, fct_drag, fct_stop) {
	for(var i=0; i<L_id_drag.length; i++) {
		 var node = document.getElementById( L_id_drag[i] );
		 if(node == null) {alert('Problem initializing a drag with unknow id ' + L_id_drag[i]); return;}
		 drag_info_obj.Tab_drag[L_id_drag[i]] = [fct_start, fct_drag, fct_stop];
		 node.setAttribute('onmousedown', "COMET_SVG_start_drag('"+id_grp+"', '"+L_id_drag[i]+"', event);" );
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Drop_zone(id_node, accept_class, feedback_start, feedback_hover, feedback_out, feedback_done, feedback_undone, fct) {
	var node  = document.getElementById(id_node);
	if(node == null) {alert('Problem initializing a drop zone with unknow id ' + id_node); return;}
	
	drag_info_obj.Tab_drop[id_node] = [accept_class, feedback_start, feedback_hover, feedback_out, feedback_done, feedback_undone, fct];
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function get_svg_canvas_of (node) {
	var current_node = node;
	while(current_node != null && current_node.nodeName != 'svg') {current_node = current_node.parentNode;}
	
	return current_node;
}

//___________________________________________________________________________________________________________________________________________
//_______________________________________________________ Coordinates converstion _______________________________________________________
//___________________________________________________________________________________________________________________________________________
function convert_coord_from_page_to_node(x,y,node) {  						
	var coord = new Array();													
	coord['x'] = x;                         									
	coord['y'] = y;                      										
	var current_node = node;	                      							

	while(current_node.nodeName != 'HTML' && current_node.nodeName != 'svg') {  
		current_node = current_node.parentNode;                      			
		}

	if(current_node.nodeName == 'svg') {										
		coord['x'] -= current_node.offsetLeft;								
		coord['y'] -= current_node.offsetTop;									
		var ma_matrice = current_node.createSVGMatrix();						
		ma_matrice.e = coord['x'];										
		ma_matrice.f = coord['y'];										
		var matriceres = node.getCTM().inverse().multiply(ma_matrice);			

		coord['x'] = matriceres.e;											
		coord['y'] = matriceres.f;											
		}																			

	return coord;																
} 																			

 
//___________________________________________________________________________________________________________________________________________
//________________________________________________________ Move node _____________________________________________
//___________________________________________________________________________________________________________________________________________
function set_svg_origine(id,x,y) {											
	var node = document.getElementById(id);									
	if(node != null) {														
		var nCTM = node.parentNode.getCTM().inverse().multiply(node.getCTM()); 
		nCTM.e = x;																
		nCTM.f = y;																
		node.setAttribute('transform', 'matrix('+nCTM.a+','+nCTM.b+','+nCTM.c+','+nCTM.d+','+nCTM.e+','+nCTM.f+')'); 
		}																		
}

//___________________________________________________________________________________________________________________________________________
//_____________________________________________________ Load SVG description ______________________________________________________
//___________________________________________________________________________________________________________________________________________
function Load_SVG(id_root, clear_descendants, add_svg_tag, SVG_descr, is_string) {
	var node_root = document.getElementById(id_root);
	if (node_root == null) {alert("There is no root node to plug SVG:\n\tid_root : " + id_root + "\n\tSVG : " + SVG_str); return;}
	
	if(clear_descendants) {
		 for(var i = node_root.childNodes.length - 1; i>=0 ; i--) {node_root.removeChild( node_root.childNodes[i] );}
		}
		
	if(add_svg_tag) {SVG_str = '<svg xmlns="http://www.w3.org/2000/svg" version="1.1">' + SVG_str + '</svg>';}
	
	if(is_string) {
		 var parser  = new DOMParser();
		 var doc_dom = parser.parseFromString(SVG_descr, "text/xml");
		} else {var doc_dom = SVG_descr;}
	
	var L_nodes = new Array();;
	for(var i = 0; i < doc_dom.firstChild.childNodes.length; i++) {
		 //alert(doc_dom.firstChild.childNodes[i].nodeName);
		 if(doc_dom.firstChild.childNodes[i].nodeName != "#text") {
			  var node_to_import = document.importNode(doc_dom.firstChild.childNodes[i], true);
			  L_nodes.push( node_to_import );
			  node_root.appendChild( node_to_import );
			 }
		}
		
	return L_nodes;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function test_dd (id_drag_g, id_drag_z, id_drop_z, id_pipo_circle, id_pipo_line) {
//accept_class, feedback_start, feedback_hover, feedback_out, feedback_done, feedback_undone, fct
	Drop_zone(id_drop_z, '*', function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Drop zone possible in " + z.getAttribute('id') + 'from ' + n.getAttribute('id');}
											  , function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Hover drop zone " + z.getAttribute('id') + ' with node ' + n.getAttribute('id');}
											  , function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Out of drop zone " + z.getAttribute('id') + ' with node ' + n.getAttribute('id') + ' last zone was ' + drag_info_obj.last_drop_zone_hover.getAttribute('id') ;}
											  , function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Release on drop zone " + z.getAttribute('id') + ' with node ' + n.getAttribute('id');}
											  , function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Release outside of drop zone " + z.getAttribute('id') + ' with node ' + n.getAttribute('id');}
											  , function(z, n, e) {document.getElementById('Ajax_Raw').innerHTML = "Plop on drop zone " + z.getAttribute('id') + ' with node ' + n.getAttribute('id');}
											  );
	document.getElementById(id_drag_g).setAttribute('pipo_line'  , id_pipo_line  );
	document.getElementById(id_drag_g).setAttribute('pipo_circle', id_pipo_circle);
	Draggable(id_drag_g, [id_drag_z], null
									, function(n, e) {
										 var matrix_n = n.parentNode.getCTM().inverse().multiply(n.getCTM()).translate(100, 50);
										 var line   = document.getElementById(n.getAttribute('pipo_line'  ));
										 var circle = document.getElementById(n.getAttribute('pipo_circle'));
										 line.setAttribute('x1', matrix_n.e);
										 line.setAttribute('y1', matrix_n.f);
										}
									, null
									);
	//var query_svg  = "http://194.199.23.189/kasanayan/bin/processor.tcl?request=http://194.199.23.189/kasanayan/bd/widgets/root.xml";
	var query_svg  = "essai_svg.svg";
	var svg_canvas = get_svg_canvas_of( document.getElementById(id_drag_g) );
	$.post(query_svg, {}, function (data_xml) {
									 document.getElementById('Ajax_Raw').innerHTML = (new XMLSerializer()).serializeToString(data_xml);
									 var g_graph = Load_SVG(svg_canvas.id + '_g_root', false, false, data_xml, false)[0];
									 //alert(g_graph);
									 g_graph.setAttribute('transform', g_graph.getAttribute('transform') + ' translate(50, 50)');
									 for(var i = 0; i < g_graph.childNodes.length; i++) {
										 var xml_node = g_graph.childNodes[i];
										 if(xml_node.nodeName == "g" && xml_node.getAttribute('class') == "node") {
											 Draggable(xml_node.id, [xml_node.id], null, null, null);
											}
										}
									}
						, 'xml'
			   );
}

