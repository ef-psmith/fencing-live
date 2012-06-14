



var pageloader;
var xsl;

function onPageLoaded() {
   xsl = loadXMLDoc(xsldoc);
   pageloader = new pageload();
   pageloader.fetch();

}

// Scroll delay of 30 seconds
var scrolldelay = 15000;


/**
Object for scrolling between pages
*/
function scroller(div, pageloader) {

   // Save the pageloader
   this.pageloader = pageloader;

   this.stop =
      function() {
         // Does nothing if we aren't running
         if (this.running) {
            clearInterval(this.timer);
            this.running = false;
            this.timer = null;
         }
      };
      this.start = function() {
         // does nothing if we are already running
         if (!this.running) {
            this.finished = false;
            var scroller = this;
            this.timer = setInterval(function() {
               scroller.pageindex += 1;
               if (scroller.pageindex < scroller.pages.length) {
                  scroller.movetopage(scroller.pageindex);
               }
               else {
                  // Mark that we are finished
                  scroller.finished = true;
                  // Tell the page we are finished.  If there is still one going then go back to the first page
                  if (scroller.running && !scroller.pageloader.scrollerfinished()) {

                     scroller.pageindex = 0;
                     if (scroller.pageindex < scroller.pages.length) {
                        scroller.movetopage(scroller.pageindex);
                     }
                  }
               }
            }, scrolldelay);

            // We are running
            this.running = true;
         }
      };
   // Initially we aren't running
   this.running = false;

   this.pages = new Array();
   this.pageindex = 0;

   this.myElement = div;
   
   /*
   Function to reload the div
   */
   this.load = function(xmlelem, force) {
      // Check we are running
      if (this.running || force) {
         // Get the remaining pages.
         var pages = xmlelem.getElementsByTagName('page');

         this.pageindex = 0;

         // reset the array of extra pages
         this.pages = new Array();

         for (var p = 0; p < pages.length; ++p) {


            this.pages.push(pages[p].textContent);
         }
         // Overwrite the inner HTML of the node.
         translateElement(xmlelem.getElementsByTagName('content')[0], this.myElement, true);
      }
   };

   this.movetopage = function(index) {
      // Hide the old page
      var currdiv = null;
      if (index > 0) {
         currdiv = document.getElementById(this.pages[index - 1]);
      }
      else if (0 < this.pages.length) {
         // Setting the first one, so make the last one hidden as we might be looping again while waiting for another scroller
         currdiv = document.getElementById(this.pages[this.pages.length - 1]);
      }
      // Make the specified one visible
      var newdiv = document.getElementById(this.pages[index]);
      
      // Try to reload the div from the latest XML source.
      var newcontents = this.pageloader.currentcompxml.ownerDocument.getElementById(this.pages[index]);
      
      if (null == newcontents) {
      
         //for (cntnt in this.pageloader.currentcompxml.childNodes) {
         //         alert("Child " + cntnt.nodeType + " of name " + cntnt.nodeName);
         //}
         var cntnts = this.pageloader.currentcompxml.getElementsByTagName("content");
         
         //alert("Found " + cntnts.length + " content nodes.  Node one is called" + cntnts[0].nodeName);
         
         for (var citer = 0; citer < cntnts.length; ++citer) {
            var cntnt = cntnts[citer]; 
                        
                //  alert("Found " + cntnt.nodeType + " of name " + cntnt.nodeName);
            for (var divi = 0; divi < cntnt.childNodes.length; ++divi) {
            
               var div = cntnt.childNodes[divi];
               
               // Check we are an element
               if (1 == div.nodeType) {
                  var idattr = div.getAttribute("id");

                   //alert("Found " + div.nodeName);
                  if (idattr == this.pages[index]) {
                     //alert("Got it!");
                     newcontents = div;
                  }
               }
            }
            
         }
         
      }
      
      
      // Update the inner XML and the attributes
      if (null != newcontents) {
      
         // Replacing the contents.
         
         var repdiv = document.createElement('div');
         
         translateElement(newcontents, repdiv, true);
         
         var parent = newdiv.parentNode;
         
         parent.replaceChild(repdiv, newdiv);
         
         newdiv = repdiv;
      }
      
      
      if (null != newdiv) {
         if (null != currdiv) {
            currdiv.style.visibility = "hidden";
         }
         newdiv.style.visibility = "visible";
      }
      
      this.pageloader.showmessages();
   };
}


