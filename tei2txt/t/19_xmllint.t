use warnings;
use strict;
use Test::More;
use DTA::TEI::Text::Test;

sub break_xmllint {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/mixed_content/paragraph_without_text.xml',
        is_fragment => 1,
        xslt_params => { show_form_feed => 0 },
    );
    $t->diff unless ok($t->equal, 'absaetze die nur xml content enthalten werden korrekt dargestellt (whitspace)');
}

break_xmllint;
done_testing;
