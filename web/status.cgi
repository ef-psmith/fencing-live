#!/opt/bin/perl -w
#
use lib '/share/Public/engarde/lib';
# use Engarde;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);

use strict;
#use diagnostics;

my @weapons;
my $weaponPath = param('wp') || "";

#%::competition = ();
#@::controlIP = ();
#$::statusTimeout = 60000;

#$::numfencers = 0;
#$::numpresent = 0;

readConfiguration();

####################################################################################################
# display control/status home screen
####################################################################################################
HTMLdie("This is a restricted page /$ENV{'REMOTE_ADDR'}") unless (grep {/$ENV{'REMOTE_ADDR'}/} @::controlIP) ;
  
if ($weaponPath  eq "") {

  control();
  
} else {
  my $action = param('Action') || "";
  my $status = param('Status');
  my $name   = param('Name');
  SWITCH:{
    if ($action =~ /update/i)  {update_status($weaponPath, $status) ; last SWITCH;}
    if ($action =~ /details/i) {display_weapon($weaponPath, $name) ;  last SWITCH;}
    if ($action =~ /hide/i)    {hide_weapon($weaponPath) ;            last SWITCH;}
    if ($action =~ /show/i)    {show_weapon($weaponPath) ;            last SWITCH;}
    print "Location: ".url()."\n\n" ;    
  }
}
