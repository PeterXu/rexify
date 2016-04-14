package Config::common;

use Rex -base;

sub do_test {
   my $output = run "uptime";
   say $output;

   my (%params) = @_;
   my $arg = %params{arg};
   if (!$arg) {$arg = "no";}
   print $arg;
}

# reload=yes|no, default yes
sub do_apt {
    my (%params) = @_;
    my $reload = %params{reload};
    if (!$reload) {$reload = "yes";}

    file "/etc/apt/sources.list",
        source => "files/apt/sources.list",
        owner  => "root",
        group  => "root",
        mode   => 644,
        on_change => sub {
            $reload = "yes";
        };

    if ($reload eq "yes") {say run "apt-get update";}
};


1;
