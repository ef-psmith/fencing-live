#!/opt/bin/perl -w
# (c) Copyright Oliver Smith & Peter Smith 2007-2010 
# oliver_rps@yahoo.co.uk

# modified to reduce the amount of info needed in the config file by
# having a standard layout for each stage of the competition based on the "whereami" output
# as follows
#
#
#	poules not drawn	-	check-in list
#	poules drawn		-	fencers, poules, pistes
#	poules in progress	-	poules + fpp
#	poules finished		-	poules + ranking 
#	tableau drawn		-	tableau + final ranking

# for dev purposes (mostly)
use lib "../lib";
use lib "../eng-perl";

use strict;
use Engarde;
use Data::Dumper;

use XML::Simple;
# use IO::Handle;

use vars qw($pagedetails);

$Engarde::DEBUGGING=2;

##################################################################################
# writeToFiles
##################################################################################
sub writeToFiles 
{
   my $text = shift;
   my $writexml = shift;
   
   print WEBPAGE $text;
   
   if ($writexml ne 0)
   {
      print XMLPAGE $text;
   }
}

##################################################################################
# writeTableauMatch
##################################################################################
sub writeTableauMatch 
{
	my $bout = shift;
	my $roundnumber = shift;

	my $tab = $roundnumber == 1 ? "" : "\t";
	my $noseed = $roundnumber == 1 ? "" : "noseed";

	# print "writeTableauMatch: bout = " . Dumper(\$bout);

	writeToFiles("$tab\t\t<!-- ************ BOUT ************ -->\n", 0);
	writeToFiles("$tab\t\t<div id=\"container\"><div id=\"position\">\n",1);
	writeToFiles("$tab\t\t\t<div class=\"bout\">\n",1);						# BOUT 

	foreach my $key (qw/A B/)
	{
		my $fencer = $bout->{'fencer' . $key};
		my $seed = $bout->{'seed' . $key};

		if (!defined($fencer)) 
		{
			$fencer = '&#160;';
			# $seed = '';
		}
		my $result = "";

		$result = "winner" if (defined($bout->{'winner'}) && $bout->{'winner'} eq $fencer);

		writeToFiles("$tab\t\t\t\t<div class=\"$key $result\">\n",1);
		writeToFiles("$tab\t\t\t\t<div id=\"container\"><div id=\"position\">\n",1);

		writeToFiles("$tab\t\t\t\t\t<span class=\"seed\">$seed</span>\n",1) if $roundnumber == 1;
		
		writeToFiles("$tab\t\t\t\t\t<span class=\"fencer $noseed\">$fencer</span>\n",1);

		if ($roundnumber == 1) 
		{
			my $country = $bout->{'nation' . $key};

			if (defined($country)) 
			{
				writeToFiles("$tab\t\t\t\t\t<span class=\"country\">$country</span>\n",1);
			}
		} 

		writeToFiles("$tab\t\t\t\t</div></div>\n",1);
		writeToFiles("$tab\t\t\t\t</div>\n",1);

		my $title = "";

		if ($key eq "A")
		{
			if ($bout->{'winner'})
			{
				if ($bout->{'fencerA'} && $bout->{'fencerB'})
				{
					$title = "$bout->{'scoreA'} / $bout->{'scoreB'}";
					$title = "by exclusion" if $title =~ /exclusion/;
					$title = "by abandonment" if $title =~ /abandon/;
					$title = "by penalty" if $title =~ /forfait/;
				}
				else
				{  
				   $title = "&#160;";
				}
			}
			else
			{
				$title = "Piste: " . $bout->{'piste'} if $bout->{'piste'};
				$title .= " Time: $bout->{'time'}" if $bout->{'time'} && $bout->{'time'} ne "0:00";
				$title .= "&#160;";
			}

			writeToFiles("$tab\t\t\t\t<div class=\"boutinfo\">\n", 1);			
			writeToFiles("$tab\t\t\t\t<div id=\"container\"><div id=\"position\">$title</div></div>\n", 1);
			writeToFiles("$tab\t\t\t\t</div>\n", 1);
		}
	} 

	writeToFiles("$tab\t\t\t</div> <!-- bout -->\n", 1);   # close BOUT div
	writeToFiles("$tab\t\t</div></div>  <!-- container -->\n", 1);								# close 4th DIV
	writeToFiles("$tab\t\t<!-- ************ END BOUT ************ -->\n\n", 1);
}

