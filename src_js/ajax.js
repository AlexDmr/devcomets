var Debug = {

    _console: null,

    echo : function (msg)
    {
        if ((Debug._console == null) || (Debug._console.closed))
        {
            Debug._console = window.open("", "console",
                "scrollbars=yes,resizable=yes,height=100,width=300");
            Debug._console.document.open("text/html", "replace");
            Debug._console.document.writeln("<pre>");
        }

        if(msg.constructor==Array)
        {
            Debug._console.document.writeln(Debug.echoArray(msg));
        }
        else
        {
            msg = msg.replace(/</g, "&lt;");
            msg = msg.replace(/>/g, "&gt;");

            Debug._console.document.writeln(msg);
        }

        Debug._console.scrollTo(0,10000);
        Debug._console.focus();
    },

    echoArray : function (array, indent)
    {
        if(!indent)
        {
            var indent = "";
        }

        if(array.constructor==Array)
        {
            var str = "\n";
            for(var x in array)
            {
                str += indent + x + " => " + Debug.echoArray(array[x], indent + "  ");
            }
            str += indent + "\n";

            return str;
        }
        else
        {
            return array + "\n";
        }

    },

    end : function ()
    {
        Debug._console.document.close();
    }
}
/* ---------------------------------------------------------------------------------------
 * ajax.js
 * ---------------------------------------------------------------------------------------
 * This file contains a set of javascript functions to handle basic AJAX actions
 * ---------------------------------------------------------------------------------------
 * Copyright (C) 2006 Lionel Balme
 * http://iihm.imag.fr/balme/projects/ctk/
 * ---------------------------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * ---------------------------------------------------------------------------------------
 * Version: 1.0
 * ---------------------------------------------------------------------------------------
 * Dependency list
 *
 * http://iihm.imag.fr/balme/projects/ctk/ecma/common.js
 * ---------------------------------------------------------------------------------------
 */


