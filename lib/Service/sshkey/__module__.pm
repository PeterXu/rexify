package Service::sshkey;

use Rex -base;

desc "config ssh public key";
task "prepare", sub {
    upload "~/.ssh/id_rsa.pub", "/tmp";

    my $cmdstr = <<END;
    fauth="\$HOME/.ssh/authorized_keys";
    rsa=\$(cat /tmp/id_rsa.pub); 
    mkdir -p \$HOME/.ssh && touch \$fauth;
    cat \$fauth | grep "\$rsa" >/dev/null 2>&1 || echo "\$rsa" >> \$fauth;
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

 include qw/Service::sshkey/;

 task yourtask => sub {
    Service::sshkey::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
