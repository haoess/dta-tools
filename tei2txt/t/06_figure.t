use Test::More tests=> 6; 
use Data::Dumper;
use DTA::TEI::Text::Test;

sub leer {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/abbildungen/leer.xml',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Leere Abbildung");
}

sub titel {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/abbildungen/titel.xml',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Abbildung mit Titel");
}

sub titel_erklaerung {
    my $t = DTA::TEI::Text::Test->new(
    input_filename => 't/test_data/abbildungen/titel_erklaerung.xml',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Abbildung mit Titel und Erläuterung");
}

sub electricitaet {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/abbildungen/electricitaet.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Abbildung mit alles");
}

sub vogt_briefe {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/abbildungen/vogt_briefe.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Abbildung mit alles");
}

sub fussnote_in_figure {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/abbildungen/virchow.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, "Abbildung mit alles");
}


&leer;
&titel;
&titel_erklaerung;
&electricitaet;
&vogt_briefe;
&fussnote_in_figure;
