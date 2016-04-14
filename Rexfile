#!/usr/bin/env perl

use Rex::Args;
Rex::Args->parse_rex_opts;

# cur user
$cuser = `whoami`;

# command-line opts
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


## set group
sub set_group {
    use Rex::Group::Lookup::INI;
    groups_file $rini;

    # config /etc/hosts
    my $host = "/tmp/etc.hosts";
    open( my $fhost, ">", "$host" ) || die "Can't open $host: $!\n";
    print $fhost "## [$host begin]\n";

    my %groups = Rex::Group->get_groups;
    foreach my $grp (keys %groups) {
        my @val = @{$groups{$grp}};
        chomp $grp;
        $grp =~ s/(^\s+|\s+$)//g;
        if ($grp !~ /^@/) { print $fhost "@val\t\t$grp\n";}
    }

    print $fhost "## [$host end]\n";
    close($fhost);
}


&init_env;
&set_group;


1;
