package Service::hosts;

use Rex -base;

desc "set /etc/hosts: --cleanonly=yes";
task "prepare", sub {
    my $params = shift;
    my $clean = $params->{cleanonly};

    # clear previous
    my $hosts0 = "## custom hosts begin";
    my $hosts1 = "## custom hosts end";
    my $cmdstr = <<END;
    sed -in /"$hosts0"/,/"$hosts1"/d /etc/hosts;
END
    say run $cmdstr;
    if ($clean eq "yes") {
        return;
    }

    # set latest
    my $hosts = "/tmp/hosts.extra";
    upload $hosts, $hosts;

    $cmdstr = <<END;
    cat /etc/hosts | grep "$hosts0" >/dev/null 2>&1 || cat $hosts >> /etc/hosts; rm -f $hosts;
END
    say run $cmdstr;
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::hosts/;

 task yourtask => sub {
    Service::hosts::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
