use strict;
use warnings;
use Test::More; 
use Data::Dumper;
use DTA::TEI::Text::Test;

sub hi_variants {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/hi/varianten.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, 'Verschiedene Varianten von <hi>');
}

sub chamisso_initiale { 
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/hi/chamisso_schlemihl_1814.xml_0017.xml',
        is_fragment=>1,
        xslt_params => { show_page_number => 0 },
    );
    $t->diff unless ok($t->equal, 'Chamisso Beispiel funktioniert');
}


chamisso_initiale;
hi_variants;
done_testing;
