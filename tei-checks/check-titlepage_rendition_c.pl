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