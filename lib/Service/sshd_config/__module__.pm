package Service::sshd_config;

use Rex -base;

desc "secure in sshd_config";
task "do", sub {
    # disable ssh login with password only with key.
    my $cmdstr = <<END;
    sed -in 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; 
    rm -f /etc/ssh/sshd_confign; 
    service ssh reload;
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

 include qw/Service::sshd_config/;

 task yourtask => sub {
    Service::sshd_config::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
