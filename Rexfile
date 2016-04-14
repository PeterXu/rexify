#!/usr/bin/env perl
#

# $ENV{RUSER}, $ENV{RPASS}, $ENV{RLOG}, $ENV{RINI}
$ruser = $ENV{RUSER};
$rpass = $ENV{RPASS};
$rlog  = $ENV{RLOG};
$rini  = $ENV{RINI}; 

# term color
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;


## init env
sub init_env {
    if (!$ruser) { die "Pls set RUSER!\n"; }
    if (!$rlog) { $rlog = "/tmp/rex.log"; }
    if (!$rini) { $rini = "etc/server.ini"; }

    user "$ruser";
    private_key "~/.ssh/id_rsa";
    public_key  "~/.ssh/id_rsa.pub";
    key_auth;

    logging to_file => "$rlog";
    timeout 5; # ssh timeout
}


sub set_group {
    use Rex::Group::Lookup::INI;
    groups_file $rini;

    # config /etc/hosts
    my $host = "/tmp/etc.hosts";
    open( my $HOSTS, ">", "$host" ) || die "Can't open $host: $!\n";
    print $HOSTS "## [$host begin]\n";

    my %groups = Rex::Group->get_groups;
    foreach my $grp (keys %groups) {
        my @val = @{$groups{$grp}};
        chomp $grp;
        $grp =~ s/(^\s+|\s+$)//g;
        if ($grp !~ /^@/) {
            print $HOSTS "@val\t\t$grp\n";
        }
    }

    print $HOSTS "## [$host end]\n";
    close($HOSTS);
}

&init_env;
&set_group;


