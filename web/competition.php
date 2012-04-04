
<?php
	$compid = $_REQUEST['competition'];
	$tournid = $_REQUEST['tournament'];

  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />

<!-- Entry List -->
<xsl:template match="competition[@id = ' . $compid . ']//entry">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title>EYC 2011</title>
<link href="../css/portal.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
<h1><xsl:value-of select="../../@titre_ligne"/></h1>
<p><a><xsl:attribute name="href">portal.php?tournament=' . $tournid .'</xsl:attribute>Up to all Competitions</a></p>
<table class="entry">
<tr><th class="entry">Name</th><th class="entry">Club</th></tr>
<xsl:for-each select="fencer">
<xsl:sort select="@sequence" data-type="number" />
	<tr>
	<td class="entry"><a><xsl:attribute name="href">fencer.php?competition=' . $compid . '&amp;fencer=<xsl:value-of select="@id"/>&amp;tournament=' . $tournid .'</xsl:attribute>
<xsl:value-of select="@name" /></a></td>
	<td class="entry"><xsl:value-of select="@affiliation" /></td>
</tr>
		</xsl:for-each>
</table>
<p><a><xsl:attribute name="href">portal.php?tournament=' . $tournid .'</xsl:attribute>Up to all Competitions</a></p>
</body>
</html>
</xsl:template>


</xsl:stylesheet>';

  $xslt = new XSLTProcessor();
  $xslt->importStylesheet(new SimpleXMLElement($xslt_string));


   $xmlDoc = new DOMDocument();
   $xmlDoc->load("$tournid/toplevel.xml");


  echo $xslt->transformToXml($xmlDoc);
?>