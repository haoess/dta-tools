use DTA::TEI::Text::Test;
use Data::Dumper;
use Test::More tests => 2;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/endnoten/simple_endnote.xml',
        txt            => 't/test_data/endnoten/simple_endnote.txt',
        is_fragment    => 1,
    );
    $t->diff
      unless ok( $t->equal, "Einfache Endnote wird richtig dargestellt." );
}
sub editorial_note {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/endnoten/editorial_note.xml',
        txt            => 't/test_data/endnoten/editorial_note.txt',
        is_fragment    => 1,
    );
    $t->diff
      unless ok( $t->equal, "Editorial notes are ignored." );
}
&simple;
&editorial_note;
