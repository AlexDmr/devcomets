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
	evt.stopPropagation();
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
	//document.getElementById('Ajax_Raw').innerHTML = "document.getElementById('" + id_grp + "')";
	
	// Manage drop zones
	drag_info_obj.svg_canvas     = get_svg_canvas_of(node_grp);
	drag_info_obj.svg_rect       = drag_info_obj.svg_canvas.createSVGRect();
	drag_info_obj.svg_rect.width = drag_info_obj.svg_rect.height = 1;
	drag_info_obj.pt_src = drag_info_obj.svg_canvas.createSVGPoint();;
	drag_info_obj.pt_dst = drag_info_obj.svg_canvas.createSVGPoint();;
	
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
	if(evt.button != 0) {return;}

	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unknow id ' + id_grp); return;}
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(evt.pageX, evt.pageY, node_grp.parentNode);
	var dx = coord['x'] - dsx; var dy = coord['y'] - dsy;
	
	node_grp.setAttribute('transform', " translate(" + dx + "," + dy + ")" + dCTM);
	
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
	drag_info_obj.Tab_drop_actives     = new Array();
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
	while(current_node != null && current_node.nodeName != 'svg' && current_node.nodeName != 'svg:svg') {current_node = current_node.parentNode;}
	
	return current_node;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Register_CB_onwheel_with_id (node_id, fct_CB) {return Register_CB_onwheel(document.getElementById(node_id), fct_CB);}
function Register_CB_onwheel   (node, fct_CB)    {
	if (node.addEventListener) {
			node.addEventListener('DOMMouseScroll', fct_CB, false);
			node.addEventListener('mousewheel'    , fct_CB, false); // Chrome
			return 1;
		}
	return 0;
}


//___________________________________________________________________________________________________________________________________________
function Register_node_id_SVG_zoom_onwheel(node_id) {return Register_node_SVG_zoom_onwheel(document.getElementById(node_id));}
function Register_node_SVG_zoom_onwheel   (node)    {
	return Register_CB_onwheel(node, SVG_zoom_onwheel);
}

//___________________________________________________________________________________________________________________________________________
function SVG_zoom_onwheel(e) {
	e.stopPropagation(); e.cancelBubble = true; e.preventDefault(); e.returnValue = false;
    var nDelta = 0;
	if ( e.wheelDelta ) { // IE and Opera
         nDelta= e.wheelDelta;
         if ( window.opera ) {  // Opera has the values reversed
            nDelta= -nDelta;
        }
    } else if (e.detail) { // Mozilla FireFox
         nDelta= -e.detail;
		}
	
	var svg_canvas = get_svg_canvas_of(e.currentTarget);
	SVG_zoom(svg_canvas, e.currentTarget, window.pageXOffset + e.clientX - svg_canvas.offsetLeft, window.pageYOffset + e.clientY - svg_canvas.offsetTop, nDelta<0?0.9:1.1);
//	alert(e.currentTarget);

	return false;
}

//___________________________________________________________________________________________________________________________________________
function SVG_zoom(svg_canvas, node, x, y, z_factor) {
	var P = svg_canvas.createSVGPoint(); P.x = x; P.y = y;
	
	P = P.matrixTransform(node.getCTM().inverse());
	
	document.getElementById('Ajax_Raw').value = 'Wheel at ' + P.x + ';' + P.y;
	
	var M = node.parentNode.getCTM().inverse().multiply(node.getCTM()).translate((1-z_factor) * P.x, (1-z_factor) * P.y).scale(z_factor);
	node.setAttribute('transform', 'matrix(' + M.a + ',' + M.b + ',' + M.c + ',' + M.d + ',' + M.e + ',' + M.f + ')');
	// node.setAttribute('transform', node.getAttribute('transform') + ' translate(' + (1-z_factor) * P.x + ', ' + (1-z_factor) * P.y + ') scale(' + z_factor + ', ' + z_factor + ')');
}

