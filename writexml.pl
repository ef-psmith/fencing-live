#!/opt/bin/perl -w
# vim: set ts=4 sw=4:
# (c) Copyright Oliver Smith & Peter Smith 2007-2010 
# oliver_rps@yahoo.co.uk

# standard layout for each stage of the competition based on the "whereami" output
# as follows
#	 poules not drawn		-	 check-in list
#	 poules drawn			-	 fencers, poules, pistes
#	 poules in progress	-	 poules + fpp
#	 poules finished		-	 poules + ranking 
#	 tableau drawn			-	 tableau + final ranking

# for dev purposes (mostly)
use lib "../lib";
use lib "../eng-perl";

use strict;
use Engarde;
use Data::Dumper;
use Carp qw(cluck);
use XML::Simple;
# use IO::Handle;


# NOTE:
#
# If you get the error "could not find PaserDetails.ini..."
# run this from the command line
#	
# perl -MXML::SAX -e "XML::SAX->add_parser('XML::SAX::PurePerl')->save_parsers()"
#


# New XML / XSLT / Ajax scheme
#
# Create a hashref in memory containing all of the required data and write to an XML file

# New logic....

# read_config()
#
# foreach (competition)
# {
#	suck_data_into_hashref();
# }
#
# foreach (series)
# {
#	write_xml();
# }
#
# write_top_level_xml();
#
# sleep;


##################################################################################
# Main starts here
##################################################################################

# set AUTOFLUSH on STDOUT to ensure messages are written in the correct order
my $fh = select(STDOUT);
$| = 1;
select($fh);

#my %compmap;
#my $competitionlist;
#my $targetlocation;

my $comp_output;

my $ini = shift || "live.xml";
my $runonce = shift || 0;


while (1)
{
	my $config = read_config($ini);
	
	$Engarde::DEBUGGING=$config->{debug};

	$comp_output = {};
	
	# $comp_output->{competition} = [];
	
	my $comps = $config->{competition};
	
	# generate the data
	
	foreach my $cid ( sort keys %$comps)
	{		
		next unless $config->{competition}->{$cid}->{enabled} eq "true";	
	
		my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw");
		
		next unless $c;
		
		do_comp($c, $cid, $config->{competition}->{$cid});
	}
		
	XMLout($comp_output, KeyAttr => [], SuppressEmpty => undef, OutputFile => $config->{targetlocation} . "/toplevel.xml");
	
	# output the relevant bits for each series
	my $series = $config->{series};
	
	# print Dumper(\$series);

	foreach my $sid ( sort keys %$series)
	{
		# print Dumper(\$series->{$sid});
		next unless ($series->{$sid}->{enabled} eq "true");

		my $outfile = $config->{targetlocation} . "/series" . $sid . "/series.xml"; 
		
		my $series_output = {};
		
		my @array = @{$comp_output->{competition}};
		

		foreach my $cid (@{$series->{$sid}->{competition}})
		{
			#print "series_output: cid $cid starting\n";
			# print Dumper($_);
			my ($index) = grep $array[$_]->{id} eq $cid, 0 .. $#array;
			#print "cid $cid: index = $index\n";
			
			next unless defined($index);
			#print "cid $cid: index = $index\n";
			push @{$series_output->{competition}}, @{$comp_output->{competition}}[$index]; 
		}
	
		XMLout($series_output, KeyAttr => [], SuppressEmpty => undef, OutputFile => $outfile);	
	}

	unless ($runonce)
	{
		sleep 30;
	}
	else
	{
		exit ;
	}
}


