#!/usr/bin/perl -w
#
# print header('-Cache-Control'=>'no-store') removed no caching means reload page from top
# but refresh method means there will be no prior pages in history so no problem

use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);
use strict;
use lib "/home/engarde/live/web/bift";
#use diagnostics;

$::allowCheckInWithoutPaid = 0;
$::defaultNation = "GBR";
@::weapons = () ;
$::checkinTimeout = 30000;

$::weaponPath = param('wp') || "";
$::action = param('Action') || "List";

%::fencers = ();
%::clubs = ();
%::nations = ();
%::additions = ();
%::addclubs = ();
@::keys = ();

$::maxfkey = -1;
$::maxckey = -1;
$::maxnkey = -1;

$::numfencers = 0;
$::numpresent = 0;

do 'procs.pl';

sub loadFencerData {
  my ($wp) = @_;
  
  $::maxfkey = &readData(\%::fencers, "$wp/tireur.txt");
  $::maxckey = &readData(\%::clubs,   "$wp/club.txt");
  $::maxnkey = &readData(\%::nations, "$wp/nation.txt");
  &readData(\%::additions, "$wp/additional.txt");
  &readData(\%::addclubs,  "$wp/addclub.txt");
  ($::numpresent, $::numfencers) = &getFencersPresent;
}

sub desk {
  my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$::checkinTimeout.");\n}";
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in Desk',
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
  
  print "<table border=0 cellspacing=0 cellpadding=0 width=640>";
  print "<tr><td align=center><h2>Check-in Desk</h2></td></tr><tr><th align=left>Please choose a weapon/competition.</th></tr>" ;
  foreach (@::weapons) {
    my $w = $_;
    my $state = &readStatus($w->{'path'});
    if ((defined($state->{'status'}) && $state->{'status'} !~ /hidden/i) && 
        (defined($state->{'hidden'}) && $state->{'hidden'} =~ /false/i)) {
      print "<tr><td align=left><a href=".url()."?wp=$w->{'path'}>$w->{'name'}</a></td></tr>" ;
    }
  }
  print "</table><br><a href=\"index.html\">Back</a>\n" ;
  print end_html();
}


sub closed {
  my $JSCRIPT="function closeWin() {\n  opener.location.reload();\n  setTimeout('window.close()',1000);\n}";

  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'closeWin()'
        );
  print table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              h2('Check-in is closed')
            ])
          )
        );
  print end_html();
}

sub checkIn {
  my $JSCRIPT="function closeWin() {\n  opener.location.reload();\n  setTimeout('window.close()',1000);\n}";

  my ($name, $first);
  
  if (defined(param('Item'))) {
    $::fencers{param('Item')}->{'presence'} = "present";
    
    $name   = $::fencers{param('Item')}->{'nom'} ;
    $name   =~ s/"//g ;
    $first  = $::fencers{param('Item')}->{'prenom'} ;
    $first  =~ s/"//g ;
  
    &writeData(\%::fencers, "tireur", "$::weaponPath/tireur.txt");
    
  } else {
    HTMLdie("Item not defined for check-in");
  }
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'closeWin()'
        );
  print table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              h2($first,$name.' checked in.')
            ])
          )
        );
  print end_html();
}


