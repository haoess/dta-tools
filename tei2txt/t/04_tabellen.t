#!/usr/bin/perl 
use Test::More tests => 3;
use DTA::TEI::Text::Test;

sub simple {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/tabellen/simple-table.xml',
        txt            => 't/test_data/tabellen/simple-table.txt',
        is_fragment => 1,
    );
    $t->diff
      unless ok( $t->txt eq $t->result,
              'einfache tabelle wird richtig im kontext dargestellt.' );

    # print $t->result;
}

sub astronomisch {
    my $t =
      DTA::TEI::Text::Test->new( input_filename => 't/test_data/04-table.xml', );
    $t->diff
      unless ok( $t->equal,
              'komplexe tabelle mit astronomischen beobachtungen' );
}

sub newline_in_table {
    my $t = DTA::TEI::Text::Test->new(
        xml         => 't/test_data/tabellen/table_newline_in_cell.xml',
        is_fragment => 1,
    );
    $t->diff unless ok( $t->txt eq $t->result, 'newlines in tabllenzeilen' );
}

sub newline_in_table_no_newline {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/tabellen/table_newline_in_cell.xml',
        txt => 't/test_data/tabellen/table_newline_in_cell_no_newline.txt',
        xslt_params => { 'show_newlines_in_cells' => 0 },
        is_fragment => 1,
    );
    $t->diff
      unless ok( $t->txt eq $t->result,
              'newlines in tabllenzeilen with "newlines_in_cells" disabled' );
}

sub row_col_span {
    my $t = DTA::TEI::Text::Test->new(
        input_filename => 't/test_data/tabellen/row_span.xml',
        txt => 't/test_data/tabellen/row_span.txt',
        is_fragment      => 1,
    );
    $t->diff unless ok( $t->equal, 'row und colspans' );
}

&simple;

# &astronomisch;
# &newline_in_table;
&newline_in_table_no_newline;
&row_col_span;
