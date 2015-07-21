#!/usr/bin/perl -w

# process TLE ephemeris files for XMM and CXO

# Robert Cameron
# June 2004

#  updated Feb 10, 2015       T. Isobe (tisobe@cfa.harvard.edu)

$tle_url = "http://www.celestrak.com/NORAD/elements/science.txt";

chdir "/data/mta4/proj/rac/ops/ephem/TLE";

# fetch the TLE data

#@tle = `/usr/local/bin/lynx -source $tle_url`;
@tle = `/usr/bin/lynx -source $tle_url`;
die scalar(gmtime)." No TLE data found in $tle_url\n" unless (@tle);

foreach $i (0..$#tle) { 
    $cxo = $i if ($tle[$i] =~ /^CXO\s*$/);
    $xmm = $i if ($tle[$i] =~ /^XMM/);
}

if ($cxo) {
    open (CF, ">cxo.tle") or die scalar(gmtime)." $0: $!\n";
    for ($cxo..$cxo+2) { print CF $tle[$_] };
    open (CF2, ">cxo.tle2") or die scalar(gmtime)." $0: $!\n";
    print CF2 "2 -7200 14400 5\n";
    for ($cxo+1..$cxo+2) { print CF2 $tle[$_] };
    print CF2 "0 0 0 0\n";
} else { print STDERR "$0: CXO TLE not found at $tle_url\n" };

if ($xmm) {
    open (XF, ">xmm.tle") or die scalar(gmtime)." $0: $!\n";
    for ($xmm..$xmm+2) { print XF $tle[$_] };
    open (XF2, ">xmm.tle2") or die scalar(gmtime)." $0: $!\n";
    print XF2 "2 -7200 14400 5\n";
    for ($xmm+1..$xmm+2) { print XF2 $tle[$_] };
    print XF2 "0 0 0 0\n";
} else { print STDERR "$0: XMM TLE not found at $tle_url\n" };

`rm cxo.spctrk; ./spacetrack < cxo.tle2 > cxo.spctrk`;
`rm xmm.spctrk; ./spacetrack < xmm.tle2 > xmm.spctrk`;
`rm cxo.j2000; ./get_tle2.pl < cxo.spctrk > cxo.j2000`;
`rm xmm.j2000; ./get_tle2.pl < xmm.spctrk > xmm.j2000`;
`./cocoxmm`;
