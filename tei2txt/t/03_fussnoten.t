use Test::More tests => 7;
use DTA::TEI::Text::Test;
# use Encode;
use File::Slurp;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/simple.xml',
        txt => 't/test_data/fussnoten/simple.txt',
        is_fragment => 1,
        xslt_params => {
            use_authentic_footnote_sign => 0,
        }
    );
    $t->diff unless ok($t->equal, 'Fussnoten werden korrekt gerendert');
    # print $t->txt;
    # write_file '/tmp/soll.txt', $t->txt;
    # write_file '/tmp/ist.txt', $t->result;
}

sub multiple_footnotes_bug {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/multiple_bug.xml',
        txt => 't/test_data/fussnoten/multiple_bug.txt',
        xslt_params => {
            show_form_feed => 0,
            use_authentic_footnote_sign => 0,
        },
        # is_fragment => 1,
    );
    $t->diff unless ok($t->equal, 'Fussnoten werden nicht mehrfach gezeigt');
}

sub spacing {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/spacing.xml',
        txt => 't/test_data/fussnoten/spacing.txt',
        is_fragment => 1,
        xslt_params => {
            use_authentic_footnote_sign => 0,
        }
    );
    $t->diff unless ok($t->equal, 'Fussnoten-Spacing ist korrekt.');
}

sub spacing_authentic {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/spacing.xml',
        txt => 't/test_data/fussnoten/spacing_authentic.txt',
        is_fragment => 1,
        xslt_params => {
            use_authentic_footnote_sign => 1,
        }
    );
    $t->diff unless ok($t->equal, 'Typographische / Textgetreue Fussnotenzeichen.');
}

sub continued_footnote {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/continued_footnote.xml',
        txt => 't/test_data/fussnoten/continued_footnote.txt',
        is_fragment => 1,
        # xslt_params => {
            # use_authentic_footnote_sign => 0,
        # }
    );
    $t->diff unless ok($t->equal, 'Fortgesetzte Fussnoten.');
}

sub footnote_order {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/treviranus_biologie06_1822.xml_0144.xml',
        txt => 't/test_data/fussnoten/treviranus_biologie06_1822.xml_0144.txt',
        # is_fragment => 1,
        # xslt_params => {
            # use_authentic_footnote_sign => 0,
        # }
    );
    $t->diff unless ok($t->equal, 'Fussnoten Reihenfolge.');
}

sub space_before_mark {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/fussnoten/space_after.xml',
        txt => 't/test_data/fussnoten/space_after.txt',
        is_fragment => 1,
        # xslt_params => {
            # use_authentic_footnote_sign => 0,
        # }
    );
    $t->diff unless ok($t->equal, 'Space vor Fussnoten Anchor.');
}

&simple;
&multiple_footnotes_bug;
&spacing;
&spacing_authentic;
&continued_footnote;
&footnote_order;
&space_before_mark;
