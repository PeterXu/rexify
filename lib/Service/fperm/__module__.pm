package Service::fperm;

use Rex -base;
 
my $ruser = $ENV{RUSER};

task do => sub {
    my $params = shift;
    my $fdir = $params->{fdir};
    if ($fdir) {
        chgrp "$ruser", "$fdir", recursive => 1;
        chown "$ruser", "$fdir", recursive => 1;
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

 include qw/Service::fperm/;

 task yourtask => sub {
    Service::fperm::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
