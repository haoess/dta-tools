use Test::More tests => 2;
use DTA::TEI::Text::Test;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/marginalia/simple.xml',
        txt           => 't/test_data/marginalia/simple.txt',
        is_fragment    => 1,
    );
    $t->diff unless ok( $t->equal, 'Marginalia werden dargestellt' );
}

sub vorgaben_beispiel {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/marginalia/vorgabenbeispiel.xml',
        txt           => 't/test_data/marginalia/vorgabenbeispiel.txt',
        is_fragment    => 1,
    );
    $t->diff
      unless ok( $t->equal, 'Marginalia werden dargestellt (Franks Beispiel)' );
}
&simple;
&vorgaben_beispiel;
