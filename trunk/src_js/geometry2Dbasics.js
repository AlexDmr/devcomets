//___________________________________________________________________________________________________________________________________________
//__________________________________________________________ Geometry 2D basics _____________________________________________________________
//___________________________________________________________________________________________________________________________________________
function Eq_second_degre(a, b, c) {
	var rep = new Array();
	var delta = b*b - 4*a*c; 
	if(delta  < 0) {alert('delta = ' + delta);}
	if(delta == 0) {rep.push(-b/(2*a));}
	if(delta  > 0) {
		 var d = Math.sqrt(delta);
		 rep.push((-b -d)/(2*a), (-b + d)/(2*a));
		 //alert('rep = ' + rep);
		}

	return rep;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function get_intersections_oval_line (cx, cy, rx, ry, x1, y1, x2, y2) {
	// Easy cases where there is no intersection
	if( x1 > cx+rx && x2 > cx + rx
	  ||x1 < cx-rx && x2 < cx - rx
	  ||y1 > cy+ry && y2 > cy + ry
	  ||y1 < cy-ry && y2 < cy - ry) {return [];}

	// There may be some intersections ...
	var rep = new Array();
	var RX = rx*rx;
	var RY = ry*ry;
	
	// Easy intersections with axe parrallele line
	if(x1 == x2) {
		 var alpha = (x1 - cx)*(x1 - cx)/RX;
		 var T_rep = Eq_second_degre( 1
									, -2*cy
									, cy*cy + (alpha - 1)*RY
									);
		 for(var i = 0; i < T_rep.length; i++) {
			 if(T_rep[i] >= Math.min(y1, y2) && T_rep[i] <= Math.max(y1, y2)) {rep.push(x1, T_rep[i]);}
			}
		}

	if(y1 == y2) {
		 var alpha = (y1 - cy)*(y1 - cy)/RY;
		 var T_rep = Eq_second_degre( 1
									, -2*cx
									, cx*cx + (alpha - 1)*RX
									);
		 for(var i = 0; i < T_rep.length; i++) {
			 if(T_rep[i] >= Math.min(x1, x2) && T_rep[i] <= Math.max(x1, x2)) {rep.push(T_rep[i], y1);}
			}
		}
		
	// General case where the line can be expressed as y = ...
	if(x1!=x2 && y1!=y2) {
		 var X = x2-x1; //Math.abs(x2-x1);
		 var Y = y2-y1; //Math.abs(y2-y1);
		 var beta = x1 - cx - y1*X/Y;
		 // Get the y-axis values
		 var T_rep = Eq_second_degre( X*X*RY/(Y*Y) + RX
									, -2*cy*RX + 2*X*beta*RY/Y
									, beta*beta*RY + cy*cy*RX - RX*RY
									);
		 for(var i = 0; i < T_rep.length; i++) {
			 if(T_rep[i] >= Math.min(y1, y2) && T_rep[i] <= Math.max(y1, y2)) {
				 rep.push((T_rep[i] - y1)*X/Y + x1, T_rep[i]);
				}
			}
		}
		
	// return the results as a list of coordinate <x, y, x, y, ...>
	return rep;
}

//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
//___________________________________________________________________________________________________________________________________________
function get_unitary_vector_from(x1, y1, x2, y2) {
	var X = x2-x1;
	var Y = y2-y1;
	var D = Math.sqrt(X*X + Y*Y);
	return new Array(X/D, Y/D);
}

//___________________________________________________________________________________________________________________________________________
function get_right_perpendicular_vector_from(x, y) {
	return new Array(y, -x);
}

//___________________________________________________________________________________________________________________________________________
function get_left_perpendicular_vector_from(x, y) {
	return new Array(-y, x);
}
