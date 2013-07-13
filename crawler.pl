#!/usr/bin/env perl
#
# Financial crawler
# crawler.pl

# Import modules
use 5.10.0;
use strict;
use warnings;
use utf8;

BEGIN{push @INC, 'lib'; }
use List::MoreUtils;
use Term::ANSIColor;
use Mojo::UserAgent;
use IO::Tee;
use Data::Dumper;
use DateTime::Format::Flexible;
use Win32::Console::ANSI;

# Set text strings
use constant USAGE_TEXT => "Usage: crawler <input-file> <output-file> [-h|--help] [-d|--debug] [-q|--quiet] [-i|--ignore]";

# Set signal handlers
$SIG{'INT'} = \&exit_handler;
$SIG{'QUIT'} = \&exit_handler;

# Create argument variables, defaulting to false
my $help_mode = 0;
my $debug_mode = 0;
my $quiet_mode = 0;
my $discard_mode = 1; # On by default
my $keywords_filename = '';
my $output_filename = '';

# Process arguments
for my $arg (@ARGV){
    if ($arg =~ "^-"){
        # Check for flags first
        $arg =~ s/^-*//; # Remove all dashes from beginning of flag

        # And process:
        $debug_mode = 1 if ($arg eq "d" or $arg eq "debug");
        $quiet_mode = 1 if ($arg eq "q" or $arg eq "quiet");
        $discard_mode = 0 if ($arg eq "i" or $arg eq "ignore");
        $help_mode = 1 if ($arg eq 'h' or $arg eq "help");
    } else {
        # Use non-flag args as variables for files in order:
        if ($keywords_filename eq '') { $keywords_filename = $arg; }
        elsif ($output_filename eq '') { $output_filename = $arg; }
    }
}

if ($help_mode){
    say USAGE_TEXT;
    say "Perform a web crawl to classify sentiment on a list of keywords";
    say '';
    say "Arguments:";
    say "  -h, --help    Print this help message.";
    say "  -d, --debug   Run in debug mode. Everything printed to the log is also output to screen.";
    say "  -q, --quiet   Run in quiet mode. Supress all output except ending summary of crawl.";
    say "  -i, --ignore  In the event a date is missing from a page, assume it meets range criteria";
    say "                   and proceed to analyze.";
    say '';
    say "Files (user defined):";
    say "  <input-file>  List of keywords for the crawler to search for. Each line represents a";
    say "                   grouping of keywords, with the first word representing the main keyword";
    say "                   and the other words used as aliases for that keyword. A relevant page";
    say "                   must contain ALL keywords. Keywords may be quoted to allow multiple";
    say "                   words used as one keyword.";
    say "  <output-file> File to accept statistical output of crawl. An existing file will have";
    say "                   output appended, with existing text preserved.";
    say '';
    say "Files (constant):";
    say "  websites.txt  List of URLs, one per line, representing the root website for the crawler";
    say "                   to begin searching from. By default, no links are followed that are";
    say "                   outside the domain specified.";
    say "  positive.txt  A list of positive keywords and weights seperated by whitespace.";
    say "  negative.txt  A list of negative keywords and weights separated by whitespace. Note that";
    say "                   the crawler will automatically consider these negative weights, so no";
    say "                   minus sign is necessary.";
    exit;
}

if (!$output_filename){
    say USAGE_TEXT;
    exit;
}

# Process mode
$debug_mode = 0 if ($quiet_mode);
say colored("Running in DEBUG mode...", 'underline yellow') if ($debug_mode);

# Set other files
my $urls_filename = "websites.txt";
my $positive_filename = "positive.txt";
my $negative_filename = "negative.txt";
my $log_filename = "crawler.log";

# Open files
open(my $in_keywords, "<", $keywords_filename)
  or die "Could not open $keywords_filename to read keywords!\n";
open(my $in_urls, "<", $urls_filename)
  or die "Could not open $urls_filename to read urls!\n";
open(my $in_positive, "<", $positive_filename)
  or die "Could not open $positive_filename to read positive wordlist!\n";
open(my $in_negative, "<", $negative_filename)
  or die "Could not open $negative_filename to read negative wordlist!\n";

# Open output files, multiplex based on mode
open(my $out_file, ">>", $output_filename)
  or die "Could not open $output_filename for output!\n";
open(my $log_file, ">>", $log_filename)
  or die "Could not open $log_filename for logging!\n";

