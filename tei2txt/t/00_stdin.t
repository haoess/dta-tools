use strict;
use warnings;
use Test::More tests => 2;
use Test::Moose;
use Data::Dumper;
require_ok('DTA::TEI::Text::Test');

*STDIN = *DATA;

my $t = DTA::TEI::Text::Test->new(
    input_filename => '-',
    is_fragment => 1,
);

is( $t->result, "foo\n" );

done_testing;
__DATA__
<p>foo</p>
