function COMET_SVG_start_drag(id_grp, id_drag, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unlknow id ' + id_grp); return;}
	
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
	document.body.setAttribute('onmousemove', "COMET_SVG_drag     ('"+id_grp+"', '"+id_drag+"', '" + node_grp.getAttribute('transform') + "', " + x + ", " + y + ", evt);" );
	document.body.setAttribute('onmouseup'  , "COMET_SVG_stop_drag('"+id_grp+"', '"+id_drag+"', evt);" );
}

function COMET_SVG_drag      (id_grp, id_drag, dCTM, dsx, dsy, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unlknow id ' + id_grp); return;}
	
	// Express the current transformation of the node on the form of a Matrix
	var coord  = convert_coord_from_page_to_node(evt.pageX, evt.pageY, node_grp.parentNode);
	var dx = coord['x'] - dsx; var dy = coord['y'] - dsy;
	
	node_grp.setAttribute('transform', dCTM + " translate(" + dx + "," + dy + ")");  
}


function COMET_SVG_stop_drag (id_grp, id_drag, evt) {
	var node_grp  = document.getElementById(id_grp);
	if(node_grp == null) {alert('Problem starting a drag with unlknow id ' + id_grp); return;}
	
	document.body.setAttribute('onmousemove', node_grp.getAttribute('html_onmousemove_save') );
	document.body.setAttribute('onmouseup'  , node_grp.getAttribute('html_onmouseup_save')   );
	node_grp.setAttribute('html_onmousemove_save', '' );
	node_grp.setAttribute('html_onmouseup_save'  , '' );
}



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

 

function set_svg_origine(id,x,y) {											
	var node = document.getElementById(id);									
	if(node != null) {														
		var nCTM = node.parentNode.getCTM().inverse().multiply(node.getCTM()); 
		nCTM.e = x;																
		nCTM.f = y;																
		node.setAttribute('transform', 'matrix('+nCTM.a+','+nCTM.b+','+nCTM.c+','+nCTM.d+','+nCTM.e+','+nCTM.f+')'); 
		}																		
}																			