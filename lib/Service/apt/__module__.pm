package Service::apt;

use Rex -base;

desc "config apt source: --reload=yes|no, default no";
task "do", sub {
    my $params = shift;
    my $reload = $params->{reload};

    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "yes";
        };

    if ($reload eq "yes") {
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
