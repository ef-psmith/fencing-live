sub readStatus {
  my $data ;
  my $opt ;
  my %status = ();
  my ($path) = @_;

  if (-e "$path/weapon.status") {
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

sub readConfiguration {
  my $data ;
  my $opt ;
  my $name ;
  my $path ;
  my $status ;

  open(FH,"< /home/engarde/live/web/bift/check-in.conf") || HTMLdie("Couldn't open check-in.conf");
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


sub writeData {
  my ($href, $classe, $filename) = @_;

  sysopen(FH, "$filename", O_WRONLY) || HTMLdie("Could not open $filename for writing\n$!");
  flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $filename");
  foreach (keys(%{$href})) {
    my $key = $_ ;
    my $line = "{[classe $classe] ";
    my $last_length = 0;
    ###### check next line #####
    foreach (keys(%{$href->{$key}})) {
      if (!/^(classe|cle|modifie)$/) {
        if ((length($line) - $last_length) > 80) {
          $last_length = length($line);
          $line .= "\r\n ";
        }
        ###### check next line #####
        $line .= "[$_ $href->{$key}{$_}] ";
      }
    }
    ###### check next line #####
    $line .= "[modifie vrai] [cle $key]}\r\n";
    print FH $line;
  }
  close(FH);
}


sub readData {
  my ($href, $filename) = @_;
  my $file ;
  my $max_key = -1;
  
  open(FH,"< $filename");
  flock(FH, LOCK_SH) || &HTMLdie("Couldn't obtain shared lock on $filename $!");
  {
    # set input record separator to null temporarily - slurp mode
    local $/ ;
    # read the whole file
    $file = <FH>;
  }
  close(FH);
  $file =~ s/\r?\n//g;
  foreach ($file =~ /{\s*(.*?)\s*}/g) {
    my @items = ($_ =~ /\[([^\[\]]+)\]/g) ;
    if ($#items > 0) {
      my $fkey = "" ;
      my %record = ();
      foreach (@items) {
        my ($key, $value) = split(/\s+/,$_,2) ;
        if ($key eq "cle") {
          $fkey = $value ;
        } else {
          $record{$key} = $value ;
        }
      }
      if ($fkey ne "") {
        ###### check next line #####
        $href->{$fkey} = {%record} ;
        if ($fkey > $max_key) {
          $max_key = $fkey;
        }
      } else {
        &HTMLdie("missing key in $filename");
      }
    }
  }
  return $max_key;
}


#sub byClass {
#  my ($href, $a, $b) = @_ ;
#  if ($href->{$a}{'stat'} eq $href->{$b}{'stat'}) {
#    return ($href->{$a}{'pos'} <=> $href->{$b}{'pos'});
#  } else {
#    if ($href->{$a}{'stat'} eq "q") {return -1;}
#    if ($href->{$b}{'stat'} eq "q") {return 1;}
#    if ($href->{$a}{'stat'} eq "a") {return -1;}
#    if ($href->{$b}{'stat'} eq "a") {return 1;}
#    return 0;
#  }
#}


sub getClassification {
  my ($href, $wp) = @_;
  my $first;
  my %poulesTableaux = ();
  my $tab_round;

  sub byClass {
    if ($href->{$a}{'stat'} eq $href->{$b}{'stat'}) {
      return ($href->{$a}{'pos'} <=> $href->{$b}{'pos'});
    } else {
      if ($href->{$a}{'stat'} eq "q") {return -1;}
      if ($href->{$b}{'stat'} eq "q") {return 1;}
      if ($href->{$a}{'stat'} eq "a") {return -1;}
      if ($href->{$b}{'stat'} eq "a") {return 1;}
      return 0;
    }
  }
  
  # read classifiction at start of poules
  readClassData($href, "$wp/claspou_init_1.txt");

  # read classifiction at end of each poule
  # fencers eliminated are not repeated in later files.
  # (what happens if there are exemptions from the poules?)
  for ($pr = 1;-e "$wp/claspou_fin_${pr}.txt"; $pr++) {
    readClassData($href, "$wp/claspou_fin_${pr}.txt");
  }
  
  # read classifiction at start of tableaux
  readClassData($href, "$wp/clastab_initial.txt");

  if (-e "$wp/suite_tableaux.txt") {
    # identify first tableau
    readData(\%poulesTableaux, "$wp/suite_tableaux.txt");
    ($tab_round) = ($poulesTableaux{'1'}->{'tableauinitial'} =~ /a(\d+)/i);

    # process losers from each round that has completed
    # (how does repecharge affect this?)
    for (; $tab_round > 1; $tab_round = ($tab_round/2)) {
      my %hash;
      readHashData(\%hash, "$wp/tableauA${tab_round}.txt");
      last if ($hash{'etat'} ne "termine");

      # extract losers
      my $string = $hash{'les_matches'};
      my @rank = ();
      while ((length $string) > 0) {
        my %thash = ();
        $string = extractHashData(\%thash, $string);
        while (($key, $value) = each %thash) {
          my ($a,$b,$sa,$sb,$w,$ra,$rb) = ($value =~ /\s*(\d+|\(\)|nobody)/g);
          # need to check for exclusions
          if ($a && $b && ($a ne "nobody") && ($b ne "nobody")) {
            my $l = ($a == $w) ? $b : $a ;
            push @rank,$l;
          }
          $first = $w;
        }
      }
      
      # sort losers according to ranking at start of tableau
      @rank = sort byClass @rank;

      # update losers position and mark them eliminated
      my $next_rank = ($tab_round / 2) + 1;
      my $this_pos  = 0;
      my $last_pos  = 0;
      foreach (@rank) {
        $this_pos = $next_rank unless ($href->{$_}{'pos'} == $last_pos);
        $last_pos = $href->{$_}{'pos'};
        $next_rank++ unless ($next_rank == 3);
        # need to check for exclusion
        $href->{$_}{'pos'}  = $this_pos;
        $href->{$_}{'stat'} = 'e';
      }
      if ($tab_round == 2) {
        $href->{$first}{'pos'}  = 1;
        $href->{$first}{'stat'} = 'e';
      }
    }
  }
}


sub readClassData {
  my ($href, $filename) = @_;
  return unless (-e $filename);
  # read file
  my %record ;
  open(FH,"< $filename");
  flock(FH, LOCK_SH) || &HTMLdie("Couldn't obtain shared lock on $filename");
  while (<FH>) {
    my ($stat, $pos, $key) = split(/;/,$_);
    my %record = ();
    $record{'pos'}  = $pos;
    $record{'stat'} = $stat;
    $href->{$key} = {%record};
  }
  close(FH);
}


sub readHashData {
  my ($href, $filename) = @_;
  my $file ;
  
  open(FH,"< $filename");
  flock(FH, LOCK_SH) || &HTMLdie("Couldn't obtain shared lock on $filename");
  {
    # set input record separator to null temporarily - slurp mode
    local $/ ;
    # read the whole file
    $file = <FH>;
  }
  close(FH);
  $file =~ s/\r?\n//g;
  &extractHashData($href, $file);
}


sub extractHashData {
  my ($href, $instring) = @_;
  my $bc = 0;
  my $str = "";
  my $hashstr = "";
  foreach ($instring =~ /({|}|[^{}]+)/g) {
    if ($hashstr eq "") {
      if ($_ =~ /{/) {
        $str .= $_ unless ($bc == 0);
        ++$bc;
      } elsif ($_ =~ /}/) {
        --$bc;
        if ($bc < 0) {&HTMLdie("Unexpected closing brace");}
        if ($bc == 0) {
          $hashstr = $str;
          $str = "";
        } else {
          $str .= $_ ;
        }
      } elsif ($bc > 0) {
        $str .= $_ ;
      }
    } else {
      $str .= $_ ;
    }
  }

  if ($bc > 0) {&HTMLdie("Missing closing brace");}
  my $key;
  foreach ($hashstr =~ /\s*(\[\s*\w+\s+|\]|[^\[\]]+)/g) {
    if ($_ =~ /\[/) {
      if ($bc == 0) {
        ($key) = ($_ =~ /\[\s*(\w+)/);
        $value = "";
      } else {
        $value .= $_ ;
      }
      ++$bc;
    } elsif ($_ =~ /\]/) {
      --$bc;
      if ($bc < 0) {&HTMLdie("Unexpected ]");}
      if ($bc == 0) {
        $href->{$key} = $value;
      } else {
        $value .= $_ ;
      }
    } else {
      $value .= $_ ;
    }
  }
  if ($bc > 0) {&HTMLdie("Missing ]");}
  return $str;
}


sub getFencersPresent {
  my $tot;
  my $pres;
  my @keys;
  
  @keys = keys(%::fencers);
  $tot  = scalar(@keys);
  $pres = 0;
  foreach (@keys) {
    if ($::fencers{$_}->{'presence'} eq "present") {
      ++$pres;
    }
  }
  return ($pres, $tot);
}
  
}
