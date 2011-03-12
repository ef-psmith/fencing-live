<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="col1matches" select="number(8)"/>

<xsl:template match="tableau">
<html>
<head>
	<link rel="stylesheet" href="../css/live.css" type="text/css" />
</head>
<body>
<topdiv class="tableau hidden" id="tableau" name="topdiv">
<pages>
	<xsl:for-each select="match[@number mod $col1matches = 1]">
		<xsl:sort select="@number" />
		<page>T<xsl:value-of select="(@number - 1) div $col1matches" /></page>
	</xsl:for-each>
</pages>
<content>
	<xsl:for-each select="match[@number mod $col1matches = 1]">
	<div class="tableau">
		<xsl:attribute name="id">T<xsl:value-of select="(@number - 1) div $col1matches" /></xsl:attribute>
		<xsl:if test="(@number -1) div $col1matches > 0"><xsl:attribute name="class">tableau hidden</xsl:attribute></xsl:if>
		<div class="twocol1">
			<!-- **************************** HALF **************************** -->
			<div class="half">
				<xsl:apply-templates select="." mode="half" />
			</div>
			<div class="half">
				<xsl:apply-templates select="../match[current()/@number + 2]" mode="half" />
			</div>
		</div>
	</div>
	</xsl:for-each>
</content>
</topdiv>
</body>
</html>
</xsl:template>


<xsl:template match="match" mode="half">
		<xsl:apply-templates select="." mode="render" />
		<xsl:apply-templates select="../match[current()/@number + 1]" mode="render" > 
			<xsl:sort select="@number" data-type="number" />
		</xsl:apply-templates>
	
</xsl:template>



<xsl:template match="match" mode="render">
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
