$ruser = "peter";
$rpass = $ENV{RPASS};
$rlog  = "/tmp/rex.log";

if (!$rpass) {
    print "[WARN] Please export RPASS=...\n";
    exit 0;
}
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
## misc config
sudo TRUE;
sudo_password "$rpass";



## init groups
sub initx {
    use File::Spec;
    my $path = File::Spec->rel2abs(__FILE__);
    my ($vol, $dir, $file) = File::Spec->splitpath($path);

    my $hosts = "/tmp/hosts.extra";
    system "sh $dir/genhosts.sh $hosts";

    open(FILE, "<", $hosts) || die "cannot open: $!\n";
    while ($line = <FILE>){
        if ($line =~ /^\d/) {
            chomp($line);
            my @names = split(/ +/, $line);
            my $len = @names;
            if ($len == 2) {
                my $key = $names[0];
                my $val = $names[1];
                @groups_all = (@groups_all, $val);
                group $val => $key;
            }
        }elsif ($line =~ /^#-/){
            chomp($line);
            $line = substr($line, 2, length($line));
            my @names = split(/=/, $line);
            my $len = @names;
            if ($len == 2) {
                $key = $names[0];
                $val = $names[1];
                $key =~ s/(^ +| +$)//g; 
                $val =~ s/(^ +| +$)//g; 
                my @vals = split(/,/, $val);
                group $key => (@vals);
            }
        }
    }
    close(FILE);
}

@group_all = ();
&initx;
group groups_all => (@groups_all);
#exit 0;


## task testing
desc "one test example";
task "test", sub {
    say run "uptime";
};

## task custom
desc "one custom task: --by=run|scp ..";
task "custom", sub {
    my $params = shift;
    my $by = $params->{by};
    if ($by eq "run") {
        my $cmd = $params->{cmd};
        say run "$cmd";
    }elsif($by eq "scp") {
        my $src = $params->{src};
        my $dst = $params->{dst};
        if (!$dst) {
            $dst = $src;
        }
        if ($src) {
            upload $src, $dst;
        }
    }
};



## ==============
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


## ==============
## task hosts
desc "set /etc/hosts";
task "prepare_hosts", sub {
    upload "/tmp/hosts.extra", "/tmp/hosts.extra";

    # clear previous
    my $cmdstr = <<END;
    sed -in /"## custom hosts begin"/,/"## custom hosts end"/d /etc/hosts;
END
    say run $cmdstr;

    # set latest
    $cmdstr = <<END; 
    key="custom hosts begin"; extra="/tmp/hosts.extra";
    cat /etc/hosts | grep "\$key" >/dev/null 2>&1 || cat \$extra >> /etc/hosts;
    rm -f /tmp/hosts.extra;
END
    say run $cmdstr;
};


## ==============
## task preapre apt
desc "config apt";
task "prepare_apt", sub {
    upload "files/sources.list", "/etc/apt/sources.list";
    upload "files/docker.list", "/etc/apt/sources.list.d/docker.list";

    my $cmdstr = "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D";
    say run $cmdstr;
    say run "apt-get update";
};


## ==============
## task docker
desc "config docker";
task "prepare_docker", sub {
    run "apt-get update";
    pkg "docker-engine", ensure => "present";
    upload "/etc/default/docker", "/etc/default/docker";
    upload "/lib/systemd/system/docker.service", "/lib/systemd/system/docker.service";
    say run "usermod -aG docker $ruser";
};

