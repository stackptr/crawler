use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;

my %keywords;


my $keyword = "Test";
my @aliases = ("Alias", "One", "Two");
my %keyword_data = (
    aliases => \@aliases,
);

$keywords{$keyword} = \%keyword_data;

add_weight(30);
add_weight(30);
add_weight(10);
add_weight(30);

sub add_weight {
    my $weight = shift;
    if (defined $keywords{$keyword}{"pages"}{$weight}){
        $keywords{$keyword}{"pages"}{$weight}++;
    } else {
        $keywords{$keyword}{"pages"}{$weight} = 1;

    }
}


print Dumper (\%keywords);

foreach my $k (keys %keywords){
    foreach my $w (keys %{$keywords{$k}{"pages"}}){
        my $count = $keywords{$k}{"pages"}{$w};
        say "$w => $count";
    }
}
