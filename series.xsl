<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" />

<!-- Global variables for controlling the display parameters -->
<xsl:variable name="pagesize" select="number(40)" />
<xsl:variable name="entrysize" select="number(138)" />
<xsl:variable name="poolsperpage" select="number(2)"/>
<xsl:variable name="col1size" select="number(4)"/>


<!-- **********************************************************************************
	LISTS
*************************************************************************************** -->
<!-- Entry List -->
<xsl:template match="lists/entry">
<topdiv name="topdiv" id="vlistid" class="vlist_entry">
	<!-- This is the list of pages to scroll through -->
	<pages>
		<xsl:for-each select="fencer[@sequence mod ($entrysize ) = 1]">
			<xsl:sort select="@sequence" data-type="number"/>
			<page>EN<xsl:value-of select="(@sequence - 1) div ($entrysize)" /></page>
		</xsl:for-each >
	</pages>
	<content>
	<!-- Display HTML starts here. 
			First the list header -->
<div class="vlist_title" id="vtitle"><h2>Entry List for <xsl:value-of select="../../@titre_ligne" /></h2></div>

<xsl:for-each select="fencer[@sequence mod ($entrysize) = 1]">

				<div>
					<xsl:if test="@sequence != 1"><xsl:attribute name="class">col_multi  hidden</xsl:attribute></xsl:if>
					<xsl:if test="@sequence  = 1"><xsl:attribute name="class">col_multi visible</xsl:attribute></xsl:if>
					<xsl:attribute name="id">EN<xsl:value-of select="(@sequence - 1) div $entrysize" /></xsl:attribute>
			<!-- Now the list contents -->
					<xsl:apply-templates select="." mode="entryfencer" />
					<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + ($entrysize)) and ./@sequence &gt; current()/@sequence ]" mode="entryfencer" >
						<xsl:sort select="@sequence" data-type="number" />
					</xsl:apply-templates>
				</div>			
		</xsl:for-each>
	</content>
</topdiv>
</xsl:template>

<xsl:template match="fencer" mode="entryfencer">
<span class="elim_p">	<span class="col_name"><xsl:value-of select="@name" /></span>
	<span class="col_club"><xsl:value-of select="@affiliation" /><xsl:if test="string-length(@affiliation) = 0"><span style="display:none">NONE</span></xsl:if></span></span>
</xsl:template>


<xsl:template match="lists/fpp">
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
<div class="vlist_title" id="vtitle"><h2>Fencers/Pools/Pistes</h2></div>
<div class="vlist_header" id="vheader">
		<table class="vlist_table">
			<tr>
			<td class="vlist_name">Name</td>
			<td class="vlist_club">Club</td>
			<td class="vlist_poule">Pool</td>
			<td class="vlist_piste">Piste</td>
		</tr>
	</table>
</div>
			
	<!-- Now the list contents -->
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<div>
				<xsl:attribute name="id">FPP<xsl:value-of select="(@sequence - 1) div $pagesize" /></xsl:attribute>
				<xsl:if test="@sequence != 1"><xsl:attribute name="class">vlist_body hidden</xsl:attribute></xsl:if>
				<xsl:if test="@sequence  = 1"><xsl:attribute name="class">vlist_body visible</xsl:attribute></xsl:if>
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

<xsl:template match="lists/where">
<topdiv class="vlist2" name="topdiv" id="vlistid2">
	<!-- This is the list of pages to scroll through -->
	<pages>
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<xsl:sort select="@sequence" />
			<page>WH<xsl:value-of select="(@sequence - 1) div $pagesize" /></page>
		</xsl:for-each >
	</pages>
	<content>
	<!-- Display HTML starts here. 
			First the list header -->
<div class="vlist_title" id="vtitle"><h2>Where should I be?</h2></div>
<div class="vlist_header" id="vheader">
		<table class="vlist_table">
			<tr>
			<td class="vlist_name">Name</td>
			<td class="vlist_round">Round</td>
			<td class="vlist_piste">Piste</td>
			<td class="vlist_time">Time</td>
		</tr>
	</table>
