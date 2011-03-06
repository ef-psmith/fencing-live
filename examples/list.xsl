<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="pagesize" select="number(20)" />

<xsl:template match="fpp">
<topdiv class="vlist" name="topdiv" id="fpp">
	<pages>
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<xsl:sort select="@sequence" />
			<page>FPP<xsl:value-of select="(@sequence - 1) div $pagesize" /></page>
		</xsl:for-each >
	</pages>
	<content>
		<xsl:apply-templates select="fencer[@sequence mod $pagesize = 1]" mode="fpplist"/>
	</content>
</topdiv>
</xsl:template>

<xsl:template match="fencer" mode="fpplist">
		<div class="vlist">
			<table>
				<xsl:attribute name="id">FPP<xsl:value-of select="(@sequence - 1) div $pagesize" /></xsl:attribute>
				<xsl:apply-templates select="." mode="fppfencer" />
				<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + $pagesize) and ./@sequence &gt; current()/@sequence ]" mode="fppfencer" >
					<xsl:sort select="@sequence" data-type="number" />
				</xsl:apply-templates>
			</table>
		</div>
</xsl:template>

<xsl:template match="fencer" mode="fppfencer">
		<tr >
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_club"><xsl:value-of select="@affiliation" /></td>
			<td class="vlist_poule"><xsl:value-of select="@poule" /></td>
			<td class="vlist_piste"><xsl:value-of select="@piste" /></td>
		</tr>
</xsl:template>


<xsl:template match="ranking">
	<xsl:text disable-output-escaping="yes">
		&lt;div class=&quot;vlist2&quot; id=&quot;V0&quot;&gt;
		&lt;table class=&quot;vlist_table&quot;&gt;
	</xsl:text>
	
	<xsl:apply-templates select="fencer">
		<xsl:sort select="@sequence" />
	</xsl:apply-templates>
	<xsl:text disable-output-escaping="yes">
		&lt;/table&gt;
		&lt;/div&gt;
	</xsl:text>
</xsl:template>



</xsl:stylesheet>