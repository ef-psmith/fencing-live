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

#my $config = config_read();

# HTMLdie(Dumper(\$config->{series}));

if ($weaponPath) 
{  
	# my $comp = Engarde->new($config->{competition}->{$weaponPath}->{source} . "/competition.egw", 1);

	# loadFencerData($comp);

	SWITCH: {
		################################################################################################
		# check fencer in and reload Check-in screen
		################################################################################################
		if ($action eq "Check") {&checkIn; last SWITCH;}
    
		################################################################################################
		# Update files and reload Check-in screen
		################################################################################################
		if ($action eq "Write") {&writeFiles; last SWITCH;}
    
		################################################################################################
		# Generate Check-in List screen
		################################################################################################
		#if ($action eq "List") {displayList($weaponPath, \$config); last SWITCH;}
    
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
		# Disable a comp
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
