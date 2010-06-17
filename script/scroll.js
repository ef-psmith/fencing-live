
onerror=handleErr();

// Arrays are used to emulate passing by reference

var hasTableau = false;
var hasVlist = false;
var pauseTime = 20 * 1000;

// standard id prefixes for swapable elements
var tswapsprefix = "T";
var vswapsprefix = "V";


function onPageLoaded() {
   startSwapTimers();
}


function handleErr(msg,url,l) 
{
		//alert(msg);
		//Handle the error here
		return true;
}



function onSwapTimer(swaparea) 
{
	// get the divs

	var currentdiv = document.getElementById(swaparea.prefix + swaparea.currentvalue);
	var nextdiv = document.getElementById(swaparea.prefix + (swaparea.currentvalue + 1));
	var currenttitlediv = document.getElementById(swaparea.titleprefix + swaparea.currentvalue);
	var nexttitlediv = document.getElementById(swaparea.titleprefix + (swaparea.currentvalue +1));

	// alert("counter = " + counters[index] + ", currentdiv = " + currentdiv + ", nextdiv = " + nextdiv);
	if (nextdiv)
	{
	   swaparea.currentvalue += 1;
	}
	else
	{
	   nextdiv = document.getElementById(swaparea.prefix + 0);
		swaparea.finished = true;
		swaparea.currentvalue = 0;
		checkFinished();
	}

	// alert("swaplist = " + swaplist + ", index = " + index);
	currentdiv.style.visibility = "hidden";
	nextdiv.style.visibility = "visible";

	if (currenttitlediv)
	{
		if (!nexttitlediv)
		{
		   nexttitlediv = document.getElementById(swaparea.titleprefix + 0);
		}

		currenttitlediv.style.visibility = "hidden";
		nexttitlediv.style.visibility = "visible";
	}
}

function startSwapTimers() 
{
   // alert(swaplist);
   var i;
   for (i in areas) {
      var area = areas[i];
      area.timer = function(obj) { return setInterval(function() { onSwapTimer(obj) }, pauseTime); } (area);
   }
   if (undefined == i) {
      //Call the finished callback
      finished_callback();
   }
}

function checkFinished() {

   var i;
   var finished = true;
   for (i in areas) {
      if (!areas[i].finished) {
         finished = false;
      }
   }
	if (finished) {

	   //Call the finished callback
	   finished_callback();
	}
}
