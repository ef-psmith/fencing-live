	function onPageLoaded()
	{
	   finished_callback();
	}
	
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
	
	
	function callback()
	{
	   // Clean up the links
	   // Go thought the areas looking for the mid list and the vlist
	   var hasvlist = false;
	   var hasmidlist = false;
	   
	   var i;
	   for (i in areas)
	   {
	      if (areas[i].type == 'mlist')
	         hasmidlist = true;
	      else if (areas[i].type == 'vlist')
	         hasvlist = true;
	   }
	   var midlistelem = document.getElementById('mlistnav');
	   if (null != midlistelem)
	   {
	      if (hasmidlist)
	      {
   	      midlistelem.style.display = 'inline';
	      }
	      else
	      {
   	      midlistelem.style.display = 'none';
	      }
	   }
	   var vlistelem = document.getElementById('vlistnav');
	   if (null != vlistelem)
	   {
	      if (vlistelem)
	      {
   	      vlistelem.style.display = 'inline';
	      }
	      else
	      {
   	      vlistelem.style.display = 'none';
	      }
	   }
	   
	   // Back through the areas getting the enablement correct based on selected
	   for (i in areas)
	   {
	      var area = areas[i];
	      
	      EnableArea(area, area.type == currentselection);
	   }
	
	   setTimeout(function() {finished_callback();}, 30000);
	}


	function ChangeView(newdivname)
	{
	   var currdiv = document.getElementById(currentdivdisplayed);
	   var newdiv = document.getElementById(newdivname);
	   if (null != newdiv)
	   {
	      if (null != currdiv)
	      {
		      currdiv.style.visibility = "hidden";
		   }
		   newdiv.style.visibility = "visible";
		   // Store the new div name
		   currentdivdisplayed = newdivname;
	   }
	}
	function finished_callback() {

	   // Kill the current timers
	   var i;
	   for (i in areas) {
	      clearInterval(areas[i].timer);
	      areas[i].timer = undefined;
	   }
	   // We are going to the same place
	   next_location = this_location;
		makeRequest(next_location + ".xml", "");
	}
	


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

var mtime = "";
var this_location = "";

function xmlloaded(xmldoc) 
{
   var page = xmldoc.getElementsByTagName('page')[0];
   // Only process if the two pages are different or have different modified times
   if (null != xmldoc && (this_location != next_location || mtime != page.getAttribute('mtime')))
   {   

      // First get rid of the old divs.
      var i;
      for (i in areas) {
         var area = areas[i];
         // Get rid of any static title block
         if (null != area.statics) {
            var k;
            for (k in area.statics) {
               var title;
               do
               {
                  title = document.getElementById(area.statics[k]);
                  if (null != title) {
                     title.parentNode.removeChild(title);
                  }
               } while (null != title);
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
            ++j;
         } while (null != titleobj || null != bodyobj);
      }
      // Now sort out the new page

      // Get rid of the old areas
      areas = new Array();
      
      // Allowed classes object being used as a map
      var allowedclasses = {};
      
      document.title = page.getAttribute('title');
      mtime = page.getAttribute('mtime');

      // Do the surround colour
      if (null != document.getElementById('top'))
         document.getElementById('top').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('bottom'))
         document.getElementById('bottom').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('left'))
         document.getElementById('left').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('right'))
         document.getElementById('right').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('mlistnav'))
         document.getElementById('mlistnav').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('vlistnav'))
         document.getElementById('vlistnav').style.background = page.getAttribute('backcolour');
      if (null != document.getElementById('upnav'))
         document.getElementById('upnav').style.background = page.getAttribute('backcolour');

      // Sort out the locations
      this_location = next_location;
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
