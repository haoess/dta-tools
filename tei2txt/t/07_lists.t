use DTA::TEI::Text::Test;
use Test::More tests=>1;

sub simple {
    my $t = DTA::TEI::Text::Test->new(

    input_filename => 't/test_data/listen/simple_list.xml',
    txt => 't/test_data/listen/simple_list.txt',
    is_fragment => 1,
    );
    $t->diff unless ok($t->equal, 'Simple list');
}
&simple;
