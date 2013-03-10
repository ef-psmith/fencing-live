
<?php
	$compid = $_REQUEST['competition'];
	$tournid = $_REQUEST['tournament'];

    $tabpage = $_COOKIE['tabpage'];

    if ("" == $tabpage) $tabpage="entry";


  $xslt_string = '<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />

<xsl:variable name="tabpage" select="\'' . $tabpage . '\'" />

<!-- Entry List -->
<xsl:template match="competition[@id = ' . $compid . ']">

<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head>
<title><xsl:value-of select="@titre_ligne"/></title>
<link href="./css/portal.css" rel="stylesheet" type="text/css" media="screen" />
<script type="text/javascript">

var curtab = \'<xsl:value-of select="$tabpage" />\';

function changeTab(pageid) {

   // Set the cookie to say that we are looking at that page
   document.cookie = \'tabpage\' + \'=\' + pageid;

   // Get the outer div that contains the pages
   var oldpage = document.getElementById(curtab).style.display = \'none\';
   var newpage = document.getElementById(pageid).style.display = \'block\';


  // Get the outer div that contains the pages
  var oldpage = document.getElementById(curtab + \'tab\').style.color = \'white\';
  var newpage = document.getElementById(pageid + \'tab\').style.color = \'black\';


   curtab = pageid;

}
</script>

</head>
<body>
<h1><xsl:value-of select="@titre_ligne"/></h1>
<p><a><xsl:attribute name="href">portal.php?tournament=' . $tournid .'</xsl:attribute>Up to all Competitions</a></p>

<ul>
<xsl:for-each select="lists[@name = \'ranking\' or @name = \'entry\']">
<li>
<a class="tabs">
<xsl:choose>
<xsl:when test="@name = \'ranking\' and @type = \'pools\'">
<xsl:attribute name="href">javascript:changeTab(\'pranking\')</xsl:attribute>
<xsl:attribute name="id">prankingtab</xsl:attribute>
<xsl:if test="\'pranking\' = $tabpage">
<xsl:attribute name="style">color:black;</xsl:attribute>
</xsl:if>
Ranking after the pools
</xsl:when>
<xsl:when test="@name = \'ranking\' and @type = \'final\'">
<xsl:attribute name="href">javascript:changeTab(\'franking\')</xsl:attribute>
<xsl:attribute name="id">frankingtab</xsl:attribute>
<xsl:if test="\'franking\' = $tabpage">
<xsl:attribute name="style">color:black;</xsl:attribute>
</xsl:if>
Final ranking
</xsl:when>
<xsl:when test="@name = \'entry\'">
<xsl:attribute name="href">javascript:changeTab(\'entry\')</xsl:attribute>
<xsl:attribute name="id">entrytab</xsl:attribute>
<xsl:if test="\'entry\' = $tabpage">
<xsl:attribute name="style">color:black;</xsl:attribute>
</xsl:if>
Entries
</xsl:when>
</xsl:choose>
</a>
</li>
</xsl:for-each>
</ul>
<br />
<div id="tabpages">
<xsl:apply-templates select="lists" />
</div>


<p><a><xsl:attribute name="href">portal.php?tournament=' . $tournid .'</xsl:attribute>Up to all Competitions</a></p>
</body>
</html>
</xsl:template>


<xsl:template match="competition[@id = ' . $compid . ']/lists[@name=\'entry\']">
<div id="entry">
<xsl:if test="\'entry\' != $tabpage">
<xsl:attribute name="style">display:none;</xsl:attribute>
</xsl:if>
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
</div>
</xsl:template>



<xsl:template match="competition[@id = ' . $compid . ']/lists[@name=\'ranking\' and @type=\'final\']">
<div id="franking">
<xsl:if test="\'franking\' != $tabpage">
<xsl:attribute name="style">display:none;</xsl:attribute>
</xsl:if>
<table class="entry">
<tr><th class="entry">Pos</th><th class="entry">Name</th><th class="entry">Club</th></tr>
<xsl:for-each select="fencer">
<xsl:sort select="@sequence" data-type="number" />
    <tr>
    <xsl:attribute name="class"><xsl:value-of select="@elimround" /></xsl:attribute>
    <td class="entry"><xsl:value-of select="@position" /></td>

    <td class="entry"><a><xsl:attribute name="href">fencer.php?competition=' . $compid . '&amp;fencer=<xsl:value-of select="@id"/>&amp;tournament=' . $tournid .'</xsl:attribute>
<xsl:value-of select="@name" /></a></td>
    <td class="entry"><xsl:value-of select="@affiliation" /></td>
</tr>
        </xsl:for-each>
</table>
</div>
</xsl:template>


<xsl:template match="competition[@id = ' . $compid . ']/lists[@name=\'ranking\' and @type=\'pools\']">
<div id="pranking">
<xsl:if test="\'pranking\' != $tabpage">
<xsl:attribute name="style">display:none;</xsl:attribute>
</xsl:if>
<table class="entry">
<tr><th class="entry">Pos</th><th class="entry">Name</th><th class="entry">Club</th><th class="entry">V/M</th><th class="entry">Ind</th><th class="entry">HS</th></tr>
<xsl:for-each select="fencer">
<xsl:sort select="@sequence" data-type="number" />
    <tr>
    <td class="entry"><xsl:value-of select="@position" /></td>

    <td class="entry"><a><xsl:attribute name="href">fencer.php?competition=' . $compid . '&amp;fencer=<xsl:value-of select="@id"/>&amp;tournament=' . $tournid .'</xsl:attribute>
<xsl:value-of select="@name" /></a></td>
    <td class="entry"><xsl:value-of select="@affiliation" /></td>
    <td class="entry"><xsl:value-of select="@vm" /></td>
    <td class="entry"><xsl:value-of select="@ind" /></td>
    <td class="entry"><xsl:value-of select="@hs" /></td>
</tr>
        </xsl:for-each>
</table>
</div>
</xsl:template>


</xsl:stylesheet>';

  $xslt = new XSLTProcessor();
  $xslt->importStylesheet(new SimpleXMLElement($xslt_string));


   $xmlDoc = new DOMDocument();
   $xmlDoc->load($tournid . "/competitions/". $compid . ".xml");

//echo $xslt_string;
  echo $xslt->transformToXml($xmlDoc);
?>