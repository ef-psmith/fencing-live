
	
	function EnableArea(area, enable)
	{
	   // We are going to use the display css attribute to hide things
	   var displayvalue = enable ? 'block' : 'none';
      // Get rid of any static title block
      if (null != area.statics) {
         var k;
         for (k in area.statics) {
            var title = document.getElementById(area.statics[k]);   
            if (null != title) {
               title.style.display = displayvalue;
            }
         }
      }
      // Now do the various prefix nodes
      var titleobj;
      var bodyobj;
      var j = 0;
      do {

         titleobj = document.getElementById(area.titleprefix + j);
         if (null != titleobj) {
            titleobj.style.display = displayvalue;
         }

         bodyobj = document.getElementById(area.prefix + j);
         if (null != bodyobj) {
            bodyobj.style.display = displayvalue;
         }
         ++j;
      } while (null != titleobj || null != bodyobj);
	}
	
	// the current selection for the navigation
	var currentselection = 'vlist';
	
	function ChangeSelected(areatype)
	{
	   var foundarea = false; 
	   var i;
	   for (i in areas)
	   {
	      var area = areas[i];
	      foundarea = foundarea || area.type == areatype;
	      EnableArea(area, area.type == areatype);
	   }
	   if (foundarea)
	      currentselection = areatype;
	   else
	   {
	      // Go back to where we were
	      for (i in areas)
	      {
	         var area = areas[i];
	         foundarea = foundarea || area.type == areatype;
	         EnableArea(area, area.type == currentselection);
	      }
	   }
	   return false;
	}



	var http_request = false;

	function makeRequest() {

	   http_request = false;
	   if (window.XMLHttpRequest) { // Mozilla, Safari,...
	      http_request = new XMLHttpRequest();
	      if (http_request.overrideMimeType) {
	         http_request.overrideMimeType('text/xml');
	      }
	   } else if (window.ActiveXObject) { // IE
	      try {
	         http_request = new ActiveXObject("Msxml2.XMLHTTP");
	      } catch (e) {
	         try {
	            http_request = new ActiveXObject("Microsoft.XMLHTTP");
	         } catch (e) { }
	      }
	   }
	   if (!http_request) {
	      alert('Cannot create XMLHTTP instance');
	      return false;
	   }

	   var requestor = this;
	   http_request.onreadystatechange =
   function() {
      if (http_request.readyState == 4) {
         if (http_request.status == 200) {

            var xmldoc = http_request.responseXML;
            requestor.reload(xmldoc, false);

         }
      }
   };
	   http_request.open('GET', filelocation, true);
	   http_request.send(null);
	   http_request.requestor = this;
	}


var pauseTime = 10 * 1000;
var mtime = "";
var this_location = "";


// Translates an xmlelement into an html one
function translateElement(xmlelem, myElement)
{
   if (null == xmlelem)
      return;
      
   // Build up the html
   
   var newhtml = "";
   var j; 
	for (j in xmlelem.childNodes)
	{
	   if (undefined != xmlelem.childNodes[j] && xmlelem.childNodes[j].nodeType == 1) {
	      var childxml = new XMLSerializer().serializeToString(xmlelem.childNodes[j]);
	      newhtml += childxml;
	   }
	}
   
   myElement.className = xmlelem.getAttribute("class");
   myElement.id = xmlelem.getAttribute("id");

   // Set the inner html
   myElement.innerHTML = newhtml;
   
   document.body.appendChild(myElement);
}