</div>
			
	<!-- Now the list contents -->
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<div>
				<xsl:attribute name="id">WH<xsl:value-of select="(@sequence - 1) div $pagesize" /></xsl:attribute>
				<xsl:if test="@sequence != 1"><xsl:attribute name="class">vlist_body hidden</xsl:attribute></xsl:if>
				<xsl:if test="@sequence  = 1"><xsl:attribute name="class">vlist_body visible</xsl:attribute></xsl:if>
				<table class="vlist_table">
					<xsl:apply-templates select="." mode="wherefencer" />
					<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + $pagesize) and ./@sequence &gt; current()/@sequence ]" mode="wherefencer" >
						<xsl:sort select="@sequence" data-type="number" />
					</xsl:apply-templates>
				</table>
			</div>
		</xsl:for-each >
	</content>
</topdiv>
</xsl:template>

<xsl:template match="fencer" mode="wherefencer">
		<tr >
			<td class="vlist_name"><xsl:value-of select="@name" /></td>
			<td class="vlist_round"><xsl:value-of select="@round" /></td>
			<td class="vlist_piste"><xsl:value-of select="@piste" /></td>
			<td class="vlist_time"><xsl:value-of select="@time" /></td>
		</tr>
</xsl:template>

<!-- Ranking list after the poules-->
<xsl:template match="lists/ranking">
<xsl:choose>
<xsl:when test="../../lists/where">
<topdiv class="vlist_ranking" name="topdiv" id="vlistid">
	<!-- This is the list of pages to scroll through -->
	<pages>
		<xsl:for-each select="fencer[@sequence mod ($pagesize) = 1]">
			<xsl:sort select="@sequence" />
			<page>RK<xsl:value-of select="(@sequence - 1) div $pagesize" /></page>
		</xsl:for-each >
	</pages>
	<content>
	<!-- Display HTML starts here. 
			First the list header -->
<div class="vlist_title" id="vtitle"><h2>Ranking</h2></div>
<div class="vlist_header" id="vheader">
		<table class="vlist_table">
			<tr>
			<td class="vlist_position">Pos</td>
			<td class="vlist_name">Name</td>
			<td class="vlist_club">Club</td>
		</tr>
	</table>
</div>
<!-- Now the list contents -->
		<xsl:for-each select="fencer[@sequence mod $pagesize = 1]">
			<div>
				<xsl:attribute name="id">RK<xsl:value-of select="(@sequence - 1) div $pagesize" /></xsl:attribute>
				<xsl:if test="@sequence != 1"><xsl:attribute name="class">vlist_body hidden</xsl:attribute></xsl:if>
				<xsl:if test="@sequence  = 1"><xsl:attribute name="class">vlist_body visible</xsl:attribute></xsl:if>
				<table class="vlist_table">
				<xsl:apply-templates select="." mode="finalfencer" />
				<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + ($pagesize * 2)) and ./@sequence &gt; current()/@sequence ]" mode="finalfencer" >
					<xsl:sort select="@sequence" data-type="number" />
				</xsl:apply-templates>
				</table>
			</div>
		</xsl:for-each >
	</content>
</topdiv>



</xsl:when>
<xsl:otherwise>
<topdiv class="vlist_ranking2" name="topdiv" id="vlistid">
	<!-- This is the list of pages to scroll through -->
	<pages>
		<xsl:for-each select="fencer[@sequence mod ($pagesize * 2) = 1]">
			<xsl:sort select="@sequence" />
			<page>RK<xsl:value-of select="(@sequence - 1) div ($pagesize * 2) " /></page>
		</xsl:for-each >
	</pages>
	<content>
	<!-- Display HTML starts here. 
			First the list header -->
