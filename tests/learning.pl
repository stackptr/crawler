use 5.010;
use strict;
use warnings;
use utf8;

use Data::Dumper;

BEGIN { push @INC, "../lib"; }
use Algorithm::NaiveBayes;

my $nb = Algorithm::NaiveBayes->new;

# For each file in each directory, retrieve a hash with each key being a
# unique word, and each value the associated frequency of that word.

# Start with scanning good reviews directory
my @files = <set/good/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	say "Reading $_";
	my %attr = hash_file($_);
	$nb->add_instance ( attributes => \%attr, label => 'good');
	say "Completed processing";
}

# Then scan bad reviews
@files = <set/bad/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	say "Reading $_";
	my %attr = hash_file($_);
	$nb->add_instance ( attributes => \%attr, label => 'bad');
	say "Completed processing";
}

# Train, and cross fingers
$nb->train;

# Test unknown reviews
@files = <set/unknown/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	say "Testing $_";
	my %attr = hash_file($_);
	my $result = $nb->predict(attributes => \%attr);
	print Dumper($result);
}


# Subroutine that takes a file path and returns a hash of the word frequencies
sub hash_file {
	my ($file) = @_;
	my %words;

	my @word_list;
	open FILE, $file or die $!;
	while(<FILE>){
		chomp;
		push @word_list, split;
	}
	close FILE;

	foreach (@word_list){
		$_ =~ s/[[:punct:]]//g; # Remove punctuation
		next if ($_ eq '');

		# Increment frequency if word is in hash, or add to hash
		if (exists $words{$_} ){
			$words{$_}++;
		} else {
			$words{$_} = 1;
		}

	}
	return %words;
}