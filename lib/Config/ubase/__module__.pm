package Config::ubase;

use Rex -base;

use Config::common;


task "do" => sub {
   my %param = ('testing'=>'true', 'ruser'=>"$ENV{RUSER}");
   Config::common::do_test(%param);

   Config::common::do_apt(%param);
   Config::common::do_docker(%param);
   Config::common::do_pip(%param);

   $param{conf} = 'etc/base0.txt';
   Config::common::do_soft(%param);
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
