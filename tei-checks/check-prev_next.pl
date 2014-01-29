#!/usr/bin/perl

=head1 NAME

check-prev_next.pl -- Checks if @next and @prev values match the pattern /^#(.*)/ and link to existing ids according to DTABf.

=head1 INVOCATION

    $ perl check-prev_next.pl $INFILE > $OUTFILE

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

my $correct = 1;
my $ln = 1;

my @ids = ($xml =~ /xml:id="(.*?)"/gis);
my %idhash = map { $_ => 1 } @ids;

while ($xml =~ m!(next|prev)="(.*?)"!gis) {
	if(!exists($idhash{$2})){
		$ln = ($` =~ tr/\n//)+1;
		print "reference does not exist: $1=\"$2\" \@line: $ln\n";
		$correct = 0;
	}elsif(!($2 =~ /^#(.*)/)){
		$ln = ($` =~ tr/\n//)+1;
		print "reference doesnt match pattern: $1=\"$2\" \@line: $ln\n";
		$correct = 0;		
	}
}

exit $correct;
