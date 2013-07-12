#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use utf8;
BEGIN{push @INC, "../lib"}
use Mojo::UserAgent;
use Data::Dumper;
use List::MoreUtils;
use DateTime::Format::Flexible;

# Define user agent
my $ua = Mojo::UserAgent->new(max_redirects => 5)->detect_proxy;

# Create array of urls to test:
my @url = ("http://www.businessweek.com/articles/2013-06-28/nothings-quiet-on-the-bond-front",
    "http://edition.cnn.com/2013/07/12/world/europe/russia-us-snowden/index.html?hpt=hp_t1",
    "http://www.forbes.com/sites/nathanvardi/2013/07/12/larry-robbins-obamacare-trade-helps-him-become-one-of-the-nations-hottest-hedge-fund-managers/",
    "http://www.businessinsider.com/edward-snowden-asylum-moscow-airport-venezuela-human-rights-groups-2013-7",
    "http://www.bloomberg.com/news/2013-07-12/gangs-ruled-prison-as-for-profit-model-put-blood-on-floor.html",
    "http://www.reuters.com/article/2013/07/12/us-usa-economy-idUSBRE96A0G320130712",
    "http://online.wsj.com/article/SB10001424127887323740804578601573895219316.html?mod=WSJ_hpp_LEFTTopStories"
);

my ($tx, $date, @parsed);
foreach (@url){
    $tx = get_url($_);
    $date = find_date($tx->res->dom);
    parse($date);
    say '';
}

# Routine to return $tx object
sub get_url {
    my $url = shift;
    $tx = $ua->get($url);
    say $tx->res->dom->at('html title')->text;
    return $tx;
}

# Routine to parse the DOM to find a publication date
sub find_date {
    my $dom = shift;
    my $date;
    
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

sub parse {
    my $str = shift;
    say $str;

    my $ret = DateTime::Format::Flexible->parse_datetime($str);

    say "=> $ret";
}
