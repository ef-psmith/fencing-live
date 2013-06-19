



var pageloader;
var xsl;

// Scroll delay of 30 seconds
var scrolldelay = 15000;

function onPageLoaded(aEvent) {

   xsl = loadXMLDoc(xsldoc);
   if (null == pageloader) {
      pageloader = new pageload();
   }
   
   
   pageloader.fetch();
   
      
}


/** **********************************
      Class for scrolling between pages
    ********************************** */
function scroller(div, pageloader) {

   // Save the pageloader
   this.pageloader = pageloader;

   // Stop scrolling
   this.stop =
      function() {
         // Does nothing if we aren't running
         if (this.running) {
            clearInterval(this.timer);
            this.running = false;
            this.timer = null;
         }
      };
      
   /**
      Start scrolling around the div
   */
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
   
   // Is this a scroller that reloads the competition xml
   this.reloader = false;

   this.myElement = div;
   
   /**
   Function to reload the div
   */
   this.load = function(xmlelem, force) {
      // Check we are running
      if (this.running || force) {
         // Get the list of page IDs.
         var xmlpages = xmlelem.getElementsByTagName('page');

         this.pageindex = 0;

         // reset the array of extra pages
         this.pages = new Array();

         for (var p = 0; p < xmlpages.length; ++p) {

            this.pages.push(xmlpages[p].textContent);
         }
         // Overwrite the inner HTML of the node.
         translateElement(xmlelem.getElementsByTagName('content')[0], this.myElement, true);
      }
   };

   this.movetopage = function(index) {
      if (this.reloader)
         this.reloadcompfile(this.pageloader.currentcompid, index);
      else
         this.changepage(index);
   }
   
      /**
         Move to a specific page of the scrolling
   */
   this.changepage = function(index) {
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
      var newcontents = this.pageloader.proccompxml.ownerDocument.getElementById(this.pages[index]);
      
      if (null == newcontents) {
      
         //for (cntnt in this.pageloader.rawcompxml.childNodes) {
         //         alert("Child " + cntnt.nodeType + " of name " + cntnt.nodeName);
         //}
         var cntnts = this.pageloader.rawcompxml.getElementsByTagName("content");
         
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
   
   
   /**
      Get the competition file
   */
   this.reloadcompfile = function(compid, newpage) {

      if (null == compid) {
         return;
      }

      var compfilename = '../competitions/' + compid + '.xml';

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

                  // If the id of the competition we have loaded is the same as the current id then save it.
                  if (compid == requestor.pageloader.currentcompid)
                  {                   

                     // Now get the competition node   
                     var thiscompnode = xmldoc.getElementsByTagName('competition')[0];

                     // if we moved competitions then we need to regenerate the processed xml
                     var comp = transformDoc(thiscompnode, xsl);
                     requestor.pageloader.proccompxml = comp;
                     requestor.pageloader.rawcompxml = xmldoc;
                  } 

                  requestor.changepage(newpage);


               } else {
                  // Failed so try again
                  setTimeout(function() {requestor.fetchpages(compid);}, 5000);
               }
            }
         };

      http_request.open('GET', compfilename, true);
      http_request.send(null);
   }

}


// Last refresh time (from server)
var lastrefresh = 0;


/** **********************************
      pageload class
    ********************************** */