// Last refresh time (from server)
var lastrefresh = 0;

function pageload() {

   // The competition id
   this.currentpage = null;
   
   this.xmlsource = null;
   this.currentcompxml = null;
   this.messages = null;
   
   this.showmessages = function() {
      // Is there a message for the current competition
      
      var msgs = this.messages.getElementsByTagName('message');
      for (var i = 0;i < msgs.length; ++i) {
         var msg = msgs[i];
         if (this.currentpage == msg.getAttribute("competition")) {
            // Got the message for our competition
            for (var j = 0; j < msg.childNodes.length; ++j) {
               if (3 == msg.childNodes[j].nodeType) {
                  // text node
                  var txt = msg.childNodes[j].data;
                  
                  if (null != txt && 0 < txt.length) {
                     // Got something to display.
                     var msgdiv = document.getElementById("messages");
                     if (null != msgdiv) {
                        // Set the message text
                        msgdiv.innerHTML = txt;
                        
                        msgdiv.style.visibility = "visible";
                        // now put a timer on to switch it off.
                        
                        // Reload in one third of the scroll delay
                        setTimeout(function() {
                              msgdiv.style.visibility = "hidden";; 
                           }, scrolldelay / 3);
                     }
                  }
                  // Found the text node so break out of the loop
                  break;
               }
            }
            // We have found our competition so return early.
            break;
     
         }
      }
   }

   this.reload =
      function(xmldoc, force) {

         if (null == xmldoc) {
            this.fetch();
            return;
         }      
         // Store the xmldocument
         this.xmlsource = xmldoc;
         
         
         // If we haven't got a current page then update the page now
         if (null == this.currentpage) {
            this.updatepage(force);
         }
         
         
         var comps = xmldoc.getElementsByTagName('competition');
         
         // Look for our page 
         for (var p = 0; p < comps.length; ++p) {

            // Run the stylesheet
            var comp = transformDoc(comps[p], xsl);
            if (this.currentpage == comp.getAttribute('id')) {
               // this is our current page so store the xml
               this.currentcompxml = comp;
            }
         }
         
         
         // 10 second reload
         {
            var ploader = this;
            // Reload in 10 seconds.
            setTimeout(function() { ploader.fetch(); }, 10000);
            return;
         }
         
      }
         
    this.updatepage = 
      function(force) {
      
         // First clear the messages
         
         var msgdiv = document.getElementById("messages");
         if (null != msgdiv) {                                 
            msgdiv.style.visibility = "hidden";
         }
         
         var xmldoc = this.xmlsource;
         var serieses = xmldoc.getElementsByTagName('series');
         var comp_id = null;

         // If we got some series then use them, otherwise we just display all the competitions
         if (0 < serieses.length) {
            for (var s = 0; s < serieses.length; ++s) {
               var series = serieses[s];
               if (series_id = series.getAttribute('id')) {
                  // We have found the series we want.

                  var seriescomps = series.getElementsByTagName('comp');
                  // Default the competition we want to the first one
                  if (0 < seriescomps.length) {
                     comp_id = seriescomps[0].textContent;
                  }

                  // Go looking for the competition we have. 
                  // (we don't care about the last one as we will use the default first one in that case)
                  for (var c = 0; c < seriescomps.length - 1; ++c) {
                     if (seriescomps[c].textContent == this.currentpage) {
                        // We want the next one, this is safe as we don't iterate over the last member of the list
                  	// And if the last one matches then we want the first, which we have stored anyway so don't want to overwrite
                        comp_id = seriescomps[c + 1].textContent;
                        break;
                     }
                  }
               }
            }
         } else {
            var allcomps = xmldoc.getElementsByTagName('competition');

            // default to the first one
            if (0 < allcomps.length) {
               comp_id = allcomps[0].getAttribute('id');
            }
            // Go looking for our competition
            for (var c = 0; c < allcomps.length - 1; ++c) {
               if (allcomps[c].getAttribute('id') == this.currentpage) {
                  // We want the next one, this is safe as we don't iterate over the last member of the list
                  // And if the last one matches then we want the first, which we have stored anyway so don't want to overwrite
                  comp_id = allcomps[c + 1].getAttribute('id');
                  break;
               }
            }

         }

         var comps = xmldoc.getElementsByTagName('competition');
         // Look for our page and check the time as well.
         for (var p = 0; p < comps.length; ++p) {

            var comp = transformDoc(comps[p], xsl);
            if (comp_id == comp.getAttribute('id')) {
               // We have changed page.
               this.currentpage = comp_id;
               
               this.currentcompxml = comp;

               // Background colours
               var borders = document.getElementsByName('border');
               for (var b = 0; b < borders.length; ++b) {
                  borders[b].style.backgroundColor = comp.getAttribute('background');
               }

               // Kill all the div timers
               for (var s = 0; s < this.scrollers.length;  ++s) {
                  this.scrollers[s].stop();
               }
               // clear the array
               this.scrollers = new Array();

               // Since we are repainting the page we want to get rid of all the divs below the body.
               var topdivs = document.getElementsByName('topdiv');
               while (0 < topdivs.length) {
                  // Remove the top divs
                  document.body.removeChild(topdivs[0]);
               }

               // Now get the new div definitions
               var newdivs = comp.getElementsByTagName('topdiv');
               if (0 < newdivs.length) {
                  for (var d = 0; d < newdivs.length; ++d) {
                     // Create the div.
                     var divelem = newdivs[d];

                     var myElement = document.createElement('div');

                     // Add the new scroller, this will fill in the div
                     var newscroller = new scroller(myElement, this);
                     newscroller.load(divelem, true);
                     this.scrollers.push(newscroller);

                     // Set various attributes here so they don't get overwritten by the xml load.
                     myElement.className = divelem.getAttribute("class");
                     myElement.id = divelem.getAttribute("id");
                     myElement.setAttribute('name', 'topdiv');

                     document.body.appendChild(myElement);
                  }

                  // Start all the div timers
                  for (var s in this.scrollers) {
                     this.scrollers[s].start();
                  }
                  this.showmessages();
                  // Early return to avoid a reload
                  return;
               }
               else {
                  var myElement = document.createElement('div');

                  myElement.className = "centreinfo";
                  myElement.id = "compinfo";
                  myElement.setAttribute('name', 'topdiv');
                  myElement.innerHTML = "<h1>" + comp.getAttribute('titre_ligne') + "</h1>";

                  document.body.appendChild(myElement);
                  break;
               }
            }
         }
         this.showmessages();
      };
      
   // AJAX requests
   this.fetch = function() {
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
                  // Store the messages
                  requestor.messages = xmldoc;
                  // Now get the actual data
                  requestor.fetchpages();

               } else {
                  setTimeout('requestor.fetch()', 5000);
               }
            }
         };
      http_request.open('GET', messageslocation, true);
      http_request.send(null);
   }
   
   
   this.fetchpages = function() {

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
                  setTimeout('requestor.fetchpages()', 5000);
               }
            }
         };
      http_request.open('GET', filelocation, true);
      http_request.send(null);
   }
   
   this.scrollers = new Array();

   this.scrollerfinished = function() {
      var allfinished = true;
      for (var s = 0; s < this.scrollers.length; ++s) {
         if (!this.scrollers[s].finished) {
            allfinished = false;
         }
      }
      if (allfinished) {

         // Kill all the div timers
         for (var s = 0; s < this.scrollers.length; ++s) {
            this.scrollers[s].stop();
         }

         this.updatepage();
      }

      return allfinished;
   }
}


