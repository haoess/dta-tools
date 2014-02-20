use warnings;
use strict;

use Test::More;
use XML::Compare;

use File::Basename qw( basename );
use DTAStyleSheets qw( process );

sub slurp {
    my $file = shift;
    open( my $fh, '<', $file ) or die "could not open $file: $!";
    my $contents = do { local $/; <$fh> };
    close $fh;
    chomp( $contents );
    return $contents;
}

my $stylesheet = 'dta-base.xsl';

my $test_cnt = 0;
foreach my $file ( glob 't/tag_*.xml' ) {
    my $tag = basename( $file, '.xml' );
    $tag =~ s/^tag_//;

    my $got = process( $stylesheet, $file );
    my $expected  = slurp("t/tag_$tag.html");
     
    my $same = eval { XML::Compare::same( $got, $expected ) };
    if ( $same ) {
        pass( $tag );
    }
    else {
        $@ =~ s/ at \S+\.pm line \d+\.$//;
        fail( $tag );
        diag( "  testing tag $tag: $@\n" );
        diag( "got:\n$got\n\n" );
        diag( "expected:\n$expected\n\n" );

    }
    $test_cnt++;
}

done_testing( $test_cnt );
