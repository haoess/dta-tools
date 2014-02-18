#!/usr/bin/perl

=head1 NAME

check-titlepage_rendition_c.pl -- Checks if <div type="titlepage"> does not contain @rendition="#c" according to DTABf.

=head1 INVOCATION

    $ perl check-titlepage_rendition_c.pl $INFILE > $OUTFILE

=head1 VERSION

Version 0.01

=head1 SEE ALSO

L<http://www.deutschestextarchiv.de/doku/basisformat>.

=head1 AUTHOR

Arne Binder

=head1 LICENSE AND COPYRIGHT

    This program is free software, you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License v3 (LGPL-3.0).
    You may copy, distribute and modify the software provided that
    modifications are open source. However, software that includes
    the license may release under a different license.

    See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

use warnings;
use strict;
use utf8;

binmode( STDOUT, ':utf8' );
my $fh;
open($fh, '<:utf8', pop ) or die $!;
my $xml = do { local $/; <$fh> };
close $fh;

my $ln = 1;
my $correct = 1;

while ($xml =~ m!<titlePage.*?>(.*?)<\/titlePage>!gs) {
	my $titlepage = $1;
	my $ln = ($` =~ tr/\n//)+1;
	while ($titlepage =~ m/rendition="(.*?)"/gs){
		my $ln2 = ($` =~ tr/\n//)+$ln;
		foreach(split('[ \t\n]', $1)){
			if($_ eq "#c"){ 
				print "found rendition=\"$1\" in titlepage \@line: $ln2\n";
				$correct = 0;
			}
		}
	}
}

exit $correct;
