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
	
	$comp_output->{competition} = [];
	
	my $comps = $config->{competition};
	
	# generate the data
	
	foreach my $cid ( sort keys %$comps)
	{
		# print Dumper (\$config->{competition}->{$cid});

		# print Dumper(\$config->{competition}->{$cid});
		
		next unless $config->{competition}->{$cid}->{enabled} eq "true";	
	
		my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw");
		
		next unless $c;
		
		do_comp($c, $cid, $config->{competition}->{$cid});
	}
		
	#print Dumper(\$comp_output);
	#print "************ XML *************************\n";
	print XMLout($comp_output, KeyAttr => []);
	#print "************ END *************************\n";
	exit;
	
	# output the relevant bits for each series
	my $series = $config->{series};
	
	foreach my $sid ( sort keys %$series)
	{
		next unless ($config->{series}->{$sid}->{enabled} eq "true");
		
		# print Dumper(\$config->{series}->{$sid});
	}

	# print Dumper(\$comp_output);
	
	print "************ XML *************************\n";
	print XMLout($comp_output, KeyAttr => []);
	print "************ END *************************\n";
	
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
	
	if ($where =~ /poules/)
	{
		my @hp = want($c, "poules");
		
		$out->{pools} = do_poules($c, @hp);
		push @{$out->{lists}}, do_list($c, $nif, @hp);
		
	}
	
	if ($where =~ /tableau/ || $where eq "termine")
	{
		if ($where eq "termine")
		{	
			my @tableaux = ($c->tableaux)[-2,-1];
			
			# print Dumper (\@tableaux);
			# print "createRoundTableaus: tableaux (where=termine) = @tableaux\n";
			# print "createRoundTableaus: where (where=termine) = $where\n";
			
			# $out->{lists} = do_list($c, $nif);
		}
		else
		{
			
			# @tableaux = $c->tableaux(1);
		}
		
		push @{$out->{lists}}, do_list($c, $nif);
	}
	
	if ($where eq "debut")
	{
		push @{$out->{lists}}, do_list($c, $nif, "debut");
	}
	
	#if mid list needed
	
	my $wh = do_where($c);
	
	print Dumper(\$wh);
	
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
			$out = {'number' => $pnum+1, 'piste' => $poule->piste || '', 'heure' => $poule->heure || '', 'size' => $poule->size};
			$out->{fencers} = $poule->grid(1);

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
			#######################################################
			# Fencers, Pools, Pistes
			#######################################################

			$fencers = $c->fpp();
			
			# print Dumper(\$fencers);
			
			my $sequence=1;
			foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
			{
				push @lout, {	name => $fencers->{$fid}->{nom}, 
								affiliation => $fencers->{$fid}->{$aff} || '',
								piste => $fencers->{$fid}->{piste} || '', 	
								poule => $fencers->{$fid}->{poule} || '', 
								sequence => $sequence};
				$sequence++;
			}

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
			
			my $sequence = 1;
			
			foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
			{
				push @lout, {	name => $fencers->{$fid}->{nom_court}, 
								affiliation => $fencers->{$fid}->{$aff} || '',
								elimround => "p", 	
								position => $fencers->{$fid}->{seed} || '', 
								sequence => $sequence};
				$sequence++;
			}
			
			$list->{ranking}->{fencer} = [@lout];
			$list->{ranking}->{count} = @lout;
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
								sequence => $sequence};
				$sequence++;
			}
			
			$list->{ranking}->{fencer} = [@lout];
			$list->{ranking}->{count} = @lout;
		}
		elsif ($vertlist eq 'entry')
		{
			$fencers = $c->tireurs;
			
			# print Dumper(\$fencers);
			
			my $sequence = 1;
			
			foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
			{
				push @lout, {	name => $fencers->{$fid}->{nom}, 
								affiliation => $fencers->{$fid}->{$aff} || '',
								seed => $fencers->{$fid}->{serie} || '', 
								sequence => $sequence};
				$sequence++;
			}
			
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
	
	my $fencers = $c->matchlist;
	
	# print $c->titre_ligne . ": " . Dumper(\$fencers);
	
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
	# print Dumper(\$fencers);
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
	# my $config = $xml->XMLin($cf);
	my $data = XMLin($cf);
	
	# print Dumper(\$data);
	return $data;
}


##################################################################################
# sorting subs for use by list output
##################################################################################
sub namesort
{
	#$fencers{$fid}->{$a}->{nom} cmp $fencers->{$fid}->{$b}->{nom};
}

sub ranksort
{
	#print STDERR "DEBUG: ranksort(): a = $a, b = $b\n" if $Engarde::DEBUGGING > 1;
	#$pagedetails->{'entry_list'}->{$a}->{seed} <=> $pagedetails->{'entry_list'}->{$b}->{seed};
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

		print STDERR "DEBUG: which_list(): w = [@w]\n" if $Engarde::DEBUGGING > 1;

		return "ranking" if $w[1] eq $w[2];
		return "result" unless $w[1] eq $w[2];
	}
	elsif ($where eq "debut")
	{
		return "entry";
	}
}