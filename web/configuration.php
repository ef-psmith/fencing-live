
<html>
<head>
<title>Fencing Screens Configuration</title>

<script type="text/javascript" src="jscolor/jscolor.js"></script>
<script type="text/javascript">
var changed = false;
function somethingchanged()
{
	changed = true;
	document.getElementById("save_button").disabled = false;
}

function ontimer()
{
	if (!changed)
	{
  		window.location.assign("./configuration.php")
	}
}
</script>


</head>
<body>

<script type="text/javascript">

var t = setTimeout("ontimer()", 30000);
</script>


<?php
ini_set('display_errors',1);
 error_reporting(E_ALL);


	// Configuration information on where to find the config file, a place for the temporary file and the base area for Engarde files
	$configfilelocation = 'D:/Screens/Live/live.xml';
	$tempconfigfilelocation = 'D:/Screens/Live/templive.xml';
	$basepath  = 'D:/Screens/Live/Examples/Invicta';



 	$maxcompnum = 0;

	class Competition {

		public $id = -1;
		// Competition file
		public $path = '';
		// Name of the directory containing the competition
		public $name = '';

		// Background colour to use for this competition
		public $colour = 'white';
		// Is this competition enabled
		public $enabled = 0;
		// Have we found the competition file
		public $found = 0;

		// NIF value
		private $nif = 0;

		function createname()
		{
			$path_parts = pathinfo($this->path);
			$this->name = $path_parts['basename'];
		}

		function load($xml)
		{
			$this->id = $xml->getAttribute('id');
			global $maxcompnum;
			// Sort out the maximum competition number so we can create new competitions
			if ($this->id > $maxcompnum)
				$maxcompnum = $this->id;

			if ($this->id == -1)
			{
				$maxcompnum = $maxcompnum + 1;
				$this->id = $maxcompnum;
			}

			foreach ($xml->childNodes AS $item)
			{
				if ('source' == $item->nodeName)
				{
					$this->path = $item->nodeValue;
					$this->createname();
				}
				else if ('enabled' == $item->nodeName)
				{
					$this->enabled = $item->nodeValue;
				}
				else if ('background' == $item->nodeName)
				{
					$this->colour = $item->nodeValue;
				}
				else if ('nif' == $item->nodeName)
				{
					$this->nif = $item->nodeValue;
				}
			}
		}

		function write($elem, $doc)
		{
			$elem->setAttribute('id', $this->id);
			$elem->appendChild($doc->createTextNode("\n\t\t"));
			$elem->appendChild($doc->createElement('enabled', $this->enabled));
			$elem->appendChild($doc->createTextNode("\n\t\t"));
			$elem->appendChild($doc->createElement('background', $this->colour));
			$elem->appendChild($doc->createTextNode("\n\t\t"));
			$elem->appendChild($doc->createElement('source', $this->path));
			$elem->appendChild($doc->createTextNode("\n\t\t"));
			$elem->appendChild($doc->createElement('nif', $this->nif));
		}

		function Dump()
		{
			return "Competition (id=$this->id)<br/>Source: $this->path<br/>Background: $this->colour<br/>NIF: $this->nif <br/>Enabled: $this->enabled <br/>Found: $this->found <br/>";
		}
	}


	$maxseriesnum = 0;

	class Series {

		public $id = -1;
		public $enabled = 0;

		// Competitions
		public $comps = array();

		function __construct($xml)
		{
			$this->id = $xml->getAttribute('id');
			global $maxseriesnum;
			// Sort out the maximum competition number so we can create new competitions
			if ($this->id > $maxseriesnum)
				$maxseriesnum = $this->id;

			if ($this->id == -1)
			{
				$maxseriesnum = $maxseriesnum + 1;
				$this->id = $maxseriesnum;
			}

			foreach ($xml->childNodes AS $item)
			{
				if ('competition' == $item->nodeName)
				{
					array_push($this->comps,$item->nodeValue);
				}
				else if ('enabled' == $item->nodeName)
				{
					$this->enabled = $item->nodeValue;
				}
			}
		}
		function write($elem, $doc)
		{
			$elem->setAttribute('id', $this->id);
			$elem->appendChild($doc->createTextNode("\n\t\t"));
			$elem->appendChild($doc->createElement('enabled', $this->enabled));

			foreach ($this->comps AS $comp)
			{
				$elem->appendChild($doc->createTextNode("\n\t\t"));
				$elem->appendChild($doc->createElement('competition', $comp));
			}
		}

		function Dump()
		{
			$info = "Series (id=$this->id)<br/>";

			foreach ($this->comps AS $comp)
			{
				$info = $info . "Competition: $comp<br/>";
			}
			return $info;
		}
	}


	function find_files($path, $pattern, $callback) {
		$path = rtrim(str_replace("\\", "/", $path), '/') . '/*';
		foreach (glob ($path) as $fullname) {
			if (is_dir($fullname)) {
				find_files($fullname, $pattern, $callback);
			} else if (preg_match($pattern, $fullname)) {
				call_user_func($callback, $fullname);
			}
		}
	}



	// The list of competitions we use
	$competitionsbyname = array();
	$competitionsbyid = array();

	// The series
	$seriesbyid = array();


	function found_competition($fullname)
	{
		global $maxcompnum,$competitionsbyname , $competitionsbyid;
		$comp = 0;
		$path_parts = pathinfo($fullname);
		if (array_key_exists($path_parts['dirname'],$competitionsbyname))
		{
			$comp = $competitionsbyname[$path_parts['dirname']];
		}
		else
		{
			// Create a new competition
			$comp = new Competition;

			// Set the new id
			$maxcompnum = $maxcompnum + 1;
			$comp->id = $maxcompnum;
			// And the path
			$comp->path = $path_parts['dirname'];

			$comp->createname();


			$competitionsbyname[$comp->path] = $comp;
			$competitionsbyid[$comp->id] = $comp;

		}

		$comp->found = 'true';
		//echo "<p>Found $fullname. <br/>".$comp->Dump()."</p>";
	}

	$configxml = new DOMDocument();
	$configxml->load($configfilelocation);


	$doc = $configxml->documentElement;
	foreach ($doc->childNodes AS $item)
	{
		// Only care about series and competitions
		if ('competition' == $item->nodeName)
		{
			// Create the competition
			$comp = new Competition;
			// Load the competition from the XML
			$comp->load($item);

			//echo $comp->Dump();

			$competitionsbyname[$comp->path] = $comp;
			$competitionsbyid[$comp->id] = $comp;

		}
		else if ('series' == $item->nodeName)
		{
			$series = new Series($item);

			//echo $series->Dump();

			$seriesbyid[$series->id] = $series;
		}

  	}
	find_files($basepath, "/competition.egw/", 'found_competition');

	// If we are receiving postdata then we need to adjust the state of the objects and recreate the XML
	if (array_key_exists("ConfigurationChanges",$_REQUEST))
	{

		$newconfigxml = new DOMDocument();
		$newconfigxml->loadXML('<?xml version="1.0" ?><config/>');
		$newdoc = $newconfigxml->documentElement;

		// We are going to clone all the non competition and non series nodes into the new xml

		foreach ($doc->childNodes AS $item)
		{
			if (3 != $item->nodeType)
			{
				if ('competition' != $item->nodeName && 'series' != $item->nodeName)
				{
					$newdoc->appendChild($newconfigxml->createTextNode("\n\t"));
					$newdoc->appendChild($newconfigxml->importNode($item->cloneNode(TRUE), TRUE));
				}
			}
		}



		// Are the competitions enabled and in the series
		foreach ($competitionsbyid AS $comp)
		{
			// Looking for a request parameter called "comp_xxx"
			if (array_key_exists("comp_".$comp->id, $_REQUEST))
			{
				$comp->enabled = 'true';
			}
			else
			{
				$comp->enabled = 'false';
			}

			// Looking for a request parameter called "comp_xxx"
			if (array_key_exists("compcolour_".$comp->id, $_REQUEST))
			{
				$comp->colour = $_REQUEST["compcolour_".$comp->id];
			}

			// Now sort out whether the competition is in each series
			foreach ($seriesbyid AS $series)
			{
				// Looking for a request parameter called "compinseries_ccc_sss"
				if (array_key_exists("compinseries_".$comp->id . '_' .$series->id, $_REQUEST))
				{
					// Is this competition in the seris
					if (in_array($comp->id, $series->comps))
					{
						// Nothing to do as it is already there
					}
					else
					{
						// Add it
						array_push($series->comps, $comp->id);
					}
				}
				else
				{
					// We assume that it isn't there
					// Is this competition in the seris
					if (in_array($comp->id, $series->comps))
					{
						$newcomps = array();

						foreach ($series->comps AS $scomp)
						{
							if ($scomp != $comp->id)
								array_push($newcomps, $scomp);
						}

						$series->comps = $newcomps;
					}
					else
					{
						// Not there so nothing to do
					}
				}
			}

			// Now write out the competition
			$compelem = $newconfigxml->createElement('competition');

			$comp->write($compelem, $newconfigxml);

			$newdoc->appendChild($newconfigxml->createTextNode("\n\t"));
			$newdoc->appendChild($compelem);

		}

		// Work out whether the series are enabled
		foreach ($seriesbyid AS $series)
		{
			// Looking for a request parameter called "series_xxx"
			if (array_key_exists("series_".$series->id, $_REQUEST))
			{
				$series->enabled = 'true';
			}
			else
			{
				$series->enabled = 'false';
			}
			// Now write out the series
			$serelem = $newconfigxml->createElement('series');

			$series->write($serelem, $newconfigxml);

			$newdoc->appendChild($newconfigxml->createTextNode("\n\t"));
			$newdoc->appendChild($serelem);

		}



		$newconfigxml->save($tempconfigfilelocation);

		// Delete the old config file
		unlink($configfilelocation);
		rename($tempconfigfilelocation,$configfilelocation);

  	}



	// Now we have all the available competitions and are going to output the form table
	?>
	<form name="config" action="configuration.php" method="post">
	<input id="save_button" type="submit" value="Save" disabled="disabled"/>
	<input type="hidden" name="ConfigurationChanges" value="Saved"/>
	<table>
