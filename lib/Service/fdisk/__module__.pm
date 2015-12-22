package Service::fdisk;

use Rex -base;
use Rex::Commands::Partition;

desc "fdisk for: --mountpoint=.. --ondisk=sd? --fstype=ext? [--label=..]";
task "do" => sub {
    my $option = shift;
    my $mountpoint = $option->{mountpoint};
    my $ondisk = $option->{ondisk};
    my $fstype = $option->{fstype};
    my $label = $option->{label};

    unless ($mountpoint) { die "You have to specify --mountpoint=..\n"; }
    unless ($ondisk) { die "You have to specify --ondisk=sd?\n"; }
    unless ($fstype) { die "You have to specify --fstype=ext?\n"; }

    chomp $ondisk;
    if ($ondisk eq "sda") { 
        die "[WARN] <$ondisk> may be your system disk!"; 
        return;
    }

    my $exec = Rex::Interface::Exec->create;
    my $device = "/dev/$ondisk";
    my ($m_out, $m_err) = $exec->exec("mount");
    my @mounted = split( /\r?\n/, $m_out );

    my $check = "yes";
    my $already_mounted;
    ($already_mounted) = grep { m/on $mountpoint/ } @mounted;
    if ($already_mounted) {
        if ($check eq "yes") {
            die "[WARN] $mountpoint already mounted\n";
            return;
        }else {
            $exec->exec("umount $mountpoint");
        }
    }

    ($already_mounted) = grep { m/$device/ } @mounted;
    if ($already_mounted) {
        die "[WARN] <$device> already mounted\n";
        return;
    }

    run "sed -in /LABEL=$label/d /etc/fstab";
    run "[ -e /dev/${ondisk}1 ] && parted /dev/$ondisk rm 1";
    run "[ -e /dev/${ondisk}2 ] && parted /dev/$ondisk rm 2";
    run "[ -e /dev/${ondisk}3 ] && parted /dev/$ondisk rm 3";
    #clearpart "$ondisk";
    clearpart "$ondisk", initialize => "gpt";

    #return;
    mkdir "$mountpoint";
    partition "$mountpoint",
        ondisk  => "$ondisk",
        fstype  => "$fstype",
        label   => "$label",
        grow    => 1,
        mount_persistent => TRUE,
        type   => "primary";
};

1;

=pod

=head1 NAME

$::module_name - {{ SHORT DESCRIPTION }}

=head1 DESCRIPTION

{{ LONG DESCRIPTION }}

=head1 USAGE

{{ USAGE DESCRIPTION }}

 include qw/Service::fdisk/;

 task yourtask => sub {
    Service::fdisk::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
