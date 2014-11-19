#!/usr/bin/perl

use warnings;
use strict;

use utf8;
binmode( STDOUT, ':utf8' );

while( <> ) {
    binmode ARGV, ':utf8';

    # ignore empty lines
    next if /^\s+$/;
    
    # fix space mess
    s/\s+$//g;
    s/[ \t]+/ /g;

    # lonesome dots, e. g. in "text ¹." → "text."
    s/ \././g;

    # poor man's unicruft
    s/a\x{364}/ä/g;
    s/o\x{364}/ö/g;
    s/u\x{364}/ü/g;
    s/\x{a75b}c\.?/etc./g;
    s/\x{a75b}/r/g;
    s/ſ/s/g;

    # de-hyphenate
    tr/¬-/-/;
    s/- (?![aeiouäöü]|vnd)//g;
    s/- ([[:upper:]])/-$1/g;

    print "$_\n";
}
