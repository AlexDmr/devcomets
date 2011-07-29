// Drop_zone('CPool_COMET_2_drop_circle', '*', null, null, null, null);
// Draggable('CPool_COMET_2', ['CPool_COMET_2_drag'], null, null, function(n, e) {});
// drag_info_obj.svg_rect.x = 0; drag_info_obj.svg_rect.y = 0; drag_info_obj.svg_rect.width = 1; drag_info_obj.svg_rect.height = 1;
//___________________________________________________________________________________________________________________________________________
function get_all_descendants(n) {
	var L_rep = new Array();
	var L     = new Array(n);
	var L_tmp = new Array();
	while(L.length > 0) {
		 for(var i=0; i<L.length; i++) {for(j=0; j< L[i].childNodes.length; j++) {L_tmp.push( L[i].childNodes[j] );}
									   }
		 L.splice(0, L.length); L = L.concat( L_tmp );
		 L_rep = L_rep.concat( L );
		 L_tmp.splice(0, L_tmp.length);
		}
	return L_rep;
}

//___________________________________________________________________________________________________________________________________________
function get_all_ancestors(n, limit) {
	if(limit == undefined) {limit = document;}
	var L_rep = new Array();
	p = n.parentNode;
	while(p != limit) {L_rep.push(p); p = p.parentNode;}
	return L_rep;
}

//___________________________________________________________________________________________________________________________________________
function Drag_info_obj() {
	this.infos = "Object to store functions usefull for dragging...";
	this.Tab_drag = new Array();
	this.Tab_drop = new Array();
	
	this.Tab_active_drags = new Array(); // Contains id of nodes

	this.Tab_rotozoom                 = new Array(); // Contains group id that index Objects for managing the rotozoom.
	this.Tab_rotozoom_actives_pointer = new Array(); // Contains pointer indexing groups id that can be rotozoomed
	
	this.Tab_tmp_SVG_point = new Array();
	this.tmp_matrix = null;
	
	this.pipo_event = new Object();
		this.pipo_event.info = 'Used for update';
	
	// Manage dependencies between groups (moving an ancester group implies taking care of its active group descendants)
	this.Tab_dependencies = new Array(); // Index by group id Objects of the form <array of dependant group id, function to be called to update, take group id as parameter>
	this.displayDependencies = function() {
		 for(var i in this.Tab_dependencies) { 
			 console.log(i);
			 for(var j in this.Tab_dependencies[i]) {console.log('  ' + j + ': ' + this.Tab_dependencies[i][j]);}
			}
		}
	this.addDependency = function(grp_node, fct) {
							 var id_grp = grp_node.id;
							 Obj = new Object();
							 Obj.dependOn = null;
							 Obj.Tab      = new Array();
							 Obj.fct      = fct;
							 Obj.grp_node = grp_node;
							 Obj.active   = false;
							 // Add to Tab groups that are descendants of this group id
							 var L_descendants = get_all_descendants(grp_node);
							 var L_ancestors   = get_all_ancestors  (grp_node);
							 for(var i in this.Tab_dependencies) { 
								 var n = this.Tab_dependencies[i].grp_node;
								 // Update the descendant dependencies
								 var p = this.Tab_dependencies[i].dependOn;
								 while(L_descendants.indexOf( p ) >= 0) {n = p; p = this.Tab_dependencies[n.id].dependOn;}
								 if(L_descendants.indexOf( n ) >= 0) {Obj.Tab.push(n);
																	  var old_dependOn = this.Tab_dependencies[n.id].dependOn;
																	  if(old_dependOn != null && old_dependOn != grp_node) {
																			 this.Tab_dependencies[old_dependOn.id].Tab.splice(this.Tab_dependencies[old_dependOn.id].indexOf(n), 1);
																			 this.Tab_dependencies[n.id].dependOn = grp_node;
																			}
																	 }
								 // Update the ancestor dependencies
								 if(L_ancestors.indexOf(n) >= 0) {
									 // Is there a closer ancestor in the dependencies list?
									 var closest_dependant_ancestor = null; var closest_dependant_ancestor_tmp = n;
									 while(closest_dependant_ancestor_tmp != closest_dependant_ancestor) {
										 closest_dependant_ancestor = closest_dependant_ancestor_tmp;
										 for(var j=0; j<this.Tab_dependencies[closest_dependant_ancestor.id].Tab.length; j++) {
											 if(L_ancestors.indexOf( this.Tab_dependencies[closest_dependant_ancestor.id].Tab[j].grp_node ) >= 0) {
												 closest_dependant_ancestor_tmp = this.Tab_dependencies[closest_dependant_ancestor.id].Tab[j].grp_node;
												 break;
												}
											}
										 // Update the closest ancestor and the Obj
										 Obj.dependOn = closest_dependant_ancestor;
										 this.Tab_dependencies[closest_dependant_ancestor.id].Tab.push(grp_node);
										}
									}
								}
							 
							 // Register in the Tab
							 this.Tab_dependencies[id_grp] = Obj;
							}
	this.updateDependenciesRelatedTo = function(id_grp) {
											 for(var i=0; i<this.Tab_dependencies[id_grp].Tab.length; i++) {
												 var n_dep = this.Tab_dependencies[id_grp].Tab[i];
												 var o_dep = this.Tab_dependencies[n_dep.id];
												 if(o_dep.active && o_dep.fct) {o_dep.fct(n_dep);}
												}
											}
}

var drag_info_obj = new Drag_info_obj();

