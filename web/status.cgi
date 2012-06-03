#!/usr/bin/perl -w
#

use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);
use strict;
#use diagnostics;

@::weapons = () ;
$::weaponPath = param('wp') || "";

%::competition = ();
@::controlIP = ();
$::statusTimeout = 60000;

$::numfencers = 0;
$::numpresent = 0;

do 'procs.pl';

sub loadCompetitionData {
  my @sections ;
  my @items ;
  my %record ;
  my $file ;
  my $key ;
  my $value ;
  my $name ;
  my $data ;
  my ($path) = @_;

  open(FH,"< $path/competition.egw");
  flock(FH, LOCK_SH) || HTMLdie("Couldn't obtain shared lock on $path/competition.egw");
  {
    # set input record separator to null temporarily - slurp mode
    local $/ ;
    # read the whole file
    $file = <FH>;
  }
  close(FH);
  $file =~ s/\r?\n//g;
  $file =~ s/(\)) *(\(\s*def)/$1\n$2/g;
  @sections = ($file =~ /(^\(\s*def.*$)/mg);
  if ($#sections > 0) {
    foreach (@sections) {
      ($name,$data) = ($_ =~ /def\s+(\w+)\s+(.*)/);
      @items = ($data =~ /(\w+\s+(?:\w+|\((?:\s*\w+\s*|\(.*?\))*?\)|{.*?}|".*?"))/g); 
      if ($#items > 0) {
        foreach (@items) {
          ($key,$value) = ($_ =~ /(\w+)\s+(.*)/);
          $record{$key} = $value;
        }
        $::competition{$name} = {%record};
      }
    }
  }
}

&readConfiguration ;

sub control {
  my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$::statusTimeout.");\n}";
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Control',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'doLoad()'
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );
  
  print "<br><br><table border=0 cellspacing=0 cellpadding=0 width=720>\n";
  print "<tr><td></td><th align=left>Status</th><th align=left></th><th align=left>Action</th><th align=left></th></tr>\n" ;
  foreach (@::weapons) {
    my $w = $_;
    my $state = &readStatus($w->{'path'});
    my $name = $w->{'name'};
    
    if (!defined $state->{'hidden'}) {
      $state->{'hidden'} = "true";
      &update_hidden($w->{'path'}, "true");
    }

    $name =~ s/"//g;
    print "<tr><th align=left>$name</th>" ;
    
    if ((!defined $state->{'status'}) || ($state->{'status'} =~ /hidden/i)) {

      print "<td align=left>Check-in</td><td align=left>Not Ready</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Ready\">Setup check-in</a></td><td>Hidden</td></tr>" ;

    } elsif ($state->{'status'} =~ /check in/i) {

      print "<td align=left>Check-in</td><td align=left>Open</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Running\">Close check-in</a></td><td>";
      if ($state->{'hidden'} =~ /false/i) {
        print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
      } else {
        print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
      }
      print "</td></tr>" ;

    } elsif ($state->{'status'} =~ /ready/i) {

      print "<td align=left>Check-in</td><td align=left>Ready</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Check%20in\">Open check-in</a></td><td>";
      if ($state->{'hidden'} =~ /false/i) {
        print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
      } else {
        print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
      }
      print "</td></tr>" ;

    } else {
    
      &loadCompetitionData($w->{'path'});
      
      SWITCH: {
        if ($::competition{'ma_formule'}->{'etat'} =~ /termine/) {
	  print "<td align=left>Complete</td><td align=left></td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
          if ($state->{'hidden'} =~ /false/i) {
            print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          } else {
            print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
          }
          print "</td></tr>" ;
	  last SWITCH;
	}
        if ($::competition{'ma_formule'}->{'etat'} =~ /debut/) {
	  print "<td align=left>Waiting</td><td align=left>Start</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
          if ($state->{'hidden'} =~ /false/i) {
            print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          } else {
            print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
          }
          print "</td></tr>" ;
	  last SWITCH;
	}
        if ($::competition{'ma_formule'}->{'etat'} =~ /poules/) {
	  print "<td align=left>Poules</td><td align=left>Round $::competition{'ma_formule'}->{'nutour'}: " ;
	  if ($::competition{'ma_competition'}->{'poules_a_saisir'}) {
	    my @p = ($::competition{'ma_competition'}->{'poules_a_saisir'} =~ /(\d+)/g);
	    print scalar(@p)." poules running.</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
            if ($state->{'hidden'} =~ /false/i) {
              print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
            } else {
              print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
            }
            print "</td></tr>" ;
	  } else {
	    print "complete.</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
            if ($state->{'hidden'} =~ /false/i) {
              print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
            } else {
              print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
            }
            print "</td></tr>" ;
	  }
	  last SWITCH;
	}
        if ($::competition{'ma_formule'}->{'etat'} =~ /tableaux/) {
	  print "<td align=left>D.E.</td><td align=left>" ;
	  if ($::competition{'ma_competition'}->{'tableaux_en_cours'}) {
	    my @t = ($::competition{'ma_competition'}->{'tableaux_en_cours'} =~ /(\d+)/g);
	    foreach (@t) {
	      if ($_ > 8) {
	        print " Last $_ " ;
              } elsif ($_ == 8) {
	        print " Quarter final ";
              } elsif ($_ == 4) {
	        print " Semi final ";
              } else {
	        print " Final";
	      }
	    }
	  }
	  print "</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
          if ($state->{'hidden'} =~ /false/i) {
            print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          } else {
            print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
          }
          print "</td></tr>";
	  last SWITCH;
	}
	print "<td align=left>Error</td><td align=left>Unknown</td><td align=left></td><td align=left></td></tr>" ;
      }
    }
  }
  print "</table><br><a href=\"index.html\">Back</a>\n" ;
  print end_html();
}

