#
# $ENV{RUSER}, 
# $ENV{RPASS}, 
# $ENV{RSUDO}, "stdin|y|n" 
# $ENV{RTODO}, "stdin|y|n"
#
$ruser = "peter";
$rpass = $ENV{RPASS};
$rlog  = "/tmp/rex.log";
$rini = "etc/server.ini";

$hosts_ = "/tmp/hosts.extra";
$hosts0_ = "## custom hosts begin";
$hosts1_ = "## custom hosts end";

if ($ENV{RUSER}) {
    $ruser = $ENV{RUSER};
}
$ENV{RUSER} = $ruser;
if ($ENV{RINI}) {
    $rini = $ENV{RINI};
}

user "$ruser";
#password "";
#pass_auth;
private_key "~/.ssh/id_rsa";
public_key "~/.ssh/id_rsa.pub";
key_auth;

logging to_file => "$rlog";
#logging to_syslog => "rexify";
timeout 2; # ssh timeout


## check sudo
&checkx;
sub checkx {
    use Term::ANSIColor qw(:constants);
    $Term::ANSIColor::AUTORESET = 1;
    print BOLD "[INFO] you can activate sudo by RPASS=passwd or 'rex -s -S passwd'\n";
    print BOLD "[INFO] use config <$rini>\n";

    my $sure;
    if ($rpass) {
        print BOLD YELLOW "\n[WARN] sudo(RPASS) activate?(y/n [n]):";
        $sure = $ENV{RSUDO};
        if ($sure eq "") {
            $sure = <STDIN>;
        }
        print "\n";

        chomp($sure);
        if ($sure eq "y") {
            sudo TRUE;
            sudo_password "$rpass";
        }
    }
    if ($sure eq "y") {
        print BLUE "[WARN] sudo(RPASS) [[activated]]!\n";
    }else {
        print RED "[WARN] sudo(RPASS) [[deactivated]]!\n";
    }

    print BOLD YELLOW "\n[WARN] continue?(y/n [y]):";
    $sure = $ENV{RTODO};
    if ($ENV{RTODO} eq "") {
        $sure = <STDIN>;
    }
    print "\n";
    chomp($sure);

    print "\n\n";
    if ($sure eq "n") {
        exit 0;
    }
}

&initx;
sub initx {
    use Rex::Group::Lookup::INI;
    groups_file $rini;

    # config /etc/hosts
    open( my $HOSTS, ">", "$hosts_" ) || die "Can't open $hosts_: $!\n";
    print $HOSTS "$hosts0_\n";

    my @zgroups = ();
    my %groups = Rex::Group->get_groups;
    foreach my $grp (keys %groups) {
        my @val = @{$groups{$grp}};
        chomp $grp;
        $grp =~ s/(^\s+|\s+$)//g;
        if ($grp !~ /^@/) {
            print $HOSTS "@val\t\t$grp\n";
            @zgroups = (@zgroups, $grp);
        }else {
            #print $HOSTS "#-$grp = @val\n";
        }
    }

    print $HOSTS "$hosts1_\n";
    close($HOSTS);
    #group "zzzgroups" => (@zgroups);
}


##========================================================
##========================================================

## task testing
desc "one test example";
task "test", sub {
    say run "uptime";
};

require Service::sshkey;
require Service::hosts;
require Service::apt;
require Service::docker;
require Service::pip;

require Service::softs;
require Service::fperm;
require Service::fdisk;

# utils
require Service::manual;
require Service::run;
require Service::upload;