//___________________________________________________________________________________________________________________________________________
//___________________________________________________ Drag nodes _____________________________________________________
//___________________________________________________________________________________________________________________________________________
function COMET_SVG_start_drag_touch_from_SVG_in_opera(event) {
	console.log('COMET_SVG_start_drag_touch_from_SVG_in_opera. target: ' + event.target + ' currentTarget: ' + event.currentTarget);
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// Call getIntersectionList to get the SVG_elements
	for(var i = 0; i < event.changedTouches.length; i++) {
		 var touch = event.changedTouches.item(i);
		 var svg_canvas = event.target; if(svg_canvas == null || svg_canvas == undefined) {alert('problem, event.target is ' + svg_canvas + '. (from COMET_SVG_new_point_for_rotozoom_touch_for_SVG_in_opera)'); return;}
		 var coord  = convert_coord_from_page_to_node(touch.pageX, touch.pageY, svg_canvas);
			 drag_info_obj.Tab_tmp_SVG_point[svg_canvas].x = coord['x'];
			 drag_info_obj.Tab_tmp_SVG_point[svg_canvas].y = coord['y'];
		 var L_svg_elements = svg_canvas.getIntersectionList(drag_info_obj.Tab_tmp_SVG_point[svg_canvas], null);
		 if(L_svg_elements.length > 0) {
			 touch.target = L_svg_elements[L_svg_elements.length - 1];
			 var currentTarget = touch.target;
				while(currentTarget != null && currentTarget.hasAttribute && !currentTarget.hasAttribute('ALX_touch')) {currentTarget = currentTarget.parentNode;}
			 if(currentTarget != null && currentTarget.hasAttribute && currentTarget.getAttribute('ALX_touch')=='COMET_SVG_start_drag_touch') {
				 Register_drag_node(currentTarget, touch.identifier, touch );
				}
			}
		}
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_start_drag_touch(event) {
	// console.log('COMET_SVG_start_drag_touch ' + event.changedTouches[0].target.getAttribute('id') );
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	var touch = event.changedTouches.item(0);
	var currentTarget = touch.target;
		while(!currentTarget.hasAttribute('ALX_touch')) {currentTarget = currentTarget.parentNode;}
		
	Register_drag_node(currentTarget, touch.identifier, touch );
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_start_drag_mouse(event) {
	if(event.button != 0) {return;}
	
	// console.log('COMET_SVG_start_drag_mouse ' + event.currentTarget.getAttribute('id') );
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	Register_drag_node(event.currentTarget, 'mouse', event );
}

//___________________________________________________________________________________________________________________________________________
function Register_drag_node(node, source, event) {
	// console.log('event drag on node: ' + node + ' source: ' + source );
	var grp_node = drag_info_obj.Tab_drag[node.id].grp_node;

	// Is the group node still being dragged ?
	for(var i in drag_info_obj.Tab_active_drags) {
		 if (drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ].grp_node == grp_node) {console.log('still dragging this node ' + node); return;}
		}
	
	// Register the node as an active dragging node
	drag_info_obj.Tab_active_drags.push( node.id );
	drag_info_obj.Tab_drag[node.id].pointer = source;
	drag_info_obj.Tab_drag[node.id].pageX = event.pageX; drag_info_obj.Tab_drag[node.id].pageY = event.pageY;
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(event.pageX, event.pageY, grp_node.parentNode);
	var x = coord['x'];
	var y = coord['y'];
	var ma_matrice = grp_node.getCTM();
	var dCTM = grp_node.parentNode.getCTM().inverse().multiply(ma_matrice);
	grp_node.setAttribute('transform', "matrix("+dCTM.a+","+dCTM.b+","+dCTM.c+","+dCTM.d+","+dCTM.e+","+dCTM.f+")");
	drag_info_obj.Tab_drag[node.id].ox = x;
	drag_info_obj.Tab_drag[node.id].oy = y;
	drag_info_obj.Tab_drag[node.id].original_CTM = grp_node.getAttribute('transform');
	
	// Trigger the related drag start function
	if(drag_info_obj.Tab_drag[node.id].fct_start != null) {drag_info_obj.Tab_drag[node.id].fct_start(grp_node, event);}
	
	// Unplug and replug on top the current node so that it is displayed above its sibling
	var parentNode = grp_node.parentNode;
	// XXX DEBUG
	// parentNode.removeChild( grp_node );
	// parentNode.appendChild( grp_node );
	
	// Manage drop zones
	drag_info_obj.Tab_drag[node.id].svg_rect         = drag_info_obj.Tab_drag[node.id].svg_canvas.createSVGRect();
	drag_info_obj.Tab_drag[node.id].svg_rect.width   = drag_info_obj.Tab_drag[node.id].svg_rect.height = 1;
	drag_info_obj.Tab_drag[node.id].pt_src 		     = drag_info_obj.Tab_drag[node.id].svg_canvas.createSVGPoint();
	drag_info_obj.Tab_drag[node.id].pt_dst 		     = drag_info_obj.Tab_drag[node.id].svg_canvas.createSVGPoint();
	drag_info_obj.Tab_drag[node.id].last_drop_zone   = null;
	drag_info_obj.Tab_drag[node.id].Tab_drop_actives = new Array();
	
	for(var i in drag_info_obj.Tab_drop) {
		 var L_nodes = $(drag_info_obj.Tab_drop[i].accept_class);
		 var contains = false;
		 for (var j=0; j < L_nodes.length; j++) {if(L_nodes[j] == grp_node) {contains = true; break;}}
		 if(contains) {
			 //Trigger the start drag function associated to the drop zone
			 var node_drop_zone = drag_info_obj.Tab_drop[i].node;
			 if (drag_info_obj.Tab_drop[i].feedback_start != null) {drag_info_obj.Tab_drop[i].feedback_start(node_drop_zone, grp_node, event);}
			 //Register the drop zone a a currently active one
			 drag_info_obj.Tab_drag[node.id].Tab_drop_actives[node_drop_zone.id] = drag_info_obj.Tab_drop[i];
			}
		}
	
	// Update dependencies
	drag_info_obj.Tab_dependencies[grp_node.id].active = true;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Manage_draggables_mouse(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// Is the mouse dragging something ?
	for(var i in drag_info_obj.Tab_active_drags) {
		 if (drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ].pointer == 'mouse') {
			 var id_node  = drag_info_obj.Tab_active_drags[i];
			 var grp_node = drag_info_obj.Tab_drag[id_node].grp_node;
			 Drag_group(drag_info_obj.Tab_drag[id_node].node, grp_node, event);
			 // and its finish
			 break;
			}
		}
}

//___________________________________________________________________________________________________________________________________________
function Manage_draggables_touch(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// console.log('event.changedTouches.length: ' + event.changedTouches.length);
	// Is the mouse dragging something ?
	for(var touch_i = 0; touch_i < event.changedTouches.length; touch_i++) {
		 var touch    = event.changedTouches.item(touch_i);
		 var touch_id = touch.identifier;
		 // console.log('  Tab_active_drags.length: ' + drag_info_obj.Tab_active_drags.length);
		 for(var i in drag_info_obj.Tab_active_drags) {
			 if (drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ].pointer == touch_id) {
				 var id_node = drag_info_obj.Tab_active_drags[i];
				 var grp_node = drag_info_obj.Tab_drag[id_node].grp_node;
				 // console.log("  let's drag with pointer " + touch_id);
				 Drag_group(drag_info_obj.Tab_drag[id_node].node, grp_node, touch );
				 // and its finish
				 break;
				}
			}
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function get_drop_zone_via_HTML(grp_node, node, x, y) {
	var p = grp_node.parentNode;
		// p.removeChild(grp_node);
		var L = Array();
		
		grp_node.setAttributeNS(null, 'pointer-events', 'none');
		
	var new_drop_zone = null;
	var current_drop_zone = document.elementFromPoint(x - window.pageXOffset, y - window.pageYOffset);
	while( current_drop_zone != null && current_drop_zone.nodeName != 'svg'
		 &&current_drop_zone.nodeName != 'svg:svg'
		 &&drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ current_drop_zone.id ] == undefined) {current_drop_zone = current_drop_zone.parentNode; if(current_drop_zone == null) {break;}}
	if(current_drop_zone != null) {
		 var drop_zone_tab = drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ current_drop_zone.id ];
		 if(drop_zone_tab != undefined && drop_zone_tab != null) {
			 new_drop_zone = current_drop_zone;
			}
		}
		// p.appendChild(grp_node);
		grp_node.setAttributeNS(null, 'pointer-events', 'all');
	// console.log('new_drop_zone: ' + new_drop_zone.id);

	return new_drop_zone;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function get_drop_zone_via_SVG(grp_node, node, x, y) {
	if(drag_info_obj.Tab_drag[node.id].svg_canvas.offsetLeft) {
		 drag_info_obj.Tab_drag[node.id].svg_rect.x = x - drag_info_obj.Tab_drag[node.id].svg_canvas.offsetLeft - 1;
		 drag_info_obj.Tab_drag[node.id].svg_rect.y = y - drag_info_obj.Tab_drag[node.id].svg_canvas.offsetTop  - 1;
		} else {drag_info_obj.Tab_drag[node.id].svg_rect.x = x - drag_info_obj.Tab_drag[node.id].svg_canvas.parentNode.offsetLeft - 1;
				drag_info_obj.Tab_drag[node.id].svg_rect.y = y - drag_info_obj.Tab_drag[node.id].svg_canvas.parentNode.offsetTop  - 1;
			   }

	var Tab_SVG_elements = drag_info_obj.Tab_drag[node.id].svg_canvas.getIntersectionList(drag_info_obj.Tab_drag[node.id].svg_rect, null);
	var new_drop_zone = null;
	if(Tab_SVG_elements != null && Tab_SVG_elements.length > 1) {
		 var current_drop_zone = Tab_SVG_elements[ Tab_SVG_elements.length - 2 ];
		 while( current_drop_zone.nodeName != 'svg'
			  &&current_drop_zone.nodeName != 'svg:svg'
			  &&drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ current_drop_zone.id ] == undefined) {current_drop_zone = current_drop_zone.parentNode;}
		 var drop_zone_tab = drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ current_drop_zone.id ];
		 if(drop_zone_tab != undefined && drop_zone_tab != null) {
			 new_drop_zone = current_drop_zone;
			}
		}
		
	return new_drop_zone;
}