##################################################################################
# writeBlurb
##################################################################################
# Write the blurb at the top of the file
sub writeBlurb 
{
	# print "writeBlurb: starting\n";

	my $page = shift;
	my $hastableau = shift;
	my $haspoules = shift;
	my $vertlist = shift;
	my $hasmidlist = shift;

	# print "writeBlurb: page = " . Dumper(\$page);
   
	my $nextpage = $page->{'nextpage'};
	my $pagetitle = $page->{'pagetitle'};
	my $refresh = $page->{'refresh_time'};
	my $layout = $page->{'layout'};
	my $bkcolour = $page->{'background'};
	my $csspath = $page->{'csspath'};
	my $scriptpath = $page->{'scriptpath'};

	# DO NOT ADD A "DOCTYPE" LINE 
	# We need the browser to be in quirks mode for some of the CSS layout to work properly 
	# and any DOCTYPE causes firefox to operate in strict mode
	print WEBPAGE "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n";
	
	print WEBPAGE "<head>\n";
	
	print WEBPAGE "<title>$pagetitle</title>\n";

	print WEBPAGE "<META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\">\n";
	print WEBPAGE "<META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">\n";

	print WEBPAGE "<style type=\"text/css\">\n\t#top, #bottom, #left, #right { background: $bkcolour;}\n</style>\n";

	print WEBPAGE "<link href=\"".$csspath."live.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";

	print WEBPAGE "<script type=\"text/javascript\">\n";
	print WEBPAGE "\tvar next_location=\"$nextpage\";\n";
	
	
   	print WEBPAGE "\tfunction finished_callback() {\n";
	print WEBPAGE "\t\twindow.location.replace(next_location);\n\t}\n";
	print WEBPAGE "\tvar areas = [\n";
	if ($hastableau)
	{
	   print WEBPAGE "\t\t{\n\t\t\t'prefix': 'T',\n\t\t\t'titleprefix':'TT',\n\t\t\t'finished': false,\n\t\t\t'currentvalue':0\n\t\t}\n";
	   print WEBPAGE "\t\t,\n\t\t{\n\t\t\t'prefix': 'M',\n\t\t\t'finished': false,\n\t\t\t'currentvalue':0\n\t\t}\n";
	   if (defined($vertlist) || $haspoules)
	   {
	      print WEBPAGE "\t\t,\n";
	   }
	}
	if ($haspoules)
	{
	   print WEBPAGE "\t\t{\n\t\t\t'prefix': 'T',\n\t\t\t'statics': ['ptitle'],\n\t\t\t'finished': false,\n\t\t\t'currentvalue':0\n\t\t}\n";
	   if (defined($vertlist))
	   {
	      print WEBPAGE "\t\t,\n";
	   }
	}
	if (defined($vertlist))
	{
	   print WEBPAGE "\t\t{\n\t\t\t'prefix': 'V',\n\t\t\t'statics': ['vtitle', 'vheader'],\n\t\t\t'finished': false,\n\t\t\t'currentvalue': 0\n\t\t}\n";
	}
	print WEBPAGE "\t\t];\n</script>\n";

	# this must come after the local variables above and for some reason the XHTML closure doesn't 
	# always work so we need to use </script> in full
	print WEBPAGE "<script src=\"".$scriptpath."scroll.js\" type=\"text/javascript\"></script>\n";
	print WEBPAGE "</head>\n";
	print WEBPAGE "<body onload=\"onPageLoaded()\">\n";
	
	print WEBPAGE "<div id=\"left\"></div>\n";
	print WEBPAGE "<div id=\"right\"></div>\n";
	print WEBPAGE "<div id=\"top\"></div>\n";
	print WEBPAGE "<div id=\"bottom\"></div>\n";

   # Now the XML header blurb
   print XMLPAGE '<?xml version="1.0" ?>'."\n<returndata>\n";
   
   
	print XMLPAGE "<page backcolour=\"" . $page->{'background'}. "\" title=\"" . $page->{'pagetitle'} . "\" target=\"" . $page->{'nextpage'}. "\" mtime=\"" .  $page->{'compmtime'}. "\">\n";
	if ($hastableau)
	{
	   print XMLPAGE "<area><type>tableau</type><titleprefix>TT</titleprefix><prefix>T</prefix><class>tableau</class><class>tableau hidden</class><class>title</class><class>title hidden</class><class>twotitle</class><class>twotitle hidden</class></area>";
	}
	if ($haspoules) 
	{
	   print XMLPAGE "<area><type>poules</type><static>ptitle</static><prefix>T</prefix><class>tableau</class><class>tableau hidden</class><class>title</class></area>";
	} 
	if (($vertlist eq 'entry')) 
	{
	   print XMLPAGE "<area><type>vlist</type><static>vlistid</static><prefix>V</prefix><class>col_multi</class></area>";
	}
	elsif(defined($vertlist))
	{
	   print XMLPAGE "<area><type>vlist</type><static>vlistid</static><static>vheader</static><prefix>V</prefix><class>vlist</class></area>";
	} 
	
	if (defined($hasmidlist) && $hasmidlist)
	{
	   print XMLPAGE "<area><type>mlist</type><static>vlist2</static><static>mid_title</static><prefix>MT</prefix><class>vlist2</class><class>mid_title</class></area>";
	} 
	print XMLPAGE "</page>\n";
}

##################################################################################
# writePoule
##################################################################################
# Write out a poule, writePoule(comp, page)
sub writePoule 
{
	my $comp = shift;
	my $page = shift;

	my $round = $page->{'poules'}[0]->{'round'};
	my $compname = $comp->titre_ligne;

	my $div_id = $page->{'poule_div'};

	# Note that we are going to use tableau as the generic container for poules as well.
	my $poule_class = 'tableau';

	if (defined($page->{'poule_class'})) 
	{
		$poule_class = $page->{'poule_class'};
	}

	writeToFiles("<div class=\"title\" id=\"ptitle\"><h2>$compname Round $round</h2></div>\n", 1);
	writeToFiles("<div class=\"$poule_class\" id=\"$div_id\">\n", 1);
	
	my @poules = @{$page->{'poules'}};
	
	foreach my $pouledef (@poules) 
	{
		my @g = $pouledef->{'poule'}->grid;

		# print "writePoules: grid = " . Dumper(\@g);

		writeToFiles("\t<h3>" . $pouledef->{'poule_title'} . "</h3>\n", 1);
		writeToFiles("\t<table class=\"poule\">\n", 1);
		
		# my $lineNum = 0;
		my $titles = $g[0];
		
		writeToFiles("\t\t<tr>\n", 1);

		my $cellNum;
		my $resultNum = 1;

		# print "writePoules: titles = " . Dumper(\$titles);

		for ($cellNum = 1; $cellNum < scalar @$titles; $cellNum++)
		{
			my $text = $$titles[$cellNum];
			my $class = $$titles[$cellNum] || "blank";

			if ($$titles[$cellNum] eq "result")
			{	
				$text = $resultNum;
				$resultNum++;
			}

			writeToFiles("\t\t\t<th class=\"poule-title-$class\">$text</th>\n", 1);
		}

		writeToFiles("\t\t</tr>\n", 1);
		my $lineNum = 1;

		foreach my $line (@g)
		{
			$resultNum = 1;
			# skip titles
			next if $$line[0] eq "id";

			writeToFiles("\t\t<tr>\n", 1);

			# print "writePoules: line = " . Dumper(\$line);

			for ($cellNum = 1; $cellNum < scalar @$line; $cellNum++)
			{
				$$line[$cellNum] = "" unless defined $$line[$cellNum];

				my $text = $$line[$cellNum];
				$text = "" if $text && $text eq "()";

				my $class = $$titles[$cellNum] || "emptycol";

				if ($class eq "result")
				{
					$class = "blank" if $resultNum eq $lineNum;
					$resultNum++;
				}
	
				writeToFiles("\t\t\t<td class=\"poule-grid-$class\">$text</td>\n", 1);
			}

			writeToFiles("\t\t</tr>\n", 1);
			$lineNum++;
		}

		writeToFiles("\t</table>\n", 1);
		writeToFiles("\t<p></p>\n", 1);
	}

	writeToFiles("</div>\n", 1);
}