<div class="vlist_title" id="vtitle"><h2>Ranking</h2></div>
<!-- Now the list contents -->
		<xsl:for-each select="fencer[@sequence mod ($pagesize * 2)  = 1]">
			<div>
				<xsl:attribute name="id">RK<xsl:value-of select="(@sequence - 1) div ($pagesize * 2)" /></xsl:attribute>
				<xsl:if test="@sequence != 1"><xsl:attribute name="class">col_multi2 hidden</xsl:attribute></xsl:if>
				<xsl:if test="@sequence  = 1"><xsl:attribute name="class">col_multi2 visible</xsl:attribute></xsl:if>
				<xsl:apply-templates select="." mode="finalfencer2" />
				<xsl:apply-templates select="../fencer[./@sequence &lt; (current()/@sequence + ($pagesize * 2)) and ./@sequence &gt; current()/@sequence ]" mode="finalfencer2" >
					<xsl:sort select="@sequence" data-type="number" />
				</xsl:apply-templates>
			</div>
		</xsl:for-each >
	</content>
</topdiv>

</xsl:otherwise>
</xsl:choose>
		
</xsl:template>

<xsl:template match="fencer" mode="finalfencer">
		<tr>
			<xsl:attribute name="class"><xsl:value-of select="@elimround" /></xsl:attribute>
			<td class="vlist_position"><xsl:value-of select="@position" /></td>
			<td class="vlist_name"><xsl:value-of select="substring(@name,1,17)" /></td>
			<td class="vlist_club"><xsl:value-of select="substring(@affiliation,1,20)" /></td>
		</tr>
</xsl:template>


<xsl:template match="fencer" mode="finalfencer2">
		<span>
			<xsl:attribute name="class"><xsl:value-of select="@elimround" /></xsl:attribute>
			<span class="col_rank"><xsl:value-of select="@position" /></span>
			<span class="col_name"><xsl:value-of select="substring(@name,1,17)" /></span>
			<span class="col_club"><xsl:value-of select="substring(@affiliation,1,20)" /></span>
		</span>
</xsl:template>

<!-- **********************************************************************************
	POULES
*************************************************************************************** -->

<xsl:template match="pools">
<topdiv class="poule" id="pools" name="topdiv">
<pages>
	<xsl:for-each select="pool[@number mod $poolsperpage = 1]">
		<xsl:sort select="@number" data-type="number"/>
		<page>P<xsl:value-of select="(@number - 1) div $poolsperpage" /></page>
	</xsl:for-each>
</pages>
<content>
<h1><xsl:value-of select="../@titre_ligne" /> &#x2014; <xsl:value-of select="count(pool)" /> Pools</h1>
	<xsl:for-each select="pool[@number mod $poolsperpage = 1]" >
		<div class="poulediv">
			<xsl:attribute name="id">P<xsl:value-of select="(@number - 1) div $poolsperpage" /></xsl:attribute>
			<xsl:if test="@number != 1"><xsl:attribute name="class">poulediv hidden</xsl:attribute></xsl:if>
			<xsl:if test="@number  = 1"><xsl:attribute name="class">poulediv visible</xsl:attribute></xsl:if>
			<!--<h2>Poules <xsl:value-of select="@number" /> <xsl:if test="../pool[./@number = current()/@number + 1]">&#160;and <xsl:value-of select="@number + 1" /></xsl:if></h2>-->
			<xsl:apply-templates select="." mode="render" />
			<xsl:apply-templates select="../pool[./@number &lt; (current()/@number + $poolsperpage) and ./@number &gt; current()/@number ]" mode="render" >
				<xsl:sort select="@number" data-type="number" />
			</xsl:apply-templates>
		</div>
	</xsl:for-each>
</content>
</topdiv>
</xsl:template>