var Ajax = {

	/**
	 * Reference onto a XMLHTTP object
	 */
	xmlHttp : false,

	/**
	 * Name of the chosen get method to manage the current actions. One of "set" or "add"
	 */
	method : false,

	/**
	 * Value of the DOM ID attribute of the DOM object to use as a placeholder for the
	 * running action
	 */
	id : false,

	/**
	 * Is the Object still sending a message?
	 */
	is_sending   : false,
	stop_sending : false,

	/**
	 * Default value for the url of the element to use as a loading feedback
	 */
	default_loading_element : "<img src=\"ajax-loader.gif\"/>",

	/**
	 * Url of the picture to use as a loading feedback. Default value is "ajax-loader.gif"
	 */
	loader_img : false,


	/** Set a user-defined url of a picture to use as a loading feedback
	 * @param loader_img (string) a valid url onto a image file
	 */
	setLoaderPictureUrl : function (loader_img)
	{
		Ajax.loader_img = loader_img;
	},



	/** Perform an AJAX GET request onto a web-server
	 * @param method (string) One of "set" or "add". If _method worth "set", the result of
	 * 									the request will replace content inside the placeholder, if _method
	 *									worth "add", the result of the request will be added to the current
	 *									content within the placeholder.
	 * @param url (string) a valid url.
	 * @param id (string) (optional) the id of the DOM element to use as a placeholder for
	 * 						the	server reponse.
	 * @param data (array) (optional) an array where keys are data names and values are data
	 *							values:
	 *														array(
	 *															(string) name => (string) value,
	 *															...
	 *														)
	 */
	get : function (method, url, id, data, loading_feedback)
	{   if(Ajax.is_sending || Ajax.stop_sending) {return;}
	    Ajax.is_sending = true;
		Ajax.getXmlHttpObject();
		Ajax.method = method;
		Ajax.id = id;
		
		if (Ajax.xmlHttp == null)
		{
			alert ("Browser does not support HTTP Request");
			return
		}

		Ajax.xmlHttp.onreadystatechange = Ajax.xmlHttpStateChanged;

	
		Ajax.loader_img = Ajax.default_loading_element;
		if(loading_feedback)
		{
			Ajax.loader_img = loading_feedback;
		}

		if(data)
		{
			var post = "";
			for(var x in data)
			{
				/* post += x + "=" + Base64.encode(data[x]) + "&"; */
				post += x + "=" + encodeURIComponent(data[x]) + "&";
			}
			//Debug.echo("Envoi : " + post);
			Ajax.xmlHttp.open("POST",url,true);
			Ajax.xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8; Accept-Language: en,fr;");
			
			Ajax.xmlHttp.setRequestHeader("Cache-Control","no-cache");
			//Ajax.xmlHttp.setRequestHeader('Content-Type','text/plain');
			Ajax.xmlHttp.send( post );
		}
		else
		{
			Ajax.xmlHttp.open("GET",url,true);
			Ajax.xmlHttp.send(null);
		}

	},



	/*
		--------------------------------------------------------------------------------------
		Following functions are for INTERNAL USE ONLY
		--------------------------------------------------------------------------------------
	*/

	/** Internal Use Only: instantiation of a XMLHTTP object
	 * @return an instance of XMLHttpRequest (gecko browsers) or Msxml2.XMLHTTP or
	 * Microsoft.XMLHTTP (Microsoft browsers)
	 */
	getXmlHttpObject: function ()
	{
		if(!Ajax.xmlHttp)
		{
			var objXMLHttp=null;
			try
			{
				objXMLHttp=new ActiveXObject("Msxml2.XMLHTTP");
			}
			catch(e)
			{
				try
				{
					objXMLHttp=new ActiveXObject("Microsoft.XMLHTTP");
				}
				catch(e)
				{
					objXMLHttp=new XMLHttpRequest();
				}
			}

			Ajax.xmlHttp = objXMLHttp;
		}
	},



	/** Internal Use Only: Manage the ajax update
	*/
	xmlHttpStateChanged : function ()
	{
		if (Ajax.xmlHttp.readyState==4 || Ajax.xmlHttp.readyState=="complete")
		{
			if(Ajax.method == "set")
			{
			 if(Ajax.id && Ajax.xmlHttp.responseText.length > 2) {
               var node = document.getElementById(Ajax.id);
			   //Debug.echo( "____\n" + Ajax.xmlHttp.responseText.length );
			   var pos_deb = 0;
			   do {
				 t_var = parseInt(Ajax.xmlHttp.responseText.substr(pos_deb, 16), 10);
				   pos_deb = Ajax.xmlHttp.responseText.indexOf(" ", pos_deb) + 1;
				 t_val = parseInt(Ajax.xmlHttp.responseText.substr(pos_deb, 16), 10);
				   pos_deb = Ajax.xmlHttp.responseText.indexOf(" ", pos_deb) + 1;
				 node_name = Ajax.xmlHttp.responseText.substr(pos_deb, t_var);
				 if (node_name == "reload")	{
				   //window.location.reload(); 
				   var ad = document.URL.substr(0, document.URL.lastIndexOf("/")+1 );
				   location.replace( ad + 'index.php?Comet_port=' + document.getElementById('Comet_port').value );
				   break;
				  }
				 node = document.getElementById( node_name );
				 if(node == null) {
				  //Debug.echo( "____\nNODE " + Ajax.xmlHttp.responseText.substr(pos_deb, t_var) + " is not present" );
				 } 
 				   pos_deb += t_var + 1;
				 if(node != null) {node.innerHTML = Ajax.xmlHttp.responseText.substr(pos_deb, t_val);}
				   pos_deb += t_val + 1;
			    } while ( pos_deb < Ajax.xmlHttp.responseText.length-2 ) 
			  } 
			}
			else if(Ajax.method == "add")
			{   Debug.echo( "ADD" );
				if(Ajax.id) document.getElementById(Ajax.id).innerHTML += Ajax.xmlHttp.responseText;
			}
/*			else if(Ajax.method == "reload")
			{   Debug.echo( "RELOADING" );
				location.reload();
			}*/
			else
			{
				if(Ajax.id) setInnerHtml(Ajax.id, "AJAX: '"+Ajax.method+"' is an unknow method.");
			}
		 Ajax.is_sending = false;	
		}
		else if(Ajax.method != "add")
		{
			/* if(Ajax.id) setInnerHtml(Ajax.id, Ajax.loader_img); */
		}
	}
}



//NO-AJAX, just DHTML willing to be removed from here
var dragit = "";

function drag(event)
{
	try
	{
		divStyle = document.getElementById(dragit).style;
	}
	catch(e)
	{
		return;
	}

	divStyle.top = event.clientY - 10;
 	divStyle.left = event.clientX - 10;
// 		document.getElementById("id2").innerHTML =
// 			event.clientX + ":" + event.clientY
// 			+ " - " + divStyle.left + ":" + divStyle.top
// 			+ " - " + divStyle.width + ":" + divStyle.height
// 		;
}

function startDrag(id)
{
	dragit = id;
}

function stopDrag()
{
	dragit = false;
}

