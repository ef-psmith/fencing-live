#!/opt/bin/perl -w
#

use lib '/share/Public/engarde/lib';
use lib 'C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-perl';

use Engarde::Control;
use Data::Dumper;

use CGI::Carp qw(fatalsToBrowser warningsToBrowser cluck);
use CGI::Pretty qw(:standard *table -no_xhtml);

# my $weaponPath = param('wp') || "";
# my $action = param('action') || "";

if (param()) 
{  
	# HTMLdie(Dumper(param()));
	
	SWITCH: {
		################################################################################################
		# Update core config
		################################################################################################
		if (param("basic")) {config_update_basic(); last SWITCH;}
    
		################################################################################################
		# Update output locations
		################################################################################################
		if (param("output")) {config_update_output(); last SWITCH;}
		
		################################################################################################
		# Update IP restrictions
		################################################################################################
		if (param("controlip")) {config_update_ip(); last SWITCH;}
		
		################################################################################################
		# Add a new competition to the screens (not included in a series - go to scrrens.cgi for that)
		################################################################################################
		if (param("newcomp")) {weapon_add(param("newcomp")); last SWITCH;}

		################################################################################################
		# Flush the config and create a default one
		################################################################################################
		if (param("flush")) {HTMLdie(Dump()); last SWITCH;}
		
    
		&HTMLdie("Undefined action requested." . Dump());
	}
} 
else 
{
  	config_form();
}
