use warnings;
use strict;

use Test::More;

use File::Basename qw( basename );
use DTAStyleSheets qw( process );

sub slurp {
    my $file = shift;
    open( my $fh, '<', $file ) or die $!;
    my $contents = do { local $/; <$fh> };
    close $fh;
    chomp( $contents );
    return $contents;
}

my $stylesheet = 'dta-base.xsl';

my $test_cnt = 0;
foreach my $file ( glob 't/basic_*.xml' ) {
    my $feature = basename( $file, '.xml' );
    $feature =~ s/^basic_//;
    is( process( $stylesheet, $file ), slurp("t/basic_$feature.html"), "feature $feature successfully processed" );
    $test_cnt++;
}

done_testing( $test_cnt );