//___________________________________________________________________________________________________________________________________________
function Drag_group(node, grp_node, event) {
	// console.log('Drag_group');
	// Save the last pointer values
	drag_info_obj.Tab_drag[node.id].pageX = event.pageX; drag_info_obj.Tab_drag[node.id].pageY = event.pageY;
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(event.pageX, event.pageY, grp_node.parentNode);
	var dx = coord['x'] - drag_info_obj.Tab_drag[node.id].ox; var dy = coord['y'] - drag_info_obj.Tab_drag[node.id].oy;

	grp_node.setAttribute('transform', " translate(" + dx + "," + dy + ")" + drag_info_obj.Tab_drag[node.id].original_CTM);

	// Update dependencies
	drag_info_obj.updateDependenciesRelatedTo(grp_node.id);
	
	// Callback during drag
	if(drag_info_obj.Tab_drag[node.id].fct_drag != null) {drag_info_obj.Tab_drag[node.id].fct_drag(grp_node, event);}
	
	// Managing the drop zones
	var new_drop_zone = drag_info_obj.get_drop_zone(grp_node, node, event.pageX, event.pageY);
	
	if(new_drop_zone != drag_info_obj.Tab_drag[node.id].last_drop_zone) {
		 if(drag_info_obj.Tab_drag[node.id].last_drop_zone != null) {drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ drag_info_obj.Tab_drag[node.id].last_drop_zone.id ].feedback_out(drag_info_obj.last_drop_zone_hover, grp_node, event);}
		 if(                                 new_drop_zone != null) {drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ new_drop_zone.id                      ].feedback_hover(new_drop_zone, grp_node, event);}
		 drag_info_obj.Tab_drag[node.id].last_drop_zone = new_drop_zone;
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Stop_draggables_mouse(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// Is the mouse dragging something ?
	for(var i in drag_info_obj.Tab_active_drags) {
		 if (drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ].pointer == 'mouse') {
			 var id_node = drag_info_obj.Tab_active_drags[i];
			 var grp_node = drag_info_obj.Tab_drag[id_node].grp_node;
			 Stop_draggables_pointer(drag_info_obj.Tab_drag[id_node].node, grp_node, event);
			 // and its finish
			 break;
			}
		}
}

//___________________________________________________________________________________________________________________________________________
function Stop_draggables_touch(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// console.log('Stop_draggables_touch ');
	for(var i = 0; i < event.changedTouches.length; i++) {
		 var touch    = event.changedTouches.item(i);
		 var touch_id = touch.identifier;
		 // console.log('  id: ' + touch_id);
		 for(var i in drag_info_obj.Tab_active_drags) {
			 if (drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ].pointer == touch_id) {
				 var id_node = drag_info_obj.Tab_active_drags[i];
				 var grp_node = drag_info_obj.Tab_drag[id_node].grp_node;
				 Stop_draggables_pointer(drag_info_obj.Tab_drag[id_node].node, grp_node, touch );
				 // and its finish
				 break;
				}
			}
		}
}