sub do_comp 
{
	my $c = shift;
	my $cid = shift;
	my $config = shift;
	
	my $nif = $config->{nif};
	
	my $out = {};
	
	$out->{id} = $cid;
	$out->{titre_ligne} = $c->titre_ligne;
	$out->{background} = $config->{background};

	# $out->{nif} = $nif;
	
	my $where = $c->whereami;
	
	# print Dumper(\$where);
	
	
	if ($where eq "debut")
	{
		debug(1, $c->titre_ligne . ": debut");
		push @{$out->{lists}}, do_list($c, $nif, "debut");
	}
	else
	{
		my $dom = $c->domaine_compe;
		my $aff = $dom eq "national" ? "club" : "nation";
		
		############################################
		# Always need the entry list for the portal
		############################################
		{
			my $list = {};
		
			my @lout = do_entry_list($c, $aff);

			$list->{entry}->{fencer} = [@lout];
			$list->{entry}->{count} = @lout;
			$list->{entry}->{nif} = $nif;
			push @{$out->{portallists}}, $list;
		}
		
		if ($where =~ /poules/)
		{
			my @hp = want($c, "poules");

			$out->{pools} = do_poules($c, @hp);
			push @{$out->{lists}}, do_list($c, $nif, @hp);

		}

		if ($where =~ /tableau/ || $where eq "termine")
		{
			$out->{tableau} = do_tableau($c, $where);
			push @{$out->{lists}}, do_list($c, $nif, "result");

			# And also push the pools out for the portal
			my @hp = want($c, "poules");

			$out->{portalpools} = do_poules($c, @hp);

			{
				my $fencers = $c->ranking("p");

				# print Dumper(\$fencers);

				my @lout = do_ranking_list($fencers, $aff);
				my $list = {};

				$list->{ranking}->{fencer} = [@lout];
				$list->{ranking}->{count} = @lout;
				$list->{ranking}->{type} = "pools";
				push @{$out->{portallists}}, $list;
			}
		}
	}
	
	my $wh = do_where($c);
	
	debug(3, "cid $cid: where = " . Dumper(\$wh));
	
	push @{$out->{lists}}, $wh if $wh->{where}->{count};
	push @{$comp_output->{competition}}, $out;
}

 
sub do_poules
{
	my $c = shift;
	my @hp = @_;
	my $round;
	
	if ($hp[1])
	{
		if ($hp[2] eq "constitution")
		{
			$round = $hp[1] - 1;
		}
		else
		{
			$round = $hp[1];
		}
	}

	return undef unless $round;
	
	my $pnum = 0;
	my $poule;

	my @pout;
	
	my $p = {};
	
	do {
		my $out = {};

		$poule = $c->poule($round,$pnum + 1);

		if (defined($poule)) 
		{
			# debug(1, "fpp: poule = " . Dumper(\$poule));

			$out = {'number' => $pnum+1, 'piste' => $poule->piste_no || '&#160;', 'heure' => $poule->heure || '', 'size' => $poule->size};
			# debug(1, "fpp: out = " . Dumper(\$out));

			$out->{fencers} = $poule->grid(1);

			# debug(1, "fpp: out2 = " . Dumper(\$out));

			push @pout, $out;
		}
		$pnum++;
	} 
	while(defined($poule) && defined($poule->{'mtime'}));
	
	$p->{pool} = [@pout];
	$p->{count} = @pout;
	$p->{round} = $round;
	
	return $p;
}	

sub do_fpp_list
{
	my $c = shift;
	my $aff = shift;
	
	my @lout;
	
	#######################################################
	# Fencers, Pools, Pistes
	#######################################################

	my $fencers = $c->fpp();

	# print Dumper(\$fencers);

	my $sequence=1;
	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom}, 
						affiliation => $fencers->{$fid}->{$aff} || '',
						piste => $fencers->{$fid}->{piste_no} || ' ', 	
						poule => $fencers->{$fid}->{poule} || '', 
						id => $fid || '',
						sequence => $sequence};
		$sequence++;
	}

	return @lout;
}

sub do_entry_list
{
	my $c = shift;
	my $aff = shift;
	
	my @lout;
	
	
	my $fencers = $c->tireurs;
				
	# print Dumper(\$fencers);

	my $sequence = 1;

	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom}, 
						affiliation => $fencers->{$fid}->{$aff} || '',
						seed => $fencers->{$fid}->{serie} || '',
						id => $fid || '',
						sequence => $sequence};
		$sequence++;
	}

	return @lout;
}

sub do_ranking_list
{
	my $fencers = shift;
	my $aff = shift;
	my @lout;
	my $sequence = 1;

	foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom_court}, 
						affiliation => $fencers->{$fid}->{$aff} || '',
						elimround => "p", 	
						position => $fencers->{$fid}->{seed} || '',
						id => $fid || '', 
						sequence => $sequence};
		$sequence++;
	}
	return @lout;
}

