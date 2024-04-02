#=======================================================================
#         FILE:  Text.pm
#  DESCRIPTION:  
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#    COPYRIGHT:  Artistic License 2.0
#=======================================================================
package DTA::TEI::Text;
$VERSION = '0.09';

1;
=pod 

=head1 NAME

DTA::TEI::Text - Transform TEI/XML to Plain/Text

=head1 SYNOPSIS

    use DTA::TEI::Text::Transform;
    my $t2t = DTA::TEI::Text::Transform->new;

    # from single file
    my $txt = $t2t->process({filename => '/path/to/file.xml'});

    # from directory of xml files
    my $txt = $t2t->process({filename => '/path/to/dir/of/xml-files'});

    # from TEI fragment string
    my $txt = $t2t->process({string=>'<p>Foo<lb/>Bar.</p>', is_fragment=>1});

    # from STDIN via filename "-"
    my $txt = $t2t->process({filename => '-'});

=head1 REQUIRES

=over

=item File::Slurp

=item Moose

=item Test::More

=item XML::LibXML

=item XML::LibXSLT

=item File::Share

=item Data::Dumper

=item String::Diff

=back

=head1 DESCRIPTION

DTTT transforms TEI to Text. Input is pre-processed (to make even fragments
valid TEI), transformed using a XSLT stylesheet and post-processed to remove
excessive whitespace and fix encoding problems.

=head2 Whitespace Handling

=head3 Pre-Processing

TEI is normalized before XSL transformation using these steps:

=over

=item Purge all TEI:c

=item Fold multiple newlines into one

=item Remove insignificant newlines (before '<')

=item Replace significant newlines with space

=item Replace trailing, leading spaces

=item Fold multiple spaces into one

=back 

=head3 Post-Processing

Afterwards, the following st

=over

=item C<!!FORMFEED!!>' macro is transformed into \f\n

=item Fold multiple spaces, space after tabs, trailing and leading space

=item Fold more than 2 empty lines into one

=back


=head2 Processing parameters

All Parameters can be passed DTA::TEI::Text::Transform at instance creation to
the C<new> method for setting defaults or later to the C<process> method.

The following constructs are equivalent:

    my $t = DTA::TEI::Text::Transform->new(xslt_params=>{show_form_feed => 0});
    $t->process({ filename => '/some/file' });

or

    my $t = DTA::TEI::Text::Transform->new;
    $t->xslt_params({show_form_feed => 0});
    $t->process({ filename => '/some/file' });

or

    my $t = DTA::TEI::Text::Transform->new;
    $t->process({ filename => '/some/file', xslt_params => { show_form_feed => 0} });

=head3 filename

Path to the file/set of files to be transformed. If file is a directory,
process all files with an C<.xml> extension as TEI.

Providing C<-> as file name, input is read from C<STDIN>.

=head3 string 

String of XML data to be transformed.

=head3 xslt_params

B<optional, default {}>

Parameters passed on to the XSL tranformator, see B<XSLT parameters> below.

=head3 output_filename

B<optional, default ''>

Path to a filename, where the output should be written to.

=head3 to_stdout

B<optional, default 1>

Boolean flag to indicate whether to print results to STDOUT.

=head3 is_fragment

B<optional, default 0>

Boolean flag that indicates whether the input should be treated as an XML
fragment. If set to 1, DTTT will surround input with valid TEI scaffolding.
Useful for tests.

=head2 XSLT parameters

All boolean parameters are by default set to 1.

=head3 show_page_numbers

Whether or not to display page numbers in Text output.

=head3 show_form_feed

Whether or not to display form feed + newline (C<\f\n>) at the end of each page.

=head3 show_line_numbers

Whether or not to display line numbers in poems etc.

=head3 show_newlines_in_cells

Show linebreaks in table cells. Setting this to C<0> makes tables more
readable in plain text.

=head3 show_bogensignatur

=head3 show_kolumnentitel

Show Bogensignatur / Kolumnentitel (i.e. C<<fw>> with C<@place="bottom"> or
C<@place="top">).

=head3 show_page_numbers_in_bogensignatur

=head3 show_page_numbers_in_kolumnentitel

B<default 0>

Show Bogensignatur / Kolumnentitel with C<@type="page number">. This can be
confusing when used together with C<show_page_numbers> since they show
redundant and possibly differing information.

=head3 show_sig_in_bogensignatur

=head3 show_sig_in_kolumnentitel

Show Bogensignatur / Kolumnentitel with C<@type="sig">. 

=head3 show_catchword

Whether to show catchwords (words at the end of pages indicating the first word
on the next page).

=head3 use_authentic_footnote_sign

When set to C<0>, footnote signs will be replaced with a superscript numbered version

=head3 gap_char

Char used to visualize gaps in the text. Default is "_" (undescore).

=head1 SEE ALSO

L<XML::LibXSLT>

=head1 AUTHOR

Konstantin Baierer, <konstantin.baierer@gmail.com>

=head1 LICENSE



=cut