sub writeFiles {
  my $JSCRIPT="function closeWin() {\n  opener.location.reload();\n  setTimeout('window.close()',1500);\n}";
  if (defined(param('Item'))) {
    if (param('Item') == -1) {
      $::maxfkey += 1;
      $::fencers{$::maxfkey} = {};
      $::fencers{$::maxfkey}->{'classe'}  = "tireur";
      $::fencers{$::maxfkey}->{'modifie'} = "vrai";
      $::fencers{$::maxfkey}->{'points'}  = "0.00";
      $::fencers{$::maxfkey}->{'serie'}   = "999";
      $::fencers{$::maxfkey}->{'status'}  = "normal";
      param('Item',$::maxfkey);
    }
    $::fencers{param('Item')}->{'nom'}     = "\"".uc(param('nom'))."\"";
    $::fencers{param('Item')}->{'prenom'}  = "\"".ucfirst(param('prenom'))."\"";
    $::fencers{param('Item')}->{'licence'} = "\"".param('licence')."\"";
    
    # copy name to additions as engarde will truncate it
    $::additions{param('Item')}->{'surname'} = $::fencers{param('Item')}->{'nom'};
    $::additions{param('Item')}->{'name'}    = $::fencers{param('Item')}->{'prenom'};

    # check for new nation (nation = -1)
    if (param('nation') == -1) {
      # check for matching nation incase it has been added recently
      foreach (keys(%::nations)) {
        if ($::nations{$_}->{'nom'} eq param('newnation')) {
          param('nation',$_);
          last;
        }
      }
    }
    # if nation still -1 then it is new
    if (param('nation') == -1) {
      $::maxnkey += 1;
      $::nations{$::maxnkey} = {};
      $::nations{$::maxnkey}->{'classe'}     = "nation";
      $::nations{$::maxnkey}->{'modifie'}    = "vrai";
      $::nations{$::maxnkey}->{'nom'}        = "\"".uc(param('newnation'))."\"";
      $::nations{$::maxnkey}->{'nom_etendu'} = "\"\"";
      param('nation',$::maxnkey);
    }
    # set fencers nation
    $::fencers{param('Item')}->{'nation1'} = param('nation');
    
    # check for new or existing club
    if ((param('club') == -1) || ($::clubs{param('club')}->{'nation1'} != param('nation'))) {
      my $thisclub;
      if (param('club') == -1) {
        $thisclub = param('newclub');
      } else {
        $thisclub = $::clubs{param('club')}->{'nom'};
      }
      # check for matching club incase it has been added recently
      foreach (keys(%::clubs)) {
        if (($::clubs{$_}->{'nom'} eq $thisclub) && ($::clubs{$_}->{'nation1'} == param('nation'))) {
          param('club',$_);
          last;
        }
      }
    }
    # check for new club (club = -1) or clubs nation != fencers nation
    if (param('club') == -1) {
      $::maxckey += 1;
      $::clubs{$::maxckey} = {};
      $::clubs{$::maxckey}->{'nom'}     = "\"".uc(param('newclub'))."\"";
      $::clubs{$::maxckey}->{'classe'}  = "club";
      $::clubs{$::maxckey}->{'modifie'} = "vrai";
      $::clubs{$::maxckey}->{'nation1'} = param('nation');
      param('club',$::maxckey);
      
      # copy name to additions as engarde will truncate it
      $::addclubs{$::maxckey}->{'nom'}  = $::clubs{$::maxckey}->{'nom'} ;
    }
    elsif ($::clubs{param('club')}->{'nation1'} != param('nation')) {
      $::maxckey += 1;
      $::clubs{$::maxckey} = {};
      $::clubs{$::maxckey}->{'nom'}     = $::clubs{param('club')}->{'nom'} ;
      $::clubs{$::maxckey}->{'classe'}  = $::clubs{param('club')}->{'classe'} ;
      $::clubs{$::maxckey}->{'modifie'} = $::clubs{param('club')}->{'modifie'} ;
      $::clubs{$::maxckey}->{'nation1'} = param('nation');
      param('club',$::maxckey);
      
      # copy name to additions as engarde will truncate it
      $::addclubs{$::maxckey}->{'nom'}  = $::clubs{$::maxckey}->{'nom'} ;
    }
    # set fencers club
    $::fencers{param('Item')}->{'club1'} = param('club');
    
    if (!defined(param('presence')) || (param('presence') ne "present")) {
      $::fencers{param('Item')}->{'presence'} = "absent";
    } else {
      $::fencers{param('Item')}->{'presence'} = "present";
    }
    if (defined(param('paid')) && (param('paid') == 1)) {
      $::additions{param('Item')}->{'rcvd'} = $::additions{param('Item')}->{'owing'};
      $::additions{param('Item')}->{'owing'} = 0;
    }
    if (defined(param('nva')) && (param('nva') == 1)) {
      $::additions{param('Item')}->{'nva'} = 1;
    } else {
      $::additions{param('Item')}->{'nva'} = 0;
    }
    
    ##
    ##  Write new info to files
    ##
    &writeData(\%::fencers, "tireur", "$::weaponPath/tireur.txt");
    &writeData(\%::clubs, "club", "$::weaponPath/club.txt");
    &writeData(\%::nations, "nation", "$::weaponPath/nation.txt");
    &writeData(\%::additions, "", "$::weaponPath/additional.txt");
    &writeData(\%::addclubs, "", "$::weaponPath/addclub.txt");
            
  } else {
    HTMLdie("Item not defined for edit");
  }
  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'closeWin()'
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        ),
        h2('Entry '.param('Item').' modified'),
        end_html();
}