sub do_list
{
	my $c = shift;
	my $nif = shift;
	my @stage = @_ ;
	
	my @lout;
	
	my $list = {};
	
	# Now sort out the vertical list
	my $vertlist = want($c, "list");
	
	# print $c->titre_ligne . ": " . Dumper(\@hp) . Dumper(\$vertlist);
	
	my $fencers;
	
	
	if ($vertlist) 
	{
		my $dom = $c->domaine_compe;
		my $aff = $dom eq "national" ? "club" : "nation";

		if ($vertlist =~ /fpp/) 
		{
			# We need the fpp for the series
			@lout = do_fpp_list($c, $aff);		
			
			$list->{fpp}->{fencer} = [@lout];
			$list->{fpp}->{count} = @lout;
			$list->{fpp}->{round} = $stage[1];
			
			
		} 
		elsif ($vertlist =~ /ranking/) 
		{
			#######################################################
			# Ranking after the pools	
			#######################################################

			
			# Need to check the round no
			if (defined($stage[2]) && $stage[2] eq "finished")
			{
				#print "getting ranking for round $haspoules\n";
				$fencers = $c->ranking("p", $stage[1]);
			}
			elsif (defined($stage[2]) && $stage[2] eq "constitution")
			{
				#print "getting ranking for round $haspoules - 1\n";
				$fencers = $c->ranking("p", $stage[1] - 1);
			}
			else
			{
				$fencers = $c->ranking("p");
			}
			
			# print Dumper(\$fencers);
			
			@lout = do_ranking_list($fencers, $aff);
			
			
			$list->{ranking}->{fencer} = [@lout];
			$list->{ranking}->{count} = @lout;
			$list->{ranking}->{type} = "pools";
		} 
		elsif ($vertlist eq 'result') 
		{ 
			#######################################################
			# Final Ranking
			#######################################################
				
			$fencers = $c->ranking();
				
			# print Dumper(\$fencers);
			
			my $sequence = 1;
			
			foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
			{
				push @lout, {	name => $fencers->{$fid}->{nom}, 
								affiliation => $fencers->{$fid}->{$aff} || '',
								position => $fencers->{$fid}->{seed} || '', 	
								elimround => $fencers->{$fid}->{group} || '', 
								id => $fid || '',
								sequence => $sequence};
				$sequence++;
			}
			
			$list->{ranking}->{fencer} = [@lout];
			$list->{ranking}->{count} = @lout;
			$list->{ranking}->{type} = "final";
		}
		elsif ($vertlist eq 'entry')
		{
			@lout = do_entry_list($c, $aff);
			
			$list->{entry}->{fencer} = [@lout];
			$list->{entry}->{count} = @lout;
			$list->{entry}->{nif} = $nif;
		}
	 }
	 
	 return $list;
}


sub do_where
{
	my $c = shift;
	
	my $out = {};
	
	return $out unless want($c, "where");

	my $fencers = $c->matchlist;
	
	#print "do_where: " . $c->titre_ligne . ": " . Dumper(\$fencers);
	
	my @list;
	
	my $sequence = 1;
	
	foreach my $f (sort keys %$fencers)
	{
		push @list, { 	name => $f, 
						time => $fencers->{$f}->{time} || "", 
						round => $fencers->{$f}->{round} || "", 
						piste => $fencers->{$f}->{piste} || "",
						sequence => $sequence 
					};
		$sequence++;
	}
	
	$out->{where}->{fencer} = [@list];
	$out->{where}->{count} = @list;
	
	return $out;
}