//___________________________________________________________________________________________________________________________________________
function Stop_draggables_pointer(node, grp_node, event) {
	// Trigger stop drag callback
	if(drag_info_obj.Tab_drag[node.id].fct_stop != null) {drag_info_obj.Tab_drag[node.id].fct_stop(grp_node, event);}
	
	// Manage drop zones
	if(drag_info_obj.Tab_drag[node.id].last_drop_zone != null) {
		 var fct = drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ drag_info_obj.Tab_drag[node.id].last_drop_zone.id ].feedback_done;
			if(fct != null) {fct(drag_info_obj.Tab_drag[node.id].last_drop_zone, grp_node, event);}
		 var fct = drag_info_obj.Tab_drag[node.id].Tab_drop_actives[ drag_info_obj.Tab_drag[node.id].last_drop_zone.id ].fct;
			if(fct != null) {fct(drag_info_obj.Tab_drag[node.id].last_drop_zone, grp_node, event);} 
		}
	// Trigger callbacks for feedback undone
	for(var i in drag_info_obj.Tab_drag[node.id].Tab_drop_actives) {
		 // console.log('? undone for '+ i + ': ' + drag_info_obj.Tab_drop_actives[i] + ' in ' + drag_info_obj.Tab_drag[node.id].last_drop_zone.id);
		 if(drag_info_obj.Tab_drop[ i ].node != drag_info_obj.Tab_drag[node.id].last_drop_zone) {
			 var fct = drag_info_obj.Tab_drop[ i ].feedback_undone;
			 if(fct) {fct(drag_info_obj.Tab_drag[node.id].Tab_drop_actives[i], grp_node, event);}
			}
		}
	
	// Manage/Clear drop zones
	drag_info_obj.Tab_drag[node.id].Tab_drop_actives = new Array();
	drag_info_obj.Tab_drag[node.id].last_drop_zone   = null;
	
	// Remove node from actives drags
	var i = drag_info_obj.Tab_active_drags.indexOf(node.id);
	drag_info_obj.Tab_active_drags.splice(i, 1);
	
	// Update dependencies
	drag_info_obj.Tab_dependencies[grp_node.id].active = false;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function init_draggable() {
	// Dragging
	document.addEventListener   ('mousemove', Manage_draggables_mouse, false);
	document.addEventListener   ('mouseup'  , Stop_draggables_mouse  , false);
	document.addEventListener   ('touchmove', Manage_draggables_touch, false);
	document.addEventListener   ('touchend' , Stop_draggables_touch  , false);
	// Rotozooming
	document.addEventListener   ('mousemove', Manage_rotozoomables_mouse, false);
	document.addEventListener   ('mouseup'  , Stop_rotozoomables_mouse  , false);
	document.addEventListener   ('touchmove', Manage_rotozoomables_touch, false);
	document.addEventListener   ('touchend' , Stop_rotozoomables_touch  , false);
}

//___________________________________________________________________________________________________________________________________________
function Draggable(id_grp, L_id_drag, fct_start, fct_drag, fct_stop) {
	var grp_node = document.getElementById( id_grp );
	if(grp_node == null) {alert('Problem initializing a drag with unknow group id ' + id_grp); return;}
	
	for(var i=0; i<L_id_drag.length; i++) {
		 var id_node = L_id_drag[i];
		 var node = document.getElementById( id_node );
		 if(node == null) {alert('Problem initializing a drag with unknow id ' + L_id_drag[i]); continue;}
		 node.setAttribute('ALX_touch', 'COMET_SVG_start_drag_touch');
		 
		 drag_info_obj.Tab_drag[id_node] = new Object();
			drag_info_obj.Tab_drag[id_node].grp_node  = grp_node; //console.log(node.getAttribute('id') + ' is associated to group ' + grp_node.getAttribute('id') );
			drag_info_obj.Tab_drag[id_node].node      = node;
			drag_info_obj.Tab_drag[id_node].fct_start = fct_start;
			drag_info_obj.Tab_drag[id_node].fct_drag  = fct_drag;
			drag_info_obj.Tab_drag[id_node].fct_stop  = fct_stop;
			drag_info_obj.Tab_drag[id_node].last_drop_zone_hover = null;
			drag_info_obj.Tab_drag[id_node].svg_canvas = get_svg_canvas_of(grp_node);
			
			var rect_svg = drag_info_obj.Tab_drag[id_node].svg_canvas.createSVGRect();
				rect_svg.width = rect_svg.height = 1;
				drag_info_obj.Tab_tmp_SVG_point[drag_info_obj.Tab_drag[id_node].svg_canvas] = rect_svg;
			if(drag_info_obj.get_drop_zone == undefined) {
				 try {drag_info_obj.Tab_drag[id_node].svg_canvas.getIntersectionList(rect_svg, null)
					  drag_info_obj.get_drop_zone = get_drop_zone_via_SVG;
					 } catch(err) {drag_info_obj.get_drop_zone = get_drop_zone_via_HTML;}
				}
			
		 // node.setAttribute('onmousedown', "COMET_SVG_start_drag('"+id_grp+"', '"+L_id_drag[i]+"', evt);" );
		 node.addEventListener('mousedown', COMET_SVG_start_drag_mouse, false);
		 node.addEventListener('touchstart' , COMET_SVG_start_drag_touch, false);
		 // In case where events are not dispatched to the SVG elements inside an SVG document, subscribe at the SVG document level:
		 drag_info_obj.Tab_drag[node.id].svg_canvas.addEventListener('touchstart', COMET_SVG_start_drag_touch_from_SVG_in_opera, false);
		}
	
	// Add dependency
	drag_info_obj.addDependency(grp_node, update_drag_group);
}

