



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
         translateElement(xmlelem.getElementsByTagName('content')[0], this.myElement);
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
      if (null != newdiv) {
         if (null != currdiv) {
            currdiv.style.visibility = "hidden";
         }
         newdiv.style.visibility = "visible";
      }
   };
}


// Last refresh time (from server)
var lastrefresh = 0;

function pageload() {

   this.currentpage = null;

   this.reload =
      function(xmldoc, force) {

         if (null == xmldoc) {
            this.fetch();
            return;
         }
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
                  comp_id = allcomps[c + 1].getAttribute('id');
                  break;
               }
            }

         }

         // If we haven't a compid then return.  Or if we haven't changed since last time.
         if (null == comp_id /*|| lastrefresh == xmldoc.getAttribute('time')*/) {
            var ploader = this;
            // Reload in 10 seconds.
            setTimeout(function() { ploader.fetch(); }, 10000);
            return;
         }


         var comps = xmldoc.getElementsByTagName('competition');
         // Look for our page and check the time as well.
         for (var p = 0; p < comps.length; ++p) {

            var comp = transformDoc(comps[p], xsl);
            if (comp_id == comp.getAttribute('id')) {
               // We have changed page.
               this.currentpage = comp_id;

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
         {
            // Failed so reload
            var ploader = this;
            // Reload in 10 seconds.
            setTimeout(function() { ploader.fetch(); }, 10000);
            return;
         }
      };
   this.fetch = makeRequest;
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
         this.fetch();
      }

      return allfinished;
   }
}


