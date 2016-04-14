package Config::ubase;

use Rex -base;

use Config::common;

task "do_test" => sub {
   my %params = ('testing'=>'true', 'ruser'=>"$ENV{RUSER}");
   Config::common::do_test(%params);
};

task "do" => sub {
   my %params = ('testing'=>'true', 'ruser'=>"$ENV{RUSER}");

   Config::common::do_apt(%params);
   Config::common::do_docker(%params);
   Config::common::do_pip(%params);

   $params{conf} = 'etc/base0.txt';
   Config::common::do_soft(%params);
};

task "do_ssh" => sub {
   my %params = ('testing'=>'true', 'ruser'=>"$ENV{RUSER}");

   Config::common::do_sshkey(%params);
   Config::common::do_sshd(%params);
};

task "do_hosts" => sub {
   my %params = ('testing'=>'true', 'ruser'=>"$ENV{RUSER}");

   Config::common::do_hosts(%params);
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Config::ubase/;

 task yourtask => sub {
    Config::ubase::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
