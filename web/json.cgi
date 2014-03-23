#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/home/engarde/lib';
use lib 'C:/Users/psmith/Documents/prs2712@gmail.com/escrime/eng-perl';

# use Engarde;
use Engarde::Control;
use Engarde::DB;
use CGI qw(:standard *table -no_xhtml);
use strict;

my $wp = param('wp') || "";
my $action = lc(param('Action')) || lc(param('action')) || "list";
my $f = param('id');

# $action = "list" if $action eq "undefined";

SWITCH: 
{
    ################################################################################################
    # get list of open events
    ################################################################################################
    if ($action eq "listEvents") {Engarde::DB::config_read_json; last SWITCH;}

    ################################################################################################
    # check fencer in 
    ################################################################################################
    if ($action eq "check") {Engarde::DB::fencer_checkin($wp,$f); last SWITCH;}
    
	################################################################################################
    # scratch fencer
    ################################################################################################
    if ($action eq "scratch") {Engarde::DB::fencer_scratch($wp,$f); last SWITCH;}
	
	################################################################################################
    # un check-in
    ################################################################################################
    if ($action eq "uncheck") {Engarde::DB::fencer_absent($wp,$f); last SWITCH;}
    
	################################################################################################
    # un-scratch fencer
    ################################################################################################
    if ($action eq "unscratch") {Engarde::DB::fencer_absent($wp,$f); last SWITCH;}
	
    ################################################################################################
    # Generate Check-in List screen
    ################################################################################################
    if ($action eq "list") {Engarde::DB::fencer_checkin_list($wp); last SWITCH;}
    
    ################################################################################################
    # Open add/edit screen
    ################################################################################################
    if ($action eq "edit") { frm_fencer_edit($wp,$f); last SWITCH;}
    
	################################################################################################
    # Write a new record 
	# Is this needed in here?  
    # If so, it will need an additional param to pass the json string
	################################################################################################
    if ($action eq "write") { fencer_edit($wp,$f); last SWITCH;}
    
    # HTMLdie("Undefined action $action requested.");
}

1;
