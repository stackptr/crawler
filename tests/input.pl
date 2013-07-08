use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Text::Balanced ("extract_delimited");

open(my $input, "<", "test_input") or die $!;
open(my $multi, "<", "test_multi") or die $!;

my %words;
while(<$input>){
    chomp;
    my @line = split (" ", $_);
    $words{$line[0]} = $line[1];
}
#print Dumper(\%words);

my %keywords;
while(<$multi>){
    next if /^#/; # Handle comments
    chomp;

    my ($extracted, $suffix, $prefix) = extract_delimited($_, q{"'});

    print Dumper($extracted);
    print Dumper($suffix);
    print Dumper($prefix);


    my @line = split (" ", $suffix);

    my ($keyword, @aliases);
    
    my %keyword_data = (
        aliases => \@aliases,
        pages => [0, 0, 0],
    );
    $keywords{$keyword} = \%keyword_data;
}

print Dumper (\%keywords);

