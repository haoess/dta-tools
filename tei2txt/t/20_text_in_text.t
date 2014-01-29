use strict;
use warnings;
use Test::More; 
use Data::Dumper;
use DTA::TEI::Text::Test;


sub cramer_97 {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/text_in_text/cramer_mutter_1874.xml_0097.xml',
        # is_fragment => 1,
    ) ;
    $t->diff unless ok($t->equal, 'Beispiel fuer <text> in <text>');
}


cramer_97;
# hi_variants;
done_testing;
