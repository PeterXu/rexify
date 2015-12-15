package Service::pip;

use Rex -base;

desc "config pip.conf with custom index-url";
task prepare => sub {
    my $ruser = $ENV{RUSER};
    file "~/.pip/pip.conf", 
        source => "files/etc/pip.conf",
        owner  => "$ruser",
        group  => "$ruser",
        mode   => 755;
    file "/tmp/get-pip.py", source => "files/bin/get-pip.py";
    run "python /tmp/get-pip.py";
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
