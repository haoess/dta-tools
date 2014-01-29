use Test::More tests => 4;
use DTA::TEI::Text::Test;

sub sic_corr {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/choice/sic_corr.xml',
        txt => 't/test_data/choice/sic_corr.txt',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '<sic> and <corr> are handled (corr takes precedence)');
}
sub orig_reg {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/choice/orig_reg.xml',
        txt => 't/test_data/choice/orig_reg.txt',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '<orig> and <ref> are handled (orig takes precedence)');
}
sub reg_only {
    my $t = DTA::TEI::Text::Test->new(
input_filename => 't/test_data/choice/reg_only.xml',
        txt => 't/test_data/choice/reg_only.txt',
   is_fragment => 1,
    );
    $t->diff unless ok($t->equal, '<reg> without <orig>: reg is displayed');
}
sub abbr_expand {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/choice/abbr_expan.xml',
        txt => 't/test_data/choice/abbr_expan.txt',
        is_fragment => 1,
    );
    $t->diff unless ok($t->equal, 'Ignore <expan> in <choice>');
}
&sic_corr;
&orig_reg;
&reg_only;
&abbr_expand;