my ($out, $log);
if ($quiet_mode){
    # Quiet mode: write stats and log to file
    $out = $out_file;
    $log = $log_file;
} elsif ($debug_mode) {
    # Debug mode: print stats, print log
    $out = IO::Tee->new(\*STDOUT, $out_file);
    $log = IO::Tee->new(\*STDOUT, $log_file);
} else {
    # Default mode: print stats, write log to file
    $out = IO::Tee->new(\*STDOUT, $out_file);
    $log = $log_file;
}

# Write timestamps to output and log files:
my $time_start = time;
my $timestamp = localtime;
say $log_file "\n\n*** BEGIN LOGGING AT $timestamp\n";
say $out_file "\n\n*** BEGIN OUTPUT AT $timestamp\n";

# Create some lists for later processing
my (%keywords, %positive_words, %negative_words, @urls);

# Process and close input files

# Process keywords file, allowing for quoted keywords and multiple terms to be matched
while(<$in_keywords>){
    next if /^#/; # Handle comments
    chomp;

    # Regex to break up double quoted words
    my @fields = /([^\s"]+|(?:[^\s"]*"[^"]*"[^\s"]*)+)(?:\s|$)/g;
    $_ =~ s/"//g foreach @fields;

    # Construct keyword entry from line
    my $keyword = shift @fields;

    my (@aliases, @dates);

    # Parse date and alias strings
    foreach (@fields){
        my $date_regex = "^(19|20)\\d\\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])\$";
        if (/$date_regex/){
            if ($#dates < 1 ) {
                push @dates, parse_date($_);
            } else {
                next;
            }
        } else {
            push @aliases, $_;
        }
    }

    # Process dates
    @dates = sort @dates;
    my $begin = $dates[0];
    my $end = $dates[1];

    my %keyword_data = (
        aliases => \@aliases,
        begin => $begin,
        end => $end
    );

    # Push keyword entry to list of keywords
    $keywords{$keyword} = \%keyword_data;
}
close $in_keywords;

push @urls, Mojo::URL->new($_) while (<$in_urls>);
chomp(@urls);
close $in_urls;

while(<$in_positive>){
    chomp;
    my @line = split(" ", $_);
    $positive_words{$line[0]} = $line[1];
}
close $in_positive;

while(<$in_negative>){
    chomp;
    my @line = split(" ", $_);
    $negative_words{$line[0]} = $line[1];
}
close $in_negative;

# Print these lists in DEBUG:
if ($debug_mode) {
    say $log "Keywords:";
    foreach my $keyword (keys %keywords){
        print $log "\t$keyword";
        foreach my $alias (@{$keywords{$keyword}{"aliases"}}){
            print $log " $alias" 
        }
        print $log "\n";
    }

    say $log "\nURLS:";
    say $log "\t$_" foreach (@urls);

    say $log "\nPositive words:";
    say $log "\t$_" foreach (keys %positive_words);

    say $log "\nNegative words:";
    say $log "\t$_" foreach (keys %negative_words);
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

    # Verbose mode?
    #say $log "Searching $url";
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
    }

    return;
}

# Search document subroutine
sub search_document {
    my ($url, $tx) = @_;
    my @paragraphs = $tx->res->dom->find('p')->pluck('text')->each;
    my $text = join("\n", @paragraphs);

    say $log "Searching: $url";
    
    foreach my $keyword (keys %keywords){
        # Create the list of terms to work with:
        my @terms;
        push @terms, $keyword;
        push @terms, @{$keywords{$keyword}{"aliases"}};

        # Make sure all the terms exist at least once in the text
        next unless List::MoreUtils::all { $text =~ /\Q$_\E/ } @terms;

        # If there is a begin date specified, then attempt to parse date from DOM
        if (defined $keywords{$keyword}{"begin"}){
            my $page_date = find_date($tx->res->dom);

            if(not defined $page_date){
                if($discard_mode){
                    # If date couldn't be found and we're discarding pages, log and return
                    say $log "No date found. Discarding.";
                    return;
                } else {
                    # Otherwise just log it
                    say $log "No date found. Continuing.";
                }
            } else {
                # Date was obtained, so compare to keyword's begin/end dates to see if meets criteria
                $page_date = parse_date($page_date);
                if ($page_date > $keywords{$keyword}{"begin"}){
                    if(defined $keywords{$keyword}{"end"}){
                        if ($page_date < $keywords{$keyword}{"end"}){
                            # Do nothing, all qualifications are met: begin < page < end
                        } else {
                            say $log "Page is newer than end date. Discarding.";
                            return;
                        }
                    } else {
                        # Do nothing, all qualifications are met: begin < page (no end specified)
                    }

                } else {
                    say $log "Page is older start date. Discarding.";
                    return;
                }
            }

        }

        # Now iterate through each paragraph finding at least one term and then any pos/neg words
        my $found;
        my $weight = 0;
        foreach my $p (@paragraphs){
            # If keyword found in paragraph, search paragraph for pos/neg words
            if (List::MoreUtils::any {$p =~ /\Q$_\E/} @terms) {
                $found = 1;
                foreach (keys %positive_words) {
                    if ($p =~ m/$_/){
                        say $log "$keyword: Found positive word ($_)";
                        $weight += $positive_words{$_};
                    }
                }
                foreach (keys %negative_words) {
                    if ($p =~ m/$_/){
                        say $log "$keyword: Found negative word ($_)";
                        $weight -= $negative_words{$_};
                    }
                }
            }
        }

        next if (not $found); # Skip processing if nothing was found
        
        # Only print message on non-neutral page
        if ($weight != 0){
            print color 'bold white';
            print $out "$keyword";
            print color 'reset';
            print $out ": ";
            if ($weight > 0) {
                print color 'green';
                print $out "POSITIVE";
                print color 'reset';
                print $out " (+$weight) - ";
            } elsif ($weight < 0) {
                print color 'red';
                print $out "NEGATIVE";
                print color 'reset';
                print $out " ($weight) - ";
            }
            print color 'underline blue';
            print $out "$url\n";
            print color 'reset';

            # Add to pages hash
            if (defined $keywords{$keyword}{"pages"}{$weight}){
                $keywords{$keyword}{"pages"}{$weight}++;
            } else {
                $keywords{$keyword}{"pages"}{$weight} = 1;
            }
        }
    }
}

