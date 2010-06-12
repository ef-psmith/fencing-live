
   var http_request = false;

   function makeRequest(url, parameters) {
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
            } catch (e) {}
         }
      }
      if (!http_request) {
         alert('Cannot create XMLHTTP instance');
         return false;
      }
      http_request.onreadystatechange = alertContents;
      http_request.open('GET', url + parameters, true);
      http_request.send(null);
   }

var pauseTime = 10 * 1000;

   function alertContents() {
      if (http_request.readyState == 4) {
         if (http_request.status == 200) {

            var xmldoc = http_request.responseXML;
            xmlloaded(xmldoc);

         }
      }
   }

function xmlloaded(xmldoc) 
{
   // First get rid of the old divs.
   var i;
   for (i in areas) {
      var area = areas[i];
      // Get rid of any static title block
      if (null != area.statics) {
         var k;
         for (k in area.statics) {
            var title = document.getElementById(area.statics[k]);
            if (null != title) {
               title.parentNode.removeChild(title);
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
            titleobj.parentNode.removeChild(titleobj);
         }

         bodyobj = document.getElementById(area.prefix + j);
         if (null != bodyobj) {
            bodyobj.parentNode.removeChild(bodyobj);
         }
      } while (null != titleobj || null != bodyobj);
   }
   // Now sort out the new page

   // Get rid of the old areas
   areas = new Array();
   
   // Allowed classes object being used as a map
   var allowedclasses = {};
   
   var page = xmldoc.getElementsByTagName('page')[0];

   // Do the surround colour
   document.getElementById('top').style.background = page.getAttribute('backcolour');
   document.getElementById('bottom').style.background = page.getAttribute('backcolour');
   document.getElementById('left').style.background = page.getAttribute('backcolour');
   document.getElementById('right').style.background = page.getAttribute('backcolour');

   next_location = page.getAttribute('target');

   var areanodes = xmldoc.getElementsByTagName('area');
   var n;
   for (n in areanodes) {
      var areanode = areanodes[n];

      // We are expecting child nodes defining the prefix, title prefix and various statics
      var statics = new Array();
      var prefix = null;
      var titleprefix = null;
      var type = null;
      var classes = new Array();
      var m;
      for (m in areanode.childNodes) {
         if ("prefix" == areanode.childNodes[m].tagName) {
            prefix = areanode.childNodes[m].childNodes[0].nodeValue;
         }
         else if ("titleprefix" == areanode.childNodes[m].tagName) {
            titleprefix = areanode.childNodes[m].childNodes[0].nodeValue;
         }
         else if ("type" == areanode.childNodes[m].tagName) {
            type = areanode.childNodes[m].childNodes[0].nodeValue;
         }
         else if ("static" == areanode.childNodes[m].tagName) {
            statics[statics.length] = areanode.childNodes[m].childNodes[0].nodeValue;
         }
         else if ("class" == areanode.childNodes[m].tagName) {
            classes[classes.length] = areanode.childNodes[m].childNodes[0].nodeValue;
         }
      }
      
      // Check that this is one of the desired types
      var n;
      for (n in allowedareas) {
         if (allowedareas[n] == type) {
            // Add the area
            areas[areas.length] = {
               'prefix': prefix,
               'titleprefix': titleprefix,
               'type': type,
               'statics': statics,
               'finished': false,
               'currentvalue': 0
            };
            
            // Add all the classes into the allowed classes collection
            var classit;
            for (classit in classes)
            {
               allowedclasses[classes[classit]] = true;
            }
         }
      }
   }
   
   // Now we need to go through the children of the return data adding the divs if they are of the correct class
   var i;
   
   var xmldoc = http_request.responseXML;
   var returndata = xmldoc.getElementsByTagName('returndata')[0];

   for (i in returndata.childNodes) {
      var divdata = returndata.childNodes[i];

      // We only care about divs
      if (divdata.nodeType == returndata.nodeType) {

         if ("div" == divdata.tagName)
         {
            // Check the class against the allowed ones
            if (allowedclasses.hasOwnProperty(divdata.getAttribute('class')) && allowedclasses[divdata.getAttribute('class')])
            {
               translateElement(divdata);
            }
         }
      }
   }
   
   // We are done so call the callback.
   if (null != callback)
   {
      callback();
   }

}

// Translates an xmlelement into an html one
function translateElement(xmlelem)
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
   var myElement = document.createElement('div');
   
   myElement.className = xmlelem.getAttribute("class");
   myElement.id = xmlelem.getAttribute("id");

   // Set the inner html
   myElement.innerHTML = newhtml;
   
   document.body.appendChild(myElement);
}