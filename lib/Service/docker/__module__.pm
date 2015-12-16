package Service::docker;

use Rex -base;

desc "config docker: --reload=yes|no|all, default no";
task "do", sub {
    # another way
    # wget -qO- https://get.docker.com/gpg | sudo apt-key add -
    # wget -qO- https://get.docker.com/ | sh
    
    my $params = shift;
    my $reload = $params->{reload};
    my $ruser = $ENV{RUSER};

    file "/etc/apt/sources.list.d/docker.list",
        source => "files/apt/docker.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "all";
        };

    if ($reload eq "all") {
        #my $cmdstr = "apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D";
        #say run $cmdstr;
        upload "files/apt/docker-trusted.gpg", "/etc/apt/trusted.gpg";
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
    upload "files/etc/docker.service", "/lib/systemd/system/docker.service";

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

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::docker/;

 task yourtask => sub {
    Service::docker::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
