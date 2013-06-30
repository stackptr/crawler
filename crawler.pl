#!/usr/bin/env perl
#
# Financial crawler
# crawler.pl

# Import modules
use 5.010;
use strict;
use warnings;
use utf8;
use Mojo::UserAgent;

# Set text strings
use constant USAGE_TEXT => "usage: crawler <input-file> <output-file>";

# Create argument variables, defaulting to false
my $debug_mode = 0;
my $verbose_mode = 0;
my $keywords_filename = '';
my $output_filename = '';

# Process arguments
for my $arg (@ARGV){
    if ($arg =~ "^-"){
        # Check for flags first
        $arg =~ s/^-*//; # Remove all dashes from beginning of flag

        # And process:
        $debug_mode = 1 if ($arg eq "d" or $arg eq "debug");
        $verbose_mode = 1 if ($arg eq "v" or $arg eq "verbose");
    } else {
        # Use non-flag args as variables for files in order:
        if ($keywords_filename eq '') { $keywords_filename = $arg; }
        elsif ($output_filename eq '') { $output_filename = $arg; }
    }
}

if (!$output_filename){
    say USAGE_TEXT;
    exit;
}
say "Running in DEBUG mode..." if ($debug_mode);

# Set other files
my $urls_filename = "websites.txt";
my $positive_filename = "positive.txt";
my $negative_filename = "negative.txt";

# Open files
open(my $in_keywords, "<", $keywords_filename)
  or die "Could not open $keywords_filename to read keywords!\n";
open(my $in_urls, "<", $urls_filename)
  or die "Could not open $urls_filename to read urls!\n";
open(my $in_positive, "<", $positive_filename)
  or die "Could not open $positive_filename to read positive wordlist!\n";
open(my $in_negative, "<", $negative_filename)
  or die "Could not open $negative_filename to read negative wordlist!\n";

# Create some lists for later processing
my (%keywords, @positive_words, @negative_words, @urls);

# Process and close input files
my @keyword_list;
push @keyword_list, $_ while (<$in_keywords>);
chomp @keyword_list;
$keywords{$_} = 0 foreach (@keyword_list);
close $in_keywords;

push @urls, Mojo::URL->new($_) while (<$in_urls>);
chomp(@urls);
close $in_urls;

push @positive_words, $_ while(<$in_positive>);
chomp(@positive_words);
close $in_positive;

push @negative_words, $_ while(<$in_negative>);
chomp(@negative_words);
close $in_negative;

# Print these lists in DEBUG:
if ($debug_mode) {
    say "Keywords:";
    say "\t$_" foreach (keys %keywords);

    say "\nURLS:";
    say "\t$_" foreach (@urls);

    say "\nPositive words:";
    say "\t$_" foreach (@positive_words);

    say "\nNegative words:";
    say "\t$_" foreach (@negative_words);
}


# Begin constructing crawler
my $conn_max = 4;   # Maximum connections
my $active = 0;     # Active connection counter

# Create user agent and specify max redirects
my $ua = Mojo::UserAgent
    ->new(max_redirects => 5)
    ->detect_proxy;

# Define event loop
Mojo::IOLoop->recurring(
    0 => sub { # Wait 0 seconds => invoke callback (asap)
        for ($active + 1 .. $conn_max) {

            # Get the next URL in the queue, and quit when no more exist
            return ($active or Mojo::IOLoop->stop)
                unless my $url = shift @urls;

            # Perform GET request on URL with a subsequent callback
            ++$active;  # Add new active connection
            $ua->get($url => \&get_callback);
        }
    }
);

# Start event loop if necessary
Mojo::IOLoop->start unless Mojo::IOLoop->is_running;

# Define the callback that occurs for an active connection
sub get_callback {
    my (undef, $tx) = @_;  # Gather subroutine args
    --$active;  # Remove previously-created active connection

    # Make sure we've actually retrieved an HTML page
    return
        if not $tx->res->is_status_class(200)
        or $tx->res->headers->content_type !~ m{^text/html\b}ix;

    # Request URL
    my $url = $tx->req->url;

    say "Searching $url" if ($verbose_mode);
    parse_html($url, $tx);

    return;
}

# Subroutine to parse each page
sub parse_html {
    my ($url, $tx) = @_;  # Gather subroutine args

    # At this point:
    # $url = Mojo::URL object
    # $tx = Mojo::Transaction object
    
    # Search document
    search_document($url, $tx);

    # Extract and enqueue URLs
    for my $e ($tx->res->dom('a[href]')->each) {

        # Validate href attribute
        my $link = Mojo::URL->new($e->{href});
        next if 'Mojo::URL' ne ref $link;

        # "normalize" link
        $link = $link->to_abs($tx->req->url)->fragment(undef);
        next unless grep { $link->protocol eq $_ } qw(http https);

        # Don't go deeper than /a/b/c
        next if @{$link->path->parts} > 3;

        # Access every link only once
        state $uniq = {};
        ++$uniq->{$url->to_string};
        next if ++$uniq->{$link->to_string} > 1;

        # Don't visit other hosts
        next if $link->host ne $url->host;

        push @urls, $link;
        #say " -> $link";
    }
    #say '';

    return;
}

# Search document subroutine
sub search_document {
    my ($url, $tx) = @_;
    my @paragraphs = $tx->res->dom->find('p')->pluck('text')->each;
    
    foreach my $term (keys %keywords){
        my $found = 0;
        foreach my $text (@paragraphs){
            if ($text =~ m/$term/){ $found = 1; }
            
            if ($found) {
                foreach (@positive_words) {
                    if ($text =~ m/$_/){
                        say "$term: Found positive word ($_)";
                        $keywords{$term} += 1;
                    }
                }
                foreach (@negative_words) {
                    if ($text =~ m/$_/){
                        say "$term: Found negative word ($_)";
                        $keywords{$term} -= 1;
                    }
                }
            }
        }
        say "Weight for $term in $url: $keywords{$term}" if ($found);
    }
}

