package Config::common;

use Rex -base;
use Rex::Commands::Partition;


sub do_test {
    my $output = run "hostname && uptime";
    say $output;

    my (%params) = @_;
    #print "params: ", %params, "\n\n";
    if (%params{todo} ne "true") {
        print "todo is not true\n";
        return;
    }
}



# ([reload=>yes|no], [source=>no|yes]), default reload yes, source no.
sub do_apt {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $reload = %params{reload};
    unless ($reload) {$reload = "yes";}

    my $source = %params{source};
    if ($source eq "yes") {
    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "yes";
        };
    }

    if ($reload eq "yes") {say run "apt-get -y update";}
};


# (ruser=>.., [reload=yes|no|all]), reload default no
# another way:
#   wget -qO- https://get.docker.com/gpg | sudo apt-key add -
#   wget -qO- https://get.docker.com/ | sh
sub do_docker {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $ruser = %params{ruser};
    my $reload = %params{reload};
    unless ($ruser) { die "usage: do_docker(ruser=>.., [reload=yes|no|all])"; }

    my $version = %params{version};
    unless($version) { $version = "present"; }


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
        run "apt-get -y update";
    }

    pkg "docker-engine", 
        ensure => "$version",
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
    if (%params{todo} ne "true") {return;}

    pkg "python-pip", ensure => "present";
    run "pip install -U pip";

    my $version = %params{version};
    unless($version) { 
        run "pip install docker-compose";
    }else {
        run "pip install docker-compose==$version";
    }
};


