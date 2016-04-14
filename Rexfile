#!/usr/bin/env perl

use Rex::Args;
use Rex::Helper::INI;


# cur user
$cuser = `whoami`;

# command-line opts
Rex::Args->parse_rex_opts;
my %opts   = Rex::Args->getopts;
$ruser = $opts{u}; # user
$rpass = $opts{p}; # pass
$spass = $opts{S}; # sudo pass

$pubkey = $opts{K}; # public key
$prikey = $opts{P}; # private key

# custom opts
$rlog = $ENV{RLOG};
$rini = $ENV{RINI};

# term color
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;


## ================================================

## init env
sub init_env {
    if (!$ruser) { die "Pls run with rex: -u user\n"; }
    if (!$rlog) { $rlog = "/tmp/rex.log"; }
    if (!$rini) { $rini = "etc/server.ini"; }

    user "$ruser";
    if (!$prikey) { private_key "~/.ssh/id_rsa"; key_auth; }
    if (!$pubkey) { public_key  "~/.ssh/id_rsa.pub"; key_auth; }

    logging to_file => "$rlog";
    timeout 5; # ssh timeout
}

## parse group
sub parse_group {
  my ($file) = @_;

  open( my $INI, "<", "$file" ) || die "Can't open $file: $!\n";
  my @lines = <$INI>;
  chomp @lines;
  close($INI);

  # config /etc/hosts
  my $host = "/tmp/etc.hosts";
  open( my $fhost, ">", "$host" ) || die "Can't open $host: $!\n";
  print $fhost "## [$host begin]\n";


  my $hash = Rex::Helper::INI::parse(@lines);

  for my $k ( keys %{$hash} ) {
    my @servers;
    for my $servername ( keys %{ $hash->{$k} } ) {
      my $add = {};
      if ( exists $hash->{$k}->{$servername}
        && ref $hash->{$k}->{$servername} eq "HASH" )
      {
        $add = $hash->{$k}->{$servername};
      }

      my $obj = Rex::Group::Entry::Server->new( name => $servername, %{$add} );
      push @servers, $obj;
    }

    if ($k !~ /^@/) { 
        chomp $k;
        $k =~ s/(^\s+|\s+$)//g;
        printf $fhost ("%-20s    %s\n", $k, @servers);
    }else {
        group( "$k" => @servers );
    }
  }

  print $fhost "## [$host end]\n";
  close($fhost);
}


## ================================================

# init
init_env;
parse_group $rini;

# modules
require Config::ubase;


1;
