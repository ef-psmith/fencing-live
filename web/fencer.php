
<?php

	$compid = $_REQUEST['competition'];
	$fencerid = $_REQUEST['fencer'];
  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:output method="xml" />

<!-- Match every fencer -->
<xsl:template match="competition[@id = ' . $compid . ']/lists/portalentry/fencer[@id = ' . $fencerid . ']">
<xsl:variable name="fencername" select="@name" />
<html>
<body>
<h1><xsl:value-of select="../../../@titre_ligne"/></h1>
<h2><xsl:value-of select="@name"/></h2>

<xsl:for-each select="../../../lists/ranking/fencer[@id = ' . $fencerid . ']">
<p><xsl:choose>
<xsl:when test="../@type = \'final\'">Final Position: </xsl:when>
<xsl:otherwise>Seeding after the poules: </xsl:otherwise>
</xsl:choose>
<xsl:value-of select="@position" /></p>
</xsl:for-each>

<p>Direct Elimination</p>
<table>
<xsl:for-each select="../../../tableau/matches//match[fencerA/@id = ' . $fencerid . ' or fencerB/@id = ' . $fencerid . ']">
<xsl:sort select="../@count" data-type="number"/>
<tr><td><xsl:value-of select="name(..)" /></td><td><xsl:value-of select="fencerA/@name" /></td><td><xsl:value-of select="@score" /></td><td><xsl:value-of select="fencerB/@name" /></td></tr>
</xsl:for-each>
</table>


<xsl:for-each select="../../../pools/pool/fencers/fencer[@fencerid = ' . $fencerid . ']">
<p>Round <xsl:value-of select="../../../@round"/> Poule</p>
<table>
<xsl:variable name="poolid" select="@id"/>
<xsl:for-each select="result[@id != current()/@id]">
<xsl:variable name="score" select="@score"/>
<xsl:for-each select="../../fencer[@id = current()/@id]/result[@id = $poolid]">
<tr><td><xsl:value-of select="$fencername" /></td><td><xsl:value-of select="$score" /></td><td><xsl:value-of select="@score" /></td><td><xsl:value-of select="../@name" /></td></tr>
</xsl:for-each>
</xsl:for-each>
</table>
</xsl:for-each>

<br />
<a><xsl:attribute name="href">competition.php?competition=' . $compid .'</xsl:attribute>Up</a>
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