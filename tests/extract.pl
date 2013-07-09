use 5.010;
use strict;
use warnings;
use Data::Dumper;

while(<DATA>){
    chomp;
    my @fields = /([^\s"]+|(?:[^\s"]*"[^"]*"[^\s"]*)+)(?:\s|$)/g;

    $_ =~ s/"//g foreach @fields;
    say $_ foreach @fields;
}

__DATA__
Keyword alias "alias two"
"Long keyword" alias
No quotes here
