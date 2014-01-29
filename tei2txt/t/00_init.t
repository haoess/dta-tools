#=======================================================================
#         FILE:  00_init.t
#  DESCRIPTION:  Test class loading and such
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#      CREATED:  09/19/2011 04:54:56 PM
#=======================================================================
use strict;
use warnings;
use Test::More tests => 3;
use Test::Moose;
use Data::Dumper;
require_ok('DTA::TEI::Text::Test');
my $t = DTA::TEI::Text::Test->new(
    input_filename => 't/test_data/fussnoten/simple.xml',
    is_fragment => 1,
);
can_ok($t, 'diff');
can_ok($t, 'equal');
# can_ok($t, 'equal');


done_testing;