##################################################################################
# writematchlist
##################################################################################

sub writeMatchlist
{
	my $comp = shift;
	my $pagesize = shift;

	my $divid; 
	my $rownum = 1;
	my $hidden = "";

	print STDERR "DEBUG: writeMatchlist(): div id = M$divid\n" if $Engarde::DEBUGGING > 1;

	my $list = $comp->matchlist;


	foreach my $m (sort keys %$list)
	{
		if ($rownum eq $pagesize || not defined $divid)
		{
			if (defined $divid)
			{
				writeToFiles("\t\t</table>\n", 1);
				writeToFiles("\t</div>\n", 1); # /VLIST_BODY
				$divid++; 
				$rownum = 1;
				$hidden = "hidden";
			}
			else
			{
				$divid=0; 
			}
			print STDERR "DEBUG: writeMatchlist(): new div id = $divid\n" if $Engarde::DEBUGGING > 1;

			writeToFiles("\t<div class=\"vlist_body vlist2_body $hidden\" id=\"M$divid\">\n", 1);		# VLIST_BODY
			writeToFiles("\t\t<table class=\"vlist_table\">\n", 1);
		}

		print STDERR "DEBUG: writeMatchlist(): rownum = $rownum, m = $m\n" if $Engarde::DEBUGGING > 1;

		writeToFiles("\t\t<tr>\n", 1);

		writeToFiles("\t\t\t<td class=\"vlist_name\">$m</td>\n", 1);
		writeToFiles("\t\t\t<td class=\"vlist_round\">$list->{$m}->{'round'}</td>\n", 1);
		writeToFiles("\t\t\t<td class=\"vlist_piste\">$list->{$m}->{'piste'}</td>\n", 1);
		writeToFiles("\t\t\t<td class=\"vlist_time\">$list->{$m}->{'time'}</td>\n", 1);

		writeToFiles("\t\t</tr>\n", 1);

		$rownum++;
	}

	writeToFiles("\t\t</table>\n", 1);
	writeToFiles("\t</div>\n", 1) ; # /VLIST_BODY

}

##################################################################################
# writeTableau
##################################################################################
# Write out a tableau, writeTableau(data, pagedetails)
sub writeTableau 
{
	my $comp = shift;
	my $page = shift;

	print STDERR "DEBUG: writeTableau(): entry\n" if $Engarde::DEBUGGING > 1;

	# print Dumper(\$page);

	my $where = $page->{'where'};
	my $lastN = $page->{'lastN'};

	my @winners;
	
	# print "**********\nWhere = $where, lastN = $lastN\n";

	# this is the bout before this tableau.  Should be divisible by 2.
	my $preceeding_bout = $page->{'preceeding_bout'};
	
	writeToFiles("<div class=\"$page->{title_class}\" id=\"$page->{'title_id'}\"><h2>$page->{'tableau_title'}</h2></div>\n", 1);
	writeToFiles("<div class=\"$page->{tableau_class}\" id=\"$page->{'tableau_div'}\">\n", 1);  # 1st DIV		"tableau"

	my $numrounds = $page->{'num_cols'};

	$numrounds = 1 unless defined($numrounds);
	
	# Work out the number of bouts
	my $numbouts = $page->{'num_bouts'};
	
	# print "writeTableau: Number of rounds: $numrounds Number of bouts: $numbouts\n";

	my $minbout = $preceeding_bout + 1;
	my $maxbout = $minbout + $numbouts;

	# my $bout;
	
	for (my $roundnum = 1; $roundnum <= $numrounds; $roundnum++) 
	{
		print STDERR "DEBUG: writeTableau(): roundnum = $roundnum, maxbout = $maxbout\n" if $Engarde::DEBUGGING;

		my $colname = $roundnum == 1 ? "twocol1" : "twocol";
		writeToFiles("<div class=\"$colname\">\n", 1);						# COLUMN

		for (my $boutnum = $minbout; $boutnum < $maxbout; $boutnum++) 
		{
			if ($boutnum == $minbout || $boutnum == $minbout + 2) 
			{
				writeToFiles("\t<!-- **************************** HALF **************************** -->\n", 1);
				writeToFiles("\t<div class=\"half\">\n", 1) if ($roundnum < 3 && ($boutnum == $minbout || $boutnum == $minbout + 2));						# VERTICAL DIVIDER
			}

			if ($roundnum == 1 )
			{
				writeToFiles("\t\t<!-- *************************** QUARTER **************************** -->\n", 1);
				writeToFiles("\t\t<div class=\"quarter\">\n", 1); 
			}

			# writeToFiles("<!--   MATCH GOES HERE -->\n", 1);

			# print "writeTableau: getting round $roundnum, bout $boutnum\n";
			my $bout = $comp->match($where, $boutnum);

			if ($roundnum == $numrounds) 
			{
				# last col so collect any winners
				#
				# Not required in the 3 column layout but will leave it in in case we revert to tableau + 1 col for the final later 
				push @winners, $bout->{winner} || "&#160;";
			}

			# print "writeTableau: bout = " . Dumper(\$bout);
			writeTableauMatch($bout, $roundnum);

			writeToFiles("\t\t</div> <!-- quarter -->\n", 1) if $roundnum == 1 ;					# close VERTICAL DIVIDER
			writeToFiles("\t</div>  <!-- half -->\n", 1) if ($roundnum < 3 && ($boutnum == $minbout + 1 || $boutnum == $minbout + 3));	
		}

		writeToFiles("</div><!-- twocol -->\n", 1);				# close 2nd DIV
		# end of col div

		# next round has half as many bouts
		
		$numbouts /= 2;
		my $newlastN = $lastN/2;
		$preceeding_bout /=2; 
		$minbout = $preceeding_bout + 1;
		$maxbout = $minbout + $numbouts;

		# Change the where
		$where =~ s/\d+/$newlastN/;
		$lastN = $newlastN;

		# print "writeTableau: where = $where, lastN = $lastN\n";

	}


	# It would be better to have this bit sensitive to the stage of the competition - e.g, when we get to the final
	# there is no point displayig the middle column since everybody will know what's going on.
	

	#if (@winners)
	#{
	#print "DEBUG: writeTableau: we have winners!\n" . Dumper (\@winners);
	#
	#writeToFiles("<div class=\"twocol\">\n", 1);
	#
	#foreach (@winners)
	#{
	#writeToFiles("\t<div class=\"half\">\n", 1);
	#writeToFiles("\t\t<div id=\"container\"><div id=\"position\">\n", 1);
	#print "writeTableau: winner = $_\n";
	#writeToFiles("\t\t<div class=\"A final winner\">\n", 1);
	#writeToFiles("\t\t\t<div id=\"container\"><div id=\"position\">\n", 1);
	#writeToFiles("\t\t\t\t$_\n", 1);
	#writeToFiles("\t\t\t</div></div>\n", 1);
	#writeToFiles("\t\t</div>\n", 1);
	#writeToFiles("\t\t</div></div>\n", 1);
	#writeToFiles("\t</div>\n", 1);

	#}

	#writeToFiles("</div>\n", 1);
	#}
	
	writeToFiles("</div>  <!-- tableau -->\n", 1);					# close 1st DIV
	print STDERR "DEBUG: writeTableau(): exit\n" if $Engarde::DEBUGGING;
}

