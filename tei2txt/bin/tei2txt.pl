#!/usr/bin/perl 
#=======================================================================
#         FILE:  tei2txt.pl
#  DESCRIPTION:  
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#      CREATED:  10/27/2011 04:13:17 PM
#=======================================================================
use DTA::TEI::Text::Transform;

my $app = DTA::TEI::Text::Transform->new_with_options;
$app->to_stdout(1);
$app->process;
