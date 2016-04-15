package Config::ubase;

use Rex -base;

use Config::common;

task "do_test" => sub {
    my %params = ('todo'=>'true', 'ruser'=>"$ENV{RUSER}");
    Config::common::do_test(%params);
};


desc "[\@ref] for apt/docker/pip/base0.txt";
task "do" => sub {
    my %params = ('todo'=>'true', 'ruser'=>"$ENV{RUSER}");

    Config::common::do_apt(%params);
    Config::common::do_docker(%params);
    Config::common::do_pip(%params);

    $params{conf} = 'etc/base0.txt';
    Config::common::do_softs(%params);
};


desc "[\@ref] do by --mod=.., sshkey|sshd|hosts, softs|upload|fdisk|chown|run --xx";
task "do_mod" => sub {
    my $args = shift;
    my $mod = $args->{mod};
    unless ($mod) { die "usage by --mod=.."; }

    my %params = ('todo'=>'true', 'ruser'=>"$ENV{RUSER}");

    if ($mod eq "sshkey") {
        Config::common::do_sshkey(%params);
    }elsif($mod eq "sshd") {
        Config::common::do_sshd(%params);
    }elsif($mod eq "hosts") {
        Config::common::do_hosts(%params);
    }elsif($mod eq "softs") {
        unless ($args->{conf}) { die "usage: --mod=softs --conf=base0.txt"; }
        $params{conf} = $args->{conf};

        Config::common::do_softs(%params);
    }elsif($mod eq "upload") {
        unless ($args->{src} or $args->{dst}) { 
            die "usage: --mod=upload --src=.. --dst=..\n"; 
        }

        $params{src} = $args->{src};
        $params{dst} = $args->{dst};

        Config::common::do_upload(%params);
    }elsif($mod eq "fdisk") {
        unless ($args->{mountpoint} or $args->{ondisk} or $args->{fstype}) {
            die "usage: --mountpoint=/mnt/share --ondisk=sdb|c --fstype=ext3|4, [--label=..])\n";
        }

        $params{mountpoint} = $args->{mountpoint};
        $params{ondisk} = $args->{ondisk};
        $params{fstype} = $args->{fstype};

        if ($args->{label}) { $params{label} = $args->{label}; }

        Config::common::do_fdisk(%params);
    }elsif($mod eq "chown") {
        unless($args->{path}) { die "usage: --path=.. [--owner=.. --group=..]\n"; }
        $params{path} = $args->{path};

        unless($args->{owner}) { $params{owner} = $params{ruser}; }
        else { $params{owner} = $args->{owner}; }

        if ($args->{group}) { $params{group} = $args->{group}; }

        Config::common::do_chown(%params);
    }elsif($mod eq "run") {
        unless($args->{cmd}) { die "usage: --cmd=str|\@file.. [--func=.. --echo=yes|no]\n"; }
        $params{cmd} = $args->{cmd};

        if ($args->{func}) { $params{func} = $args->{func}; }
        if ($args->{echo}) { $params{echo} = $args->{echo}; }

        Config::common::do_run(%params);
    }else {
        die "do not support --mod=$mod";
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
