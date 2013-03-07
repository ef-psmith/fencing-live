#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/share/Public/engarde/lib';
use lib 'C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-perl';

# use Engarde;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use strict;

my $weaponPath = param('wp') || "";
my $action = lc(param('Action')) || "list";

####################################################################################################
# display check-in home screen
####################################################################################################

if ($weaponPath  eq "") {
  
  frm_checkin_desk();
  
} else {

  SWITCH: {
    ################################################################################################
    # check fencer in and reload Check-in screen
    ################################################################################################
    if ($action eq "check") {fencer_checkin(); last SWITCH;}
    
    ################################################################################################
    # Generate Check-in List screen
    ################################################################################################
    if ($action eq "list") {frm_checkin_list($weaponPath); last SWITCH;}
    
    ################################################################################################
    # Update files and reload Check-in screen
    ################################################################################################
    if ($action eq "edit") { frm_fencer_edit($weaponPath); last SWITCH;}
    
    &HTMLdie("Undefined action $action requested.");
  }
}
