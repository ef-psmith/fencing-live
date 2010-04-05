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
# use IO::Handle;

use vars qw($pagedetails);

$Engarde::DEBUGGING=1;

######################################
# processcomp ($compfile, \%pistedata)
######################################
sub processcomp
{
   # Competition filename
   my $compname = shift;
   # Reference to a hash of piste data
   my $pistedata = shift;
   
   # Create the comp
	my $comp = Engarde->new($compname);
	
	my $where = $comp->whereami;
	
	print "Initial where: $where\n";
	
	# write the start of the competition fragment
	my $compspan = "<span class=\"competition\"><h3>".$comp->titre_ligne."</h3><p>State:";
	my $compbouts = "";
	
	# If we are finished then just return a finished fragment of xhtml
	if ($where =~ /termine/)
	{
	   $compspan = $compspan . "Finished</p></span>\n";
	}
	# Now check for a Tableau
	elsif ($where =~ /tableau/)
	{
	   # Truncate the where string to the tableau name
		$where =~ s/tableau //;

		my @w = split / /, $where;
		
		$where = $w[0];
		
		print "Where: $where\n";
		
		# Get the tableau
		my $tab = $comp->tableau($where);
		
		
		my $boutnum = 1;
		my $numbouts;
		($numbouts) = ($where =~ /\D*(\d*)/);
		while($boutnum < $numbouts / 2)
		{
	      my $bout = $comp->match($where, $boutnum);
		   # For each bout that both fencers but no winner
		   if (!defined($bout->{winner}) && defined($bout->{fencerA}) && defined($bout->{fencerB}))
		   {
		      # Do we have a piste defined?
		      if (defined($bout->{'piste'}))
		      {
		         my $piste = $bout->{'piste'};
		         my $time = $bout->{'time'} if $bout->{'time'} && $bout->{'time'} ne "0:00";
		         my $fencerA = $bout->{fencerA};
		         my $fencerB = $bout->{fencerB};
   		      
		         my $hours;
		         my $mins;
		         ($hours, $mins) = ($time =~ /(\d*):(\d*)/);
   		      
		         print "Time is $hours:$mins\n";
		         my @timeData = localtime(time);
   		     
		         my $boutdata = "<p";
		         # If we are more than 30 mins past the time the bout should have started then we are late
		         my $timesincestart = (60 * $timeData[2] + $timeData[1]) - (60 * $hours + $mins);

		         if (30 < $timesincestart)
		         {
		            $boutdata = $boutdata. " class=\"late\"";
		         }
   		      
		         $boutdata = $boutdata .">$time - $fencerA vs $fencerB (".$comp->titre_ligne.")</p>";
		         print $boutdata . "\n";
		         if (!defined(${$pistedata}{$piste}))
		         {
		            ${$pistedata}{$piste} = $boutdata;
		         }
		         else
		         {
		            ${$pistedata}{$piste} = ${$pistedata}{$piste}.$boutdata;
		         }
		      }
		      else
		      {
		         # We have a bout without a piste so add it to the competition info
		         $compbouts = $compbouts. "<p>".$bout->{fencerA}." vs ".$bout->{fencerB}." (".$comp->titre_ligne.")</p>\n";
		      }
		   } 
		   # Increment the bout number
		   $boutnum = 1 + $boutnum;
	   }
	   
		$compspan = $compspan . "In tableau $where</p><h3>Bouts without a piste allocated</h3>$compbouts</span>\n";
	}
	
	elsif ($where eq "poules 1 constitution")
	{
	   $compspan = $compspan . "Building first round of poules</p></span>\n";
	}
	elsif ($where =~ /poules/)
	{
		my @hp = split / /,$where;
		
	   my $haspoules = $hp[1];

	   my %pouledefs;
   	
	   if ($haspoules) 
	   { 
		   if ($hp[2] eq "constitution")
		   {
			   $haspoules = $haspoules-1;
		   }
	      $compspan = $compspan . "Poule round $haspoules</p></span>\n";
		  
	      my $defindex = 1;
         	
	      my $poule; 
	      do 
	      {
	         # Get the poule object
		      $poule = $comp->poule($haspoules,$defindex);

            # The poule is finished if it has a grid member
		      if (defined($poule) && !defined($poule->grille)) 
		      {
		      
			      my $piste = $poule->piste_no;
			      my $time = $poule->time();
			      
			      if (!defined($time))
			      {
			         $time = "00:00";
			      }
			      
			      print "Poule $defindex at time $time\n";
			      
			      
		         my $pouledata = "<p>$time - Poule $defindex (".$comp->titre_ligne.")</p>";
			      # If the piste is defined then add to the piste
			      if (defined($piste))
			      {
			      
		            if (!defined(${$pistedata}{$piste}))
		            {
		               ${$pistedata}{$piste} = $pouledata;
		            }
		            else
		            {
		               ${$pistedata}{$piste} = ${$pistedata}{$piste}.$pouledata;
		            }
			         
			      }
			      else
			      {
			         # If the piste isn't defined then add to the Competition list
			         $compbouts = $compbouts. "$pouledata\n";
			      }
			      
		         #print "Poule: " . Dumper(\$poule);
		      }
		      
		      $defindex++;
		   }
	      while(defined($poule) && defined($poule->{'mtime'}));

	   }
	   else
	   {
	      
	      $compspan = $compspan . "Doing poules(just not sure what)</p></span>\n";
	   }
	}
	elsif ($where =~ /debut/)
	{
	   $compspan = $compspan . "Not Started</p></span>\n";
	}
	print "Span for this competition:\n$compspan\n";
	return $compspan;
}



