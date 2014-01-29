#!/usr/bin/perl 
use Test::More tests => 3;
use DTA::TEI::Text::Test;
use File::Slurp;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename         => 't/test_data/pagebreaks/simple.xml',
        txt         => 't/test_data/pagebreaks/simple.txt',
        is_fragment     => 1,
        xslt_params => { show_page_numbers => 0 },
    );
    $t->diff unless ok($t->equal, 'Seitenumbrueche werden durch \f ersetzt.');
    # write_file '/tmp/0deleteme/ist.txt', $t->result;
}

# !! OBSOLET !!
# kann immer nur einen Zeilenumbruch pro Datei geben
sub mehrere {
    my $t = DTA::TEI::Text::Test->new(
    input_filename         => 't/test_data/pagebreaks/fold_multiple.xml',
    is_fragment     => 1,
        xslt_params => { show_page_numbers => 0 },
    );
    # my $expected = "Foo\nBar\nBlub!!FORMFEED!!Blub\nBar\nFoo";
    $t->diff unless ok( $t->equal, 'Mehrere "leere" Seitenumbrüche werden eliminiert.' );
    # warn $t->result;
}

sub formfeed_on_off {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/pagebreaks/simple.xml',
        txt => 't/test_data/pagebreaks/simple_no_form_feed.txt',
        is_fragment => 1,
    );
    # can_ok($t, 'process');
    $t->result( $t->process({ xslt_params => {
                    'show_form_feed' => 0,
                    'show_page_numbers' => 0,
    }}));
    $t->diff unless ok($t->equal, 'FORMFEED+NEWLINE turned off (passed to process not BUILD)');
}

sub minimal {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/pagebreaks/minimal.xml',
        txt => 't/test_data/pagebreaks/minimal.txt',
        is_fragment => 1,
        xslt_params => {
            show_page_numbers => 0,
            show_form_feed => 0,
        },
    );
    $t->diff unless ok($t->equal, 'Seite nur mit pb ergibt leere Ausgabe');
}

&simple;
&formfeed_on_off;
&minimal;
# &mehrere;
