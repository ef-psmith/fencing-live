
	

// Translates an xmlelement into an html one
function translateElement(xmlelem, myElement, doattr)
{
   if (null == xmlelem)
      return;
      
   // Build up the html
   
   var newhtml = getInnerXML(xmlelem);
      
   if (doattr) {
      myElement.className = xmlelem.getAttribute("class");
      myElement.id = xmlelem.getAttribute("id");
   }

   // Set the inner html
   myElement.innerHTML = newhtml;
   
   document.body.appendChild(myElement);
}

function getInnerXML(xmlelem) {

   var newhtml = "";
   var j; 
   for (j in xmlelem.childNodes) {
      if (undefined != xmlelem.childNodes[j] && xmlelem.childNodes[j].nodeType == 1) {
         var childxml = new XMLSerializer().serializeToString(xmlelem.childNodes[j]);
         newhtml += childxml;
      }
   }
   
   return newhtml;

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
      
      // Create a new document to put the node into and make the competition (copying the attributes) the root node.
      var parser = new DOMParser();
      transformedxml = parser.parseFromString("<competition background=\"" + xml.getAttribute("background") + "\" id=\"" + xml.getAttribute("id") + "\" titre_ligne=\""+ xml.getAttribute("titre_ligne") + "\"/>","text/xml");
      transformedxml.documentElement.appendChild(fragment);
      return transformedxml.documentElement;
   }
}
