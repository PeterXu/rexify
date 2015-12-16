package Service::softs;

use Rex -base;

desc "install softs from: --conf=etc/base.txt";
task "do", sub {
    my $params = shift;
    my $conf = $params->{conf};
    if ($conf) {
        my @softs = ();
        open(FILE, "<", $conf) || die "cannot open: $!\n";
        while (my $line = <FILE>){
            chomp($line);
            $line =~ s/(^\s+|\s+$)//g; 
            if ($line !~ /^#/){
                @softs = (@softs, $line);
            }
        }
        close(FILE);

        if (@softs) {
            # pkg [ qw/ufw iptables vim curl wget/ ], ensure => "present";
            pkg [ @softs ], ensure => "present";
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

 include qw/Service::softs/;

 task yourtask => sub {
    Service::softs::example();
 };

=head1 TASKS

=over 4

=item example

This is an example Task. This task just output's the uptime of the system.

=back

=cut
