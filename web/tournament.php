
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>


<?php
  $tournid = $_REQUEST['tournament'];
  $tournname = 'Unknown';

  if (file_exists($tournid . "/live.xml")) {


        $tournxml = simplexml_load_file($tournid . "/live.xml");


        foreach($tournxml->attributes() as $a => $b) {
            if ('tournamentname' == $a) {
                $tournname = $b;
            }
        }
        // Find the competitions
        foreach ($tournxml->children() as $c) {
            // Do we have a competition element
            if ("competition" == $c->getName()) {

                foreach($c->attributes() as $a => $b) {
                    if ('id' == $a) {
                        $compids[] = $b;
                    }
                }
            }
        }
  }

  echo '<title>' . $tournname .'</title>';
?>

<link href="./css/portal.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
<?php

    echo '<h1>'.$tournname.'</h1>';
    echo '<table class="DE">';


    foreach ($compids as $cid) {
        // Open the competition xml file

        if (file_exists($tournid . "/competitions/". $cid . ".xml")) {

            $compxml = simplexml_load_file($tournid . "/competitions/". $cid . ".xml");

            // Now go and find the competition name

            $compname = "Unknown";
            foreach($compxml->attributes() as $a => $b) {
                if ('titre_ligne' == $a) {
                    $compname = $b;
                }
            }

            echo '<tr><td class="DE"><a href="competition.php?competition=' . $cid . '&tournament=' . $tournid . '">' . $compname . '</a></td></tr>';

        }
    }

?>
</table>
</body>
</html>