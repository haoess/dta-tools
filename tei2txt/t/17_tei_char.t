use Test::More tests => 1;
use DTA::TEI::Text::Test;
use File::Slurp;

sub eckermann {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/tei_char/eckermann_goethe03_1848.xml_0039.xml',
        is_fragment => 0,
    );
    $t->diff unless ok($t->equal, '');
    # print $t->txt;
    # write_file '/tmp/soll.txt', $t->txt;
    # write_file '/tmp/ist.txt', $t->result;
}

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/tei_char/simple.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '');
}

&simple;
# &eckermann;