##################################################################################
# readfilenames 
##################################################################################
sub readfilenames 
{

	my $filedeffile = shift;

	open FILEDEFFILE, $filedeffile or die "Couldn't open competition file $filedeffile";

	my @filedefs;
	my @pistes;

   my $doingfiles = 0;
   my $doingpistes = 0;
   my $filename;
	while (<FILEDEFFILE>) 
	{
	
		if (/^\[FILES\]$/)
		{
		   $doingfiles = 1;
		}
		elsif (/^\[\/FILES\]$/) 
		{
		   $doingfiles = 0;
		}
		elsif (/^\[PISTES\]$/)
		{
		   $doingpistes = 1;
		}
		elsif (/^\[\/PISTES\]$/) 
		{
		   $doingpistes = 0;
		}
		elsif (($filename) = ($_ =~  /^(.+)$/))
		{
	      if ($doingfiles)
	      {  
		      push(@filedefs, $filename);
		   }
		   elsif ($doingpistes)
		   {
		      # Doing pistes
		      push(@pistes, $filename);
		   }
		}
		else
		{
		   print "Couldn't work out what to do with: " . $_ . "\n";
		}
	}
	close FILEDEFFILE;

	# print "pagedefs = " . Dumper(\@pagedefs);
	my %inidata;
	$inidata{ 'files'} = \@filedefs;
	$inidata{ 'pistes'} = \@pistes;
	return %inidata;
}

##################################################################################
# Main starts here
##################################################################################
my $pagedeffile = shift || "comps.ini";
my $outputfile = shift || "dtsummary.xml";
# read the page definitions

# print "MAIN: pages = " . Dumper(\@pages);

my $fh = select(STDOUT);
$| = 1;
select($fh);
# STDOUT->autoflush(1);  # to ease debugging!

while (1)
{
	print "\nRunning......\n";
	my %inidata = readfilenames ($pagedeffile);
	my $files = $inidata{'files'};
		
	my @compdata;
	my %pistedata;
	foreach my $filename (@$files)
	{
	   print "Processing file: $filename\n";
	   
	   push (@compdata, processcomp($filename, \%pistedata));
	   
	}	
		
	open( OUTFILE,"> $outputfile.tmp") || die("can't open $outputfile.tmp: $!");
	print OUTFILE "<?xml version=\"1.0\" ?>\n";
	print OUTFILE "<dtdata>\n<returndata>\n<div id=\"competitions\">\n";
	
	# print out the competition data
	foreach my $comp (@compdata)
	{
	   print OUTFILE $comp;
	}
	
	
	print OUTFILE "</div>\n<div id=\"pistes\">\n";
	my $pistes = $inidata{'pistes'};
	# Now the pistes
	foreach my $piste (@$pistes)
	{
	   print OUTFILE "<span class=\"piste\"><h2>Piste: $piste</h2>\n";
	   if (defined($pistedata{$piste}))
	   {
	      # print out the scheduled bouts
	      print OUTFILE "<h3>Scheduled bouts</h3>\n".$pistedata{$piste};
	   }
	   else
	   {
	      # No bouts
	      print OUTFILE "<p class=\"free\">Piste is free</p>\n";
	   }
	   print OUTFILE "</span>\n";
	}
	print OUTFILE "</div>\n</returndata>\n</dtdata>\n";
	
	close OUTFILE;

	rename $outputfile . ".tmp", $outputfile;
	# print "Done\nSleeping...\n";

	sleep 30;
}
			
