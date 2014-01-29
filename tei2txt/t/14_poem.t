use Test::More tests => 2;
use DTA::TEI::Text::Test;
use Data::Dumper;

sub simple {
    my $t =
      DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/poem/arnim_wunderhorn.xml',
        txt => 't/test_data/poem/arnim_wunderhorn.txt',
    );
    $t->diff unless ok( $t->equal, 'Einfache Strophenstruktur' );

    # warn Dumper $t->result;
}

sub poem_head {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/poem/arnim_tell.xml',
        txt => 't/test_data/poem/arnim_tell.txt',
        is_fragment    => 1,
    );
    $t->diff unless ok( $t->equal, 'Header in Poem <lg>' );
    # print $t->txt;
    # print $t->result;
}

simple;
poem_head;

done_testing;
