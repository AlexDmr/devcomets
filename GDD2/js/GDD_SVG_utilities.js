function Display_node(node_url, svg_canvas, svg_container_node) {
	$.post(node_url, {}, function (data_xml) {
							 for(var i = 0; i < data_xml.childNodes.length; i++) {
								 var node = data_xml.childNodes[i];
								 if(node.nodeName == "document") {
									 // Display documents
									 if(node.getAttribute('type') == 'image') {
										 // Create a SVG image under svg_container_node, load it with href...
										 
										}
									}
								 if(node.nodeName == "annotation") {
									 // Display documents
									}
								}
							}
				, 'xml'
	   );
}
