#!/opt/bin/perl -w
#

use lib '/home/engarde/lib';

use DT::Control;

my $config = config_read();

my $log = "$config->{targetlocation}/$config->{log}";

open (LOG, "/usr/bin/tail -50 $log |") or die "can't open log $!";

my $out = "";

while (<LOG>)
{
	$out = $_ . $out;
}

close LOG;


Engarde::Control::_std_header("Log Output");

print "<br>\n";

print "<textarea cols=80 rows=30 readonly>$out</textarea>";


Engarde::Control::_std_footer();


