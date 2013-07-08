use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Keyword;

open(my $input, "<", "test_input") or die $!;
open(my $multi, "<", "test_multi") or die $!;

my %words;
while(<$input>){
    chomp;
    my @line = split (" ", $_);
    $words{$line[0]} = $line[1];
}
print Dumper(\%words);

my %keywords;
while(<$multi>){
    chomp;
    my @line = split (" ", $_);
    foreach(@line){
        if ($_ =~ m/^\"/){
        }


    }
    $keywords{$line[0]} = new Keyword(@line);
}

say $keywords{$_}->getKeyword() foreach (keys %keywords);
