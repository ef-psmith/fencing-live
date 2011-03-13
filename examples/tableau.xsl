<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="col1size" select="number(8)"/>

<xsl:template match="tableau">
<html>
<head>
	<link rel="stylesheet" href="../css/live.css" type="text/css" />
</head>
<body>
<topdiv class="tableau" id="tableau" name="topdiv">
<pages>
	<xsl:for-each select="col1/match[@number mod $col1size = 1]">
		<xsl:sort select="@number" />
		<page>T<xsl:value-of select="(@number - 1) div $col1size" /></page>
	</xsl:for-each>
</pages>
<content>
	<xsl:for-each select="col1/match[@number mod $col1size = 1]">
	<div class="tableau">
		<xsl:attribute name="id">T<xsl:value-of select="(@number - 1) div $col1size" /></xsl:attribute>
		<xsl:if test="(@number -1) div $col1size > 0"><xsl:attribute name="class">tableau hidden</xsl:attribute></xsl:if>
		<div class="twocol1">
			<!-- **************************** HALF **************************** -->
			<xsl:apply-templates select="." mode="half" />
			<xsl:apply-templates select="../match[./@number mod 2 = 1 and ./@number &gt; current()/@number and ./@number &lt; (current()/@number + $col1size)]" mode="half" />
		</div>
		<div class="twocol">
			<!-- the starting number for div 2 should be ((@number + 1) / 2) -->
			<xsl:apply-templates 
				select="../../col2/match[./@number mod 2 = 1 and ./@number &lt; (((current()/@number + 1) div 2) + ($col1size div 2)) and ./@number &gt; ((current()/@number + 1) div 2) - 1]" 
				mode="half" 
			/>
		</div>
	</div>
	</xsl:for-each>
</content>
</topdiv>
</body>
</html>
</xsl:template>


<xsl:template match="match" mode="half">
	<!-- outputs a pair of matches enclosed in a "half" div -->
	<div class="half">
		<xsl:apply-templates select="." mode="render" />
		<xsl:apply-templates select="../match[current()/@number + 1]" mode="render" /> 
	</div>
</xsl:template>



<xsl:template match="match" mode="render">
	<!-- renders a match inside a "quarter" div -->
	<!-- *************************** QUARTER **************************** -->
	<div class="quarter">
		<!-- ************ BOUT ************ -->
		<div id="container"><div id="position">
			<div class="bout boutborder">
				<div class="A">
					<!-- attribute needed for "Winner" -->
				<div id="container"><div id="position">
					<span class="seed"><xsl:value-of select="fencerA/@seed" /></span>
					<span class="fencer "><xsl:value-of select="fencerA/@name" /></span>
					<span class="country"><xsl:value-of select="fencerA/@affiliation" /></span>
				</div></div>
				</div>
				<div class="boutinfo">
				<div id="container">
					<div id="position">
						<xsl:choose>
							<xsl:when test="@winner">
								<xsl:value-of select="@score" />
							</xsl:when>
							<xsl:otherwise>
								Piste: <xsl:value-of select="@piste" /><xsl:text> </xsl:text><xsl:value-of select="@heure" />
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
				</div>
				<div class="B">
				<div id="container"><div id="position">
					<span class="seed"><xsl:value-of select="fencerB/@seed" /></span>
					<span class="fencer "><xsl:value-of select="fencerB/@name" /></span>
					<span class="country"><xsl:value-of select="fencerB/@affiliation" /></span>
				</div></div>
				</div>
			</div> <!-- bout -->
		</div></div>	 <!-- container -->
		<!-- ************ END BOUT ************ -->
	</div> <!-- quarter -->
</xsl:template>

</xsl:stylesheet>
