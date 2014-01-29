use Test::More tests => 3;
use DTA::TEI::Text::Test;
use Data::Dumper;
use File::Slurp;

sub castlist {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/drama/castlist_gwissenswurm.xml',
        txt => 't/test_data/drama/castlist_gwissenswurm.txt',
    );
    $t->diff unless ok( $t->equal, 'CastList wird richtig dargestellt (Anzengruber)' );
    # write_file '/tmp/0deleteme/ist.txt', {binmode=>':utf8'}, $t->result;

    # warn Dumper $t->result;
}

sub castlist_gotter {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/drama/gotter_erbschleicher_castlist.xml',
        txt => 't/test_data/drama/gotter_erbschleicher_castlist.txt',
    );
    $t->diff unless ok( $t->equal, 'CastList wird richtig dargestellt (Gotter)' );
    # write_file '/tmp/0deleteme/ist.txt', {binmode=>':utf8'}, $t->result;

    # warn Dumper $t->result;
}

sub speakerline {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/drama/speakerline.xml',
        is_fragment    => 1,
    );
    $t->diff unless ok( $t->equal, 'Einfacher Dialog' );
}

castlist;
castlist_gotter;
speakerline;
