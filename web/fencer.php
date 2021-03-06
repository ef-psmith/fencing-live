
<?php

	$compid = $_REQUEST['competition'];
	$fencerid = $_REQUEST['fencer'];
	$tournid = $_REQUEST['tournament'];

  	$xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"><xsl:output method="xml" />

<!-- Match every fencer -->
<xsl:template match="competition[@id = ' . $compid . ']/lists[@name=\'entry\']/fencer[@id = ' . $fencerid . ']">
<xsl:variable name="fencername" select="@name" />
<xsl:variable name="fencerid" select="' . $fencerid . '" />
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><xsl:value-of select="../../@titre_ligne"/></title>
<link href="./css/portal.css" rel="stylesheet" type="text/css" media="screen" />
</head>
<body>
<h1><xsl:value-of select="../../@titre_ligne"/></h1>
<h2><xsl:value-of select="$fencername"/></h2>

<xsl:if test="starts-with(../../@stage, \'poules\')">
<xsl:for-each select="../../pools/pool/fencers/fencer[@fencerid = $fencerid]">
<p><span class="info heading">Pool: <xsl:value-of select="@number" /> Piste: <xsl:value-of select="../../@piste" /></span></p>
</xsl:for-each>
</xsl:if>


<xsl:for-each select="../../lists[@name=\'ranking\' and @type=\'final\']/fencer[@id = $fencerid]">
<p><span class="info heading">Final Position: <xsl:value-of select="@position" /></span></p>
</xsl:for-each>


<xsl:if test="count(../../tableau/match[fencerA/@id = $fencerid or fencerB/@id = $fencerid]) > 0">
<p><span class="heading">Direct Elimination</span>
<table class="DE">
<tr><th class="DE">Round</th><th class="DE">Fencer</th><th class="DE">Score/Piste-Time</th><th class="DE">Fencer</th></tr>
<xsl:for-each select="../../tableau/match[fencerA/@id = $fencerid or fencerB/@id = $fencerid]">
<xsl:sort select="../@count" data-type="number"/>
<tr><td class="DE"><xsl:value-of select="../@title" /></td><td class="DE">
<xsl:choose>
<xsl:when test="string-length(fencerA/@name) > 0 and fencerA/@id = $fencerid"><xsl:value-of select="fencerA/@name" /></xsl:when>
<xsl:when test="string-length(fencerA/@name) > 0 and fencerA/@id != $fencerid"><a><xsl:attribute name="href">fencer.php?competition=' . $compid .'&amp;fencer=<xsl:value-of select="fencerA/@id" />&amp;tournament=' . $tournid .'</xsl:attribute><xsl:value-of select="fencerA/@name" /></a>
</xsl:when>
<xsl:otherwise>BYE</xsl:otherwise></xsl:choose>
</td>
<td class="DE score">
<xsl:choose>
<xsl:when test="string-length(@score) > 0 and string-length(fencerA/@name) > 0 and string-length(fencerB/@name) > 0"><xsl:value-of select="@score" /></xsl:when>
<xsl:when test="string-length(fencerB/@name) = 0 or string-length(fencerB/@name) = 0">-</xsl:when>
<xsl:otherwise><xsl:value-of select="@piste"/> - <xsl:value-of select="@time" /></xsl:otherwise>
</xsl:choose></td>
<td class="DE">
<xsl:choose>
<xsl:when test="string-length(fencerB/@name) > 0 and fencerB/@id = $fencerid"><xsl:value-of select="fencerB/@name" /></xsl:when>
<xsl:when test="string-length(fencerB/@name) > 0 and fencerB/@id != $fencerid"><a><xsl:attribute name="href">fencer.php?competition=' . $compid .'&amp;fencer=<xsl:value-of select="fencerB/@id" />&amp;tournament=' . $tournid .'</xsl:attribute><xsl:value-of select="fencerB/@name" /></a></xsl:when>
<xsl:otherwise>BYE</xsl:otherwise></xsl:choose>
</td></tr>
</xsl:for-each>
</table></p>
</xsl:if>

<xsl:for-each select="../../lists[@name=\'ranking\' and @type=\'pools\']/fencer[@id = $fencerid]">
<p><span class="info heading">Ranking after the Pools: <xsl:value-of select="@position" /></span></p>
</xsl:for-each>

<xsl:for-each select="../../pools/pool/fencers/fencer[@fencerid = $fencerid]">
<p class="heading">Round <xsl:value-of select="../../../@round"/> Poule <xsl:value-of select="../../@number"/>
<xsl:if test="string-length(@pl)>0">
<table class="DE">
<tr><th class="DE">V/M</th><th class="DE">Ind</th><th class="DE">HS</th><th class="DE">Place</th></tr>
<tr><td class="DE"><xsl:value-of select="@vm"/></td><td class="DE"><xsl:value-of select="@ind"/></td>
<td class="DE"><xsl:value-of select="@hs"/></td><td class="DE"><xsl:value-of select="@pl"/></td></tr>
</table>
</xsl:if>
<table class="DE">
<tr><th class="DE">Fencer</th><th colspan="2"  class="DE">Score</th><th class="DE">Opponent</th></tr>
<xsl:variable name="poolid" select="@id"/>
<xsl:for-each select="result[@id != current()/@id]">
<xsl:variable name="score" select="@score"/>
<xsl:for-each select="../../fencer[@id = current()/@id]/result[@id = $poolid]">
<tr><td class="DE"><xsl:value-of select="$fencername" /></td>
<xsl:choose>
<xsl:when test="string-length($score) > 0 and string-length(@score) > 0">
<td class="DE"><xsl:value-of select="$score" /></td><td class="DE"><xsl:value-of select="@score" /></td>
</xsl:when><xsl:otherwise><td class="DE score" colspan="2">-</td></xsl:otherwise></xsl:choose>
<td class="DE"><a><xsl:attribute name="href">fencer.php?competition=' . $compid .'&amp;fencer=<xsl:value-of select="../@fencerid" />&amp;tournament=' . $tournid .'</xsl:attribute><xsl:value-of select="../@name" /></a></td></tr>
</xsl:for-each>
</xsl:for-each>
</table></p>
</xsl:for-each>

<br />
<a><xsl:attribute name="href">competition.php?competition=' . $compid .'&amp;tournament=' . $tournid .'</xsl:attribute>Up to Fencers</a>
</body>
</html>
</xsl:template>


</xsl:stylesheet>';

  $xslt = new XSLTProcessor();
  $xslt->importStylesheet(new SimpleXMLElement($xslt_string));


   $xmlDoc = new DOMDocument();
   $xmlDoc->load($tournid. "/competitions/". $compid . ".xml");


  echo $xslt->transformToXml($xmlDoc);
  //echo $xslt_string;
?>