<?php
	// The table headings are the series
	echo "<tr><th>Competitions</th>";
	foreach ($seriesbyid AS $series)
	{
		echo '<th><input onchange="somethingchanged()" type="checkbox" name="series_'. $series->id .'" value="enabled" ';
		if ('true' == $series->enabled)
			echo 'checked="checked"';

		echo '>Series '. $series->id .'</input></th>';
	}
	echo "</tr>";

	// Now a row for each competition
	foreach($competitionsbyid AS $comp)
	{
		// Check that the competition was found
		if ('true' == $comp->found)
		{
			echo '<tr><td><input onchange="somethingchanged()" type="checkbox" name="comp_'. $comp->id .'" value="enabled" ';
				if ('true' == $comp->enabled)
					echo 'checked="checked"';

				echo '>' . $comp->name .'</input><br/><input  onchange="somethingchanged()" class="color" value="'.$comp->colour . '" name="compcolour_'.$comp->id . '" /></td>';

			// now loop through each series working out if this competition is in this series
			foreach ($seriesbyid AS $series)
			{
				echo '<td><input onchange="somethingchanged()" type="checkbox" name="compinseries_'. $comp->id. '_' .$series->id .'" value="inseries" ';
				if (in_array($comp->id, $series->comps))
					echo 'checked="checked"';

				echo '/></td>';
			}

			// And finish the row for the comp
			echo '</tr>';
		}
	}

?>
</table>
	</form>
</body>
</html>