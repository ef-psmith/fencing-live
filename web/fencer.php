
<?php

	$compid = $_REQUEST['competition'];
	$fencerid = $_REQUEST['fencer'];
  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />

<!-- Entry List -->
<xsl:template match="lists/portalentry/fencer">

<xsl:if test="../../../@id = ' . $compid . ' and @id = ' . $fencerid . '">
<html>
<body>
<h1><xsl:value-of select="../../../@titre_ligne"/></h1>
<h2><xsl:value-of select="@name"/></h2>
<a><xsl:attribute name="href">competition.php?competition=' . $compid .'</xsl:attribute>Up</a>
</body>
</html>
</xsl:if>
</xsl:template>


</xsl:stylesheet>';

  $xslt = new XSLTProcessor();
  $xslt->importStylesheet(new SimpleXMLElement($xslt_string));


   $xmlDoc = new DOMDocument();
   $xmlDoc->load("toplevel.xml");


  echo $xslt->transformToXml($xmlDoc);
?>