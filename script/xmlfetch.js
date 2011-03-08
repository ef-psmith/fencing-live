
	



	function makeRequest() {

	   var http_request = false;
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
               if (http_request.status == 200 || http_request.status == 0) {

                  var xmldoc = http_request.responseXML;
                  requestor.reload(xmldoc, false);

               } else {
                  setTimeout(requestor.fetch(), 5000);
               }
            }
         };
	   http_request.open('GET', filelocation, true);
	   http_request.send(null);
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


function loadXMLDoc(dname) {
   if (window.XMLHttpRequest) {
      xhttp = new XMLHttpRequest();
   }
   else {
      xhttp = new ActiveXObject("Microsoft.XMLHTTP");
   }
   xhttp.open("GET", dname, false);
   xhttp.send("");
   return xhttp.responseXML;
}

function transformDoc(xml, xsl) {
   // code for IE
   if (window.ActiveXObject) {
      return xml.transformNode(xsl);
   }
   // code for Mozilla, Firefox, Opera, etc.
   else if (document.implementation && document.implementation.createDocument) {
      xsltProcessor = new XSLTProcessor();
      xsltProcessor.importStylesheet(xsl);
      var fragment = xsltProcessor.transformToFragment(xml, document);
      xml.appendChild(fragment);
      return xml;
   }
}