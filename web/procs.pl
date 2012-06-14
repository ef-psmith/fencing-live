use lib '/share/Public/engarde/lib';
use Engarde;
use Data::Dumper;

sub readConfiguration {
  my $data ;
  my $opt ;
  my $name ;
  my $path ;
  my $status ;

  open(FH,"< check-in.conf") || HTMLdie("Couldn't open check-in.conf");
  LINE: while (<FH>) {
    chomp;
    next LINE if ($_ eq "");
    ($opt, $data) = split(/\s+/,$_,2);
    SWITCH: {
      if ($opt =~ /controlIp/) {
        push(@::controlIP, $data);
        last SWITCH; 
      }
      if ($opt =~ /defaultNation/) {
        $::defaultNation = $data;
        last SWITCH; 
      }
      if ($opt =~ /allowCheckInWithoutPaid/) { 
        $::allowCheckInWithoutPaid = $data;
        last SWITCH; 
      }
      if ($opt =~ /weapon/) {
        ($name, $path) = ($data =~ /(".+"|[\w]+)\s+([\w\/]+)/);
        push(@::weapons, {name=>$name, path=>$path});
        last SWITCH;
      }
      if ($opt =~ /checkinTimeout/) { 
        $::checkinTimeout = $data;
        last SWITCH; 
      }
      if ($opt =~ /statusTimeout/) { 
        $::statusTimeout = $data;
        last SWITCH; 
      }
    }
  }
  close(FH);
}

sub readStatus {
  my $data ;
  my $opt ;
  my %status = ();
  my $path = shift;

  if (-e $path .  "/weapon.status") {
    open(FH,"< $path/weapon.status") || HTMLdie("Couldn't open $path/weapon.status");
    LINE: while (<FH>) {
      chomp;
      next LINE if ($_ eq "");
      ($opt, $data) = split(/\s+/,$_,2);
      $status{$opt} = $data;
    }
    close(FH);
  }
  return \%status;
}

sub HTMLdie {
  my ($msg,$title) = @_;
  
  $title || ($title = "Error");
    
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Error',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => '#000000',
          -vlink => '#000000',
          -alink => '#999900',
          -link => '#000000',
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );
  print h1($msg);
  print end_html();
       
  exit;
}