##################################################################################
# writeEntryListFencer
##################################################################################
# write a fencer into an entry list.  (key to data, webpage, details of list);
sub writeEntryListFencer {
	my $EGData = shift;
	my $col_details = shift;

	# flag to indicate if the style should be amended based on the "group" value
	my $adjust_style = shift || 0;

	my $row_class = "";

	if ($adjust_style)
	{
		my $group = $EGData->{"group"};
		$row_class = "class=\"$group\"" if $group;
	}
		
	writeToFiles("\t\t\t<tr $row_class>\n", 1);

	foreach my $column_def (@{$col_details}) 
	{
		my $col_class = $column_def->{'class'};
		my $col_key = $column_def->{'key'};
		my $col_val = defined $EGData->{$col_key} ? $EGData->{$col_key} : "&#160;";

		writeToFiles("\t\t\t\t<td class=\"$col_class\">$col_val</td>\n", 1);
	}

	writeToFiles("\t\t\t</tr>\n", 1); 

}

sub writeFencerListDivHeader
{
	my $div_id = shift;
	my $class = "vlist_body";

	$class .= " hidden" if ($div_id > 0);

	writeToFiles("\t<div class=\"$class\" id=\"V$div_id\">\n", 1);
	writeToFiles("\t\t<table class=\"vlist_table\">\n", 1);
}


sub writeFencerListDivFooter
{
	writeToFiles("\t\t</table>\n\t</div>\n", 1);
}



##################################################################################
# writeFencerList
##################################################################################
# Write out vertical list in table format  - used for all vlist divs
sub writeFencerList 
{
	local $pagedetails = shift;		# must be scoped as local to allow for sort funcs

	my $list_title = $pagedetails->{'list_title'};
	my $col_details = $pagedetails->{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";
	my $size = $pagedetails->{'size'};

	writeToFiles("<div class=\"vlist\" id=\"vlistid\">\n", 1);
	writeToFiles("\t<div class=\"vlist_title\" id=\"vtitle\"><h2>$list_title</h2></div>\n", 0);
	writeToFiles("\t<div class=\"vlist_header\" id=\"vheader\">\n", 1);
	writeToFiles("\t\t<table class=\"vlist_table\">\n\t\t\t<tr>\n", 1);
	foreach my $column_def (@{$col_details}) 
	{
		my $col_class = $column_def->{'class'};
		my $col_heading = $column_def->{'heading'};
		
		writeToFiles("\t\t\t\t<td class=\"$col_class\">$col_heading</td>\n", 1);
	}

	writeToFiles("\t\t\t\</tr>\n\t\t</table>\n\t</div>\n", 1);

	my $div_id = 0;
  
	writeFencerListDivHeader($div_id);

	if (defined ($entry_list))
	{
		my $entryindex = 0;
		if ($ref)
		{
			if ($sort_func)
			{
				foreach my $entrydetail (sort $sort_func keys %$entry_list) 
				{
					# print "entry = " . Dumper($entry_list->{$entrydetail});
				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details, 1);

					if ($entryindex == $size)
					{
						writeFencerListDivFooter();
						$div_id += 1;
						$entryindex = 0;
						writeFencerListDivHeader($div_id);
					}
					else
					{
				   		$entryindex += 1;
					}
				}
			}
			else
			{
				foreach my $entrydetail (%$entry_list) 
				{
				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details);

					if ($entryindex == $size)
					{
						writeFencerListDivFooter();
						$div_id += 1;
						$entryindex = 0;
						writeFencerListDivHeader($div_id);
					}
					else
					{
				   		$entryindex += 1;
					}
				}
			}
		}
		else
		{
			foreach my $entry (@$entry_list)
			{
				writeEntryListFencer($entry, $col_details);

				if ($entryindex == $size)
				{
					writeFencerListDivFooter();
					$div_id += 1;
					$entryindex = 0;
					writeFencerListDivHeader($div_id);
				}
				else
				{
			   		$entryindex += 1;
				}
			}
		}
	}
	
	writeFencerListDivFooter();
	
	

	
	writeToFiles("\n</div>", 1);
}

