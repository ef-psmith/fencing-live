<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="pagesize" select="number(20)" />

<xsl:template match="fpp">
	<xsl:text disable-output-escaping="yes">
		&lt;div class=&quot;vlist&quot; id=&quot;V0&quot;&gt;
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


<xsl:template match="fpp/fencer">
	<!-- <xsl:for-each select="fencer">
	<xsl:sort select="sequence" /> -->
		<tr >
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_club"><xsl:value-of select="@affiliation" /></td>
			<td class="vlist_poule"><xsl:value-of select="@poule" /></td>
			<td class="vlist_piste"><xsl:value-of select="@piste" /></td>
		</tr>
	<!-- </xsl:for-each> -->
	
	<xsl:if test="@sequence mod $pagesize = 0">
		<xsl:text disable-output-escaping="yes">
			&lt;/table&gt;
			&lt;/div&gt;
			&lt;div class=&quot;vlist hidden&quot; id=&quot;V
		</xsl:text>
		<xsl:value-of select="@sequence div 4" />
		<xsl:text disable-output-escaping="yes">
			&quot;&gt;
			&lt;table class=&quot;vlist_table&quot;&gt;
		</xsl:text>
	</xsl:if>
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