sub display_weapon {
  my ($path, $weap) = @_ ;
  my %class = ();
  my $state = &readStatus($path);
  my %additions = ();
  my @nva_in = ();
  my @nva_out = ();
  my @fen_in = ();
  my @fen_out = ();
  my $name;
  my $first;
  readData(\%additions, "$path/additional.txt");
  getClassification(\%class, "$path");
  for (keys %class) {
    if ($class{$_}->{'stat'} eq "q") {
      push @fen_in,$_ ;
      push @nva_in,$_ if ($additions{$_}->{'nva'});
    } else {
      push @fen_out,$_;
      push @nva_out,$_ if ($additions{$_}->{'nva'});
    }
  }
  
  my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$::statusTimeout.");\n}";
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Control',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'doLoad()'
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );
  

  print "<br><br><table border=0 cellspacing=0 cellpadding=5 width=640>\n";
  print "<tr><th colspan=3 align=centre>$weap</th></tr>\n" ;
  print "<tr><th align=right>Status:</th>" ;
  if ((!defined $state->{'status'}) || ($state->{'status'} =~ /hidden/i)) {

    print "<td align=left>hidden</td><td align=left>Waiting</td>" ;

  } elsif ($state->{'status'} =~ /check in/i) {

    print "<td align=left>$state->{'status'}</td><td align=left>Open</td>" ;

  } elsif ($state->{'status'} =~ /ready/i) {

    print "<td align=left>$state->{'status'}</td><td align=left>Waiting</td>" ;

  } else {
  
    &loadCompetitionData($path);
    
    SWITCH: {
      if ($::competition{'ma_formule'}->{'etat'} =~ /termine/) {
        print "<td align=left>Complete</td><td align=left></td>" ;
        last SWITCH;
      }
      if ($::competition{'ma_formule'}->{'etat'} =~ /debut/) {
        print "<td align=left>Start</td><td align=left></td>" ;
        last SWITCH;
      }
      if ($::competition{'ma_formule'}->{'etat'} =~ /poules/) {
        print "<td align=left>Poules</td><td align=left>Round $::competition{'ma_formule'}->{'nutour'}: " ;
        if ($::competition{'ma_competition'}->{'poules_a_saisir'}) {
          my @p = ($::competition{'ma_competition'}->{'poules_a_saisir'} =~ /(\d+)/g);
          print scalar(@p)." poules running.</td>" ;
        } else {
          print "complete.</td>" ;
        }
        last SWITCH;
      }
      if ($::competition{'ma_formule'}->{'etat'} =~ /tableaux/) {
        print "<td align=left>D.E.</td><td align=left>" ;
        if ($::competition{'ma_competition'}->{'tableaux_en_cours'}) {
          my @t = ($::competition{'ma_competition'}->{'tableaux_en_cours'} =~ /(\d+)/g);
          foreach (@t) {
            if ($_ > 8) {
              print " Last $_ " ;
            } elsif ($_ == 8) {
              print " Quarter final ";
            } elsif ($_ == 4) {
              print " Semi final ";
            } else {
              print " Final";
            }
          }
        }
        print "</td>";
        last SWITCH;
      }
      print "<td align=left>Error</td><td align=left>Unknown</td>" ;
    }
  }
  print "</tr></table>\n" ;
  print "<br><br><table border=0 cellspacing=0 cellpadding=10 width=640>\n";
  print "<tr><th></th><th colspan=2 align=centre>Standings</th></tr>\n<tr><th></th><th align=left>All</th><th align=left>NVA</th></tr>\n" ;
  if (scalar(@fen_in) != 0) {
    print "<tr><th valign=top align=right>Still In</th><td valign=top align=left>" ;
    for (@fen_in) {
      $name   = $additions{$_}->{'surname'} ;
      $name   =~ s/"//g ;
      $first  = $additions{$_}->{'name'} ;
      $first  =~ s/"//g ;
      print "$first $name <br>\n"
    }
    print "</td><td valign=top align=left>" ;
    for (@nva_in) {
      $name   = $additions{$_}->{'surname'} ;
      $name   =~ s/"//g ;
      $first  = $additions{$_}->{'name'} ;
      $first  =~ s/"//g ;
      print "$first $name <br>\n"
    }
    print "</td></tr>\n" ;
    print "<tr><th valign=top align=right>Eliminated</th><td valign=top align=left>" ;
  } else {
    print "<tr><th valign=top align=right>Result</th><td valign=top align=left>" ;
  }
  for (sort {$class{$a}->{'pos'} <=> $class{$b}->{'pos'}} @fen_out) {
    $name   = $additions{$_}->{'surname'} ;
    $name   =~ s/"//g ;
    $first  = $additions{$_}->{'name'} ;
    $first  =~ s/"//g ;
    print "$class{$_}->{'pos'} $first $name <br>\n"
  }
  print "</td><td valign=top align=left>" ;
  for (sort {$class{$a}->{'pos'} <=> $class{$b}->{'pos'}} @nva_out) {
    $name   = $additions{$_}->{'surname'} ;
    $name   =~ s/"//g ;
    $first  = $additions{$_}->{'name'} ;
    $first  =~ s/"//g ;
    print "$class{$_}->{'pos'} $first $name <br>\n"
  }
  print "</td></tr>\n" ;
  print "</table><br><a href=".url().">Back</a>\n" ;
  print end_html();
}