<xsl:template match="pool" mode="render">
	<h2>Pool <xsl:value-of select="@number" /></h2>
	
	<table	class="pouletable">
		<tr>
			<th class="poule-title-name">name</th>
			<th class="poule-title-club">club</th>
			<th class="poule-title-blank"></th>
			<th class="poule-title-result">1</th>
			<th class="poule-title-result">2</th>
			<th class="poule-title-result">3</th>
			<th class="poule-title-result">4</th>
			<xsl:if test="@size &gt; 4">	
				<th class="poule-title-result">5</th>
			</xsl:if>	
			<xsl:if test="@size &gt; 5">
				<th class="poule-title-result">6</th>
			</xsl:if>
			<xsl:if test="@size &gt; 6">
				<th class="poule-title-result">7</th>
			</xsl:if>
			<xsl:if test="@size &gt; 7">
				<th class="poule-title-result">8</th>
			</xsl:if>
			<th class="poule-title-blank"></th>
			<th class="poule-title-vm">vm</th>
			<th class="poule-title-hs">hs</th>
			<th class="poule-title-ind">ind</th>
			<th class="poule-title-pl">pl</th>
		</tr>
    
		<xsl:for-each select="fencers/fencer">
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
						<td class="poule-grid-result"><xsl:choose><xsl:when test="string-length(@score) > 0"><xsl:value-of select="@score"/></xsl:when><xsl:otherwise>&#160;</xsl:otherwise></xsl:choose></td>
					</xsl:otherwise>	
				</xsl:choose>
			</xsl:for-each>
			
			<td class="poule-grid-emptycol"></td>
			<td class="poule-grid-vm"><xsl:choose><xsl:when test="string-length(@vm) > 0"><xsl:value-of select="@vm" /></xsl:when><xsl:otherwise>&#160;</xsl:otherwise></xsl:choose></td>
			<td class="poule-grid-hs"><xsl:choose><xsl:when test="string-length(@hs) > 0"><xsl:value-of select="@hs" /></xsl:when><xsl:otherwise>&#160;</xsl:otherwise></xsl:choose></td>
			<td class="poule-grid-ind"><xsl:choose><xsl:when test="string-length(@ind) > 0"><xsl:value-of select="@ind" /></xsl:when><xsl:otherwise>&#160;</xsl:otherwise></xsl:choose></td>
			<td class="poule-grid-pl"><xsl:choose><xsl:when test="string-length(@pl) > 0"><xsl:value-of select="@pl"/></xsl:when><xsl:otherwise>&#160;</xsl:otherwise></xsl:choose></td>
		</tr>
		</xsl:for-each>
	</table>

</xsl:template>


<!-- **********************************************************************************
	TABLEAU
*************************************************************************************** -->

<xsl:template match="tableau">
<topdiv class="tableau" id="tableau" name="topdiv">
<pages>
	<xsl:for-each select="col1/match[@number mod $col1size = 1]">
		<xsl:sort select="col1/match/@number" />
		<page>T<xsl:value-of select="(@number - 1) div $col1size" /></page>
	</xsl:for-each>
</pages>
<content>
<h1><xsl:value-of select="../@titre_ligne" /></h1>
	<xsl:for-each select="col1/match[@number mod $col1size = 1]">
	<div class="tableaudiv">
		<xsl:attribute name="id">T<xsl:value-of select="(@number - 1) div $col1size" /></xsl:attribute>
		<xsl:if test="(@number -1) div $col1size > 0"><xsl:attribute name="class">tableaudiv hidden</xsl:attribute></xsl:if>
		<div class="tableautitle">
		   <p class="tableautitlepart"><xsl:value-of select="../../@title"/></p>
			<xsl:if test="count(../match[@number > $col1size]) > 0">
				<p class="tableautitlepart">Part <xsl:value-of select="((@number - 1) div $col1size) + 1" /> of  <xsl:value-of select="count(../match) div $col1size" /></p>
			</xsl:if>
		</div>
		<div class="twocol1">
			<!-- **************************** HALF **************************** -->
			<div class="half">
				<!-- *************************** QUARTER **************************** -->
				<div class="quarter">
					<xsl:apply-templates select="." mode="render" />
				</div>
	
				<!-- *************************** QUARTER **************************** -->
				<div class="quarter">
					<xsl:apply-templates select="../match[current()/@number + 1]" mode="render" /> 
				</div>
			</div>
