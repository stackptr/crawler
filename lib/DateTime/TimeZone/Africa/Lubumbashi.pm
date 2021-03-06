# This file is auto-generated by the Perl DateTime Suite time zone
# code generator (0.07) This code generator comes with the
# DateTime::TimeZone module distribution in the tools/ directory

#
# Generated from /tmp/6Pwc8w6J1M/africa.  Olson data version 2013d
#
# Do not edit this file directly.
#
package DateTime::TimeZone::Africa::Lubumbashi;
{
  $DateTime::TimeZone::Africa::Lubumbashi::VERSION = '1.60';
}
BEGIN {
  $DateTime::TimeZone::Africa::Lubumbashi::AUTHORITY = 'cpan:DROLSKY';
}

use strict;

use Class::Singleton 1.03;
use DateTime::TimeZone;
use DateTime::TimeZone::OlsonDB;

@DateTime::TimeZone::Africa::Lubumbashi::ISA = ( 'Class::Singleton', 'DateTime::TimeZone' );

my $spans =
[
    [
DateTime::TimeZone::NEG_INFINITY, #    utc_start
59859036608, #      utc_end 1897-11-08 22:10:08 (Mon)
DateTime::TimeZone::NEG_INFINITY, #  local_start
59859043200, #    local_end 1897-11-09 00:00:00 (Tue)
6592,
0,
'LMT',
    ],
    [
59859036608, #    utc_start 1897-11-08 22:10:08 (Mon)
DateTime::TimeZone::INFINITY, #      utc_end
59859043808, #  local_start 1897-11-09 00:10:08 (Tue)
DateTime::TimeZone::INFINITY, #    local_end
7200,
0,
'CAT',
    ],
];

sub olson_version { '2013d' }

sub has_dst_changes { 0 }

sub _max_year { 2023 }

sub _new_instance
{
    return shift->_init( @_, spans => $spans );
}



1;

