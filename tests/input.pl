use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Text::Balanced ("extract_delimited");
BEGIN{push @INC, "../lib"; }
use DateTime::Format::Flexible;

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
    
    my @fields = /([^\s"]+|(?:[^\s"]*"[^"]*"[^\s"]*)+)(?:\s|$)/g;
    $_ =~ s/"//g foreach @fields;
    
    my $keyword = shift @fields;
    my (@aliases, @dates);

    # Determine date strings or alias strings
    foreach (@fields){
        my $date_regex = "^(19|20)\\d\\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\$";
        if (/$date_regex/){
            if ($#dates < 1 ){
                push @dates, parse($_);
            } else {
                next;
            }

        } else {
            push @aliases, $_;
        }
    }

    # Process dates
    my ($begin, $end);
    @dates = sort @dates;
    $begin = $dates[0];
    $end = $dates[1];
    
    my %keyword_data = (
        aliases => \@aliases,
        pages => [0, 0, 0],
        begin => $begin,
        end => $end
    );
    $keywords{$keyword} = \%keyword_data;
}

print Dumper (\%keywords);


sub parse {
    my $str = shift;
    my $ret = DateTime::Format::Flexible->parse_datetime($str);
    return $ret->epoch();
}
