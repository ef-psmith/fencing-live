<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="pool">
	<h1>Pool <xsl:value-of select="number" /></h1>
	<table class="poule">
		<tr>
			<th class="poule-title-name">name</th>
			<th class="poule-title-club">club</th>
			<th class="poule-title-blank"></th>
			<th class="poule-title-result">1</th>
			<th class="poule-title-result">2</th>
			<th class="poule-title-result">3</th>
			<th class="poule-title-result">4</th>
			<xsl:if test="size &gt; 4">	
				<th class="poule-title-result">5</th>
			</xsl:if>	
			<xsl:if test="size &gt; 5">
				<th class="poule-title-result">6</th>
			</xsl:if>
			<xsl:if test="size &gt; 6">
				<th class="poule-title-result">7</th>
			</xsl:if>
			<xsl:if test="size &gt; 7">
				<th class="poule-title-result">8</th>
			</xsl:if>
			<th class="poule-title-blank"></th>
			<th class="poule-title-vm">vm</th>
			<th class="poule-title-hs">hs</th>
			<th class="poule-title-ind">ind</th>
			<th class="poule-title-pl">pl</th>
		</tr>
    
		<xsl:for-each select="fencer">
		<xsl:sort select="@id" />
		<tr>
			<td class="poule-grid-name"><xsl:value-of select="@name"/></td>
			<td class="poule-grid-club"><xsl:value-of select="@affiliation"/></td>
			<td class="poule-grid-emptycol"></td>
			
			<xsl:for-each select="result">
			<xsl:sort select="@id" />
				<xsl:choose>
					<xsl:when test="../@id = @id">
						<td class="poule-grid-blank"></td>
					</xsl:when>
					<xsl:otherwise>
						<td class="poule-grid-result"><xsl:value-of select="@score"/></td>
					</xsl:otherwise>	
				</xsl:choose>
			</xsl:for-each>
			
			<td class="poule-grid-emptycol"></td>
			<td class="poule-grid-vm"><xsl:value-of select="vm" /></td>
			<td class="poule-grid-hs"><xsl:value-of select="hs" /></td>
			<td class="poule-grid-ind"><xsl:value-of select="hs - hr" /></td>
			<td class="poule-grid-pl"><xsl:value-of select="pl"/></td>
		</tr>
		</xsl:for-each>
	</table>
</xsl:template>

</xsl:stylesheet>