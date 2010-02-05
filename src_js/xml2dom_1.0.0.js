/**
 * Klasse: XML2DOM
 * Beschreibung:
 *    Erzeugt aus einer XML-Zeichenkette ein DOM-Objekt.
 * Beispielnutzung:
 *    xml2dom.createDomBy(xmlString, domNodeId);
 *
 * Geschrieben von Aurelian Hermand (xml2dom@devone.de)
 * Herzlichen Dank geht an e-voc aus #javascript.de im Quakenet
 *
 * Version 1.0.0 (28.08.2006 2:44Uhr)
 */
 
var xml2dom = new function()
{
	this.xmlString = ''; // XML-Zeichenkette
	this.domNodeId = ''; // DOM-ID


	// Initialisierung
    this.load = function()
    {
    }
   
    // Erstellen der DOM Struktur aus der XML Zeichenkette
    this.createDom = function()
    {
		this.createDomBy(this.xmlString, this.domNodeId);
    }
    
    // Erstellen des DOMs per ID
    this.createDomById = function(domid)
    {
    	this.domNodeId = domid;
    	this.createDomBy(this.xmlString, this.domNodeId);
    }
    
    // Erstellen des DOMs per String
    this.createDomByString = function(xmlstr)
    {
    	this.xmlString = xmlstr;
    	this.createDomBy(this.xmlString, this.domNodeId);
    }
    
    // Erstellen des DOMs per String und ID
    this.createDomBy = function(xmlstr, domid)
    {
    	this.xmlString = xmlstr;
    	this.domNodeId = domid;
    	
		// Aufteilung in Tags und Text
		var arr = new Array();
		var whres = this.xmlString;
		var xsplit = "";
		var i = 0;
		var xopen = 0;
			
		while((xopen = whres.indexOf("<"))==0 || (xopen = whres.indexOf("<"))!=-1) {
			if(xopen==-1) {break;}
			if(xopen!=0) {
				arr[i] = whres.substr(0, xopen);
				i=i+1;
				whres.substr(xopen, whres.length-xopen);
			}
			
			xclose = whres.indexOf(">"); // Position des Schliessen Tag
			xsplit = whres.substr(xopen, xclose-xopen+1); // Elementinhalt mit < und >
			whres = whres.substr(xclose+1, whres.length-xclose-1); // Rest
			arr[i] = xsplit;

			i++;
		}
		if(whres!="") {
			arr[i] = whres;
		}
			
			
		// DOM Erstellung innerhalb des vorgegebenen Elementes
		var domobj = new Object();
		domobj = document.getElementById(this.domNodeId); // Element wo alles rein soll
		domobj = this.rekCreateDom(arr, domobj); // Elementarray, Position, ElemObj

    }
    
    // Rekursive Erstellung der DOM Elemente und Textknoten
    this.rekCreateDom = function(arr, elem)
    {
    	if(arr.length<=0) { // Rekursion beenden
    		return elem;
    	}

    	if(this.isText(arr[0])==true) { // Textknoten
    		txt = document.createTextNode(arr[0]);
    		elem.appendChild(txt);
    		restarr = new Array();b=0;for(i=1;i<arr.length;i++){restarr[b] = arr[i];b++;}
    		if(restarr.length==0) {return elem;}
    		elem = this.rekCreateDom(restarr, elem);
    		return elem;
    	}
    	else if(this.isSingleTag(arr[0])==true) { // isSingleTag
    		tag = this.getTagName(arr[0]);
    		newtag = document.createElement(tag);
			singelem = elem.appendChild(newtag);
			this.createAttributes(singelem, arr[0]);
			restarr = new Array();b=0;for(i=1;i<arr.length;i++){restarr[b] = arr[i];b++;}
    		if(restarr.length==0) {return elem;}
    		elem = this.rekCreateDom(restarr, elem);
			return elem;
    	}
    	else { // Start und Endtag rekursiv erstellen
    		tag = this.getTagName(arr[0]);
    		newtag = document.createElement(tag);
			multelem = elem.appendChild(newtag);
			this.createAttributes(multelem, arr[0]);
			
			// Endtag zum Starttag finden
			endTagPosition = this.getEndTagFromStartTag(arr, 0); // endTagPosition

			// Ermitteln des Array Inhalts für den Rek.-Aufr. und fuer den Rest
			var rekarr = new Array();
			a=0;for(i=1;i<endTagPosition;i++) {rekarr[a] = arr[i];a++;}
			var restarr = new Array();
			a=0;for(i=endTagPosition+1;i<arr.length;i++) {restarr[a] = arr[i];a++;}

			if(rekarr.length>0) {
				this.rekCreateDom(rekarr, multelem); // Innereien erstellen. Muss nichts zurückgeben -> Rekursion
			}

			if(restarr.length>0) {
				elem = this.rekCreateDom(restarr, elem); // Weitere Elemente danach hinzufügen
			}

			return elem;
    	}

    }
    
    // Ermitteln des EndTag anhand des Starttags
    this.getEndTagFromStartTag = function(arr, startTagPosition)
    {
    	var startTagPosition = startTagPosition;
    	var endTagPosition = 0;
    	
		var counter = 0; // Durchläufe bis zum richtigen Endtag
		var start = 0;
		var end = 0;
		for(var i=start; i<arr.length; i++) {
			counter++;
			if(this.isText(arr[i])==false) {
				if(this.isSingleTag(arr[i])) {} // isSingleTag
				else if(this.isEndTag(arr[i])==false) {start = start+1;}
				else if(this.isEndTag(arr[i])==true) {end = end+1;if(start==end){break;}}
			}

		}
    
    	endTagPosition = counter-1;
    	return endTagPosition;
    }
    
    // Überprüfen ob es ein Text ist
    this.isText = function(txtortag)
    {
    	if(txtortag.slice(0, 1)!="<") return true;
    	return false;
    }
    
    // Überprüfen ob es ein einzelnes Element ist, wie <img />
    this.isSingleTag = function(tag)
    {
    	if(tag.slice(0, 1)=="<" && tag[tag.length-2]=="/") return true;
    	return false;
    }
    
    // Überprüfen ob es ein einzelnes Element ist, wie <img />
    this.isEndTag = function(tag)
    {
    	if(tag.slice(0, 1)=="<" && tag[1]=="/") return true;
    	return false;
    }
    
    // Erstellen der Attributen
    this.createAttributes = function(obj, tag)
    {
    	tagName = this.getTagName(tag);
    	isST = this.isSingleTag(tag);
    	
    	// Attribute ausschneiden aus dem Tag
    	rest = tag;
    	rest = rest.substr(tagName.length+1, rest.length-tagName.length-1);
    	if(this.isSingleTag(tag)==true) { // isSingleTag
    		rest = rest.substr(0, rest.length-2);
    	}
    	else {
    		rest = rest.substr(0, rest.length-1);
    	}
    	attrString = this.trim(rest);
    	
    	if(attrString=="") return false;
    	
    	// Attributname und -werte in ein Array legen
    	var arr = new Array();
    	var rest = attrString;
    	var i = 0;
    	while(attr = rest.indexOf('=')) {
			if(attr==-1) { // Kein Attribut vorhanden
				break;
			}
			if(attr!=0) {
				attrname = rest.substr(0, attr); 					// AttrName ausschneiden
				attrname = this.trim(attrname); 					// AttrName trimmen
				rest = rest.substr(attr+1, rest.length-attr-1); 	// Rest ermitteln
				rest = this.trim(rest); 							// Rest trimmen
				val1 = rest.indexOf('"'); 							// 1. Anführungszeichen
				rest = rest.substr(val1+1, rest.length-val1-1); 	// Rest ermitteln ab 1. Anführungszeichen 
				val2 = rest.indexOf('"'); 							// 2. Anführungszeichen
				valname = rest.substr(val1, val2); 					// ValName zwischen 1. und 2. Anf.zeichen
				rest = rest.substr(val2+1, rest.length-val2-1); 	// Rest ermitteln
				rest = this.trim(rest);								// Rest trimmen
				
				arr[i] = new Array(); 								// Beide Werte in ein Array schreiben
				arr[i][0] = attrname;
				arr[i][1] = valname;
    		}
    		
    		i++;
    	}

    	// Attribute im DOM Format erstellen
		for(i=arr.length-1; i>=0; i--) {
			attr = arr[i][0];
			val = arr[i][1];
			obj.setAttribute(attr, val);
		}

    }
    
    // Erstellen eines Tagnamen aus <a> oder <a href=""> oder </a> oder </a>
    this.getTagName = function(tagName)
    {
    	tagName = tagName.slice(1, (tagName.length-1));
    	tagName = tagName.split(" ");
    	return tagName[0];
    }
    
    // Entfernen von Leerzeichen am Anfang und Ende
    this.trim = function(str)
    {
    	if(str.slice(0, 1)==" ") str = str.slice(1, str.length);
    	if(str.slice(str.length-1, str.length)==" ") str = str.slice(0, str.length-1);
    	return str;
	} 
}