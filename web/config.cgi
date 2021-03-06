#!/opt/bin/perl -w
#

use lib '/home/engarde/lib';
use lib 'C:/Users/psmith/Documents/prs2712@gmail.com/escrime/eng-perl';

use Engarde::Control;
use Data::Dumper;

use CGI::Carp qw(fatalsToBrowser warningsToBrowser cluck);
use CGI qw(:standard *table -no_xhtml);

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
		# Flush the config and create a default one
		################################################################################################
		if (param("flush")) {HTMLdie(Dump()); last SWITCH;}
		
		&HTMLdie("Undefined action requested." . Dump());
	}
} 
else 
{
  	frm_config();
}
