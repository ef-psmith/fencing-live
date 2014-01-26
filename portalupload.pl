# (c) Copyright Oliver Smith & Peter Smith 2007-2013
# oliver_rps@yahoo.co.uk
# peter.smith@englandfencing.org.uk

# standard layout for each stage of the competition based on the "whereami" output
# as follows
#	 poules not drawn		-	 check-in list
#	 poules drawn			-	 fencers, poules, pistes
#	 poules in progress	-	 poules + fpp
#	 poules finished		-	 poules + ranking 
#	 tableau drawn			-	 tableau + final ranking

# for dev purposes (mostly)
use lib "../lib";
use lib "../eng-perl";

use strict;

use Carp qw(cluck);
use XML::Simple;
$XML::Simple::PREFERRED_PARSER = "XML::Parser";

use Net::FTP;

##################################################################################
# Main starts here
##################################################################################

my $runonce = shift || 0;

#unless ($^O =~ /MSWin32/ || $runonce)
#{
	#use Proc::Daemon;
	#my $pid = Proc::Daemon::Init({ pid_file=>'/share/Public/writexml.pid'});
#
	#exit 0 if ($pid);
#}

# save original file handles
#open(OLDOUT, ">&STDOUT");
#open(OLDERR, ">&STDERR");


while (1)
{
	my $config = config_read();

	$config->{ftphost} = "ftp.pointinline.com";
	$config->{ftpuser} = "results@pointinline.com";
	$config->{ftppwd} = "eyc2013results";
	$config->{ftpcwd} = "eyc2013";

	
	$Engarde::DEBUGGING=$config->{debug};
	
	#if ($config->{log})
	#{
		#open STDERR, ">>" . $config->{targetlocation} . "/" . $config->{log} or die $!;
		#open STDOUT, ">&STDERR";

		# set AUTOFLUSH to ensure messages are written in the correct order
		#my $fh = select(STDERR);
		#$| = 1;
		#select($fh);
	#}
	
	my $ftp;
	# If we have all the ftp details and haven't already created it then create it.
	if (defined($config->{ftphost}) && 
			defined($config->{ftpuser}) && 
			defined($config->{ftppwd}) && 
			defined($config->{ftpcwd}) &&
			!defined($ftp))
	{
	
		$ftp = Net::FTP->new($config->{ftphost}, Debug => 0) or die "Cannot connect to some.host.name: $@" ;
	}

	# Check that we are defined and log in.
	if (defined($ftp))
	{
		print "FTP login\n";
		$ftp->login($config->{ftpuser},$config->{ftppwd}) or die "Cannot login ", $ftp->message;
		$ftp->cwd($config->{ftpcwd}) or die "Cannot change working directory ", $ftp->message;
	}


	# just iterate through $config->{targetlocation}/competitions/*.xml here
	
	
	if (defined $ftp)
	{
		# this needs to change to ftp all the competition/X.xml files now
		# perhaps a call to rsync might be better?
		$ftp->put($config->{targetlocation} . "/live.xml");

		$ftp->cwd("competitions");
:x

	}
	
		
    $ftp->quit unless !defined($ftp);
    undef($ftp);
   
	print "loop finished\n";
 
	unless ($runonce)
	{
		# close the redirected filehandles
		#close(STDOUT) ;
		#close(STDERR) ;

		# restore stdout and stderr
		#open(STDERR, ">&OLDERR");
		#open(STDOUT, ">&OLDOUT");

		sleep 30;
	}
	else
	{
		exit;
	}
}


############################################################################
# Debug output
############################################################################

sub debug
{
	my $level = shift;
	my $text = shift;
	
	print STDERR "DEBUG($level): $text\n" if ($level le $Engarde::DEBUGGING);
}
