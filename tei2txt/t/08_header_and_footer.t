use Test::More tests => 9;
use DTA::TEI::Text::Test;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/simple.xml',
        txt            => 't/test_data/forme_work/simple_with_page_number.txt',
        is_fragment    => 1,
        'xslt_params'  => { 'show_page_numbers' => 1 },
    );
    $t->diff
      unless ok( $t->equal,
'Kolumnentitel und Bogensignaturen werden angezeigt (show_page_numbers = 1).'
      );

    # print $t->result;
}

sub simple_without_page_number {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/simple.xml',
        txt            => 't/test_data/forme_work/simple.txt',
        is_fragment    => 1,
        'xslt_params'  => {
            qw(
              show_page_numbers 0
              )
        },
    );
    $t->diff
      unless ok( $t->equal,
'Kolumnentitel und Bogensignaturen werden angezeigt (show_page_numbers = 0).'
      );

    # print $t->result;
}

sub bogensignatur_aus {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/simple.xml',
        txt         => 't/test_data/forme_work/simple_ohne_bogensignatur.txt',
        is_fragment => 1,
        xslt_params => {
            show_page_numbers  => 0,
            show_bogensignatur => 0,
        },
    );
    $t->diff
      unless ok(
              $t->equal, 'Bogensignaturen abschaltbar (show_bogensignatur = 0).'
      );
}

sub kolumnentitel_aus {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/simple.xml',
        txt           => 't/test_data/forme_work/simple_ohne_kolumnentitel.txt',
        is_fragment   => 1,
        'xslt_params' => {
            qw(
              show_page_numbers 0
              show_kolumnentitel 0
              )
        },
    );
    $t->diff
      unless ok( $t->equal,
              'Kolumnentitel abschaltbar (show_kolumnentitel = 0).' );
}

sub kustode_an {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/catchword.xml',
        txt            => 't/test_data/forme_work/catchword.txt',
        is_fragment    => 1,
        xslt_params    => {
              show_catchword => 1
        },
    );
    $t->diff
      unless ok( $t->equal, 'Kustode wird angezeigt (show_catchword=1)' );
}

sub kustode_aus {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/catchword.xml',
        txt            => 't/test_data/forme_work/catchword_no_catchword.txt',
        is_fragment    => 1,
        xslt_params    => {
            qw(
              show_catchword 0
              )
        },
    );
    $t->diff
      unless ok( $t->equal, 'Kustode wird ausgeblendet (show_catchword=0)' );
}
sub kustode_mendelssohn {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/catchword_mendelssohn_030.xml',
        txt            => 't/test_data/forme_work/catchword_mendelssohn_030.txt',
        is_fragment    => 1,
        xslt_params    => {
              show_catchword => 1
        },
    );
    $t->diff
      unless ok( $t->equal, 'Kustode wird angezeigt (show_catchword=1), echtes Beispiel' );
}
sub pagenumber_spyri {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/spyri_heidi_1880.xml_0186.xml',
        txt            => 't/test_data/forme_work/spyri_heidi_1880.xml_0186.txt',
        # is_fragment    => 1,
        # xslt_params    => {
              # show_catchword => 1
        # },
    );
    $t->diff
      unless ok( $t->equal, 'Seitenzahlen werden per default ausgeblendet, echtes Beispiel' );
}

sub pagenumber_spacing {
    my $soll = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/spyri_heidi_1880.xml_0186.xml',
    )->result;
    my $ist = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/forme_work/spyri_heidi_1880.xml_0186_no_fw.xml',
    )->result;
    warn String::Diff::diff_merge($soll, $ist) unless ok( $soll eq $ist, 'Spacing after page number is the same with and without fw[@type="page number"]');
    # warn "'$soll'";
    # warn "'$ist'";
}

&simple;
&simple_without_page_number;
&kolumnentitel_aus;
&bogensignatur_aus;
&kustode_an;
&kustode_aus;
&kustode_mendelssohn;
&pagenumber_spyri;
&pagenumber_spacing;