//___________________________________________________________________________________________________________________________________________
//_______________________________________________________ Coordinates converstion _______________________________________________________
//___________________________________________________________________________________________________________________________________________
function convert_coord_from_page_to_node(x,y,node) {
	var coord = new Array();													
	coord['x'] = x;                         									
	coord['y'] = y;                      										
	var current_node = node;	                      							

	while(current_node.nodeName != 'HTML' && current_node.nodeName != 'svg' && current_node.nodeName != 'svg:svg') {  
		current_node = current_node.parentNode;                      			
		}

	if(current_node.nodeName == 'svg' || current_node.nodeName != 'svg:svg') {										
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
		 while(node_root.childNodes.length > 0) {node_root.removeChild( node_root.childNodes[0] );}
		}
		
	if(add_svg_tag) {SVG_descr = '<svg xmlns="http://www.w3.org/2000/svg"  xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">' + SVG_descr + '</svg>';}
	
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
function get_first_child_typed(type, node) {
	var n = null;
	for(var i = 0; i < node.childNodes.length; i++) {
		 n = node.childNodes[i];
		 if(n.nodeName == type) {return n;}
		}
	return null;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Draw_arrow(n_poly, x1, y1, x2, y2, L, S) {
	var U = get_unitary_vector_from(x1, y1, x2, y2);
	var D = get_right_perpendicular_vector_from(U[0], U[1]);
	var G = get_left_perpendicular_vector_from (U[0], U[1]);
	var Bx = x2 - L*U[0];
	var By = y2 - L*U[1];
	
	n_poly.setAttribute('points', x2+','+y2+ ' ' + (Bx+S*G[0])+','+(By+S*G[1]) + ' ' + (Bx+S*D[0])+','+(By+S*D[1]));
}

//___________________________________________________________________________________________________________________________________________
function Update_edges(node, evt) {
	var parent_graph      = node.parentNode;
	var inverse_graph_CTM = parent_graph.getCTM().inverse();
	
	//var debug_line = document.getElementById('debug_line');
	var str = "";
	var L_edges = node.getAttribute('edges_src').split(',');
	L_edges = L_edges.concat(node.getAttribute('edges_dst').split(','));
	//document.getElementById('Ajax_Raw').innerHTML = L_edges;
	var pt_src = drag_info_obj.pt_src;
	var pt_dst = drag_info_obj.pt_dst;
	
	for(var i = 0; i < L_edges.length; i++) {
		 var e = document.getElementById(L_edges[i]);
		 if(e == null) {continue;}
		 var n_src = document.getElementById(e.getAttribute('node_src'));
			var n_src_ellipse = get_first_child_typed('ellipse', n_src);
			pt_src.x = n_src_ellipse.cx.baseVal.value; pt_src.y = n_src_ellipse.cy.baseVal.value;
			pt_src = pt_src.matrixTransform(n_src_ellipse.getCTM().multiply(inverse_graph_CTM));
			
		 var n_dst = document.getElementById(e.getAttribute('node_dst'));
			var n_dst_ellipse = get_first_child_typed('ellipse', n_dst);
			pt_dst.x = n_dst_ellipse.cx.baseVal.value; pt_dst.y = n_dst_ellipse.cy.baseVal.value;
			pt_dst = pt_dst.matrixTransform(n_dst_ellipse.getCTM().multiply(inverse_graph_CTM));
			
			//document.getElementById('Ajax_Raw').innerHTML = '(' + pt_src.x + ';' + pt_src.y + ') -> (' + pt_dst.x + ';' + pt_dst.y + ')';

		 // Compute intersections
		 var T_pt_src = get_intersections_oval_line ( pt_src.x, pt_src.y
													, n_src_ellipse.rx.baseVal.value, n_src_ellipse.ry.baseVal.value
													, pt_src.x, pt_src.y
													, pt_dst.x, pt_dst.y
													);

		 var T_pt_dst = get_intersections_oval_line ( pt_dst.x, pt_dst.y
													, n_dst_ellipse.rx.baseVal.value, n_dst_ellipse.ry.baseVal.value
													, pt_src.x, pt_src.y
													, pt_dst.x, pt_dst.y
													);
		 
		 // Draw line from embeded path inside edge element
		 var n_path = get_first_child_typed('path', e);
		 if(n_path != null) {
			 n_path.setAttribute('d', 'M '+T_pt_src+' '+T_pt_dst );
			} else {alert('no path for edge '+ L_edges[i] + ' : ' + n_path);}

		 // Draw arrow from embeded polygon inside edge element
		 var n_poly = get_first_child_typed('polygon', e);
		 if(n_poly != null) {
			 Draw_arrow(n_poly, T_pt_src[0], T_pt_src[1], T_pt_dst[0], T_pt_dst[1], 12,5);
			} else {alert('no polygon for edge '+ L_edges[i] + ' : ' + n_poly);}

 		 // debug_line.setAttribute('x1', T_pt_src[0]);
		 // debug_line.setAttribute('y1', T_pt_src[1]);
		 // debug_line.setAttribute('x2', T_pt_dst[0]);
		 // debug_line.setAttribute('y2', T_pt_dst[1]);
		 // document.getElementById('Ajax_Raw').innerHTML = T_pt_src + ' ; ' + T_pt_dst;
		}

}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Line_joining_ellipses (id_svg_canvas, id_n_root, id_e_1, id_e_2) {
	var svg_canvas = document.getElementById(id_svg_canvas);
	var n_root     = document.getElementById(id_n_root);
	var n_e_1      = document.getElementById(id_e_1);
	var n_e_2      = document.getElementById(id_e_2);

	if (svg_canvas == null || id_n_root == null || n_e_1 == null || n_e_2 == null) {return null;}
	
	return Line_joining_node_ellipses(svg_canvas, n_root, n_e_1, n_e_2);
}

//___________________________________________________________________________________________________________________________________________
function get_children_of_type_class(node, type, c) {
	var rep = new Array();
	for(var i = 0; i < node.childNodes.length; i++) {
		 var n = node.childNodes[i];
		 if(n.nodeName == type && n.getAttribute('class') == c) {rep.push(n);}
		}
	return rep;
}

//___________________________________________________________________________________________________________________________________________
function Line_joining_node_ellipses (svg_canvas, n_root, n_e_1, n_e_2) {
	// get the transformations of ellipses
	var CTM_r = n_root.getCTM(); var CTM_ri = CTM_r.inverse();
	var CTM_1 = n_e_1.getCTM (); var CTM_1i = CTM_1.inverse();
	var CTM_2 = n_e_2.getCTM (); var CTM_2i = CTM_2.inverse();
	
	// get the centers
	var C_1 = svg_canvas.createSVGPoint(); C_1.x = n_e_1.cx.baseVal.value; C_1.y = n_e_1.cy.baseVal.value;
	var C_2 = svg_canvas.createSVGPoint(); C_2.x = n_e_2.cx.baseVal.value, C_2.y = n_e_2.cy.baseVal.value;

	// Express each center with respect to the coordinate system of the other
	var C_2_in_e_1 = C_2.matrixTransform( CTM_2 ).matrixTransform( CTM_1i );
	var C_1_in_e_2 = C_1.matrixTransform( CTM_1 ).matrixTransform( CTM_2i ); 
	
	// Compute collisions
	var T1 = get_intersections_oval_line(C_1.x, C_1.y, n_e_1.rx.baseVal.value, n_e_1.ry.baseVal.value, C_1.x, C_1.y, C_2_in_e_1.x, C_2_in_e_1.y);
	var P1 = svg_canvas.createSVGPoint(); P1.x = T1[0]; P1.y = T1[1];
	P1 = P1.matrixTransform( CTM_1 ).matrixTransform( CTM_ri );
	
	var T2 = get_intersections_oval_line(C_2.x, C_2.y, n_e_2.rx.baseVal.value, n_e_2.ry.baseVal.value, C_2.x, C_2.y, C_1_in_e_2.x, C_1_in_e_2.y);
	var P2 = svg_canvas.createSVGPoint(); P2.x = T2[0]; P2.y = T2[1];
	P2 = P2.matrixTransform( CTM_2 ).matrixTransform( CTM_ri );
	
	return [P1.x, P1.y, P2.x, P2.y];
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
									 //document.getElementById('Ajax_Raw').innerHTML = (new XMLSerializer()).serializeToString(data_xml);
									 var g_graph = Load_SVG(svg_canvas.id + '_g_root', false, false, data_xml, false)[0];
									 //alert(g_graph);
									 g_graph.setAttribute('transform', g_graph.getAttribute('transform') + ' translate(50, 50)');
									 var L_nodes = new Array();
									 var L_edges = new Array();
									 for(var i = 0; i < g_graph.childNodes.length; i++) {
										 var xml_node = g_graph.childNodes[i];
										 if(xml_node.nodeName == "g" && xml_node.getAttribute('class') == "edge") {
											 L_edges.push(xml_node);
											 var T_str = xml_node.childNodes[0].childNodes[0].nodeValue.split("->"); 
											 xml_node.setAttribute('node_src', T_str[0] );
											 xml_node.setAttribute('node_dst', T_str[1] );
											 xml_node.setAttribute('class', 'edge ' + T_str[0] + ' ' + T_str[1]);
											}
										 if(xml_node.nodeName == "g" && xml_node.getAttribute('class') == "node") {
											 L_nodes.push(xml_node);
											 var node_name = xml_node.childNodes[0].childNodes[0].nodeValue;
											 xml_node.setAttribute('name', node_name );
											 //xml_node.setAttribute('class', 'node ' + node_name);
											 Draggable(xml_node.id, [xml_node.id], null, Update_edges, null);
											}
										}
									 // Link related edges for each node
									 for(var i = 0; i < L_nodes.length; i++) {
										 var node       = L_nodes[i];
										 var node_name  = node.getAttribute('name');
										 var L_edges_src = new Array();
										 var L_edges_dst = new Array();
										 for(var j = 0; j < L_edges.length; j++) {
											 var e = L_edges[j];
											 if(e.getAttribute('node_src') == node_name) {L_edges_src.push(e.id); e.setAttribute('node_src', node.id);}
											 if(e.getAttribute('node_dst') == node_name) {L_edges_dst.push(e.id); e.setAttribute('node_dst', node.id);}
											}
										 node.setAttribute('edges_src', L_edges_src.toString());
										 node.setAttribute('edges_dst', L_edges_dst.toString());
										}
										
									 //DEBUG
									 var debug_line  = document.getElementById('debug_line');
									 var parent_line = debug_line.parentNode;
									 parent_line.removeChild( debug_line );
									 parent_line.appendChild( debug_line );
									}
						, 'xml'
			   );
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function CometEditor_obj() {
	this.infos = "Object to store functions usefull for convertinf from/to SVG/HTLM....";
	this.svg_canvas = null;
	this.svg_point  = null;
}

var cometEditor_obj = new CometEditor_obj();

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Add_event_converter_SVG_to_HTML_for(node_id) {
	var node = document.getElementById( node_id );
	if(node == null) return false;
	
	// Add listeners to the node so that events coordinates are translated
	node.addEventListener('click'    , convert_coords_from_svg_to_html, true);
	node.addEventListener('mousedown', convert_coords_from_svg_to_html, true);
	node.addEventListener('mouseup'  , convert_coords_from_svg_to_html, true);
	node.addEventListener('mousemove', convert_coords_from_svg_to_html, true);
	
	return true;
}

//___________________________________________________________________________________________________________________________________________
function convert_coords_from_svg_to_html(e) {
	e.clientX = 0;
	e.clientY = 0;
	//alert('coucou ' + e.clientX);
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Add_events_blocking_bubbling(node_id) {
	var node = document.getElementById( node_id );
	if(node == null) return false;
	
	// Add listeners to the node so that events coordinates are translated
	node.addEventListener('click'    , Block_events_bubbling, false);
	node.addEventListener('mousedown', Block_events_bubbling, false);
	node.addEventListener('mouseup'  , Block_events_bubbling, false);
	node.addEventListener('mousemove', Block_events_bubbling, false);
	
	return true;
}

//___________________________________________________________________________________________________________________________________________
function Block_events_bubbling(e) {
	e.stopPropagation(); e.cancelBubble = true; e.preventDefault(); e.returnValue = false;
	return false;
}

