#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;
use utf8;
use Mojo::UserAgent;

my $url = "http://www.businessweek.com/articles/2013-06-28/nothings-quiet-on-the-bond-front";
my $ua = Mojo::UserAgent->new(max_redirects => 5)->detect_proxy;

my $tx = $ua->get($url);
say $tx->res->dom->at('html title')->text;

my @text = $tx->res->dom->find('p')->pluck('text')->each;

my $all = join("\n", @text);
say $all;

foreach (@text){
    if ($_ =~ m/debt/){ print "Found one!\n"; }
}

