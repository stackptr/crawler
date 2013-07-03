use 5.010;
use strict;
use warnings;

use IO::Tee;

my $file = "test";
my $msg = "This is a test message to be multiplexed\n";

open(my $out_file, ">>", $file);

my $out = IO::Tee->new(\*STDOUT, $out_file);

print $out $msg;
