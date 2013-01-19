#!perl -w
#
use lib '/share/Public/engarde/lib';
use lib 'C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-perl';

use Engarde;
use Engarde::Control;
use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);

use strict;
#use diagnostics;

use Data::Dumper;

# HTMLdie($ENV{SCRIPT_FILENAME} . " " . cwd());

my @weapons;
my $weaponPath = param('wp') || "";

#%::competition = ();
#@::controlIP = ();
#$::statusTimeout = 60000;

#$::numfencers = 0;
#$::numpresent = 0;

my $config = read_config();

# HTMLdie(Dumper(\$config));

####################################################################################################
# display control/status home screen
####################################################################################################

if ($config->{restrictIP} eq "true")
{
	my $allowed = $config->{controlIP};

	my @dummy = grep {/$ENV{'REMOTE_ADDR'}/} @$allowed;
	#print STDERR Dumper(\@dummy);
	#HTMLdie(Dumper(@dummy));

	HTMLdie("This is a restricted page $ENV{'REMOTE_ADDR'}") unless @dummy;
}

  
if ($weaponPath eq "") 
{
	control(\$config);
} 
else 
{
	my $action = param('Action') || "";
	my $status = param('Status');
	my $name   = param('Name');

	SWITCH: {
		if ($action =~ /update/i)  {update_status($config, $weaponPath, $status) ; last SWITCH;}
		if ($action =~ /details/i) {display_weapon($weaponPath, $name) ;  last SWITCH;}
		if ($action =~ /hide/i)    {hide_weapon($weaponPath) ;            last SWITCH;}
		if ($action =~ /show/i)    {show_weapon($weaponPath) ;            last SWITCH;}
		print "Location: ".url()."\n\n" ;    
	}
}