# (pubkey=>~/.ssh/id_rsa.pub)
sub do_sshkey {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $pubkey = %params{pubkey};
    unless ($pubkey) { die "usage: do_sshkey(pubkey=>..)"; }

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


# for sshd_config
sub do_sshd {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    # disable ssh login with password only with key.
    my $cmdstr = <<END;
    sed -in 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; 
    rm -f /etc/ssh/sshd_confign; 
END
    say run $cmdstr;
    service ssh => "reload";
}


# install softs from: (list=>p1,p2|@etc/base.txt)
sub do_softs {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $list = %params{list};
    unless ($list) { die "usage: do_softs(list=>p1,p2|\@etc/base.txt)"; }

    my @softs = ();
    if ($list =~ /^@/) { 
        my $listfile = substr($list, 1);
        open(my $FILE, "<", $listfile) || die "cannot open $listfile: $!\n";
        my @lines = <$FILE>;
        chomp @lines;
        close($FILE);

        foreach my $line (@lines) {
            chomp $line;
            ($line =~ (/^#|^;|^\s*$/)) && (next);

            $line =~ s/\n|\r//g;
            $line =~ s/(^\s+|\s+$)//g;
            @softs = (@softs, $line);
        }
    }else {
        @softs = split(/,/, $list);
    }

    print "[INFO] installing @softs \n";
    # pkg [ qw/ufw iptables vim curl wget/ ], ensure => "present";
    if (@softs) { pkg [ @softs ], ensure => "present"; }
};


# set /etc/hosts: cleanonly=yes
sub do_hosts {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $clean = %params{cleanonly};

    # clear previous
    my $host = "/tmp/etc.hosts";
    my $host0 = "## etc.hosts begin";
    my $host1 = "## etc.hosts end";

    my $cmdstr = <<END;
    sed -in /"$host0"/,/"$host1"/d /etc/hosts;
END
    say run $cmdstr;
    if ($clean eq "yes") { return; }


    # set latest
    upload $host, $host;
    $cmdstr = <<END;
    cat /etc/hosts | grep "$host0" >/dev/null 2>&1 || cat $host >> /etc/hosts; rm -f $host;
END
    say run $cmdstr;
};


# upload file: (src=.. dst=..)
sub do_upload {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $src = %params{src};
    my $dst = %params{dst};

    unless ($src or $dst) { die "usage: do_upload('src'=>.., 'dst'=>..)\n"; }

    upload "$src", "$dst";
};

# (cmd=>.., [func=>.., echo=>yes|no])
sub do_run {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $echo = %params{echo};
    my $cmd = %params{cmd};
    unless ($cmd) { die "usage: do_run(cmd=>.., [echo=>yes|no])\n";}
    
    if ($cmd =~ /^@/) { 
        my $cmdfile = substr($cmd, 1);
        open(my $FILE, "<", $cmdfile) || die "Cannot open $cmdfile: $!\n";
        my @lines = <$FILE>;
        close($FILE);

        $cmd = "@lines";
    }

    if ($echo eq "yes") {
        say run "$cmd";
    }else {
        run "$cmd";
    }
};

sub do_ntp {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    upload "files/bin/ntpsync", "/etc/cron.daily/ntpsync";
}

# (mountpoint=>/mnt/share, ondisk=>sdb|c, fstype=>ext3|4, [label=>..])
sub do_fdisk {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $mountpoint = %params{mountpoint};
    my $ondisk = %params{ondisk};
    my $fstype = %params{fstype};
    my $label = %params{label};

    unless ($mountpoint) { die "have to specify --mountpoint=..\n"; }
    unless ($ondisk) { die "have to specify --ondisk=sd?\n"; }
    unless ($fstype) { die "have to specify --fstype=ext?\n"; }

    chomp $ondisk;
    if ($ondisk =~ "^sda") { die "[WARN] <$ondisk> may be your system disk!"; }

    print "[INFO] 'mount -t $fstype /dev/$ondisk $mountpoint' with lable<$label>\n";

    my $exec = Rex::Interface::Exec->create;
    my $device = "/dev/$ondisk";
    my ($m_out, $m_err) = $exec->exec("mount");
    my @mounted = split( /\r?\n/, $m_out );

    my $check = "yes";
    my $already_mounted;
    ($already_mounted) = grep { m/on $mountpoint/ } @mounted;
    if ($already_mounted) {
        if ($check eq "yes") { die "[WARN] $mountpoint already mounted\n"; }
        $exec->exec("umount $mountpoint");
    }

    ($already_mounted) = grep { m/$device/ } @mounted;
    if ($already_mounted) { die "[WARN] <$device> already mounted\n"; }

    run "sed -in /LABEL=$label/d /etc/fstab";
    run "[ -e /dev/${ondisk}1 ] && parted /dev/$ondisk rm 1";
    run "[ -e /dev/${ondisk}2 ] && parted /dev/$ondisk rm 2";
    run "[ -e /dev/${ondisk}3 ] && parted /dev/$ondisk rm 3";
    #clearpart "$ondisk";
    clearpart "$ondisk", initialize => "gpt";
    #return;
    
    mkdir "$mountpoint";
    partition "$mountpoint",
        ondisk  => "$ondisk",
        fstype  => "$fstype",
        label   => "$label",
        grow    => 1,
        mount_persistent => TRUE,
        type   => "primary";
};


# (path=>.., [owner=>.., group=>..])
sub do_chown {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $path = %params{path};
    my $owner = %params{owner};
    my $group = %params{group};

    unless ($path)  { die "usage: do_chown(path=>.., [owner=>.., group=>..])\n"; }

    print "[INFO] 'chown $owner:$group $path'\n";
    if ($owner) { chown "$owner", "$path", recursive => 1; }
    if ($group) { chgrp "$group", "$path", recursive => 1; }
};


# (file=>.., search=>.., replace=>..) 
sub do_sed {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $file = %params{file};
    my $search = %params{search};
    my $replace = %params{replace};

    unless ($file or $search or $replace)  { 
        die "usage: do_sed(file=>.., search=>.., replace=>..)\n"; 
    }

    sed qr/$search/, "$replace", $file;
}

# (dockerimg=>..)
sub do_gluster_client {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $dockerimg = %params{dockerimg};
    unless($dockerimg) {
        die "usage: do_gluster_client(dockerimg=>..)\n";
    }

    my $cmdstr = <<END;
    docker pull $dockerimg;
    docker run --rm -v /var/lib:/root/lib lark.io/glusterfs:stable cp -rf /var/lib/glusterfs /root/lib;
    ln -sf /var/lib/glusterfs/rootfs/sbin/mount.glusterfs /sbin/;
END
    say run "$cmdstr";
}

# (mountpoint=>.., volname=>.., entryhost=>..)
sub do_gluster_mount {
    my (%params) = @_;
    if (%params{todo} ne "true") {return;}

    my $mountpoint = %params{mountpoint};
    my $volname = %params{volname};
    my $entryhost = %params{entryhost};
    unless($mountpoint or $volname or $entryhost) {
        die "usage: do_gluster_mount(mountpoint=>.., volname=>.., entryhost=>..)\n";
    }

    #sed -in /$volname.*glusterfs/d /etc/fstab; 
    $volname = substr($volname, 1);
    my $cmdstr = <<END;
    mount | grep "$mountpoint" && exit 0;
    mkdir -p $mountpoint; 

    sed -in /glusterfs/d /etc/fstab; 
    echo "$entryhost:/$volname $mountpoint glusterfs defaults,_netdev 0 0" >> /etc/fstab; 
    mount -a;

    cat /etc/rc.local | grep "mount -a" && exit 0;
    sed -in '/^exit 0/d' /etc/rc.local;
    echo 'mount -a' >> /etc/rc.local; 
    echo 'exit 0' >> /etc/rc.local;
END
    say run "$cmdstr";
}



1;