sub do_tableau_matches
{

	my $t = shift;
	my $aff = shift;
	
	my @list;
	

	# print $c->titre_ligne . ": " . Dumper(\$t);

	debug(3, Dumper(\$t));

	my $numbouts = $t->{taille} / 2;

	debug(1, "do_tableau_matches: Number of bouts: $numbouts");

	foreach my $m (1..$numbouts)
	{	
		# print "do_tableau: calling match\n";
		my $match = $t->match($m);

		debug(3, "do_tableau: match = " . Dumper(\$match));

		# push @winners, ($match->{winnerid} || undef ) if $col eq 1;

		my $fa = { id => $match->{idA} || "", name => $match->{fencerA} || "", seed => $match->{seedA} || "", affiliation => $match->{$aff . 'A'} || ""};
		my $fb = { id => $match->{idB} || "", name => $match->{fencerB} || "", seed => $match->{seedB} || "", affiliation => $match->{$aff . 'B'} || ""};

		#$fa->{name} = $winners[($m * 2) - 1] unless $fa->{name};
		#$fb->{name} = $winners[$m * 2] unless $fb->{name};

		my $score = "$match->{scoreA} / $match->{scoreB}";

		$score = "by exclusion" if $score =~ /exclusion/;
		$score = "by abandonment" if $score =~ /abandon/;
		$score = "by penalty" if $score =~ /forfait/;
		$score = "" if $score eq " / ";

		push @list, { 	number => $m, 
						time => $match->{time} || "",  
						piste => $match->{piste} || "",
						fencerA => $fa,
						fencerB => $fb,
						winnername => $match->{winnername} || "",
						winnerid => $match->{winnerid} || "",
						score => $score
					};
	};

	return @list;
}

sub do_tableau
{
	my $c = shift;
	my $where = shift;

	my @w = split / /,$where;
	shift @w;
	

	print "do_tableau: w = " . Dumper(\@w);
	
	my $out = {};
	
	#my @tableaux;
	
	my $dom = $c->domaine_compe;
	my $aff = $dom eq "national" ? "club" : "nation";
	
	#if ($where eq "termine")
	#{	
	#	@tableaux = ($c->tableaux)[-2,-1];
	#}
	#else
	#{
	#	@tableaux = $c->tableaux(1);
	#	debug(1, "do_tableau: tableaux = " . Dumper(\@tableaux));
	#}
	
	
	my $col = 1;
	
	foreach my $tab (@w)
	{
		
		my $t = $c->tableau($tab,1);
		$out->{title} = $t->nom_etendu unless $out->{title};
		my @list = do_tableau_matches($t, $aff);
		
		# debug(3, "do_tableau: list = " . Dumper(\@list));
		$out->{"col$col"}->{match} = [@list];
		
		$col++;

		# print "do_tableau: winners = " . Dumper(\@winners);
	}
	
	my @alltab = $c->tableaux;
	$out->{matches} = {};
	
	foreach my $atab (@alltab)
	{
	
		my $t = $c->tableau($atab,1);
		$out->{matches}->{"$atab"}->{title} = $t->nom_etendu;
		print "do_tableau: atab = " . Dumper($atab);
		my @list = do_tableau_matches($t, $aff);
		$out->{matches}->{"$atab"}->{match} = [@list];
		my $matchcount = @list;
		$out->{matches}->{"$atab"}->{count} = $matchcount;
	}
	
	return $out;
}

sub debug
{
	my $level = shift;
	my $text = shift;
	
	print STDERR "DEBUG($level): $text\n" if ($level le $Engarde::DEBUGGING);
}

##################################################################################
# read_config
# simply reads in the XML file now
##################################################################################
sub read_config
{
	my $cf = shift; 
	# my $xml = new XML::Simple(ForceArray => 1);

	# read XML file
	# my $config = $xml->XMLin($cf, ForceArray=>1);
	my $data = XMLin($cf, ForceArray=> qr/competition/);
	
	# print Dumper(\$data);
	return $data;
}



##################################################################################
# subs to determine page content
##################################################################################

#		  Whereami							Poules?				  Tableau?			List
#
#		  ???							  N						 N				 entry
#		  poules x y y y						 Y							N				fpp
#		  poules x finished					 Y							N				ranking
#		  tableau z99						N						  Y			  result
#
sub want
{
	my $c = shift;
	my $what = shift;

	my $where = $c->whereami;

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
	elsif ($what eq "where")
	{
		my @w = split / /, $where;
		debug(1, "want(): w = [@w]");
		return undef if $w[0] eq "debut" || $w[0] eq "poules" || $w[0] eq "termine";
		my $t = $c->tableau($w[1]);
		my $size = $t->taille;
		return undef if $size < 16;
		return $size;
	}
	else
	{
		return undef;
	}
}

sub which_list
{
	my $where = shift;

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

		debug(2, "which_list(): w = [@w]");

		return "ranking" if $w[1] eq $w[2];
		return "result" unless $w[1] eq $w[2];
	}
	elsif ($where eq "debut")
	{
		return "entry";
	}
}
