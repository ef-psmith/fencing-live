

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>Fencing Results</title>
<link href="./css/portal.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
<h1>Fencing Tournament Results</h1>


<?php
  // open this directory
  $myDirectory = opendir(".");

  // get each entry
  while($entryName = readdir($myDirectory)) {

    // We only care about directories
    if ('dir' == filetype($entryName)  && '..' != $entryName && '.' != $entryName) {

        // And directories that have a live.xml file in them
        if (file_exists($entryName . "/live.xml")) {
            $dirArray[] = $entryName;
        }
    }
  }

  // close directory
  closedir($myDirectory);

  // sort em
  sort($dirArray);

  $indexCount = count($dirArray);

  if (0 == $indexCount) {
    echo "<h2>No tournaments available</h2>";
  }

  echo '<table class="DE">';
  for($index=0; $index < $indexCount; $index++) {
    // Open the live.xml and find the tournament name

    $tournxml = simplexml_load_file($dirArray[$index] . "/live.xml");


    foreach($tournxml->attributes() as $a => $b) {
        if ('tournamentname' == $a) {
            $tournname = $b;
        }
    }

    print('<tr><td class="DE"><a href="tournament.php?tournament=' . $dirArray[$index] . '">' . $tournname . '</a></tr></td>');
  }


  ?>
  </table>
  </body>
  </html>