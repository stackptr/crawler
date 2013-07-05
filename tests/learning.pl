use 5.010;
use strict;
use warnings;
use utf8;
use Data::Dumper;

BEGIN { push @INC, "../lib"; }
use Algorithm::NaiveBayes;

my $nb = Algorithm::NaiveBayes->new;

# Create list of words to ignore:
my @ignore = ('', ' ', "the", "a", "is", "I");

# For each file in each directory, retrieve a hash with each key being a
# unique word, and each value the associated frequency of that word.

# Start with scanning good reviews directory
say "*** Processing good reviews";
my @files = <set/good/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	say "Reading $_";
	my %attr = hash_file($_);
	$nb->add_instance ( attributes => \%attr, label => 'good');
}

# Then scan bad reviews
say "*** Processing bad reviews";
@files = <set/bad/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	say "Reading $_";
	my %attr = hash_file($_);
	$nb->add_instance ( attributes => \%attr, label => 'bad');
}

# Train, and cross fingers
$nb->train;

# Test unknown reviews
say "*** Predicting unknown reviews";
@files = <set/unknown/*>;
foreach (@files) {
	next if ($_ =~ m/^\./); # ignore files beginning with .
	print "$_: ";
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

    # Remove common words
    foreach my $w (@ignore){
        next if ($_ eq $w);
    }

    # Lowercase
    $_ = lc;

		# Increment frequency if word is in hash, or add to hash
		if (exists $words{$_} ){
			$words{$_}++;
		} else {
			$words{$_} = 1;
		}

	}
	return %words;
}
