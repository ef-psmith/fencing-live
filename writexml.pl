#!/usr/bin/perl -w
# (c) Copyright Oliver Smith & Peter Smith 2007-2013
# oliver_rps@yahoo.co.uk
# peter.smith@englandfencing.org.uk

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
use lib "/home/engarde/lib";

use strict;
use Engarde;
use Engarde::Control;

use Data::Dumper;
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

	# require Proc::Daemon;
	# require Proc::PID::File;

    # Daemonize
    # my $pid = Proc::Daemon::Init( { 
	# 	pid_file => '/home/engarde/public/writexml.pid',
	# 	work_dir => '/home/engarde/live/web',
	# 	child_STDOUT => '+>>/home/engarde/live/web/out.txt',
	# 	child_STDERR => '+>>/home/engarde/live/web/out.txt',
	# });

	# Engarde::debug(1,"writexml:main(): child forked as $pid");

	# exit 0 if ($pid);

    # If already running, then exit
    #if (Proc::PID::File->running()) {
    #    exit(0);
    #}

	#eval { 	
	#		require Proc::Daemon;
	#		my $pid = Proc::Daemon::Init({ pid_file=>'/home/engarde/public/writexml.pid'});
	#		exit 0 if ($pid);
	#	}

	# App::Daemon doesn't work for some reason
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
	
	$Engarde::DEBUGGING=$config->{debug};
	
	if ($config->{log})
	{
		open STDERR, ">>" . $config->{targetlocation} . "/" . $config->{log} or die $!;
		open STDOUT, ">&STDERR";

		# set AUTOFLUSH to ensure messages are written in the correct order
		my $fh = select(STDERR);
		$| = 1;
		select($fh);
	}
	
	my $comps = $config->{competition};
	
	$comps = {} unless ref $comps eq "HASH";
	
	# generate the data
	
	foreach my $cid ( sort keys %$comps)
	{		
		next unless $comps->{$cid}->{enabled} eq "true";	
		
		# don't regenerate this one if we are paused
		next if $comps->{$cid}->{hold};
		
		my $c = Engarde->new($comps->{$cid}->{source} . "/competition.egw");		
		next unless $c;
		
		do_comp($c, $cid, $config);
	}
		
	Engarde::debug(1, "loop finished");
		
	unless ($runonce)
	{
		# close the redirected filehandles
		close(STDOUT) ;
		close(STDERR) ;

		# restore stdout and stderr
		# open(STDERR, ">&OLDERR");
		# open(STDOUT, ">&OLDOUT");

		sleep 60;
	}
	else
	{
		exit;
	}
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

	my $where = $c->whereami;
	
	# insert current status
	$out->{stage} = $where;
	
	my $dom = $c->domaine_compe;
	my $aff = $dom eq "national" ? "club" : "nation";

	############################################
	# Always need the entry list
	############################################
	
	my $list = {};	
	do_entry_list($c, $aff, $list);

	$list->{entry}->{nif} = $nif;
	push @{$out->{lists}}, $list;
	
	# poules are needed for anything other than debut now
	if ($where ne "debut" && ${$c->nombre_poules}[0])
	{
		#my @hp = want($c, "poules");

		my $round = 1;
		
		Engarde::debug(1, "do_comp(): number of rounds = " . scalar @{$c->nombre_poules});
		
		while ($round <= scalar @{$c->nombre_poules})
		{
			Engarde::debug(2, "do_comp(): round = " . $round);
			my @hp = ("poules", $round, "finished");
			push @{$out->{pools}} , do_poules($c, @hp);
			$round++;
		} 

	}


	# only need fpp if we are still in the poules
	if ($where =~ /poules/)
	{
		# We need the fpp for the series
		my @lout = do_fpp_list($c, $aff);		
		
		$list->{fpp}->{fencer} = [@lout];
		$list->{fpp}->{count} = @lout;
		# $list->{fpp}->{round} = $where[1];

		# push the ranking after the pools 
		my $fencers = $c->ranking("p");

		@lout = do_ranking_list($fencers, $aff);
		my $list = {};

		$list->{ranking}->{fencer} = [@lout];
		$list->{ranking}->{count} = @lout;
		$list->{ranking}->{type} = "pools";
		push @{$out->{lists}}, $list;

	}

	if ($where =~ /tableau/ || $where eq "termine")
	{
		$out->{tableau} = do_tableau($c, $where);
		push @{$out->{lists}}, do_final_list($c, $nif);


		# push the ranking after the pools 
		my $fencers = $c->ranking("p");

		my @lout = do_ranking_list($fencers, $aff);
		my $list = {};

		$list->{ranking}->{fencer} = [@lout];
		$list->{ranking}->{count} = @lout;
		$list->{ranking}->{type} = "pools";
		push @{$out->{lists}}, $list;
	}
	
	my $wh = do_where($c);
	
	Engarde::debug(3, "cid $cid: where = " . Dumper(\$wh));
	
	push @{$out->{lists}}, $wh if $wh->{where}->{count};
	
	$out->{lastupdate} = localtime;
	
	my $outfile = $location . "/competitions/" . $cid . ".xml";
	XMLout($out, SuppressEmpty => undef, RootName=>"competition", OutputFile => $outfile . ".tmp");
	rename($outfile . ".tmp", $outfile);
	# $comp_output->{competition}->{$cid} = $out;
}


