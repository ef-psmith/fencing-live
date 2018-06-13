#!/usr/bin/perl 
# (c) Copyright Oliver Smith & Peter Smith 2007-2018
# oliver_rps@yahoo.co.uk
# peter.smith@englandfencing.org.uk

use 5.018;
use warnings;
use lib "../lib";
use lib "/home/engarde/lib";
use Engarde;
use FencingTime;
use DT::Control;
use DT::Log;
use Data::Dumper::Concise;
use Carp qw(cluck);
use XML::Simple;
# $XML::Simple::PREFERRED_PARSER = "XML::Parser";

no warnings 'once';
no warnings 'io';	

# NOTE:
#
# If you get the error "could not find PaserDetails.ini..."
# run this from the command line
#	
# perl -MXML::SAX -e "XML::SAX->add_parser('XML::SAX::PurePerl')->save_parsers()"
#
# THIS WILL BE VERY VERY SLOW!  PurePerl is not built for speed

# New XML / XSLT / Ajax scheme
#
# Create a hashref in memory containing all of the required data and write to an XML file

###  UPDATE MARCH 2013 ###
# New (improved) logic....

# read_config()
#
# foreach (competition)
# {
#	suck_data_into_hashref();
#	write_xml();
# }
#
# sleep;

##################################################################################
# Main starts here
##################################################################################


my $runonce = shift || 0;


unless ($^O =~ /MSWin32/ || $runonce)
{
	eval { use App::Daemon qw(detach) }; 
	$App::Daemon::as_user = "engarde";
	detach();
}

# save original file handles
# open(OLDOUT, ">&STDOUT");
# open(OLDERR, ">&STDERR");



while (1)
{
	my $config = config_read();

	#TRACE( sub { Dumper($config) } );
	
	my $comps = $config->{competition};
	
	$comps = {} unless ref $comps eq "HASH";

	# my $ft = FencingTime->instance({ host => $config->{ftserver} }) if $config->{ftserver};
	my $ft;

	# generate the data
	
	foreach my $cid ( sort keys %$comps)
	{
		next unless $comps->{$cid}->{enabled} eq "true";	
	
		# don't regenerate this one if we are paused
		next if $comps->{$cid}->{hold};
		
		# FT TODO
		my $c;
		if ($comps->{$cid}->{type} eq "engarde")
		{
			TRACE("type = engarde");
			# TRACE( sub { Dumper($comps-{$cid}) });
			$c = Engarde->new({file => $comps->{$cid}->{source} . "/competition.egw"});
		}
		else
		{
			TRACE("type = ft");
			$c = $ft->tournament($config->{tournamentname})->event($comps->{$cid}->{source});
		}

		next unless $c;

		$c->{cid} = $cid;
		
		do_comp($c, $cid, $config);

		undef $c;
	}
		
	INFO("loop finished");
		
	unless ($runonce)
	{
		# close the redirected filehandles
		# close(STDOUT) ;
		# close(STDERR) ;

		# restore stdout and stderr
		# open(STDERR, ">&OLDERR");
		# open(STDOUT, ">&OLDOUT");

		sleep 60;
	}
	else
	{
		#exit;
	}


	sleep 60;
}


############################################################################
# Process an individual competition into comp_output hashref
############################################################################

