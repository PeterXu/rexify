package Service::run;

use Rex -base;

desc "run cmd on remote host: --cmd=.. [--echo=yes]";
task "do" => sub {
    my $params = shift;
    my $cmd = $params->{cmd};
    my $echo = $params->{echo};
    if ($cmd) {
        if ($echo eq "yes") {
            say run "$cmd";
        }else {
            run "$cmd";
        }
    }else {
        print "remote run cmd: --cmd=..\n";
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

 include qw/Service::run/;

 task yourtask => sub {
    Service::run::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
