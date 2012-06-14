#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/share/Public/engarde/lib';
use Engarde;
use Engarde::Checkin;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);
use strict;
#use diagnostics;

$::allowCheckInWithoutPaid = 0;
$::defaultNation = "GBR";
@::weapons = () ;
$::checkinTimeout = 30000;

$::weaponPath = param('wp') || "";
$::action = param('Action') || "List";

%::fencers = ();
%::clubs = ();
%::nations = ();
%::additions = ();
%::addclubs = ();
@::keys = ();

$::maxfkey = -1;
$::maxckey = -1;
$::maxnkey = -1;

$::numfencers = 0;
$::numpresent = 0;


####################################################################################################
# display check-in home screen
####################################################################################################
readConfiguration();

if ($::weaponPath  eq "") {
  
  desk();
  
} else {

  my $comp = Engarde->new($::weaponPath);

  &loadFencerData($comp);

  SWITCH: {
    ################################################################################################
    # check fencer in and reload Check-in screen
    ################################################################################################
    if ($::action eq "Check") {&checkIn; last SWITCH;}
    
    ################################################################################################
    # Update files and reload Check-in screen
    ################################################################################################
    if ($::action eq "Write") {&writeFiles; last SWITCH;}
    
    ################################################################################################
    # Generate Check-in List screen
    ################################################################################################
    if ($::action eq "List") {&displayList; last SWITCH;}
    
    ################################################################################################
    # Update files and reload Check-in screen
    ################################################################################################
    if ($::action eq "Edit") { &editItem; last SWITCH;}
    
    &HTMLdie("Undefined action requested.");
  }
}
