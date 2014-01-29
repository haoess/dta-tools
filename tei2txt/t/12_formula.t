use Test::More; 
use DTA::TEI::Text::Test;
use Data::Dumper;

sub castlist {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/formula/simple.xml',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, 'Einfache Formeln werden richtig dargestellt');
}

castlist;

done_testing;
