#!/usr/bin/perl 
use Test::Simple tests => 1;
use DTA::TEI::Text::Test;

sub horiz {
    my $t = DTA::TEI::Text::Test->new(
        input_filename     => 't/test_data/space/sprengel_snippet.xml',
        txt     => 't/test_data/space/sprengel_snippet.txt',
        is_fragment => 1,
    );
    $t->diff unless ok( $t->equal, 'horizontal space is translated to " "' );
}
&horiz;
