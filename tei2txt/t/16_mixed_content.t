use Test::More tests => 3;
use DTA::TEI::Text::Test;
use Data::Dumper;

# warn Dumper $INC{'DTA/TEI/Text.pm'};

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/mixed_content/simple.xml',
        txt => 't/test_data/mixed_content/simple.txt',
        is_fragment    => 1,
    );
    $t->diff unless ok( $t->equal, 'Mixed Content Whitespace simple' );
    # warn Dumper $t->result;
}

sub tieck1 {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/mixed_content/tieck_lovell02_1796.xml_0007.xml',
        txt => 't/test_data/mixed_content/tieck_lovell02_1796.xml_0007.txt',
    );
    $t->diff unless ok( $t->equal, 'Tieck Beispiel 1 mixed content' );
    # warn Dumper $t->result;
}

sub tieck2 {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/mixed_content/tieck_lovell02_1796.xml_0011.xml',
        txt => 't/test_data/mixed_content/tieck_lovell02_1796.xml_0011.txt',
    );
    $t->diff unless ok( $t->equal, 'Tieck Beispiel 2  mixed content' );
    # print $t->result;
}

simple;
tieck1;
tieck2;

done_testing;
