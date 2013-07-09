use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;

my %keywords;

# Define structure to keep a list of keywords with associated arrays of aliases and page counts
%keywords = (
    "Keyword" => {
        aliases => ["test", "alias", "another"],
        pages => [0, 0, 0],
    },
    "Another" => {
        aliases => ["hello", "world"],
        pages => [1, 2, 3],
    }
);

# Add to the structure
# Define the new keyword and its aliases (for example, these might be built from a file)
my $new_keyword = "New";
my @new_aliases = ("Alias_1", "Alias_2");

# Create the keyword hash from previous definitions
my %keyword = (
    aliases => \@new_aliases,
    pages => [0, 0, 0],
);

# Add it to the keywords list of hashes
$keywords{$new_keyword} = \%keyword;

# Make sure it was added correctly
print Dumper (\%keywords);

# Read the list of keywords
foreach my $keyword (keys %keywords){
    say "Keyword: $keyword";
    say "Aliases:";
    foreach my $alias (@{$keywords{$keyword}{"aliases"}}){
        say " * $alias";
    }
    my @page_list = @{$keywords{$keyword}{"pages"}};

    say "Positive pages: $page_list[0]";
    say "Negative pages: $page_list[1]";
    say "Total pages: $page_list[2]";
    say '';
}

#Build list of words from keyword + aliases
foreach my $keyword (keys %keywords){
    my @terms;
    push @terms, $keyword;
    push @terms, @{$keywords{$keyword}{"aliases"}};
    print Dumper (\@terms);
}