##################################################################################
# writeEntryList
##################################################################################
# Write out the entry list in CSS3 multi column format 
sub writeEntryList 
{
	local $pagedetails = shift;

	my $list_title = $pagedetails->{'list_title'};
	my $col_details = $pagedetails->{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";

	my $count = scalar keys %$entry_list;

	my $out = "";
	my $nif = 0;

	if (defined ($entry_list))
	{
		foreach my $entrydetail (sort namesort keys %$entry_list) 
		{
			my $affiliation = $entry_list->{$entrydetail}->{'club'} || "&#160;";
			my $nom = $entry_list->{$entrydetail}->{'nom'};
			my $serie = $entry_list->{$entrydetail}->{'serie'} || 999;

			my $nameclass = "col_name";

			if ($serie < 11)
			{
				$nameclass .= " top10"; 
				$nif += 6;
			}
			elsif ($serie < 21)
			{
				$nameclass .= " top20"; 
				$nif += 3;
			}
			elsif ($serie < 51)
			{
				$nameclass .= " top50"; 
				$nif += 1;
			}

			$out .= "<span class=\"$nameclass\">$nom</span>";
			$out .= "<span class=\"col_club\">$affiliation</span><br />\n";
		}
	}

	$nif = int($count / 4) if $nif * 4 < $count;
	
	writeToFiles("<div class=\"vlist_title\" id=\"vlistid\"><h2>$list_title ($count - NIF estimate $nif)</h2></div>\n", 1);
	writeToFiles("<div class=\"col_multi\" id=\"V0\">\n", 1);

	writeToFiles($out, 1);

	writeToFiles("</div>\n", 1);
}

##################################################################################
# createPouleDefinitions($comp);
##################################################################################
# create an array of definitions for a set of pages describing a complete round of poules
# the first will be visible the later ones not
sub createPouleDefinitions 
{
	my $competition = shift;
	my $round = shift;

	# print "createPouleDefinitions: round = $round\n";

  	my %retval;
	
	#  my @localswaps;

	my @defs;
	my $defindex = 0;
   	
   	my $numPoulesPerPage = 2;

	my $poule;

	do {
		$poule = $competition->poule($round,$defindex + 1);

		if (defined($poule)) 
		{
			if (0 == $defindex % $numPoulesPerPage) 
			{
				my %def;

				my $divname = "T" . int($defindex / $numPoulesPerPage);

				# $localswaps[int($defindex / $numPoulesPerPage)] = $divname;

				$def{'poule_div'} = $divname;
			
				$def{'poule_class'} = 'tableau hidden' if ($defindex / $numPoulesPerPage > 0); 

				$defs[$defindex / $numPoulesPerPage] = \%def;
				
				# my @pouledefs;
				# $def{'poules'} = \@pouledefs;	
			}

			my %pouledef;

			$pouledef{'poule'} = $poule;	
			$pouledef{'round'} = $round;

			my $piste = $poule->piste_no;
			my $time = $poule->time();

			my $title = "Poule " . ($defindex + 1);

			$title .= ", Piste: $piste" if $piste;
			$title .= ", Time: $time" if $time;

			$pouledef{'poule_title'} = $title;

			${${$defs[$defindex / $numPoulesPerPage]}{'poules'}}[$defindex % $numPoulesPerPage] = \%pouledef;
		}
		$defindex++;
   	} 
	while(defined($poule) && defined($poule->{'mtime'}));


   	$retval{'definitions'} = \@defs;
	# $retval{'swaps'} = \@localswaps;
   
   	return %retval;
}

##################################################################################
# createRoundTableaus
##################################################################################
# create an array of definitions for a set of pages describing a complete round of a tableau
# the first will be visible the later ones not
sub createRoundTableaus 
{
	# print "createRoundTableaus starting\n";

	my $competition = shift;
	# my $tableaupart = shift;
	my $chosenpart = 0;
	my $numparts = 0;
	#	default is two columns
	my $numcols = 2;

	my $compname = $competition->titre_ligne;
	
  	my $retval = {};
	
	my $tab;
	my $roundsize = 0;

	# PRS - minroundsize controls the number of fencers in col1 - now fixed at 8
	my $minroundsize = 8; 
	  
   	my $where = $competition->whereami;

	# print "createRoundTableaus: where = $where\n";

 	if ($where =~ /tableau/ || $where eq "termine")
	{
		if ($where =~ /tableau/)
		{
			$where =~ s/tableau //;

			my @w = split / /, $where;

			$where = $w[0];

			# start at the last complete tableau if possible.
			#
			# my @t = $competition->tableaux;
			# print "\ncreateRoundTableaus: t = @t\n";

			#if (defined $t[0])
			#{
			#	$where = $t[0];
			#}
		}
		elsif ($where eq "termine")
		{
			my @tableaux = $competition->tableaux;
			# print "createRoundTableaus: tableaux (where=termine) = @tableaux\n";
			$where = $tableaux[-3];
			# print "createRoundTableaus: where (where=termine) = $where\n";
		}
		else
		{
			my @tableaux = $competition->tableaux(1);
			$where = $tableaux[0];
		}

		# Move to the specified place in the tableau
		# PRS - not used in current "auto" config
		if ($numparts) 
		{
			$roundsize = $numparts * $minroundsize;
			
			# print "where = $where\n";
			$where =~ s/\d+/$roundsize/;
			# print "Now where is (after round definition)  $where\n";
		}	

		# print "where99 = $where\n";
		$tab = $competition->tableau($where);

		#print "$where = " . Dumper(\$tab);

		$roundsize = $tab->taille if ref $tab;
		print "Roundsize $roundsize, Minroundsize $minroundsize\n";

		if ($roundsize < $minroundsize)	# assume it's the final - wouldn't be true if all the DE places were fought
		{
			# do it this way since we can't be certain that the tableau letter is "a" - e.g. A grade formula would be "bf"
			# after the preliminary tableau
			$where =~ s/$roundsize/$minroundsize/;
			$roundsize = $minroundsize;
		}
	}
	else
	{
		# Nothing to display
		return $retval;
	}

	# my @localswaps;

	my @defs;
	my $defindex = 0;

	my $preceedingbout = 0;
	while ($preceedingbout < $roundsize / 2) 
	{
		# print "Preceeding Bout: $preceedingbout Chosen part: $chosenpart \n";
	
		if (0 == $chosenpart || $preceedingbout == ($minroundsize /2) * $chosenpart) 
		{
			my %def;

			$def{'where'} = $where;
			$def{'num_bouts'} = $minroundsize /2;
			
			my $part = ($defindex + 1);
			if (0 != $chosenpart) {
				$part = $chosenpart;
			}

			# $part is 1 indexed and our divs are 0 indexed to avoid confusing me.
			my $divname = "T" . ($part - 1);
			my $title_id = "TT" . ($part - 1);
		
			# $localswaps[$defindex] = $divname;
		
			$def{'tableau_div'} = $divname;
			$def{'title_id'} = $title_id;
			$def{'num_cols'} = $numcols;

			if ($preceedingbout == 0 && $roundsize <= 8) 
			{
				$def{'tableau_title'} = $compname . " Final";
			} 
			elsif ($preceedingbout == 0 && $roundsize == $minroundsize)
			{
				$def{'tableau_title'} = $compname . " Last $minroundsize";
			}
			else 
			{
				$def{'tableau_title'} = $compname . " Last ". $roundsize . " part " . $part;
			}

			$def{'lastN'} = $roundsize;
			$def{'preceeding_bout'} = $preceedingbout;
		
			if ($preceedingbout != 0 && 0 == $chosenpart) 
			{
				$def{'tableau_class'} = 'tableau hidden';
				$def{'title_class'} = 'twotitle hidden';
			}
			else
			{
				$def{'tableau_class'} = 'tableau';
				$def{'title_class'} = 'twotitle';
			}

			$defs[$defindex] = \%def;
			$defindex++;
		}

		$preceedingbout += 4;
   	}

   	$retval->{'definitions'} = \@defs;
	# $retval->{'swaps'} = \@localswaps;
   	
   	return $retval;
}

##################################################################################
# readpagedefs
##################################################################################
sub readpagedefs
{

	my $pagedeffile = shift;
	
	# Looking to see if it is an xml file (by name only)
	if ($pagedeffile =~ /xml$/)
	{
	   return readpagedefsfromxml($pagedeffile);
	}
	else
	{
	   return readpagedefsfromconfig($pagedeffile);
	}
}


##################################################################################
# readpagedefsfromxml
##################################################################################
sub readpagedefsfromxml 
{

	my $pagedeffile = shift;
	
	
   my $xml = new XML::Simple(ForceArray => 1);

   # read XML file
   my $data = $xml->XMLin($pagedeffile);
   
   #print Dumper($data);
   
	
	my %currentpage;
	my $series = {};
	my @pagedefs;
	
   foreach my $seriesdef (@{$data->{series}})
   {
		undef @pagedefs;
		if ($seriesdef->{enabled})
		{			
         # Just loop around the pages
	      foreach my $pagedefin (@{$seriesdef->{page}})
	      { 
	         print Dumper($pagedefin);
			   undef %currentpage;
			   # only enabled pages
			   if ($pagedefin->{enabled})
			   {
			      # Page properties
			      $currentpage{'target'} = ${$pagedefin->{'target'}}[0];
			      $currentpage{'background'} = ${$pagedefin->{'background'}}[0];
			      $currentpage{'competition'} = ${$pagedefin->{'competition'}}[0];
			   
			      # Now the series properties which we copy to the pages
			      $currentpage{'targetlocation'} = ${$seriesdef->{'targetlocation'}}[0];
			      $currentpage{'name'} = ${$seriesdef->{'name'}}[0];
			      $currentpage{'csspath'} = ${$seriesdef->{'csspath'}}[0];
			      $currentpage{'scriptpath'} = ${$seriesdef->{'scriptpath'}}[0];
			      $currentpage{'index'} = ${$seriesdef->{'index'}}[0];
			      $currentpage{'vlistsize'} = ${$seriesdef->{'vlistsize'}}[0];
			      $currentpage{'vlist2size'} = ${$seriesdef->{'vlist2size'}}[0];
			      $currentpage{'entrylistsize'} = ${$seriesdef->{'entrylistsize'}}[0];
			   
			   
				   push @pagedefs, {%currentpage};
			   }
			}
			
			# Now sort out the next page
			
			if (@pagedefs > 0) 
			{
				for (my $iter = 0; $iter < @pagedefs; $iter++) 
				{
					${$pagedefs[$iter]}{'target'} = "page" . ($iter + 1) . ".html";

					if ($iter < $#pagedefs) 
					{
						# ${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[$iter + 1]}{'target'};
						${$pagedefs[$iter]}{'nextpage'} = "page" . ($iter + 2) . ".html";
					} 
					else 
					{
						# ${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[0]}{'target'};
						${$pagedefs[$iter]}{'nextpage'} = "page1.html";
					}
				}
			}
			
			$series->{${$seriesdef->{'name'}}[0]} = {};
			$series->{${$seriesdef->{'name'}}[0]}->{'pagedefs'} = [@pagedefs];
	   }
   }
   
	return $series;
}

##################################################################################
# readpagedefsfromconfig
##################################################################################
sub readpagedefsfromconfig 
{

	my $pagedeffile = shift;

	open PAGEDEFFILE, $pagedeffile or die "Couldn't open page definitions file";

	my @pagedefs;
	my $pageindex = 0;
	my %currentpage;
	my %currentseries;
	my $series = {};
	my $inpage = 0;
	my $inseries = 0;

	while (<PAGEDEFFILE>) 
	{
		my $name = "";
		my $value = "";

		if (/^\[SERIES\]$/)
		{
			$inseries = 1;
			undef %currentseries;
			undef @pagedefs;
			undef %currentpage;
		}
		elsif (($name, $value) = ($_ =~ /(\w*)=(.*)/)) 
		{
			$currentpage{$name} = $value if $inpage; 
			$currentseries{$name} = $value if $inseries && not $inpage; 
		}
		elsif (/^\[PAGE\]$/) 
		{
			# Beginning of a page so clear everything
			undef %currentpage;
			$inpage = 1;
		}
		elsif (($name, $value) = ($_ =~ /(\w*)=(.*)/)) 
		{
			if ($inpage) 
			{
				# Got a name value pair
				$currentpage{$name} = $value;
			}
			elsif ($inseries)
			{
			}
	   	}
		elsif (/^\[\/PAGE\]$/) 
		{
			# End of a page so check whether we want this or not
			my $enabled = $currentpage{'enabled'} || "true";

			if ($enabled eq 'true') 
			{
				# PRS - copy series values to page - makes life easier later on....
				foreach my $skey (keys %currentseries)
				{
					next if $skey eq "name";
					$currentpage{$skey} = $currentseries{$skey};
				}

				push @pagedefs, {%currentpage};
			}

			$inpage = 0;
		}
		elsif (/^\[\/SERIES\]$/) 
		{
			if (defined($currentseries{'enabled'})  && $currentseries{'enabled'} eq "true")
			{
				if (@pagedefs > 0) 
				{
					for (my $iter = 0; $iter < @pagedefs; $iter++) 
					{
						${$pagedefs[$iter]}{'target'} = "page" . ($iter + 1) . ".html";

						if ($iter < $#pagedefs) 
						{
							# ${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[$iter + 1]}{'target'};
							${$pagedefs[$iter]}{'nextpage'} = "page" . ($iter + 2) . ".html";
						} 
						else 
						{
							# ${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[0]}{'target'};
							${$pagedefs[$iter]}{'nextpage'} = "page1.html";
						}
					}
				}

				$series->{$currentseries{'name'}} = {};
				$series->{$currentseries{'name'}}->{'pagedefs'} = [@pagedefs];

				foreach my $key (keys %currentseries)
				{
					$series->{$currentseries{'name'}}->{$key} = $currentseries{$key};
				}
			}
		}

		$pageindex++;
	}
	close PAGEDEFFILE;

	# print "pagedefs = " . Dumper(\@pagedefs);
	return $series;
}
	


##################################################################################
# createpage
##################################################################################
sub createpage 
{
	my $pagedef = shift;

	# print "\n\ncreatepage: pagedef = " . Dumper(\$pagedef);
	
	#Create the competition
	my $compname = 	$pagedef->{'competition'};

	print "\ncreatepage(): processing $compname\n";

	my $comp = Engarde->new($compname);
	
	unless ($comp)
	{
		warn "no comp: $compname";
		return 1;
	}
	
	# $pagedef->{'comp'} = $comp;
	$pagedef->{'compmtime'} = $comp->mtime;

	$pagedef->{'pagetitle'} = $comp->titre_ligne;
	
	# If there are tableaus then we need to create them
	my $hastableau = want($comp, "tableau");

	# print "createpage: hastableau = $hastableau\n";

	my $tabdefs;
	
	if ($hastableau) 
	{ 
		$tabdefs = createRoundTableaus($comp, $pagedef->{'tableau'});

		# $pagedef->{'swaps'} = $tabdefs->{'swaps'};
		
	}
	# If there are poules then we need to create them

	my @hp = want($comp, "poules");

	# print "createpage: hp = @hp\n";

	my $haspoules = $hp[1];

	my %pouledefs;
	
	if ($haspoules) 
	{ 
		if ($hp[2] eq "constitution")
		{
			%pouledefs = createPouleDefinitions($comp, $haspoules-1);
		}
		else
		{
			%pouledefs = createPouleDefinitions($comp, $haspoules);
		}

		# We now have the information to create the poule divs, now set the pages up so it swaps correctly

		$pouledefs{'round'} = $haspoules;

		# $pagedef->{'swaps'} = $pouledefs{'swaps'};
	}

	# Now sort out the vertical list
	my $vertlist = want($comp, "list");

	my $listdef = undef();
	my $fencers;
	
	if ($vertlist) 
	{
		if ($vertlist =~ /fpp/) 
		{
			#######################################################
			# Fencers, Pools, Pistes
			#######################################################

			$fencers = $comp->fpp();

			my $listdataref = $fencers;

			my $entrylistdef = [ {'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
						{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'},
						# {'class' => 'init_rank', 'heading' => 'Ranking', key => 'fencer_rank'},
						{'class' => 'vlist_poule', 'heading' => 'Poule', key=> 'poule'},
						{'class' => 'vlist_piste', 'heading' => 'Piste', key=> 'piste_no'}];						
   
   
			$listdef = { 'sort' => \&namesort, 'size'=> $pagedef->{'vlistsize'},
						'list_title' => 'Fencers - Pools - Pistes', 
						'entry_list' => $listdataref, 'column_defs' => $entrylistdef };

		} 
		elsif ($vertlist =~ /ranking/) 
		{
			#######################################################
			# Ranking after the pools
			#######################################################

			# Need to check the round no
			if (defined($hp[2]) && $hp[2] eq "finished")
			{
				$fencers = $comp->ranking("p", $haspoules);
			}
			else
			{
				# PRS: need something extra here - final ranking after poules will never get displayed
				$fencers = $comp->ranking("p");
			}
	
			my $entrylistdef = [ 
				{'class' => 'seed', 'heading' => ' ', key => 'seed'},
				{'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
				{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'},
				# might need to spilit this (v/m) into 3 cols now...
				{'class' => 'vm', 'heading' => 'vm', key => 'vm'},
				{'class' => 'ind', 'heading' => 'ind', key=> 'ind'},
				{'class' => 'hs', 'heading' => 'hs', key=> 'hs'} ];						
	
			$listdef = 	{	'sort' => \&ranksort, 'size' => $pagedef->{'vlistsize'},
							'list_title' => 'Ranking after the pools', 
							'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		} 
		elsif ($vertlist eq 'result') 
		{ 
			#######################################################
			# Final Ranking
			#######################################################
			
			$fencers = $comp->ranking();
			
			my $entrylistdef = [ 
							{'class' => 'vlist_position', 'heading' => ' ', key => 'seed'},
							{'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'}];		
	
			$listdef = {	'sort' => \&ranksort, 'size' => $pagedef->{'vlistsize'},
							'list_title' => 'Overall Ranking', 
							'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		}
		elsif ($vertlist eq 'entry')
		{
			$fencers = $comp->tireurs;

			my $entrylistdef = [ 
							{'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'},
							{'class' => 'fencer_rank', 'heading' => '', key => 'serie'},
					   ];		
	
			$listdef = {	'sort' => \&namesort, 'size' => $pagedef->{'entrylistsize'},
							'list_title' => $comp->titre_ligne . ' Entries', 
							'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		}
	}
	

	my $pagename = $pagedef->{'targetlocation'} . "/" . $pagedef->{'target'};
	open( WEBPAGE,"> $pagename.tmp") || die("can't open $pagename.tmp: $!");
	
	open( XMLPAGE,"> $pagename.xml.tmp") || die("can't open $pagename.xml.tmp: $!");

	my $fh = select(WEBPAGE);
	$| = 1;			# unbuffered output
	select($fh);

	# WEBPAGE->autoflush(1);

	writeBlurb($pagedef, $hastableau, $haspoules, $vertlist, 1);
			
	# Write the tableaus if appropriate
	if ($hastableau) 
	{ 
		foreach my $tabdef (@{$tabdefs->{'definitions'}}) 
		{
			print STDERR "\n\nDEBUG: createpage(): calling writeTableau() for tabdef = " . Dumper(\$tabdef) if $Engarde::DEBUGGING > 1;
			writeTableau($comp, $tabdef);
		}


		writeToFiles("<div class=\"mid_title\" id=\"mid_title\"><h2>Where should I be?</h2></div>\n", 1);
		writeToFiles("<div class=\"vlist2\" id=\"vlist2\">\n", 1);  # VLIST2

		writeToFiles("\t<div class=\"vlist_header vlist2_header\">\n", 1);	# VLIST_HEADER
		writeToFiles("\t\t<div class=\"vlist_table\">\n", 1);				# VLIST_TABLE

		writeToFiles("\t\t\t<table class=\"vlist_table\">\n", 1);
		writeToFiles("\t\t\t\t<tr>", 1);
		writeToFiles("\t\t\t\t\t<td class=\"vlist_name\">Name</td>\n", 1);
		writeToFiles("\t\t\t\t\t<td class=\"vlist_round\">Round</td>\n", 1);
		writeToFiles("\t\t\t\t\t<td class=\"vlist_piste\">Piste</td>\n", 1);
		writeToFiles("\t\t\t\t\t<td class=\"vlist_time\">Time</td>\n", 1);
		writeToFiles("\t\t\t\t</tr>\n", 1);
		writeToFiles("\t\t\t</table>\n", 1);
		writeToFiles("\t\t</div>\n", 1) ; # /VLIST_TABLE
		writeToFiles("\t</div>\n", 1) ; # /VLIST_HEADER

		print STDERR "DEBUG: createpage(): calling writeMatchlist - page size = $pagedef->{'vlist2size'}\n" if $Engarde::DEBUGGING > 1;
	
		writeMatchlist($comp, $pagedef->{'vlist2size'});

		writeToFiles("</div>\n", 1) ; # /VLIST2
	}

	# Write the poules if appropriate
	if ($haspoules) 
	{ 
		foreach my $pouledef (@{$pouledefs{'definitions'}}) 
		{
			writePoule($comp, $pouledef);
		}
	}

	# If we have a vertical list definition defined then add that
	if (defined($listdef)) 
	{
		if ($vertlist eq "entry")
		{
			writeEntryList($listdef);
		}
		else
		{
			# fpp or ranking
			writeFencerList($listdef)
		}
	}

	print WEBPAGE "</body>\n</html>";
	print XMLPAGE "</returndata>";

	close WEBPAGE;
	close XMLPAGE;

	rename $pagename . ".tmp", $pagename;
	rename $pagename . ".xml.tmp", $pagename.".xml";

}	# end sub

##################################################################################
# sorting subs for use by list output
##################################################################################
sub namesort
{
	$pagedetails->{'entry_list'}->{$a}->{nom} cmp $pagedetails->{'entry_list'}->{$b}->{nom};
}

sub ranksort
{
	$pagedetails->{'entry_list'}->{$a}->{seed} <=> $pagedetails->{'entry_list'}->{$b}->{seed};
}

##################################################################################
# subs to determine page content
##################################################################################

#		Whereami					Poules?				Tableau?		List
#
#		???								N					N			entry
#		poules x y y y 					Y					N			fpp
#		poules x finished				Y					N			ranking
#		tableau z99						N					Y			result
#
#

sub want
{
	my $c = shift;
	my $what = shift;

	my $where = $c->whereami;

	# print "DEBUG: WANT: what = $what, where = $where\n";

	if ($what eq "tableau")
	{ 
		return 1 if ($where =~ /tableau/ || $where =~ /termine/);
	}
	elsif ($what eq "poules")
	{
		return undef if $where eq "poules 1 constitution";
		return split / /,$where if ($where =~ /poules/);
	}
	elsif ($what eq "list")
	{
		return which_list($where);
	}
	else
	{
		return undef;
	}
}

sub which_list
{
	my $where = shift;

	# print "DEBUG: which_list: where = $where\n";

	if ($where =~ /poules/)
	{
		if ($where =~ /constitution/)
		{
			# start of comp - poules not drawn yet
			return "entry" if $where =~ /poules 1/;

			# all poules in, ranking run, next round not drawn
			return "ranking";
		}
		elsif ($where =~ /finished/)
		{
			return "ranking";
		}
		else
		{
			return "fpp";
		}
	}
	elsif ($where =~ /tableau/ || $where eq "termine")
	{
		return "result" if $where eq "termine";

		my @w = split / /, $where;

		print STDERR "DEBUG: which_list(): w = [@w]\n" if $Engarde::DEBUGGING > 1;

		return "ranking" if $w[1] eq $w[2];
		return "result" unless $w[1] eq $w[2];
	}
	elsif ($where eq "debut")
	{
		return "entry";
	}
}

##################################################################################
# Main starts here (I think)
##################################################################################
my $pagedeffile = shift || "live.ini";

my $runonce = shift || 0;

# read the page definitions

# print "MAIN: pages = " . Dumper(\@pages);

my $fh = select(STDOUT);
$| = 1;
select($fh);
# STDOUT->autoflush(1);  # to ease debugging!

while (1)
{
	print "\nRunning......";
	my $pages = readpagedefs ($pagedeffile);
	foreach my $series (keys %$pages)
	{
		foreach my $pagedef (@{$pages->{$series}->{'pagedefs'}}) 
		{
			createpage ($pagedef);
		}
	}	

	# print "Done\nSleeping...\n";

	unless ($runonce)
	{
		sleep 30; 
	}
	else
	{
		exit ;
	}
}
			