<xsl:if test="count(../match[./@number mod 2 = 1 and ./@number &gt; current()/@number and ./@number &lt; (current()/@number + $col1size)]) &gt; 0">
			<div class="half">
				<!-- *************************** QUARTER **************************** -->
				<div class="quarter">
					<xsl:apply-templates select="../match[./@number mod 2 = 1 and ./@number &gt; current()/@number and ./@number &lt; (current()/@number + $col1size)]" mode="render" />
				</div>
				<!-- *************************** QUARTER **************************** -->
				<div class="quarter">
					<xsl:apply-templates select="../match[./@number mod 2 = 0 and ./@number &gt; current()/@number + 2 and ./@number &lt; (current()/@number + $col1size)]"  mode="render" /> 
				</div>
			</div>
</xsl:if>
		</div>
<xsl:if test="../../col2">
		<div class="twocol">
			<!-- the starting number for div 2 should be ((@number + 1) / 2) -->
<xsl:if test="count(../../col2/match[./@number mod 2 = 1 and ./@number &lt; (((current()/@number + 1) div 2) + ($col1size div 2)) and ./@number &gt; ((current()/@number + 1) div 2) - 1]) &gt; 0">
			<div class="half">
				<xsl:apply-templates select="../../col2/match[./@number mod 2 = 1 and ./@number &lt; (((current()/@number + 1) div 2) + ($col1size div 2)) and ./@number &gt; ((current()/@number + 1) div 2) - 1]" mode="render" />
				<xsl:apply-templates select="../../col2/match[./@number mod 2 = 0 and ./@number &lt; (((current()/@number + 1) div 2) + ($col1size div 2)) and ./@number &gt; ((current()/@number + 1) div 2) - 1]" mode="render" /> 
			</div>
</xsl:if>
		</div>
</xsl:if>
	</div>
	</xsl:for-each>
</content>
</topdiv>
</xsl:template>

<xsl:template match="match" mode="render">
		<!-- ************ BOUT ************ -->
		<div id="container"><div id="position">
			<div class="bout boutborder">
				<div class="A">
<xsl:if test="./@winnerid = fencerA/@id"><xsl:attribute name="class">A winner</xsl:attribute></xsl:if>
					<div id="container">
						<div id="position">
							<xsl:choose>
							<xsl:when test="name(..) = 'col2'">
									<span style="display:none;">&#160;</span>
								</xsl:when>
								<xsl:otherwise>
							<span class="seed"><xsl:value-of select="fencerA/@seed" /></span>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="string-length(fencerA/@name) &gt; 0">
								<span class="fencer ">
<xsl:value-of select="substring(fencerA/@name,1,17)" />  </span>
							</xsl:if>
						</div>
					</div>
				</div>
				<div class="boutinfo">
					<div id="container">
						<div id="position">
							<xsl:choose>
								<xsl:when test="string-length(@winnername) &gt; 0 and string-length(@score) != 0">
									<xsl:value-of select="@score" />
								</xsl:when>
								<xsl:when test="string-length(@winnername) &gt; 0">
									Bye
								</xsl:when>
								<xsl:when test="string-length(@piste) != 0">
									Piste: <xsl:value-of select="@piste" /><xsl:text> </xsl:text><xsl:value-of select="@time" />
								</xsl:when>
								<xsl:otherwise>
									&#160;
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</div>
				<div class="B">
<xsl:if test="./@winnerid = fencerB/@id"><xsl:attribute name="class">B winner</xsl:attribute></xsl:if>
					<div id="container">
						<div id="position">
							<xsl:choose>
							<xsl:when test="name(..) = 'col2'">
									<span style="display:none;">&#160;</span>
								</xsl:when>
								<xsl:otherwise>
							<span class="seed"><xsl:value-of select="fencerB/@seed" /></span>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="string-length(fencerB/@name) &gt; 0">
							<span class="fencer "><xsl:value-of select="substring(fencerB/@name,1,17)" /></span>
							</xsl:if>
						</div>
					</div> <!-- container -->
				</div>
			</div> <!-- bout -->
		</div></div>	 <!-- container -->
		<!-- ************ END BOUT ************ -->
</xsl:template>

</xsl:stylesheet>
