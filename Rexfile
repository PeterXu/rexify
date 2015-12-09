$ruser = "peter";
$rpass = $ENV{RPASS};
$rlog  = "/tmp/rex.log";

$hosts_ = "/tmp/hosts.extra";

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
    my $key1 = "## custom hosts begin\n";
    my $key2 = "## custom hosts end\n";
    open( my $HOSTS, ">", "$hosts_" ) || die "Can't open $hosts_: $!\n";
    print $HOSTS $key1;

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

    print $HOSTS $key2;
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
task "prepare_ssh", sub {
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
desc "set /etc/hosts";
task "prepare_hosts", sub {
    my $rhosts = "/tmp/hosts.extra";
    upload $hosts_, $rhosts;

    # clear previous
    my $cmdstr = <<END;
    sed -in /"## custom hosts begin"/,/"## custom hosts end"/d /etc/hosts;
END
    say run $cmdstr;

    # set latest
    $cmdstr = <<END; 
    key="custom hosts begin"; extra="$rhosts";
    cat /etc/hosts | grep "\$key" >/dev/null 2>&1 || cat \$extra >> /etc/hosts; rm -f \$extra;
END
    say run $cmdstr;
};


## task apt-get
desc "config apt";
task prepare_apt, sub {
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
desc "config docker";
task "prepare_docker", sub {
    # another way
    # wget -qO- https://get.docker.com/gpg | sudo apt-key add -
    # wget -qO- https://get.docker.com/ | sh

    my $updated = 0;
    #run "apt-get update";
    pkg "docker-engine", 
        ensure => "present",
        on_change => sub { 
            $updated = 1;
        };

    upload "files/etc/docker", "/etc/default/docker";
    upload "files/etc/docker.service", "/lib/systemd/system/docker.service";

    say run "usermod -aG docker $ruser";
    if ($updated == 1) {
        service docker => "restart";
    }
};


## task base soft
desc "config base soft";
task "prepare_base", sub {
    run "apt-get update";
    pkg [ qw/ufw iptables vim curl wget/ ], ensure => "present";
};

desc "install from config: --conf=etc/base.txt";
task "prepare_softs", sub {
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