sub do_comp 
{
	my $c = shift;
	my $cid = shift;
	my $config = shift;
	my $location = $config->{targetlocation};
	my $comp = $config->{competition}->{$cid};
	
	my $nif = $config->{nif};
	
	my $out = {};
	
	$out->{id} = $cid;
	$out->{titre_ligne} = $c->titre_ligne;
   	$out->{background} = $comp->{background};
   
   	$out->{message} = $comp->{message};
   
	#	<xsl:variable name="fpppagesize" select="number(30)"/>
	#	<xsl:variable name="whereamipagesize" select="number(35)"/>
	#	<xsl:variable name="rankingpagesize" select="number(30)"/>
	#	<xsl:variable name="entrysize" select="number(138)"/>
	#	<xsl:variable name="poolsperpage" select="number(2)"/>
	
  
	# sizes are per column in multi-column lists 
	$out->{fpppagesize} = 42;
	$out->{whereamipagesize} = 40;
	$out->{rankingpagesize} = 40;
	$out->{entrysize} = 132;
	$out->{poolsperpage} = 3;
   
	my $where = $c->whereami;
	DEBUG("where = $where");
	# insert current status
	$out->{stage} = $where;
	
	my $dom = $c->domaine_compe || "national";
	# my $aff = $dom eq "national" ? "club" : "nation";
	my $aff = "nation";

	############################################
	# Always need the entry list
	############################################

	# potential scope issue - check other $list variables	
	# maybe remove the $list->{type} indirection?

	my $list = {};	

	$list->{entry} = $c->entry_list;

	#TRACE( sub { Dumper(\$list) });

	# $list->{entry}->{nif} = $nif;
	#push @{$out->{lists}}, $list;
	
	# poules are needed for anything other than debut now
	if ($where ne "debut" && ${$c->nombre_poules}[0])
	{
		my $round = 1;
		
		INFO("number of rounds = " . scalar @{$c->nombre_poules});
		
		while ($round <= scalar @{$c->nombre_poules})
		{
			DEBUG(2, "do_comp(): round = " . $round);
			my @hp = ("poules", $round, "finished");
			push @{$out->{pools}} , $c->poules_list(@hp);
			$round++;
		} 
	}

	# only need fpp if we are still in the poules
	if ($where =~ /poules/)
	{
		my @lout;
		my $plist = {};

		if (ref $c eq "FencingTime::Event")
		{
			$list->{fpp} = $c->fpp;
			# push @{$out->{lists}}, $list;

			# @lout = $c->fpp;
		}
		else
		{
			# We need the fpp for the series
			@lout = do_fpp_list($c, $aff);		
		
			$list->{fpp}->{fencer} = [@lout];
			$list->{fpp}->{count} = @lout;
			# $list->{fpp}->{round} = $where[1];
		}
	}


	if ($where =~ /tableau/ || $where eq "termine" || $where =~ /finished/ )
	{
		# push the ranking after the pools 
		my $fencers = $c->ranking("p");

		my @rlout = do_ranking_list($fencers, $aff);

		# TRACE( sub { Dumper(\@rlout) });

		$list->{ranking}->{fencer} = [@rlout];
		$list->{ranking}->{count} = @rlout;
		$list->{ranking}->{type} = "pools";
		push @{$out->{lists}}, $list;
	

		$out->{tableau} = $c->tableau_with_matches($where);

		push @{$out->{lists}}, do_final_list($c, $nif);

		# my $fencers = $c->ranking();

		#my @lout = do_ranking_list($fencers, $aff);
		#my $rlist = {};

		#$rlist->{ranking}->{fencer} = [@lout];
		#$rlist->{ranking}->{count} = @lout;
		#$rlist->{ranking}->{type} = "final";
		# push @{$out->{lists}}, $rlist;
	}
	
	my $wh = do_where($c);
	
	push @{$out->{lists}}, $wh if $wh->{where}->{count};
	
	$out->{lastupdate} = localtime;
	
	my $outfile = $location . "/competitions/" . $cid . ".xml";

	DEBUG("outfile = $outfile");

	# print STDERR "do_comp: out = " . Dumper(\$out);

	# TRACE( sub { Dumper(\$out) });

	XMLout($out, SuppressEmpty => undef, RootName=>"competition", OutputFile => $outfile . ".tmp");
	rename($outfile . ".tmp", $outfile);
	# $comp_output->{competition}->{$cid} = $out;
}


############################################################################
# Process an individual competition's fencer pools pistes list 
############################################################################

sub do_fpp_list
{
	my $c = shift;
	my $aff = shift;
	
	my @lout;
	
	#######################################################
	# Fencers, Pools, Pistes
	#######################################################

	# fpp from ft returns a hashref
	#	$out = {
	#		count => nn,
	#		fencers => {
	#			1 => {
	#				},
	#			2 => {
	#				},
	#		},
	#	};	

	my $fencers = $c->fpp;

	# DEBUG( sub {  Dumper(\$fencers) });

	my $sequence=1;

	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
	{
		$fencers->{$fid}->{piste_no} = 'TBD' if ($fencers->{$fid}->{piste_no} && $fencers->{$fid}->{piste_no} eq "-1");
	
		my $aff_value;
		if ($aff eq "nation")
		{
			$aff_value = "$fencers->{$fid}->{nation} " . $fencers->{$fid}->{club} || 'U/A';
		}
		else
		{
			$aff_value = $fencers->{$fid}->{club} || 'U/A';
		}

		push @lout, {	name => $fencers->{$fid}->{nom}, 
						affiliation => substr($aff_value,0,16),
						piste => $fencers->{$fid}->{piste_no} || ' ', 	
						poule => $fencers->{$fid}->{poule} || '', 
						id => $fid || '',
						sequence => $sequence};
		$sequence++;
	}

	return @lout;
}

############################################################################
# Process an individual competition's ranking list 
############################################################################

