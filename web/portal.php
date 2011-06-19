
<?php

  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />



<xsl:template match="opt">

<html>
<body>
<table>
		<xsl:for-each select="competition">
			<xsl:sort select="@id" data-type="number"/>
			<tr><td><a><xsl:attribute name="href">competition.php?competition=<xsl:value-of select="@id"/></xsl:attribute>
<xsl:value-of select="@ titre_ligne" /></a></td></tr>
		</xsl:for-each >
</table>
</body>
</html>

</xsl:template>

</xsl:stylesheet>';

  $xslt = new XSLTProcessor();
  $xslt->importStylesheet(new SimpleXMLElement($xslt_string));


   $xmlDoc = new DOMDocument();
   $xmlDoc->load("toplevel.xml");


  echo $xslt->transformToXml($xmlDoc);
?>