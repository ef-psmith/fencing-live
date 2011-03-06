<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:variable name="pagesize" select="number(20)" />

<xsl:template match="fpp">
<topdiv class="vlist" name="topdiv" id="vlistid">
	<!-- This is the list of pages to scroll through -->
	<pages>
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<xsl:sort select="@sequence" />
			<page>FPP<xsl:value-of select="(@sequence - 1) div $pagesize" /></page>
		</xsl:for-each >
	</pages>
	<content>
	<!-- Display HTML starts here. 
			First the list header -->
<div class="vlist_title" id="vtitle"><h2>Fencers/Poules/Pistes</h2></div>
<div class="vlist_header" id="vheader">
		<table class="vlist_table">
			<tr>
			<td class="vlist_name">Name</td>
			<td class="vlist_club">Club</td>
			<td class="vlist_poule">Poule</td>
			<td class="vlist_piste">Piste</td>
		</tr>
	</table>
</div>
			
	<!-- Now the list contents -->
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<div class="vlist_body">
				<xsl:attribute name="id">FPP<xsl:value-of select="(@sequence - 1) div $pagesize" /></xsl:attribute>
				<table class="vlist_table">
					<xsl:apply-templates select="." mode="fppfencer" />
					<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + $pagesize) and ./@sequence &gt; current()/@sequence ]" mode="fppfencer" >
						<xsl:sort select="@sequence" data-type="number" />
					</xsl:apply-templates>
				</table>
			</div>
		</xsl:for-each >
	</content>
</topdiv>
</xsl:template>

<xsl:template match="fencer" mode="fppfencer">
		<tr >
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_club"><xsl:value-of select="@affiliation" /></td>
			<td class="vlist_poule"><xsl:value-of select="@poule" /></td>
			<td class="vlist_piste"><xsl:value-of select="@piste" /></td>
		</tr>
</xsl:template>


<xsl:template match="fencer" mode="wherefencer">
		<tr >
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_round"><xsl:value-of select="@round" /></td>
			<td class="vlist_piste"><xsl:value-of select="@piste" /></td>
			<td class="vlist_time"><xsl:value-of select="@time" /></td>
		</tr>
</xsl:template>

<xsl:template match="fencer" mode="finalfencer">
		<tr>
			<xsl:attribute name="class">elim_<xsl:value-of select="@elimround" /></xsl:attribute>
			<td class="vlist_postition"><xsl:value-of select="@position" /></td>
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_club"><xsl:value-of select="@affiliation" /></td>
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