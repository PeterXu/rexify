package Service::pip;

use Rex -base;

desc "config pip.conf with custom index-url";
task "do", sub {
    my $ruser = $ENV{RUSER};
    #upload "files/etc/pip.conf", "~/.pip/pip.conf";
    #upload "files/bin/get-pip.py", "/tmp/get-pip.py";
    #run "python /tmp/get-pip.py";
    run "apt-get install -y python-pip";
    run "pip install -U pip";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::pip/;

 task yourtask => sub {
    Service::pip::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