function pageload() {

   // The competition id
   this.currentcompid = null;
   
   // The config file
   this.xmlsource = null;
   // The raw XML for the current comp
   this.rawcompxml = null;
   
   // The processed XML for the current competition
   var proccompxml = null;
   
   this.showmessages = function() {
      // Is there a message for the current competition
      
      var txt = null;
      var msgs = this.xmlsource.getElementsByTagName('message');
      for (var i = 0;i < msgs.length; ++i) {
         var msg = msgs[i];
         if (this.currentcompid == msg.parentElement.getAttribute("id")) {
            // Got the message for our competition
            for (var j = 0; j < msg.childNodes.length; ++j) {
               if (3 == msg.childNodes[j].nodeType) {
                  // text node
                  txt = msg.childNodes[j].data;
                  
                  // Found the text node so break out of the loop
                  break;
               }
            }
            // We have found our competition so return early.
            break;
     
         }     
      }
      // If we have a message then display it
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
               }, 2 * scrolldelay / 3);
         }
      }
   }
        
         
    /**
      Update the whole page
    */
    this.findcomp = 
      function() {
      
      
         // First clear the messages
         
         var msgdiv = document.getElementById("messages");
         if (null != msgdiv) {                                 
            msgdiv.style.visibility = "hidden";
         }
         
         var xmldoc = this.xmlsource;
         
         // If we don't have the config XML then we can't do anything
         if (null == xmldoc) {
            return;
         }
         
                
         var compsenabled = new Object();
         var comps = xmldoc.getElementsByTagName('competition');
         
         for (var c = 0;c < comps.length; ++c) {
            // If this has an id attribute then look for the enabled attribute
            if (comps[c].hasAttribute('id')) {
               // Assume we are enabled
               var enabled = 'true';
               if (comps[c].hasAttribute('enabled')) {
                  enabled = comps[c].getAttribute('enabled');
               }
               compsenabled[comps[c].getAttribute('id')] = enabled;
            }
         }
         
         
         var serieses = xmldoc.getElementsByTagName('series');
         var comp_id = null;
         var nextcomp_id = null;

         // If we got some series then use them, otherwise we just display all the competitions
         if (0 < serieses.length) {
            for (var s = 0; s < serieses.length; ++s) {
               var series = serieses[s];
               if (series_id == series.getAttribute('id')) {
                  // We have found the series we want.

                  var seriescomps = series.getElementsByTagName('competition');
                  
                  // We haven't found our competition yet
                  var found = false;
                  // We are looking for the first competition after the one we are currently on.
                  // If we reach the end of the list before finding it then it is the first one on the list
                  for (var c = 0; c < seriescomps.length; ++c) {
                     var comp = seriescomps[c].textContent;
                     
                     // If we haven't found one then if this is enabled it is the first
                     if (null == comp_id && 'true' == compsenabled[comp])
                        comp_id = comp;
                  
                     // We don't care whether our competition is still enabled or not.
                     if (comp == this.currentcompid)                     
                        found = true;                        
                     else if (found && 'true' == compsenabled[comp]) {
                        // We have already passed our competition and this is valid so it is good enough.  So stop.
                        comp_id = comp;
                                            
                        // Got the competition so can stop looking now
                        break;
                     }
                  }
                  
                  // Found our series so no need to continue
                  break;
               }
            }
         } 
         
         
         // Store the competition ids
         this.currentcompid = comp_id;
         
         this.fetchpages(comp_id);
         
      }
         

    this.startscrollers = 
      function() {        

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
         var newdivs = this.proccompxml.getElementsByTagName('topdiv');
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
         }
         else {
            var myElement = document.createElement('div');

            myElement.className = "centreinfo";
            myElement.id = "compinfo";
            myElement.setAttribute('name', 'topdiv');
            myElement.innerHTML = "<h1>" + comp.getAttribute('titre_ligne') + "</h1>";

            document.body.appendChild(myElement);
         }
               
         this.showmessages();
         
         return true;
      };
      
      
         
      // All the divs that can scroll
      this.scrollers = new Array();

      /**
         Message to tell the whole page that the scroller, i.e. the various segments of the display, have finished

         The calling scroller will have set its own state before this is called.
      */
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

            var updated = this.fetch();
            
            // If we have no scrollers then call ourselves again in a few seconds
            
            if (0 == this.scrollers.length)
            {
               var caller = this;
               setTimeout(function() {
                  loaded = caller.scrollerfinished();
                  }, 3000);
            }
         }

         return allfinished;
      };
      
   // AJAX requests
   
   
   /**
      Get the config file
   */
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
                  requestor.xmlsource = xmldoc;
                  
                  // We have the config so go and paint the page
                  requestor.findcomp();

               } else {
                  setTimeout('requestor.fetch()', 5000);
               }
            }
         };
      http_request.open('GET', filelocation, true);
      http_request.send(null);
   }
   
   /**
      Get the competition file
   */
   this.fetchpages = function(compid) {
   
      if (null == compid) {
         return;
      }
      
      var compfilename = '../competitions/' + compid + '.xml';

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
                  
                  // If the id of the competition we have loaded is the same as the current id then save it.
                  if (compid == requestor.currentcompid)
                  {                   
                  
                     // Now get the competition node   
                     var thiscompnode = xmldoc.getElementsByTagName('competition')[0];
                     
                     
                     // Background colours
                     var borders = document.getElementsByName('border');
                     var bgcol = thiscompnode.getAttribute('background');
                     for (var b = 0; b < borders.length; ++b) {
                        borders[b].style.backgroundColor = bgcol;
                     }

                     // Timestamp
                     var tstamps = document.getElementsByName('timestamp');
                     var tstamp = thiscompnode.getAttribute('lastupdate');
                     for (var t = 0; t < tstamps.length; ++t) {
                        tstamps[t].innerHTML = tstamp;
         }

                     // if we moved competitions then we need to regenerate the processed xml
                     var comp = transformDoc(thiscompnode, xsl);
                     requestor.proccompxml = comp;
                     requestor.rawcompxml = xmldoc;
                  } 
                  
                  requestor.startscrollers();
                  

               } else {
                  // Failed so try again
                  setTimeout(function() {requestor.fetchpages(compid);}, 5000);
               }
            }
         };
         
      http_request.open('GET', compfilename, true);
      http_request.send(null);
   }
   
}