# Routine to parse the DOM to find a publication date
sub find_date {
    my $dom = shift;

    # List of meta name and property attributes
    my @meta_names = ( "dateModified", "lastmod", "datePublished", "pub_date",
    "pubdate", "dateCreated", "date", "REVISION_DATE");
    my @meta_props = ("article:published_time");
    my @meta_itemprop = ("dateModified", "datePublished");

    # Begin with reading meta tags
    for (@meta_names){
        my $ret = $dom->at("meta[name=\"$_\"]");
        next if not defined $ret;
        return $ret->attrs('content');
    }
    for (@meta_props){
        my $ret = $dom->at("meta[property=\"$_\"]");
        next if not defined $ret;
        return $ret->attrs('content');
    }
    for (@meta_itemprop){
        my $ret = $dom->at("meta[itemprop=\"$_\"]");
        next if not defined $ret;
        return $ret->attrs('value');
    }

    return;
}



# Called before exiting to clean things up
sub exit_handler {
    my ($sig) = @_;
    say "\nExiting on SIG$sig -- Stopping event loop";
    Mojo::IOLoop->stop;

    $timestamp = localtime;
    my $time_end = time;
    my $time_total = $time_end - $time_start;
    $time_total = format_seconds($time_total);

    # Prepare keywords for printing
    #for $key ( sort {$a<=>$b} keys %keywords{$keyword}{"pages"} )

    # Write summary: ensure that it is always written to file and stdout
    my $summary = IO::Tee->new(\*STDOUT, $out_file);

    print color 'yellow';
    say $summary "\n\n*** ENDED CRAWL AT $timestamp";
    print color 'reset';
    say $summary "Summary of crawl:\n";

    foreach my $keyword (keys %keywords){
        say $summary "$keyword";

        foreach my $weight (keys %{$keywords{$keyword}{"pages"}}){
            my $count = $keywords{$keyword}{"pages"}{$weight};
            print $summary "  ";
            if ($weight > 0) {
                print color 'green';
                print $summary "+$weight";
            } else {
                print color 'red';
                print $summary "-$weight";
            }
            print color 'reset';
            print $summary " -- $count page";
            print $summary "s" if ($count > 1);
            print $summary "\n";
        }
    }

    say $summary "Time taken: $time_total";

    exit;
}

# Simple function to make raw time output a bit more readable
sub format_seconds {
    my ($seconds, $minutes, $hours, $days);
    (my $time) = @_;
    
    return "$time seconds" if ($time < 60);
    if ($time < 60*60){
        $minutes = int($time/60);
        return "$minutes minutes ($time seconds)";
    } elsif ($time < 3600*24) {
        $hours = int($time/3600);
        return "$hours hours ($time seconds)";
    } else {
        $days = int($time/(60*60*24));
        return "$days days ($time seconds)";
    }
}

sub parse_date {
    my $str = shift;
    $str =~ s/UTC.*//;
    $str =~ s/T.*//;
    my $ret = DateTime::Format::Flexible->parse_datetime($str);
    return $ret->epoch();
}
