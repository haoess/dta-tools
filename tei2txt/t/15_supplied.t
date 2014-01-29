use Test::More tests=>1; 
use DTA::TEI::Text::Test;
use Data::Dumper;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/supplied/simple.xml',
    );
    $t->diff unless ok($t->equal, 'Supplied werden mit ausgegegben');
    # warn Dumper $t->result;
}

simple;

done_testing;
