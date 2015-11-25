user "peter";
#password "";
#pass_auth;

private_key "~/.ssh/id_rsa";
public_key "~/.ssh/id_rsa.pub";
key_auth;


## ==============
## groups
group all => "bogon1", "bogon2";
#sudo TRUE;
#sudo_password "mysudopw"


## ==============
## misc config
logging to_file => "/tmp/rex.log";
#logging to_syslog => "local0";
timeout 2; # ssh timeout
#parallelism 2;
#use Rex::Misc::ShellBlock;


## ==============
## task
desc "one test example";
task "test", sub {
    say run "uptime";
};


## ==============
## task ssh
desc "set ssh public key";
user "peter";
task "prepare_ssh", sub {
    #user "peter";
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
user "root";
task "prepare_hosts", sub {
    upload "/tmp/hosts.extra", "/tmp/hosts.extra";

    # clear previous
    my $cmdstr = <<END;
    sed -in /"## custom hosts"/,/""/d /etc/hosts;
END
    say run $cmdstr;

    # set latest
    $cmdstr = <<END; 
    key="custom hosts"; extra="/tmp/hosts.extra";
    cat /etc/hosts | grep "\$key" >/dev/null 2>&1 || cat \$extra >> /etc/hosts;
    rm -f /tmp/hosts.extra;
END
    say run $cmdstr;
};


## ==============
## task docker
desc "config docker";
user "root";
task "prepare_docker", sub {
    upload "/etc/default/docker", "/etc/default/docker";
    upload "/lib/systemd/system/docker.service", "/lib/systemd/system/docker.service";
};