//___________________________________________________________________________________________________________________________________________
function update_drag_group(grp_node) {
	for(var i=0; i<drag_info_obj.Tab_active_drags.length; i++) {
		 var drag_obj = drag_info_obj.Tab_drag[ drag_info_obj.Tab_active_drags[i] ];
		 if(drag_obj.grp_node == grp_node) {
			 drag_info_obj.pipo_event.pageX = drag_obj.pageX; drag_info_obj.pipo_event.pageY = drag_obj.pageY;
			 drag_info_obj.pipo_event.identifier = drag_obj.pointer;
			 Drag_group(drag_obj.node, drag_obj.grp_node, drag_info_obj.pipo_event);
			 break;
			}
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function COMET_SVG_new_point_for_rotozoom_touch_for_SVG_in_opera(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	// Call getIntersectionList to get the SVG_elements
	for(var i=0; i < event.changedTouches.length; i++) {
		 var touch = event.changedTouches.item(i);
		 var svg_canvas = event.target; if(svg_canvas == null || svg_canvas == undefined) {alert('problem, event.target is ' + svg_canvas + '. (from COMET_SVG_new_point_for_rotozoom_touch_for_SVG_in_opera)'); return;}
		 var coord  = convert_coord_from_page_to_node(touch.pageX, touch.pageY, svg_canvas);
			 drag_info_obj.Tab_tmp_SVG_point[svg_canvas].x = coord['x'];
			 drag_info_obj.Tab_tmp_SVG_point[svg_canvas].y = coord['y'];
		 var L_svg_elements = svg_canvas.getIntersectionList(drag_info_obj.Tab_tmp_SVG_point[svg_canvas], null);
		 if(L_svg_elements.length > 0) {
			 touch.target = L_svg_elements[L_svg_elements.length - 1];
			 var currentTarget = touch.target;
				while(currentTarget != null && currentTarget.hasAttribute && !currentTarget.hasAttribute('ALX_touch')) {currentTarget = currentTarget.parentNode;}
			 if(currentTarget != null && currentTarget.hasAttribute && currentTarget.getAttribute('ALX_touch')=='COMET_SVG_new_point_for_rotozoom_touch') {
				 Register_new_point_for_rotozoom(currentTarget, touch.pageX, touch.pageY, touch.identifier, touch);
				}
			}
		 // console.log('Touch on SVG canvas, there is ' + L_svg_elements.length + ' below touches');
		}
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_new_point_for_rotozoom_mouse(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	Register_new_point_for_rotozoom(event.currentTarget, event.pageX, event.pageY, 'mouse', event);
}

//___________________________________________________________________________________________________________________________________________
function COMET_SVG_new_point_for_rotozoom_touch(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	for(var i = 0; i < event.changedTouches.length; i++) {
		 var touch = event.changedTouches.item(i);
		 console.log('new point for touch ' + touch.identifier);
		 Register_new_point_for_rotozoom(touch.target, touch.pageX, touch.pageY, touch.identifier, touch);
		 // Register_new_point_for_rotozoom(event.changedTouches[i].target, event.changedTouches[i].pageX, event.changedTouches[i].pageY, event.changedTouches[i].identifier, event.changedTouches[i]);
		}
}

//___________________________________________________________________________________________________________________________________________
function Register_new_point_for_rotozoom(svg_element, pageX, pageY, identifier, event) {
	console.log('Register_new_point_for_rotozoom ' + svg_element.id + ' ' + pageX + ' ' + pageY + ' ' + identifier + ' ' + event);
	// Are we in dragging mode or in rotozoom mode
	if(drag_info_obj.Tab_drag[svg_element.id]) {
		 console.log('    drag possible');
		 // At least the drag is possible, is it also ready for rotozoom?
		 var grp_node = drag_info_obj.Tab_drag[svg_element.id].grp_node;
		 if(drag_info_obj.Tab_rotozoom[grp_node.id]) {
			 // Let's see how much point are currently actives for this group
			 if(drag_info_obj.Tab_rotozoom[grp_node.id].pointer_2 != null) {console.log('Too much actives point for doing a rotozoom on group ' + grp_node.id); return;}
			 // Register the position of the point relatively to the group
			 var coords        = convert_coord_from_page_to_node(pageX, pageY, grp_node);
			 console.log('Press of pointer ' + identifier + ' on group ' + grp_node.id + ' at <' + coords['x'] + ';' + coords['y'] + '>');
			 var coords_parent = convert_coord_from_page_to_node(pageX, pageY, grp_node.parentNode);
			 
			 // Add the pointer to the list of actives pointers for the group
			 if(drag_info_obj.Tab_rotozoom[grp_node.id].pointer_1 == null) {
				 drag_info_obj.Tab_rotozoom[grp_node.id].pointer_1 = identifier;
				 drag_info_obj.Tab_rotozoom[grp_node.id].opx1      = coords['x'];
				 drag_info_obj.Tab_rotozoom[grp_node.id].opy1      = coords['y'];
				 drag_info_obj.Tab_rotozoom[grp_node.id].x1        = coords_parent['x'];
				 drag_info_obj.Tab_rotozoom[grp_node.id].y1        = coords_parent['y'];
				 drag_info_obj.Tab_rotozoom[grp_node.id].pageX1    = pageX;
				 drag_info_obj.Tab_rotozoom[grp_node.id].pageY1    = pageY;
				 drag_info_obj.Tab_rotozoom[grp_node.id].target1   = svg_element;
				 Register_drag_node(svg_element, identifier, event); 
				} else  {drag_info_obj.Tab_rotozoom[grp_node.id].pointer_2 = identifier;
						 drag_info_obj.Tab_rotozoom[grp_node.id].opx2      = coords['x'];
						 drag_info_obj.Tab_rotozoom[grp_node.id].opy2      = coords['y'];
						 drag_info_obj.Tab_rotozoom[grp_node.id].x2        = coords_parent['x'];
						 drag_info_obj.Tab_rotozoom[grp_node.id].y2        = coords_parent['y'];
						 drag_info_obj.Tab_rotozoom[grp_node.id].pageX2    = pageX;
						 drag_info_obj.Tab_rotozoom[grp_node.id].pageY2    = pageY;
						 drag_info_obj.Tab_rotozoom[grp_node.id].delta_ox  = drag_info_obj.Tab_rotozoom[grp_node.id].opx2 - drag_info_obj.Tab_rotozoom[grp_node.id].opx1;
						 drag_info_obj.Tab_rotozoom[grp_node.id].delta_oy  = drag_info_obj.Tab_rotozoom[grp_node.id].opy2 - drag_info_obj.Tab_rotozoom[grp_node.id].opy1;
						 drag_info_obj.Tab_rotozoom[grp_node.id].target2   = svg_element;
						 
						 // Stop dragging pointer_1 : drag_info_obj.Tab_active_drags
						 var i = drag_info_obj.Tab_active_drags.indexOf(drag_info_obj.Tab_rotozoom[grp_node.id].target1.id);
						 console.log('position of the rotozoom pointer in Tab_active_drag is ' + i);
						 drag_info_obj.Tab_active_drags.splice(i, 1);
						}
			 drag_info_obj.Tab_rotozoom_actives_pointer[identifier] = grp_node.id;
			}
			
		 // Update dependencies
		 drag_info_obj.Tab_dependencies[grp_node.id].active = true;
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Manage_rotozoomables_mouse(event) {
	// console.log('Manage_rotozoomables_mouse');
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	if(drag_info_obj.Tab_rotozoom_actives_pointer['mouse']) {
		 var id_grp = drag_info_obj.Tab_rotozoom_actives_pointer['mouse'];
		 var target = null;
		 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_1 == 'mouse') {target = drag_info_obj.Tab_rotozoom[id_grp].target1;}
		 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_2 == 'mouse') {target = drag_info_obj.Tab_rotozoom[id_grp].target2;}
		 if(target == null) {
			 alert('on a un soucis avec le rotozoom sur ' + id_grp + ', la souris est hors jeu...');
			}
		 Manage_rotozoomables_pointer('mouse', event);
		}
}

//___________________________________________________________________________________________________________________________________________
function Manage_rotozoomables_touch(event) {
	event.stopPropagation(); event.cancelBubble = true; event.preventDefault(); event.returnValue = false;
	for(var i = 0; i < event.changedTouches.length; i++) {
		 var touch = event.changedTouches.item(i);
		 // var currentTarget = touch.target;
			// while(currentTarget != null && currentTarget.hasAttribute && !currentTarget.hasAttribute('ALX_touch')) {currentTarget = currentTarget.parentNode;}
		 Manage_rotozoomables_pointer(touch.identifier, touch);
		}
}

//___________________________________________________________________________________________________________________________________________
function Manage_rotozoomables_pointer(identifier, event) {
	if(drag_info_obj.Tab_rotozoom_actives_pointer[identifier]) {
		  // console.log('Manage_rotozoomables_pointer');
		  var id_grp   = drag_info_obj.Tab_rotozoom_actives_pointer[identifier];
		  var grp_node = drag_info_obj.Tab_rotozoom[id_grp].grp_node;
		  Manage_rotozoomables(grp_node, id_grp, identifier, event);
		 }
}

//___________________________________________________________________________________________________________________________________________
function Manage_rotozoomables(grp_node, id_grp, identifier, event) {
	// console.log('Manage_rotozoomables(' + grp_node.id + ', ' + identifier + ', ' + event);
		 if(drag_info_obj.Tab_rotozoom[id_grp]) {
			 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_1 == null) {console.log('  Problem with rotozoom on group ' + id_grp + ' which should normally be disabled');} else {
				  if(identifier != 'PIPO') {
					  var coords = convert_coord_from_page_to_node(event.pageX, event.pageY, grp_node.parentNode);
					  if(identifier == drag_info_obj.Tab_rotozoom[id_grp].pointer_1) {
						 drag_info_obj.Tab_rotozoom[id_grp].pageX1 = event.pageX;
						 drag_info_obj.Tab_rotozoom[id_grp].pageY1 = event.pageY;
						 drag_info_obj.Tab_rotozoom[id_grp].x1     = coords['x'];
						 drag_info_obj.Tab_rotozoom[id_grp].y1     = coords['y'];
						} else {if(identifier == drag_info_obj.Tab_rotozoom[id_grp].pointer_2) {
									drag_info_obj.Tab_rotozoom[id_grp].pageX2 = event.pageX;
									drag_info_obj.Tab_rotozoom[id_grp].pageY2 = event.pageY;
									drag_info_obj.Tab_rotozoom[id_grp].x2     = coords['x'];
									drag_info_obj.Tab_rotozoom[id_grp].y2     = coords['y'];
									}
							   }
					   } else {// Re generate the local coords
							   if(drag_info_obj.Tab_rotozoom[id_grp].pointer_1 != null) {
									 var coords = convert_coord_from_page_to_node(drag_info_obj.Tab_rotozoom[id_grp].pageX1, drag_info_obj.Tab_rotozoom[id_grp].pageY1, grp_node.parentNode);
									 drag_info_obj.Tab_rotozoom[id_grp].x1     = coords['x'];
									 drag_info_obj.Tab_rotozoom[id_grp].y1     = coords['y'];
									}
							   if(drag_info_obj.Tab_rotozoom[id_grp].pointer_2 != null) {
									 var coords = convert_coord_from_page_to_node(drag_info_obj.Tab_rotozoom[id_grp].pageX2, drag_info_obj.Tab_rotozoom[id_grp].pageY2, grp_node.parentNode);
									 drag_info_obj.Tab_rotozoom[id_grp].x2     = coords['x'];
									 drag_info_obj.Tab_rotozoom[id_grp].y2     = coords['y'];
									}
							  }
				  if(drag_info_obj.Tab_rotozoom[id_grp].pointer_2 == null) {
					} else  {
							 // console.log('  Rotozooming group ' + id_grp + ' with pointers ' + drag_info_obj.Tab_rotozoom[id_grp].pointer_1 + ' and ' + drag_info_obj.Tab_rotozoom[id_grp].pointer_2);
							 var delta_ox = drag_info_obj.Tab_rotozoom[id_grp].delta_ox;
							 var delta_oy = drag_info_obj.Tab_rotozoom[id_grp].delta_oy;
							 var delta_x  = drag_info_obj.Tab_rotozoom[id_grp].x2 - drag_info_obj.Tab_rotozoom[id_grp].x1;
							 var delta_y  = drag_info_obj.Tab_rotozoom[id_grp].y2 - drag_info_obj.Tab_rotozoom[id_grp].y1;
							 
							 var Esin = (delta_oy*delta_x - delta_ox*delta_y) 
							          / (Math.pow(delta_ox,2) + Math.pow(delta_oy,2));
							 var Ecos = 0;
							 if(delta_ox == 0) {Ecos = delta_y/delta_oy;} else {Ecos = (delta_x - delta_oy*Esin) / delta_ox;}
							 
							 var DX = drag_info_obj.Tab_rotozoom[id_grp].x1 - Ecos*drag_info_obj.Tab_rotozoom[id_grp].opx1 - Esin*drag_info_obj.Tab_rotozoom[id_grp].opy1;
							 var DY = drag_info_obj.Tab_rotozoom[id_grp].y1 + Esin*drag_info_obj.Tab_rotozoom[id_grp].opx1 - Ecos*drag_info_obj.Tab_rotozoom[id_grp].opy1;
							 
							 var M = 'matrix('+Ecos+','+(-Esin)+','+Esin+','+Ecos+','+DX+','+DY+')';
							 // console.log(M);
							 grp_node.setAttribute('transform', M);
							}
							
				  // Update dependencies
				  drag_info_obj.updateDependenciesRelatedTo(grp_node.id);
				 }
			} else {console.log('nop for group ' + id_grp + ' with pointer ' + identifier);}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Stop_rotozoomables_mouse(event) {
	Stop_rotozoomables_pointer('mouse');
}

//___________________________________________________________________________________________________________________________________________
function Stop_rotozoomables_touch(event) {
	for(var i = 0; i < event.changedTouches.length; i++) {
		 var touch = event.changedTouches.item(i);
		 Stop_rotozoomables_pointer(touch.identifier);
		}
}

//___________________________________________________________________________________________________________________________________________
function Stop_rotozoomables_pointer(identifier) {
	if(drag_info_obj.Tab_rotozoom_actives_pointer[identifier]) {
		 console.log('Stop Rotozoom with ' + identifier);
		 var id_grp = drag_info_obj.Tab_rotozoom_actives_pointer[identifier]; delete drag_info_obj.Tab_rotozoom_actives_pointer[identifier];
		 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_1 == identifier) {
			 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_2 != null) {
				 drag_info_obj.Tab_rotozoom[id_grp].pipo_event.target = drag_info_obj.Tab_rotozoom[id_grp].target2;
				 drag_info_obj.Tab_rotozoom[id_grp].pipo_event.pageX  = drag_info_obj.Tab_rotozoom[id_grp].pageX2;
				 drag_info_obj.Tab_rotozoom[id_grp].pipo_event.pageY  = drag_info_obj.Tab_rotozoom[id_grp].pageY2;
				 Register_drag_node(drag_info_obj.Tab_rotozoom[id_grp].pipo_event.target, drag_info_obj.Tab_rotozoom[id_grp].pointer_2, drag_info_obj.Tab_rotozoom[id_grp].pipo_event);
				}
			 drag_info_obj.Tab_rotozoom[id_grp].pointer_1 = drag_info_obj.Tab_rotozoom[id_grp].pointer_2;
			 drag_info_obj.Tab_rotozoom[id_grp].pointer_2 = null;
			 drag_info_obj.Tab_rotozoom[id_grp].opx1      = drag_info_obj.Tab_rotozoom[id_grp].opx2;
			 drag_info_obj.Tab_rotozoom[id_grp].opy1      = drag_info_obj.Tab_rotozoom[id_grp].opy2;
			 drag_info_obj.Tab_rotozoom[id_grp].x1        = drag_info_obj.Tab_rotozoom[id_grp].x2;
			 drag_info_obj.Tab_rotozoom[id_grp].y1        = drag_info_obj.Tab_rotozoom[id_grp].y2;
			 drag_info_obj.Tab_rotozoom[id_grp].target1   = drag_info_obj.Tab_rotozoom[id_grp].target2;
			 drag_info_obj.Tab_rotozoom[id_grp].pageX1    = drag_info_obj.Tab_rotozoom[id_grp].pageX2;
			 drag_info_obj.Tab_rotozoom[id_grp].pageY1    = drag_info_obj.Tab_rotozoom[id_grp].pageX2;
			 
			 if(drag_info_obj.Tab_rotozoom[id_grp].pointer_1 == null) {
				 // Update dependencies
				 drag_info_obj.Tab_dependencies[id_grp].active = false;
				}
			} else {drag_info_obj.Tab_rotozoom[id_grp].pointer_2 = null;
					drag_info_obj.Tab_rotozoom[id_grp].pipo_event.target = drag_info_obj.Tab_rotozoom[id_grp].target1;
					drag_info_obj.Tab_rotozoom[id_grp].pipo_event.pageX  = drag_info_obj.Tab_rotozoom[id_grp].pageX1;
					drag_info_obj.Tab_rotozoom[id_grp].pipo_event.pageY  = drag_info_obj.Tab_rotozoom[id_grp].pageY1;
				    Register_drag_node(drag_info_obj.Tab_rotozoom[id_grp].pipo_event.target, drag_info_obj.Tab_rotozoom[id_grp].pointer_1, drag_info_obj.Tab_rotozoom[id_grp].pipo_event);
				   }
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function RotoZoomable(id_grp, L_id_actives, fct_start, fct_drag, fct_start_rotozoom, fct_rotozoom, fct_stop_rotozoom, fct_stop) {
	var grp_node = document.getElementById( id_grp );
	drag_info_obj.Tab_rotozoom[id_grp] = new Object(); // Array of point identifier currently actives for the group
		drag_info_obj.Tab_rotozoom[id_grp].pointer_1  = null;
		drag_info_obj.Tab_rotozoom[id_grp].pointer_2  = null;
		drag_info_obj.Tab_rotozoom[id_grp].pipo_event = new Object();
		drag_info_obj.Tab_rotozoom[id_grp].grp_node   = grp_node;
		
	if(grp_node == null) {alert('Problem initializing a drag with unknow group id ' + id_grp); return;}
	
	for(var i=0; i<L_id_actives.length; i++) {
		 var id_node = L_id_actives[i];
		 var node = document.getElementById( id_node );
		 if(node == null) {alert('Problem initializing a drag with unknow id ' + L_id_actives[i]); continue;}
		 node.setAttribute('ALX_touch', 'COMET_SVG_new_point_for_rotozoom_touch');
		 
		 drag_info_obj.Tab_drag[id_node] = new Object();
			drag_info_obj.Tab_drag[id_node].grp_node  = grp_node; //console.log(node.getAttribute('id') + ' is associated to group ' + grp_node.getAttribute('id') );
			drag_info_obj.Tab_drag[id_node].node      = node;
			drag_info_obj.Tab_drag[id_node].fct_start = fct_start;
			drag_info_obj.Tab_drag[id_node].fct_drag  = fct_drag;
			drag_info_obj.Tab_drag[id_node].fct_stop  = fct_stop;
			
			drag_info_obj.Tab_drag[id_node].fct_start_rotozoom = fct_start_rotozoom;
			drag_info_obj.Tab_drag[id_node].fct_rotozoom       = fct_rotozoom;
			drag_info_obj.Tab_drag[id_node].fct_stop_rotozoom  = fct_stop_rotozoom;
			
			drag_info_obj.Tab_drag[id_node].last_drop_zone_hover = null;
			drag_info_obj.Tab_drag[id_node].svg_canvas = get_svg_canvas_of(grp_node);
			
			var rect_svg = drag_info_obj.Tab_drag[id_node].svg_canvas.createSVGRect();
				rect_svg.width = rect_svg.height = 1;
				drag_info_obj.Tab_tmp_SVG_point[drag_info_obj.Tab_drag[id_node].svg_canvas] = rect_svg;
			if(drag_info_obj.get_drop_zone == undefined) {
				 try {drag_info_obj.Tab_drag[id_node].svg_canvas.getIntersectionList(rect_svg, null)
					  drag_info_obj.get_drop_zone = get_drop_zone_via_SVG;
					 } catch(err) {drag_info_obj.get_drop_zone = get_drop_zone_via_HTML;}
				}
			
		 node.addEventListener('mousedown'  , COMET_SVG_new_point_for_rotozoom_mouse, false);
		 node.addEventListener('touchstart' , COMET_SVG_new_point_for_rotozoom_touch, false);
		 // In case where events are not dispatched to the SVG elements inside an SVG document, subscribe at the SVG document level:
		 drag_info_obj.Tab_drag[node.id].svg_canvas.addEventListener('touchstart', COMET_SVG_new_point_for_rotozoom_touch_for_SVG_in_opera, false);
		}
		
	// Update the dependencies
	drag_info_obj.addDependency(grp_node, update_rotozoom_group);
}

//___________________________________________________________________________________________________________________________________________
function update_rotozoom_group(grp_node) {
	for(var i in drag_info_obj.Tab_rotozoom_actives_pointer) {
		 var rotozoom_obj = drag_info_obj.Tab_rotozoom[ drag_info_obj.Tab_rotozoom_actives_pointer[i] ];
		 if(rotozoom_obj.grp_node == grp_node) {
			 // console.log('Manage_rotozoomables ' + grp_node.id);
			 if(rotozoom_obj.pointer_2 == null) {
				 update_drag_group(grp_node);
				} else {Manage_rotozoomables(grp_node, grp_node.id, 'PIPO', drag_info_obj.pipo_event);}
			 
			 break;
			}
		}
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Drop_zone(id_node, accept_class, feedback_start, feedback_hover, feedback_out, feedback_done, feedback_undone, fct) {
	var node  = document.getElementById(id_node);
	if(node == null) {alert('Problem initializing a drop zone with unknow id ' + id_node); return;}
	
	drag_info_obj.Tab_drop[id_node] = new Object();
		drag_info_obj.Tab_drop[id_node].node            = node;
		drag_info_obj.Tab_drop[id_node].accept_class    = accept_class;
		drag_info_obj.Tab_drop[id_node].feedback_start  = feedback_start;
		drag_info_obj.Tab_drop[id_node].feedback_hover  = feedback_hover;
		drag_info_obj.Tab_drop[id_node].feedback_out    = feedback_out;
		drag_info_obj.Tab_drop[id_node].feedback_done   = feedback_done;
		drag_info_obj.Tab_drop[id_node].feedback_undone = feedback_undone;
		drag_info_obj.Tab_drop[id_node].fct             = fct;
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
			// Update the dependencies
			drag_info_obj.addDependency(node, null);
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
	SVG_zoom(svg_canvas, e.currentTarget, window.pageXOffset + e.clientX - svg_canvas.parentNode.offsetLeft, window.pageYOffset + e.clientY - svg_canvas.parentNode.offsetTop, nDelta<0?0.9:1.1);
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
	
	// Update dependencies
	drag_info_obj.updateDependenciesRelatedTo(node.id);
}

//___________________________________________________________________________________________________________________________________________
//_______________________________________________________ Coordinates converstion _______________________________________________________
//___________________________________________________________________________________________________________________________________________
function convert_coord_from_page_to_node(x,y,node) {
	var coord = new Array();													
	coord['x'] = x;                         									
	coord['y'] = y;                      										
	var current_node = node;	                      							
		
	while(current_node.nodeName != 'HTML' && current_node.nodeName != 'html' && current_node.nodeName != 'svg' && current_node.nodeName != 'svg:svg') {  
		 current_node = current_node.parentNode;                      			
		}

	if(current_node.nodeName == 'svg' || current_node.nodeName != 'svg:svg') {
		// console.log('current_node: ' + current_node.getAttribute('id') );
		if(current_node.offsetLeft) {
			 coord['x'] -= current_node.offsetLeft;
			 coord['y'] -= current_node.offsetTop;
			} else  {coord['x'] -= current_node.parentNode.offsetLeft;
					 coord['y'] -= current_node.parentNode.offsetTop;
					}
		
		if(drag_info_obj.tmp_matrix == null) {
			 drag_info_obj.tmp_matrix = current_node.createSVGMatrix();
			}

		// console.log('matrice e: ' + coord['x'] + ' f:' + coord['y']);
		drag_info_obj.tmp_matrix.a = 1; drag_info_obj.tmp_matrix.b = 0;
		drag_info_obj.tmp_matrix.c = 0; drag_info_obj.tmp_matrix.d = 1;
		drag_info_obj.tmp_matrix.e = coord['x'];
		drag_info_obj.tmp_matrix.f = coord['y'];
		if(node.getCTM) {
			 var matriceres = node.getCTM().inverse().multiply( drag_info_obj.tmp_matrix );			
			 coord['x'] = matriceres.e;											
			 coord['y'] = matriceres.f;
			} else {alert('What is this node: ' + node + ' id is ' + node.id);}
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
function Clear_descendants_of(node) {
	while(node.childNodes.length > 0) {node.removeChild( node.childNodes[0] );}
}

//___________________________________________________________________________________________________________________________________________
//_____________________________________________________ Load SVG description ______________________________________________________
//___________________________________________________________________________________________________________________________________________
function Load_SVG(id_root, clear_descendants, add_svg_tag, SVG_descr, is_string) {
	var node_root = document.getElementById(id_root);
	if (node_root == null) {alert("There is no root node to plug SVG:\n\tid_root : " + id_root + "\n\tSVG : " + SVG_str); return;}
	
	if(clear_descendants) {
		 Clear_descendants_of(node_root);
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

	if (svg_canvas == null || id_n_root == null || n_e_1 == null || n_e_2 == null) {console.log('Line_joining_ellipses problem, someone is null'); return null;} //else {console.log('Line_joining_ellipses OK');}
	
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

