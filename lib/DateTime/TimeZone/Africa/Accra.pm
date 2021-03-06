# This file is auto-generated by the Perl DateTime Suite time zone
# code generator (0.07) This code generator comes with the
# DateTime::TimeZone module distribution in the tools/ directory

#
# Generated from /tmp/6Pwc8w6J1M/africa.  Olson data version 2013d
#
# Do not edit this file directly.
#
package DateTime::TimeZone::Africa::Accra;
{
  $DateTime::TimeZone::Africa::Accra::VERSION = '1.60';
}
BEGIN {
  $DateTime::TimeZone::Africa::Accra::AUTHORITY = 'cpan:DROLSKY';
}

use strict;

use Class::Singleton 1.03;
use DateTime::TimeZone;
use DateTime::TimeZone::OlsonDB;

@DateTime::TimeZone::Africa::Accra::ISA = ( 'Class::Singleton', 'DateTime::TimeZone' );

my $spans =
[
    [
DateTime::TimeZone::NEG_INFINITY, #    utc_start
60494688052, #      utc_end 1918-01-01 00:00:52 (Tue)
DateTime::TimeZone::NEG_INFINITY, #  local_start
60494688000, #    local_end 1918-01-01 00:00:00 (Tue)
-52,
0,
'LMT',
    ],
    [
60494688052, #    utc_start 1918-01-01 00:00:52 (Tue)
61083763200, #      utc_end 1936-09-01 00:00:00 (Tue)
60494688052, #  local_start 1918-01-01 00:00:52 (Tue)
61083763200, #    local_end 1936-09-01 00:00:00 (Tue)
0,
0,
'GMT',
    ],
    [
61083763200, #    utc_start 1936-09-01 00:00:00 (Tue)
61094216400, #      utc_end 1936-12-30 23:40:00 (Wed)
61083764400, #  local_start 1936-09-01 00:20:00 (Tue)
61094217600, #    local_end 1936-12-31 00:00:00 (Thu)
1200,
1,
'GHST',
    ],
    [
61094216400, #    utc_start 1936-12-30 23:40:00 (Wed)
61115299200, #      utc_end 1937-09-01 00:00:00 (Wed)
61094216400, #  local_start 1936-12-30 23:40:00 (Wed)
61115299200, #    local_end 1937-09-01 00:00:00 (Wed)
0,
0,
'GMT',
    ],
    [
61115299200, #    utc_start 1937-09-01 00:00:00 (Wed)
61125752400, #      utc_end 1937-12-30 23:40:00 (Thu)
61115300400, #  local_start 1937-09-01 00:20:00 (Wed)
61125753600, #    local_end 1937-12-31 00:00:00 (Fri)
1200,
1,
'GHST',
    ],
    [
61125752400, #    utc_start 1937-12-30 23:40:00 (Thu)
61146835200, #      utc_end 1938-09-01 00:00:00 (Thu)
61125752400, #  local_start 1937-12-30 23:40:00 (Thu)
61146835200, #    local_end 1938-09-01 00:00:00 (Thu)
0,
0,
'GMT',
    ],
    [
61146835200, #    utc_start 1938-09-01 00:00:00 (Thu)
61157288400, #      utc_end 1938-12-30 23:40:00 (Fri)
61146836400, #  local_start 1938-09-01 00:20:00 (Thu)
61157289600, #    local_end 1938-12-31 00:00:00 (Sat)
1200,
1,
'GHST',
    ],
    [
61157288400, #    utc_start 1938-12-30 23:40:00 (Fri)
61178371200, #      utc_end 1939-09-01 00:00:00 (Fri)
61157288400, #  local_start 1938-12-30 23:40:00 (Fri)
61178371200, #    local_end 1939-09-01 00:00:00 (Fri)
0,
0,
'GMT',
    ],
    [
61178371200, #    utc_start 1939-09-01 00:00:00 (Fri)
61188824400, #      utc_end 1939-12-30 23:40:00 (Sat)
61178372400, #  local_start 1939-09-01 00:20:00 (Fri)
61188825600, #    local_end 1939-12-31 00:00:00 (Sun)
1200,
1,
'GHST',
    ],
    [
61188824400, #    utc_start 1939-12-30 23:40:00 (Sat)
61209993600, #      utc_end 1940-09-01 00:00:00 (Sun)
61188824400, #  local_start 1939-12-30 23:40:00 (Sat)
61209993600, #    local_end 1940-09-01 00:00:00 (Sun)
0,
0,
'GMT',
    ],
    [
61209993600, #    utc_start 1940-09-01 00:00:00 (Sun)
61220446800, #      utc_end 1940-12-30 23:40:00 (Mon)
61209994800, #  local_start 1940-09-01 00:20:00 (Sun)
61220448000, #    local_end 1940-12-31 00:00:00 (Tue)
1200,
1,
'GHST',
    ],
    [
61220446800, #    utc_start 1940-12-30 23:40:00 (Mon)
61241529600, #      utc_end 1941-09-01 00:00:00 (Mon)
61220446800, #  local_start 1940-12-30 23:40:00 (Mon)
61241529600, #    local_end 1941-09-01 00:00:00 (Mon)
0,
0,
'GMT',
    ],
    [
61241529600, #    utc_start 1941-09-01 00:00:00 (Mon)
61251982800, #      utc_end 1941-12-30 23:40:00 (Tue)
61241530800, #  local_start 1941-09-01 00:20:00 (Mon)
61251984000, #    local_end 1941-12-31 00:00:00 (Wed)
1200,
1,
'GHST',
    ],
    [
61251982800, #    utc_start 1941-12-30 23:40:00 (Tue)
61273065600, #      utc_end 1942-09-01 00:00:00 (Tue)
61251982800, #  local_start 1941-12-30 23:40:00 (Tue)
61273065600, #    local_end 1942-09-01 00:00:00 (Tue)
0,
0,
'GMT',
    ],
    [
61273065600, #    utc_start 1942-09-01 00:00:00 (Tue)
61283518800, #      utc_end 1942-12-30 23:40:00 (Wed)
61273066800, #  local_start 1942-09-01 00:20:00 (Tue)
61283520000, #    local_end 1942-12-31 00:00:00 (Thu)
1200,
1,
'GHST',
    ],
    [
61283518800, #    utc_start 1942-12-30 23:40:00 (Wed)
DateTime::TimeZone::INFINITY, #      utc_end
61283518800, #  local_start 1942-12-30 23:40:00 (Wed)
DateTime::TimeZone::INFINITY, #    local_end
0,
0,
'GMT',
    ],
];

sub olson_version { '2013d' }

sub has_dst_changes { 7 }

sub _max_year { 2023 }

sub _new_instance
{
    return shift->_init( @_, spans => $spans );
}



1;

