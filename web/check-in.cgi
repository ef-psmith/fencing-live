#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/home/engarde/lib';
use lib 'C:/Users/psmith/Documents/prs2712@gmail.com/escrime/eng-perl';

# use Engarde;
use Engarde::Control;
use CGI qw(:standard *table -no_xhtml);
use strict;

my $weaponPath = param('wp') || "";
my $action = lc(param('Action')) || "list";
my $lic = param('lic');

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
    # scratch fencer and reload Check-in screen
    ################################################################################################
    if ($action eq "scratch") {fencer_scratch(); last SWITCH;}
	
	################################################################################################
    # un check-in fencer and reload Check-in screen
    ################################################################################################
    if ($action eq "uncheck") {fencer_absent(); last SWITCH;}
    
	################################################################################################
    # un-scratch fencer in and reload Check-in screen
    ################################################################################################
    if ($action eq "unscratch") {fencer_absent(); last SWITCH;}
	
    ################################################################################################
    # Generate Check-in List screen
    ################################################################################################
    if ($action eq "list") {frm_checkin_list($weaponPath); last SWITCH;}
    
    ################################################################################################
    # Open add/edit screen
    ################################################################################################
    if ($action eq "edit") { frm_fencer_edit($weaponPath); last SWITCH;}

   ################################################################################################
    # Add by licence
    ################################################################################################
    if ($action eq "add") { Engarde::DB::fencer_add_by_lic($weaponPath, $lic); last SWITCH;}	
 
	################################################################################################
    # Write a new record
    ################################################################################################
    if ($action eq "write") { fencer_edit($weaponPath); last SWITCH;}
    
	
    HTMLdie("Undefined action $action requested.");
  }
}
