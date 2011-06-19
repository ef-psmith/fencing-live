
<?php
	$compid = $_REQUEST['competition'];

  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />

<!-- Entry List -->
<xsl:template match="lists/portalentry">

<xsl:if test="../../@id = ' . $compid . '">
<html>
<body>
<h1><xsl:value-of select="../../@titre_ligne"/></h1>
<table>
<tr><th>Name</th><th>Club</th></tr>
<xsl:for-each select="fencer">
<xsl:sort select="@sequence" data-type="number" />
	<tr>
	<td ><a><xsl:attribute name="href">fencer.php?competition=' . $compid . '&amp;fencer=<xsl:value-of select="@id"/></xsl:attribute>
<xsl:value-of select="@name" /></a></td>
	<td ><xsl:value-of select="@affiliation" /></td>
</tr>
		</xsl:for-each>
</table>
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