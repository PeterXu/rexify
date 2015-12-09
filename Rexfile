$ruser = "peter";
$rpass = $ENV{RPASS};
$rlog  = "/tmp/rex.log";

$hosts_ = "/tmp/hosts.extra";
$hosts0_ = "## custom hosts begin";
$hosts1_ = "## custom hosts end";

$tuser = $ENV{RUSER};
if ($tuser) {
    $ruser = $tuser;
}

user "$ruser";
#password "";
#pass_auth;
private_key "~/.ssh/id_rsa";
public_key "~/.ssh/id_rsa.pub";
key_auth;

logging to_file => "$rlog";
#logging to_syslog => "local0";
timeout 2; # ssh timeout
#parallelism 2;


## check sudo
&checkx;
sub checkx {
    use Term::ANSIColor qw(:constants);
    $Term::ANSIColor::AUTORESET = 1;
    my $sure;
    if ($rpass) {
        print BOLD YELLOW "\n[WARN] sudo activate?(y/n [n]):";
        $sure = <STDIN>;
        chomp($sure);
        if ($sure eq "y") {
            sudo TRUE;
            sudo_password "$rpass";
        }
    }
    if ($sure ne "y") {
        print RED "[WARN] sudo [[deactivated]]!\n";
    }

    print BOLD YELLOW "\n[WARN] continue?(y/n [y]):";
    $sure = <STDIN>;
    chomp($sure);
    print "\n\n";
    if ($sure eq "n") {
        exit 0;
    }
}

&initx;
sub initx {
    # config /etc/hosts
    open( my $HOSTS, ">", "$hosts_" ) || die "Can't open $hosts_: $!\n";
    print $HOSTS "$hosts0_\n";

    # parse server.ini
    use Config::IniFiles;
    my $file = "etc/server.ini";
    my $ini = Config::IniFiles->new(-file => $file);
    my @groups = ();
    foreach my $sec ($ini->Sections) {
        foreach my $key ($ini->Parameters($sec)) {
            my $val = $ini->val($sec, $key);
            chomp $sec; 
            chomp $key; 
            chomp $val;
            if ($key eq "host") {
                if ($sec !~ /^@/) {
                    print $HOSTS "$val    $sec\n";
                    group $sec => $val;
                    @groups = (@groups, $sec);
                }elsif ($sec =~ /^@/) {
                    $sec =~ s/^.//;
                    group $sec => $val;
                    print $HOSTS "#-$sec = $val\n";
                }
            }
        }
    }

    print $HOSTS "$hosts1_\n";
    close($HOSTS);

    group "zzzgroups" => (@groups);
}


##========================================================
##========================================================

## task testing
desc "one test example";
task "test", sub {
    say run "uptime";
};

## task custom
desc <<END;
custom task with --by=run|scp, e.g,
    --by=run --cmd="",
    --by=scp --src="" --dst="",
    --by=sh --script="" --func="",
export RUSER=.. with real user, default '$ruser'.
export RPASS=.. with sudo password, it will activate sudo.
export RPASS= will deactivate sudo.
...
END
task "custom", sub {
    my $params = shift;
    my $by = $params->{by};
    if ($by eq "run") {
        my $cmd = $params->{cmd};
        if ($cmd) {
            say run "$cmd";
        }
    }elsif($by eq "scp") {
        my $src = $params->{src};
        my $dst = $params->{dst};
        if (!$dst) {
            $dst = $src;
        }
        if ($src) {
            upload $src, $dst;
        }
    }elsif($by eq "sh") {
        my $script = $params->{script};
        my $func = $params->{func};
        if ($script) {
            open(FILE, "<", $script) || die "cannot open: $!\n";
            my @content = <FILE>;
            close(FILE);
            if (@content) {
                say run "@content $func";
            }
        }
    }
};


## task ssh
desc "set ssh public key";
task "prep_ssh", sub {
    upload "~/.ssh/id_rsa.pub", "/tmp";

    my $cmdstr = <<END;
    fauth="\$HOME/.ssh/authorized_keys";
    rsa=\$(cat /tmp/id_rsa.pub); 
    mkdir -p \$HOME/.ssh && touch \$fauth;
    cat \$fauth | grep "\$rsa" >/dev/null 2>&1 || echo "\$rsa" >> \$fauth;
END
    say run $cmdstr;
};


## task /etc/hosts
desc "set /etc/hosts: --clean=yes";
task "prep_hosts", sub {
    my $params = shift;
    my $clean = $params->{clean};

    # clear previous
    my $cmdstr = <<END;
    sed -in /"$hosts0_"/,/"$hosts1_"/d /etc/hosts;
END
    say run $cmdstr;
    if ($clean eq "yes") {
        return;
    }

    # set latest
    my $rhosts = "/tmp/hosts.extra";
    upload $hosts_, $rhosts;
    $cmdstr = <<END; 
    key="$hosts0_"; extra="$rhosts";
    cat /etc/hosts | grep "\$key" >/dev/null 2>&1 || cat \$extra >> /etc/hosts; rm -f \$extra;
END
    say run $cmdstr;
};


## task apt-get
desc "config apt";
task prep_apt, sub {
    my $changed = 0;
    file "/etc/apt/sources.list.d/docker.list",
        source => "files/apt/docker.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            my $cmdstr = "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D";
            say run $cmdstr;
            $changed = 1;
        };

    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $changed = 1;
        };

    if ($changed == 1) {
        say run "apt-get update";
    }
};


## task docker
desc "config docker: --reload=yes|no, default no";
task "prep_docker", sub {
    # another way
    # wget -qO- https://get.docker.com/gpg | sudo apt-key add -
    # wget -qO- https://get.docker.com/ | sh
    
    my $params = shift;
    my $reload = $params->{reload};

    #run "apt-get update";
    pkg "docker-engine", 
        ensure => "present",
        on_change => sub { 
            $reload = "yes";
            say run "usermod -aG docker $ruser";
        };

    upload "files/etc/docker", "/etc/default/docker";
    upload "files/etc/docker.service", "/lib/systemd/system/docker.service";

    if ($reload eq "yes") {
        service docker => "restart";
    }
};


## task softs
desc "install from: --conf=etc/base.txt";
task "prep_softs", sub {
    my $params = shift;
    my $conf = $params->{conf};
    if ($conf) {
        my @softs = ();
        open(FILE, "<", $conf) || die "cannot open: $!\n";
        while ($line = <FILE>){
            chomp($line);
            $line =~ s/(^ +| +$)//g; 
            if ($line !~ /^#/){
                @softs = (@softs, $line);
            }
        }
        close(FILE);

        if (@softs) {
            # pkg [ qw/ufw iptables vim curl wget/ ], ensure => "present";
            pkg [ @softs ], ensure => "present";
        }
    }

    file "/usr/bin/nsenter",
        source => "files/bin/nsenter.x86_64",
        owner  => "root",
        group  => "root",
        mode   => 755,
        no_overwrite => TRUE; 
}


