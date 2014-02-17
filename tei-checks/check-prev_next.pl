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

    "THE BEER-WARE LICENSE" (Revision 42):
    
    <arne.b.binder@gmail> wrote this file. As long as you retain this notice you
    can do whatever you want with this stuff. If we meet some day, and you think
    this stuff is worth it, you can buy me a beer in return.

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