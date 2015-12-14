package Service::apt;

use Rex -base;

desc "config apt source";
task "prepare", sub {
    my $changed = 0;
    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $changed = 1;
        };

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

    if ($changed == 1) {
        say run "apt-get update";
    }
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::apt/;

 task yourtask => sub {
    Service::apt::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