sub update_status {
  my ($path, $new_status) = @_;
  if ($path) {
    my $state = &readStatus($path);
    if ($new_status) {
      $state->{'status'} = $new_status;
      sysopen(FH, "$path/weapon.status", O_WRONLY | O_CREAT, 0666) || HTMLdie("Could not open $path/weapon.status for writing\n$!");
      flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
      foreach (keys(%$state)) {
        print FH "$_ $state->{$_}\n" ;
      }
      close(FH);
    }
  }
  # reload the page with out the query string
  print "Location: ".url()."\n\n" ;
}

sub update_hidden {
  my ($path, $new_status) = @_;
  if ($path) {
    my $state = &readStatus($path);
    if ($new_status) {
      $state->{'hidden'} = $new_status;
      sysopen(FH, "$path/weapon.status", O_WRONLY | O_CREAT, 0666) || HTMLdie("Could not open $path/weapon.status for writing\n$!");
      flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
      foreach (keys(%$state)) {
        print FH "$_ $state->{$_}\n" ;
      }
      close(FH);
    }
  }
}

sub hide_weapon {
  my ($path) = @_;
  if ($path) {
    &update_hidden($path, "true");
  }
  # reload the page with out the query string
  print "Location: ".url()."\n\n" ;
}

sub show_weapon {
  my ($path) = @_;
  if ($path) {
    &update_hidden($path, "false");
  }
  # reload the page with out the query string
  print "Location: ".url()."\n\n" ;
}

####################################################################################################
# display control/status home screen
####################################################################################################
&HTMLdie("This is a restricted page /$ENV{'REMOTE_ADDR'}") unless (grep {/$ENV{'REMOTE_ADDR'}/} @::controlIP) ;
  
if ($::weaponPath  eq "") {

  &control ;
  
} else {
  my $action = param('Action') || "";
  my $status = param('Status');
  my $name   = param('Name');
  SWITCH:{
    if ($action =~ /update/i)  {&update_status($::weaponPath, $status) ; last SWITCH;}
    if ($action =~ /details/i) {&display_weapon($::weaponPath, $name) ;  last SWITCH;}
    if ($action =~ /hide/i)    {&hide_weapon($::weaponPath) ;            last SWITCH;}
    if ($action =~ /show/i)    {&show_weapon($::weaponPath) ;            last SWITCH;}
    print "Location: ".url()."\n\n" ;    
  }
}