############################################################################
# Process an individual competition's pools into comp_output hashref
############################################################################

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

			$out = {'number' => $pnum+1, 'piste' => $poule->piste_no || 'N/A', 'heure' => $poule->heure || '', 'size' => $poule->size};
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

	my $fencers = $c->fpp();

	# print Dumper(\$fencers);

	my $sequence=1;
	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom}, 
						affiliation => $fencers->{$fid}->{$aff} || 'U/A',
						piste => $fencers->{$fid}->{piste_no} || ' ', 	
						poule => $fencers->{$fid}->{poule} || '', 
						id => $fid || '',
						sequence => $sequence};
		$sequence++;
	}

	return @lout;
}

############################################################################
# Process an individual competition's entry list 
############################################################################

sub do_entry_list
{
	my $c = shift;
	my $aff = shift;
	my $list = shift;
	
	my @lout;
	
	my $fencers = $c->tireurs(1);
				
	# print Dumper(\$fencers);

	my $sequence = 1;

	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} grep /\d+/, keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom}, 
						affiliation => $fencers->{$fid}->{$aff} || 'U/A',
						seed => $fencers->{$fid}->{serie} || '',
						id => $fid || '',
						category => $fencers->{$fid}->{category} || '',
						sequence => $sequence};
		$sequence++;
	}

	$list->{entry}->{fencer} = [@lout];
	$list->{entry}->{count} = @lout;
	$list->{entry}->{present} = $fencers->{present};
	$list->{entry}->{absent} = $fencers->{absent};
	$list->{entry}->{scratch} = $fencers->{scratch};
	$list->{entry}->{entries} = $fencers->{entries};

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
		push @lout, {	name => $fencers->{$fid}->{nom_court}, 
						affiliation => $fencers->{$fid}->{$aff} || 'U/A',
						elimround => $fencers->{$fid}->{group} || '', 	
						position => $fencers->{$fid}->{seed} || '',
						id => $fid || '', 
						vm => $fencers->{$fid}->{vm},
						hs => $fencers->{$fid}->{hs},
						hr => $fencers->{$fid}->{hr},
						ind => $fencers->{$fid}->{ind},
						category => $fencers->{$fid}->{category} || '',
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
				
	Engarde::debug(2,"do_final_list(): seeds = " . Dumper(\$fencers));
			
	my $sequence = 1;
	
	foreach my $fid (sort {$fencers->{$a}->{seed} <=> $fencers->{$b}->{seed}} keys %$fencers)
	{
		push @lout, {	name => $fencers->{$fid}->{nom}, 
				affiliation => $fencers->{$fid}->{$aff} || 'U/A',
				position => $fencers->{$fid}->{seed} || '', 	
				elimround => $fencers->{$fid}->{group} || '', 
				id => $fid || '',
				category => $fencers->{$fid}->{category} || '',
				sequence => $sequence 
				};
		$sequence++;
	}
		
	$list->{ranking}->{fencer} = [@lout];
	$list->{ranking}->{count} = @lout;
	$list->{ranking}->{type} = "final";
	 
	return $list;
}


############################################################################
# Determine the current stage of a competition
############################################################################

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


############################################################################
# Process a tableau into a match structure
############################################################################

sub do_tableau_matches
{
	my $t = shift;
	my $aff = shift;
	
	my @list;
	
	# print $c->titre_ligne . ": " . Dumper(\$t);

	Engarde::debug(3, "do_tableau_matches(): t = " . Dumper(\$t));

	my $numbouts = $t->{taille} / 2;

	Engarde::debug(2, "do_tableau_matches(): Number of bouts: $numbouts");

	foreach my $m (1..$numbouts)
	{	
		# print "do_tableau: calling match\n";
		my $match = $t->match($m);

		Engarde::debug(3, "do_tableau: match = " . Dumper(\$match));

		# push @winners, ($match->{winnerid} || undef ) if $col eq 1;

		my $fa = { id => $match->{idA} || "", name => $match->{fencerA} || "", seed => $match->{seedA} || "", affiliation => $match->{$aff . 'A'} || "", category => $match->{categoryA} || ""};
		my $fb = { id => $match->{idB} || "", name => $match->{fencerB} || "", seed => $match->{seedB} || "", affiliation => $match->{$aff . 'B'} || "", category => $match->{categoryB} || ""};

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

############################################################################
# Process an individual competition's tableaux
############################################################################

sub do_tableau
{
	my $c = shift;
	my $where = shift;

	Engarde::debug(2,"do_tableau: where = $where");

	my $out = {};
	
	my $dom = $c->domaine_compe;
	my $aff = $dom eq "national" ? "club" : "nation";
	
	# my @alltab = $c->tableaux;
	my @alltab = split / /,uc($c->tableaux_en_cours);

	Engarde::debug(2, "do_tableau: alltab = @alltab");
	
	foreach my $atab (@alltab)
	{
		my $t = $c->tableau($atab,1);
		$out->{"$atab"}->{title} = $t->nom_etendu;

		Engarde::debug(2, "do_tableau: atab = $atab");
		my @list = do_tableau_matches($t, $aff);
		$out->{"$atab"}->{match} = [@list];
		my $matchcount = @list;
		$out->{"$atab"}->{count} = $matchcount;
	}
	
	return $out;
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
		Engarde::debug(3, "want(): w = [@w]");
		return undef if $w[0] eq "debut" || $w[0] eq "poules" || $w[0] eq "termine";
		return undef unless $w[1];
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

		return "ranking" unless defined $w[2];
		return "ranking" if $w[1] eq $w[2];
		return "result" unless $w[1] eq $w[2];
	}
	elsif ($where eq "debut")
	{
		return "entry";
	}
}
