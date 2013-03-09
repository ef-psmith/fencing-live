#!/opt/bin/perl -w
#

use lib '/share/Public/engarde/lib';
use lib 'C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-perl';

use Engarde::Control;

my $config = config_read();

my $log = "$config->{targetlocation}/$config->{log}";

open (LOG, "/usr/bin/tail -50 $log |") or die "can't open log $!";

my $out = "";

while (<LOG>)
{
	$out = $_ . "<br>" . $out;
}

close LOG;


Engarde::Control::_std_header("Log Output");

print "<br>$out<br>";


Engarde::Control::_std_footer();


