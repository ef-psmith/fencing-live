#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/share/Public/engarde/lib';
use lib 'C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-perl';

# use Engarde;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use Data::Dumper;

my $weaponPath = param('wp') || "";
my $action = param('Action') || "List";


if ($weaponPath) 
{  
	SWITCH: {
    
		################################################################################################
		# Update series config
		################################################################################################
		if ($action eq "update") { weapon_series_update($weaponPath); last SWITCH;}
		
		################################################################################################
		# Delete a comp
		################################################################################################
		if ($action eq "delete") { weapon_delete($weaponPath); last SWITCH;}
    
		################################################################################################
		# Disable a comp
		################################################################################################
		if ($action eq "disable") { weapon_disable($weaponPath); last SWITCH;}

		################################################################################################
		# Enable a comp
		################################################################################################
		if ($action eq "enable") { weapon_enable($weaponPath); last SWITCH;}

		&HTMLdie("Undefined action requested." . Dump());
	}
} 
else 
{
	# HTMLdie(Dump());
  	screen_config_grid();
}
