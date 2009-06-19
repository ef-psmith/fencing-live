
onerror=handleErr();

// Arrays are used to emulate passing by reference
var finished = new Array();
finished[0] = false;  // for tableau
finished[1] = false;  // for vlist

var counters = new Array();
counters[0] = 0;
counters[1] = 0;

var hasTableau = false;
var hasVlist = false;
var pauseTime = 7 * 1000;

// standard id prefixes for swapable elements
var tswapsprefix = "T";
var vswapsprefix = "V";

function onPageLoaded() 
{
	hasTableau = document.getElementById(tswapsprefix + 0);

	if (hasTableau)
	{
		startSwapTimers(tswapsprefix, 0);
	}
	else
	{
		finished[0] = true;
	}

	hasVlist = document.getElementById(vswapsprefix + 0);

	if (hasVlist)
	{
		startSwapTimers(vswapsprefix, 1);
	}
	else
	{
		finished[1] = true;
	}
}


function handleErr(msg,url,l) 
{
		//alert(msg);
		//Handle the error here
		return true;
}



function onSwapTimer(swaplist, index) 
{
	// get the divs

	var currentdiv = document.getElementById(swaplist + counters[index]);
	var nextdiv = document.getElementById(swaplist + (counters[index] + 1));
	var currenttitlediv = document.getElementById(swaplist + "T" + counters[index]);
	var nexttitlediv = document.getElementById(swaplist + "T" + (counters[index] +1));

	// alert("counter = " + counters[index] + ", currentdiv = " + currentdiv + ", nextdiv = " + nextdiv);
	if (nextdiv)
	{
		counters[index] += 1;
	}
	else
	{
		nextdiv = document.getElementById(swaplist + 0);
		finished[index] = true;
		counters[index] = 0;
		checkFinished();
	}

	// alert("swaplist = " + swaplist + ", index = " + index);
	currentdiv.style.visibility = "hidden";
	nextdiv.style.visibility = "visible";

	if (currenttitlediv)
	{
		if (!nexttitlediv)
		{
			nexttitlediv = document.getElementById(swaplist +"T" + 0);
		}

		currenttitlediv.style.visibility = "hidden";
		nexttitlediv.style.visibility = "visible";
	}
}

function startSwapTimers(swaplist, index) 
{
	// alert(swaplist);
	setInterval(function() {onSwapTimer(swaplist, index)},pauseTime);
}

function checkFinished() 
{ 
	if (true && finished[0] && finished[1])
	{
		window.location.replace(next_location);
	}
}
