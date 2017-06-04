#!/opt/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use lib '/home/engarde/lib';

# use Engarde;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use Data::Dumper;


#HTMLdie(Dump());

if (param()) 
{
	my $weaponPath = param('wp');
	my $action = param('Action');

	SWITCH: {
    
		################################################################################################
		# Update series config
		################################################################################################
		if ($action eq "update") { weapon_series_update($weaponPath); last SWITCH;}
		
		################################################################################################
		# Update series config via ajax
		################################################################################################
		if ($action eq "ajax") { weapon_series_update_ajax($weaponPath); last SWITCH;}
		
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

		################################################################################################
		# Add a new competition to the screens (not included in a series - go to scrrens.cgi for that)
		################################################################################################
		if ($action eq "newcomp") {weapon_add(param("newcomp")); last SWITCH;}

		&HTMLdie("Undefined action requested." . Dump());
	}
} 
else 
{
	# HTMLdie(Dump());
  	frm_screen();
}
