package Service::upload;

use Rex -base;

desc "upload file: --src=.. --dst=..";
task "do" => sub {
    my $params = shift;
    my $src = $params->{src};
    my $dst = $params->{dst};

    if ($src and $dst) {
        upload "$src", "$dst";
    }else {
        print "usage: --src=.. --dst=..\n";
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

 include qw/Service::upload/;

 task yourtask => sub {
    Service::upload::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
