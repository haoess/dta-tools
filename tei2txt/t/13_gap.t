use Test::More; 
use DTA::TEI::Text::Test;
use Data::Dumper;

sub castlist {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/gap/simple.xml',
   is_fragment => 1,

    );
    $t->diff unless ok($t->equal, 'Auslassungen werden korrekt dargestellt');
    # warn Dumper $t->result;
}

castlist;

done_testing;
