package Config::common;

use Rex -base;

sub do_test {
   my $output = run "uptime";
   say $output;

   my (%params) = @_;
   print "params: ", %params, "\n\n";
   if (%params{testing} eq "true") {return;}
}


# reload=yes|no, default yes
sub do_apt {
    my (%params) = @_;
    if (%params{testing} eq "true") {return;}

    my $reload = %params{reload};
    if (!$reload) {$reload = "yes";}

    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "yes";
        };

    if ($reload eq "yes") {say run "apt-get update";}
};


# reload=yes|no|all, default no
# another way
# wget -qO- https://get.docker.com/gpg | sudo apt-key add -
# wget -qO- https://get.docker.com/ | sh
sub do_docker {
    my (%params) = @_;
    if (%params{testing} eq "true") {return;}

    my $reload = %params{reload};
    my $ruser = %params{ruser};

    if (!$ruser) { die "[ERROR] no ruser"; }

    file "/etc/apt/sources.list.d/docker.list",
        source => "files/apt/docker.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "all";
        };

    if ($reload eq "all") {
        $reload = "yes";
        run "apt-get update";
    }

    pkg "docker-engine", 
        ensure => "present",
        on_change => sub { 
            $reload = "yes";
            say run "usermod -aG docker $ruser";
        };

    upload "files/etc/docker", "/etc/default/docker";

    if ($reload eq "yes") {
        service docker => "restart";
    }

    # for docker-enter
    file "/usr/bin/nsenter",
        source => "files/bin/nsenter.x86_64",
        owner  => "root",
        group  => "root",
        mode   => 755,
        no_overwrite => TRUE; 
};


# config pip
sub do_pip {
    my (%params) = @_;
    if (%params{testing} eq "true") {return;}

    pkg "python-pip", ensure => "present";
    run "pip install -U pip";
};


# config ssh public key: pubkey=~/.ssh/id_rsa.pub
sub do_sshkey {
    my (%params) = @_;
    if (%params{testing} eq "true") {return;}

    my $pubkey = %params{pubkey};
    if (!$pubkey) { die "[ERROR] no pubkey"; }

    upload "$pubkey", "/tmp/id_rsa.pub";

    my $cmdstr = <<END;
    fauth="\$HOME/.ssh/authorized_keys";
    rsa=\$(cat /tmp/id_rsa.pub); 
    mkdir -p \$HOME/.ssh && touch \$fauth;
    cat \$fauth | grep "\$rsa" >/dev/null 2>&1 || echo "\$rsa" >> \$fauth;
    rm -f /tmp/id_rsa.pub;
END
    say run $cmdstr;
};


# install softs from: conf=etc/base.txt
sub do_soft {
    my (%params) = @_;
    if (%params{testing} eq "true") {return;}

    my $conf = %params{conf};
    if (!$conf) { die "[ERROR] no conf"; }

    open(my $FILE, "<", $conf) || die "cannot open $conf: $!\n";
    my @lines = <$FILE>;
    chomp @lines;
    close($FILE);

    my @softs = ();
    foreach my $line (@lines) {
        chomp $line;
        ($line =~ (/^#|^;|^\s*$/)) && (next);

        $line =~ s/\n|\r//g;
        $line =~ s/(^\s+|\s+$)//g;
        @softs = (@softs, $line);
    }
    
    if (@softs) {
        # pkg [ qw/ufw iptables vim curl wget/ ], ensure => "present";
        pkg [ @softs ], ensure => "present";
    }
};



1;