sub do_ranking_list
{
	my $fencers = shift;
	my $aff = shift;
	my @lout;
	my $sequence = 1;

	foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
	{
		my $aff_value;

		if ($aff eq "nation")
		{
			$aff_value = "$fencers->{$fid}->{nation} " . $fencers->{$fid}->{club} || 'U/A';
		}
		else
		{
			$aff_value = $fencers->{$fid}->{club} || 'U/A';
		}

		# TRACE( sub { Dumper($fencers->{$fid}) });

		push @lout, {	name => $fencers->{$fid}->{nom_court}, 
						affiliation => substr($aff_value,0,16),
						elimround => $fencers->{$fid}->{group} || 'elim_none', 	
						position => $fencers->{$fid}->{seed} || '',
						id => $fid || '', 
						vm => $fencers->{$fid}->{vm},
						hs => $fencers->{$fid}->{hs},
						hr => $fencers->{$fid}->{hr},
						ind => $fencers->{$fid}->{ind},
						# category => $fencers->{$fid}->{category} || '',
						sequence => $sequence};
		$sequence++;
	}

	return @lout;
}

############################################################################
# Process an individual competition's list output  
############################################################################

sub do_final_list
{
	my $c = shift;
	my $nif = shift;
	
	my @lout;
	
	my $list = {};
	
	my $fencers;
	
	my $dom = $c->domaine_compe;
	my $aff = $dom eq "national" ? "club" : "nation";

	#######################################################
	# Final Ranking
	#######################################################
				
	$fencers = $c->ranking();

				
	# DEBUG( sub { Dumper(\$fencers) } );
			
	my $sequence = 1;
	
	foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
	{
		my $aff_value;
		if ($aff eq "nation")
		{
			$aff_value = "$fencers->{$fid}->{nation} " . $fencers->{$fid}->{club} || 'U/A';
		}
		else
		{
			$aff_value = $fencers->{$fid}->{club} || 'U/A';
		}

		push @lout, {	name => $fencers->{$fid}->{nom}, 
				affiliation => $aff_value,
				position => $fencers->{$fid}->{seed} || '', 	
				elimround => $fencers->{$fid}->{group} || 'elim_none', 	
				id => $fid || '',
				# category => $fencers->{$fid}->{category} || '',
				sequence => $sequence 
				};
		$sequence++;
	}
		
	$list->{ranking}->{fencer} = [@lout];
	$list->{ranking}->{count} = @lout;
	$list->{ranking}->{type} = "final";
	
	# TRACE( sub { Dumper(\$list) }); 
	return $list;
}


sub do_where
{
	my $c = shift;
	
	my $out = {};
	
	return $out unless want($c, "where");

	# matchlist is now list->{tableau}->{matchid}->{fencerA/B}
	my $matchlist = $c->matchlist;

	my @list;
	
	foreach my $t (sort { $b->{count} <=> $a->{count} } values %$matchlist)
	{
		my @matches = @{$t->{match}};
	
		# DEBUG(sub {Dumper(\@matches)});	

		INFO("entering foreach loop");

		foreach my $m (@matches)
		{
			# WARN( sub { Dumper(\$m) } );
			next if $m->{winnerid} > 0;

			$m->{piste} = 'TBD' if $m->{piste} eq "-1";
		
			if ($m->{fencerA}->{name})
			{
				my $aff = $m->{nation} || $m->{club};
				push @list, { 	name => $m->{fencerA}->{name}, 
								time => $m->{time} || "TBD", 
								round => $t->{name},
								piste => $m->{piste} || "TBD",
								aff => $aff,
							};

			}
				
			if ($m->{fencerB}->{name})
			{
				my $aff = $m->{nation} || $m->{club};
				push @list, { 	name => $m->{fencerB}->{name}, 
								time => $m->{time} || "TBD", 
								round => $t->{name},
								piste => $m->{piste} || "TBD",
								aff => $aff,
						};

			}
		}

		INFO("after foreach loop");
	}

	my $sequence = 1;

	$_->{sequence} = $sequence++ foreach sort { $a->{name} cmp $b->{name} } @list;
	
	$out->{where}->{fencer} = [@list];
	$out->{where}->{count} = @list;
	
	# DEBUG( sub { Dumper(\$out) } );

	$out;
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
	# returns the size of the largest tableau or undef

	my $c = shift;
	my $what = shift;

	my $where = $c->whereami;

	if ($what eq "where")
	{
		my @w = split / /, $where;
		DEBUG("want(): w = [@w]");
		return undef if $w[0] eq "debut" || $w[0] eq "poules" || $w[0] eq "termine";
		return undef unless $w[1];
		my $t = $c->tableau($w[1]);
		my $size = $t->taille;
		# return undef if $size < 16;
		return $size;
	}
	else
	{
		return undef;
	}
}

