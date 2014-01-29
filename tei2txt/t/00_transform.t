#=======================================================================
#         FILE:  00_transform.t
#  DESCRIPTION:  Tests for the Transform module
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#=======================================================================
use DTA::TEI::Text::Transform;
use Test::More tests=>8;
use Data::Dumper;
use File::Slurp;

require_ok('DTA::TEI::Text::Transform');
my $t2t = DTA::TEI::Text::Transform->new;
can_ok( $t2t, 'process' );

my $in_dir   = 't/test_data/0test';
my $in_file   = 't/test_data/0test/arnim_wunderhorn01_1806.xml_0210.xml';
my $in_file_str = read_file $in_file;
my $out_file = '/tmp' . '/dta_tei_test_text_tranform.test.txt';

ok( -e $in_dir && -e $in_file, 'Test TEI files exist' );

sub string {
    $t2t->input_string( $in_file_str );
    ok( $t2t->input_string eq $in_file_str, 'Input string is set');
    $t2t->process;
    my $out = $t2t->process;
    # print $out;
}

sub single_file {
    # $t2t->input_filename($in_file);
    # ok( $t2t->input_filename eq $in_file, 'single file parameter' );
    ok( $t2t->process( {filename => $in_file} ), 'processing single file' );
    my $out = $t2t->process({filename=>$in_file});
    # warn Dumper  $out;
    ok( $out && $out ne '', 'process gave output' );
}

sub single_file_STDOUT {
    # $t2t->out('-');
    # ok( $t2t->out eq '-', 'Output will go to STDOUT');
    ok( $t2t->process({filename => $in_file}), 'processing single file and print to STDOUT' );
    # TODO spare user the actual output
    # $t2t->process( {filename => $in_file, to_stdout => 1});
    # ok( ! $t2t->out, 'Output should be cleared after processing');
}
#--------------------------------------------------
# sub single_file_outfile {
#     $t2t->process({
#             filename => $in_file,
#             # output_filename => $out_file,
#     });
# }
#-------------------------------------------------- 

sub directory {
    $t2t->input_filename($in_dir);
    ok( $t2t->input_filename eq $in_dir, 'Process directory' );
    my $out = $t2t->process;
    ok( $out && $out ne '', 'process gave output' );
    # ok( ! $t2t->out, 'Output should be cleared after processing');
}
sub directory_STDOUT {
    $t2t->input_filename($in_dir);
    ok( $t2t->input_filename eq $in_dir, 'Process directory' );
    # $t2t->out( '-' );
    # print "\n\n";
    my $out = $t2t->process;
    ok( $out && $out ne '', 'process gave output' );
}

sub string_fragment {
    my $str = 'Dis is a test.<lb/>With a newlne';
    $t2t->process({string=>$str, is_fragment=>1});
}

&string;
&string_fragment;
&single_file;
# &single_file_outfile;
# &single_file_STDOUT;
&directory;
# &directory_STDOUT;
# done_testing;
