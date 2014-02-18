#!/usr/bin/perl

=head1 NAME

check-facs.pl -- Checks if @facs values within C<< <pb> >> elements according to DTABf.

=head1 INVOCATION

    $ perl check-facs.pl $INFILE > $OUTFILE

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
#use utf8;

binmode( STDOUT, ':utf8' );
my $fh;
open($fh, '<:utf8', pop ) or die $!;
my $xml = do { local $/; <$fh> };
close $fh;
my $correct = 1;

my $n = 0; 
my $ln = 1;

while ($xml =~ m!<pb\b(.*?)/>!gs) {
	my $attr = $1;
	$ln = ($` =~ tr/\n//)+1;
	my $facsId;
	eval { $facsId = _get_facsId($attr);1};
	++$n;
	if(!$@){
		if($facsId != $n){			
			print "INCORRECT NUMBER in $attr. expected: $n, found: $facsId \@line: $ln\n";
			$correct = 0;
		}
	}else{
		print $@;
	}
}



sub _get_facsId{
    my ($attr) = @_;
    $attr =~ /facs=(["'])(.*?)\1\s*/;
	my $facs = $2;
	if($facs !~/^#f([0-9]{4})$/){
		my $ln2 = ($` =~ tr/\n//)+$ln;
		$correct = 0;
		die "INCORRECT PATTERN \"$facs\" \@line: $ln2\n";
	}
	$facs =~ /#f0*([1-9][0-9]*)$/;
	return $1;
}

exit $correct;

