package Service::manual;

use Rex -base;

my $ruser=$ENV{RUSER};

desc <<END;
custom task with --by=run|scp, e.g,
    --by=run --cmd="",
    --by=scp --src="" --dst="",
    --by=sh --script="" --func="",
export RUSER=.. with real user, default '$ruser'.
export RPASS=.. with sudo password, it will activate sudo.
export RPASS= will deactivate sudo.
...
END
task "custom", sub {
    my $params = shift;
    my $by = $params->{by};
    if ($by eq "run") {
        my $cmd = $params->{cmd};
        if ($cmd) {
            say run "$cmd";
        }
    }elsif($by eq "scp") {
        my $src = $params->{src};
        my $dst = $params->{dst};
        if (!$dst) {
            $dst = $src;
        }
        if ($src) {
            upload $src, $dst;
        }
    }elsif($by eq "sh") {
        my $script = $params->{script};
        my $func = $params->{func};
        if ($script) {
            open(FILE, "<", $script) || die "cannot open: $!\n";
            my @content = <FILE>;
            close(FILE);
            if (@content) {
                say run "@content $func";
            }
        }
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

 include qw/Service::manual/;

 task yourtask => sub {
    Service::manual::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
