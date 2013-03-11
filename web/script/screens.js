



var pageloader;
var xsl;

// Scroll delay of 30 seconds
var scrolldelay = 15000;

function onPageLoaded() {
   xsl = loadXMLDoc(xsldoc);
   pageloader = new pageload();
   
   
   pageloader.fetch();
   
   // Start the regular reloading of the xml files
   var xmlreload = setInterval(function()
         {
            pageloader.fetch();
            pageloader.fetchpages(pageloader.currentcompid);
            pageloader.fetchpages(pageloader.nextcompid);
         }
      ,10000);
      
   // Start the layout
   pageloader.scrollerfinished();

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

   /**
      Move to a specific page of the scrolling
   */
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
      
      
      
      // If we haven't got processed xml then process it now
      if (null == this.pageloader.thiscompxml) {
      
         var thiscompnode = this.pageloader.currentcompxml.getElementsByTagName('competition')[0];
         this.pageloader.thiscompxml = transformDoc(thiscompnode, xsl);
      }
      
      // Try to reload the div from the latest XML source.
      var newcontents = this.pageloader.thiscompxml.ownerDocument.getElementById(this.pages[index]);
      
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


/** **********************************
      pageload class
    ********************************** */
function pageload() {

   // The competition id
   this.currentcompid = null;
   this.nextcompid = null;
   
   // The config file
   this.xmlsource = null;
   // The raw XML for the current comp
   this.currentcompxml = null;
   // The raw XML for the next comp, this is null if there is only one competition
   this.nextcompxml = null;
   
   // The processed XML for the current competition
   var thiscompxml = null;
   
   this.showmessages = function() {
      // Is there a message for the current competition
      
      var msgs = this.xmlsource.getElementsByTagName('message');
      for (var i = 0;i < msgs.length; ++i) {
         var msg = msgs[i];
         if (this.currentcompid == msg.parentElement.getAttribute("id")) {
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
        
         
    /**
      Update the whole page
    */
    this.updatepage = 
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
         
         
         // If we have a current competition id but no xml then we just return
         if (null != this.currentcompid && null == this.currentcompxml) {
            return;
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
                  // Default the competition we want to the first one
                  if (0 < seriescomps.length) {
                     comp_id = seriescomps[0].textContent;
                  }
                  if (1 < seriescomps.length) {
                     nextcomp_id = seriescomps[1].textContent;
                  }

                  // Go looking for the competition we have. 
                  // (we don't care about the last one as we will use the default first one in that case)
                  for (var c = 0; c < seriescomps.length - 1; ++c) {
                     if (seriescomps[c].textContent == this.currentcompid) {
                        // We want the next one, this is safe as we don't iterate over the last member of the list
                  	   // And if the last one matches then we want the first, which we have stored anyway so don't want to overwrite
                        comp_id = seriescomps[c + 1].textContent;
                        
                        // Now sort out the next competition id.  
                        // This remains null if we only have one competition (but we would not be in this loop if that were the case)
                        // It is the first element if the current competition is the penultimate
                        if (c == seriescomps.length - 2) {
                           nextcomp_id = seriescomps[0].textContent;
                        } else {
                           // Otherwise take the next but one competition from the series
                           nextcomp_id = seriescomps[c + 2].textContent;
                        }
                         
                    
                        break;
                     }
                  }
               }
            }
         } 
         
         
         // Store the competition ids
         this.currentcompid = comp_id;
         this.nextcompid = nextcomp_id;
         
         var changedcomps = false;
         if (this.currentcompid  != comp_id) {
            changedcomps = true;
         }
         
         var thiscomp = null;
         // We have changed page so change the xml
         if (null == this.nextcompid) {
            thiscomp = this.currentcompxml;
         } else {
            thiscomp = this.nextcompxml;
         }

         // Store the current competition xml
         this.currentcompxml = thiscomp;
         // And clear the next competition xml (also copes with moving from two competitions to one
         this.nextcompxml = null;
         
         //Check that we actually have some xml
         if (null == thiscomp)
            return false;
            
         // Now get the competition node   
         var thiscompnode = thiscomp.getElementsByTagName('competition')[0];
         
         
         
         // if we moved competitions then we need to regenerate the processed xml
         var comp = transformDoc(thiscompnode, xsl);
         this.thiscompxml = comp;
         
         //alert("Current Competition ID: " + this.currentcompid + "\nThis Competition Node ID: " + thiscompnode.getAttribute("id")+ "\nThis Processed Xml ID: " + comp.getAttribute("id"));
         

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

            var updated = this.updatepage();
            
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
                     requestor.currentcompxml = xmldoc;
                     // Note that we have reloaded the current XML
                     requestor.thiscompxml = null;
                     
                  } else if (compid == requestor.nextcompid) {
                     requestor.nextcompxml = xmldoc;
                  }
                  

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