sub displayList {
  my $JSCRIPT="function edit(item) {\n  eWin = window.open(\"".url()."?wp=$::weaponPath&Action=Edit&Item=\" + item,\"edit\",\"height=560,width=640\");\n}\n";
  $JSCRIPT=$JSCRIPT."function check(item) {\n  cWin = window.open(\"".url()."?wp=$::weaponPath&Action=Check&Item=\" + item,\"check\",\"height=100,width=640\")\n}\n";
  $JSCRIPT=$JSCRIPT."function doLoad() {\n  setTimeout('window.location.reload()',20000);\n}";
  my $row = 0;
  my $state = &readStatus($::weaponPath);

  print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in',
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
  
  print "<table border=0 cellspacing=0 cellpadding=0><tr><td align=center>\n" ;
  print "<table border=0 cellspacing=5 cellpadding=0 width=100%><tr><td align=left><a href=".url().">Check-in Desk</a></td><td align=center>Fencers Present : ".$::numpresent."/".$::numfencers."</td><td align=right>";
  print "<a href=javascript:edit('-1')>Add Fencer</a>" unless ($state->{'status'} !~ /Check in/i);
  print "</td></tr></table>\n" ;
  print "<table border=1 cellspacing=0 cellpadding=2>\n" ;
  print "<tr><th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>NAME</th><th>CLUB</th><th>NATION</th><th>LICENCE NO</th><th>NVA</th><th>OWING</th><th></th></tr>\n" ;

  @::keys = sort {$::fencers{$a}->{'nom'} cmp $::fencers{$b}->{'nom'} || uc($::fencers{$a}->{'prenom'}) cmp uc($::fencers{$b}->{'prenom'})} (keys(%::fencers)) ;

  foreach (@::keys) {
    my ($name, $first, $club, $nation, $licence, $owing, $nva);
    my $bgcolour = "#ffffff" ;

    
    $name   = $::additions{$_}->{'surname'} ;
    $name   =~ s/"//g ;
    $first  = $::additions{$_}->{'name'} ;
    $first  =~ s/"//g ;
    $club   = $::addclubs{$::fencers{$_}->{'club1'}}->{'nom'} ;
    $club   =~ s/"//g ;
    $nation = $::nations{$::fencers{$_}->{'nation1'}}->{'nom'} ;
    $nation =~ s/"//g ;
    $licence  = $::fencers{$_}->{'licence'} ;
    $licence  =~ s/"//g ;
    $owing  = $::additions{$_}->{'owing'} || 0;
    if ($owing) {
      $owing  = "&pound;".$owing;
      $bgcolour = "#FFFF00" ;
    } else {
      $owing = "";
    }
    $nva  = $::additions{$_}->{'nva'} || 0;
    if ($nva) {
      $nva  = "*";
    } else {
      $nva = "";
    }
    print "<tr><td>";
    if ($::fencers{$_}->{'presence'} ne "present") {
      if ($::allowCheckInWithoutPaid || ( $owing eq "")) {
        print "<a href=javascript:check('".$_."')>Check-in</a>" unless ($state->{'status'} !~ /Check in/i);
      }
    } else {
      $bgcolour = "#009900" ;
    }
    print "</td>";
    print "<td bgcolor=\"$bgcolour\">",$first," ",$name,"</td>" ;
    print "<td bgcolor=\"",$bgcolour,"\">",$club,"</td>" ;
    print "<td bgcolor=\"",$bgcolour,"\">",$nation,"</td>" ;
    print "<td bgcolor=\"",$bgcolour,"\">",$licence,"</td>" ;
    print "<td bgcolor=\"",$bgcolour,"\">",$nva,"</td>" ;
    print "<td bgcolor=\"",$bgcolour,"\">",$owing,"</td>" ;
    print "<td><a href=javascript:edit('".$_."')>Edit</a></td>" ;
    print "</tr>\n" ;
    $row += 1;
    if ($row == 20) {
      $row = 0;
      print "<tr><th></th><th>NAME</th><th>CLUB</th><th>NATION</th><th>LICENCE NO</th><th>NVA</th><th>OWING</th><th></th></tr>\n" ;
    }
  }
  print "</table>" ;
  print "</td></tr></table>" ;

  print end_html();
}


