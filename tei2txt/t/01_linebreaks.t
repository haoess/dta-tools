#!/usr/bin/perl 
use Test::Simple tests => 4;
use DTA::TEI::Text::Test;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename     => 't/test_data/linebreaks/simple.xml',
        txt     => 't/test_data/linebreaks/simple.txt',
        is_fragment => 1,
    );
    $t->diff unless ok( $t->equal, '<lb> is translated to \n' );
}

sub line_number {
    my $t = DTA::TEI::Text::Test->new(
        input_filename     => 't/test_data/linebreaks/line_number.xml',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '<lb> with @n attribute is shown per default.');
}
sub line_number_hidden {
    my $t = DTA::TEI::Text::Test->new(
        input_filename     => 't/test_data/linebreaks/line_number.xml',
        txt     => 't/test_data/linebreaks/line_number_no_newline.txt',
        is_fragment => 1,
        xslt_params => { show_line_numbers => 0 },
    );
    $t->diff unless ok($t->equal, '<lb> with @n attr is hidden using parameter.');
}
sub l_after_l {
    my $t = DTA::TEI::Text::Test->new(
        input_filename     => 't/test_data/linebreaks/line.xml',
        txt     => 't/test_data/linebreaks/line.txt',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '<l> after <l> with " ".');
}

&simple;
&line_number;
&line_number_hidden;
&l_after_l;
