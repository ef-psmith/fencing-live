#!/usr/bin/perl
open (PS, "ps -ef | grep writexml |");
while (<PS>)
{
	if ($_ !~ /sh \-c/)
	{
		print $_;
		@bits = split(/\s+/);
		print "\nproc $bits[1]";
		# kill the process
		$res = `kill $bits[1]`;
		print "\n$res";
	}
}
#start one new instance

$res=`perl /home/engarde/live/writexml.pl`;
print $res;