sub editItem {
  my ($name, $first, $club, $nation, $licence, $presence, $owing, $nva);
  my $state = &readStatus($::weaponPath);

  if (param('Item') != -1) {
    $name     = $::additions{param('Item')}->{'surname'} ;
    $name     =~ s/"//g ;
    $first    = $::additions{param('Item')}->{'name'} ;
    $first    =~ s/"//g ;
    $licence  = $::fencers{param('Item')}->{'licence'} ;
    $licence  =~ s/"//g ;
    $presence = $::fencers{param('Item')}->{'presence'} ;
    $owing    = $::additions{param('Item')}->{'owing'} || 0;
    $nva      = $::additions{param('Item')}->{'nva'} || 0;
  } else {
    $name     = "";
    $first    = "";
    $licence  = "";
    $presence = "absent";
    $owing    = 0;
    $nva      = 0;
  }
  
  print header(),
          start_html(
          -title => 'Birmingham International Fencing Tournament - Edit Fencer',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000"
        ),
          table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );
  
  print start_form(
          -method=>'POST',
          -action=>url()
        ),
        hidden(
          -name=>'wp',
          -value=>$::weaponPath,
          -override=>'true'
        ),
        hidden(
          -name=>'Action',
          -value=>'Write',
          -override=>'true'
        ),
        hidden(
          -name=>'Item',
          -value=>param('Item'),
          -override=>'true'
        );

  print "<fieldset><legend>Fencer Information</legend>\n";
  print table({border => 0, cellspacing=>2, cellpadding=>0},
          Tr({},
          [
            td(["Surname :",textfield(-name=>'nom',-value=>$name,-size=>32,-maxlength=>32)]),
            td(["Forename :",textfield(-name=>'prenom',-value=>$first,-size=>32,-maxlength=>32)]),
            td(["Licence No :",textfield(-name=>'licence',-value=>$licence,-size=>32,-maxlength=>32)])
          ]
          )
        );
  print "</fieldset>\n";
  print "<fieldset><legend>Affilliation</legend>\n";
  my %clubnames = ();
  my %nationnames = ();
  my $selclub   = -1;
  my $selnation = -1;
  my (@ckeys,@nkeys);
  #
  # Generate Club List
  #
  @ckeys = sort {uc($::clubs{$a}->{'nom'}) cmp uc($::clubs{$b}->{'nom'})} (keys(%::clubs));
  foreach (@ckeys) {
    $club   = $::addclubs{$_}->{'nom'} ;
    $club   =~ s/"//g ;
    $clubnames{$_} = $club;
    if (param('Item') != -1) {
      if ($_ == $::fencers{param('Item')}->{'club1'}) {
        $selclub = $_;
      }
    } else {
      if ($selclub == -1) {
        $selclub = $_;
      }
    }
  }
  push (@ckeys, '-1');
  $clubnames{'-1'} = 'Other';
  #
  # Generate Nation List
  #
  @nkeys = sort {uc($::nations{$a}->{'nom'}) cmp uc($::nations{$b}->{'nom'})} (keys(%::nations));
  foreach (@nkeys) {
    $nation   = $::nations{$_}->{'nom'} ;
    $nation   =~ s/"//g ;
    $nationnames{$_} = $nation;
    if (param('Item') != -1) {
      if ($_ == $::fencers{param('Item')}->{'nation1'}) {
        $selnation = $_;
      }
    } else {
      if ($nation eq $::defaultNation) {
        $selnation = $_;
      }
    }
  }
  push (@nkeys, '-1');
  $nationnames{'-1'} = 'Other';
  print table({border => 0, cellspacing=>2, cellpadding=>0},
          Tr({},
          [
            td(["Club :",
                popup_menu(-name=>'club',
                           -values=>\@ckeys,
                           -labels=>\%clubnames,
                           -default=>$selclub,
                           -onchange=>"if (club.value == -1) {newclub.disabled = false;} else {newclub.disabled = true;}"
                          ),
                textfield(-name=>'newclub',-value=>"",-size=>32,-maxlength=>32,-disabled=>'true')
               ]),
            td(["Nation :",popup_menu(-name=>'nation',
                                  -values=>\@nkeys,
                                  -labels=>\%nationnames,
                                  -default=>$selnation,
                                  -onchange=>"if (nation.value == -1) {newnation.disabled = false;} else {newnation.disabled = true;}"
                                 ),
                textfield(-name=>'newnation',-value=>"",-size=>3,-maxlength=>3,-disabled=>'true')
               ]),
               
          ]
          )
        );
  print "<fieldset><legend>Additional Information</legend>\n";
  if ($nva) {
    print checkbox(-name=>'nva',-value=>1,-checked=>1,-label=>'NVA Member');
  } else {
    print checkbox(-name=>'nva',-value=>1,-checked=>0,-label=>'NVA Member');
  }
  if ($owing) {
    print "<br>&pound;".$owing." outstanding ".checkbox(-name=>'paid',-value=>1,-checked=>0,-label=>'Paid');
  }
  print "</fieldset>\n";
  print "<fieldset><legend>Flags</legend>\n";
  
  if ($state->{'status'} =~ /check in/i) {
    if ($presence eq "present") {
      print checkbox(-name=>'presence',-value=>'present',-checked=>1,-label=>'Present');
    } else {
      print checkbox(-name=>'presence',-value=>'present',-checked=>0,-label=>'Present');
    }
  } else {
    print hidden(-name=>'presence',-value=>$presence,-override=>'true');
  }
  print "<br>";
  print "</fieldset>\n";
  
  print submit(-label=>'Update Record');
  
  print end_form();

  print end_html();
}


####################################################################################################
# display check-in home screen
####################################################################################################
&readConfiguration ;

if ($::weaponPath  eq "") {
  
  &desk;
  
} else {

  &loadFencerData($::weaponPath);

  SWITCH: {
    ################################################################################################
    # check fencer in and reload Check-in screen
    ################################################################################################
    if ($::action eq "Check") {&checkIn; last SWITCH;}
    
    ################################################################################################
    # Update files and reload Check-in screen
    ################################################################################################
    if ($::action eq "Write") {&writeFiles; last SWITCH;}
    
    ################################################################################################
    # Generate Check-in List screen
    ################################################################################################
    if ($::action eq "List") {&displayList; last SWITCH;}
    
    ################################################################################################
    # Update files and reload Check-in screen
    ################################################################################################
    if ($::action eq "Edit") { &editItem; last SWITCH;}
    
    &HTMLdie("Undefined action requested.");
  }
}
