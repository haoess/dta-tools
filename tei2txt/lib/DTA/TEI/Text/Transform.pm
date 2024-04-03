#=======================================================================
#         FILE:  Tranform.pm
#  DESCRIPTION:
#       AUTHOR:  Konstantin Baierer (kba), konstantin.baierer@gmail.com
#=======================================================================
package DTA::TEI::Text::Transform;
use Moose;

use XML::LibXSLT;
use Data::Dumper;
use File::Share ':all';
use DTA::TEI::Text;
use File::Temp qw(tempfile);
use IPC::Open2;

binmode STDIN, ":utf8";
binmode STDOUT, ":utf8";

my $TEI_BEFORE=<<'TEI_BEFORE';
<TEI xmlns="http://www.tei-c.org/ns/1.0">
<teiHeader>
<fileDesc>
<titleStmt>
<title>DUMMYHEADER</title>
</titleStmt>
<publicationStmt>
<p></p>
</publicationStmt>
<sourceDesc>
<p>DUMMYHEADER zur Validitätsprüfung</p>
</sourceDesc>
</fileDesc>
</teiHeader>
<text>
TEI_BEFORE

my $TEI_AFTER=<<'TEI_AFTER';
</text>
</TEI>
TEI_AFTER

with 'MooseX::Getopt';

has 'xslt_params' => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'HashRef[Str]',
    default       => sub { {} },
    cmd_aliases   => ['p'],
    documentation => 'Parameters to be passed on to the XSLT processor',
);

has 'input_filename' => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    required      => 0,
    cmd_aliases   => ['i'],
    clearer       => 'clear_input_filename',
    documentation => 'Single TEI file or Directory containing TEI data one page per file',
);

has 'input_string' => (
    traits        => ['Getopt'],
    is => 'rw',
    isa => 'Str',
    required => 0,
    clearer       => 'clear_input_string',
);

has 'xslt' => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    default       => dist_file('DTA-TEI-Text', 'xslt/tei2txt.xsl'),
    cmd_aliases   => ['x'],
    documentation => 'XSLT stylesheet to use',
);

has 'output_filename' => (
    traits        => ['Getopt'],
    is            => 'rw',
    isa           => 'Str',
    cmd_aliases   => ['o'],
    documentation => 'Output file',
    clearer       => 'clear_output_filename',
);

has 'to_stdout' => (
    traits      => ['Getopt'],
    is          => 'rw',
    isa         => 'Bool',
    cmd_aliases => ['v'],
    clearer     => 'clear_to_stdout',
);

has is_fragment => (
    traits      => ['Getopt'],
    is => 'rw',
    isa => 'Bool',
    cmd_aliases => ['x'],
    documentation => 'Specifies that XML might not be valid TEI and should be surrounded with TEI:TEI and TEI:text',
    clearer => 'clear_is_fragment',
);


has '_stylesheet' => (
    accessor => 'stylesheet',
    is       => 'rw',
    isa      => 'XML::LibXSLT::StylesheetWrapper',
);

has _parser => (
    accessor => 'libxml_parser',
    is       => 'rw',
    default  => sub { XML::LibXML->new },
);

sub process {
    my ($self, $params) = @_;
    my $output = '';
    my $input_filename = $self->input_filename;
    my $input_string = $self->input_string;
    my $to_stdout = $self->to_stdout;
    my $output_filename = $self->output_filename;
    my $xslt_params = $self->xslt_params;

    if ($params && ref($params) ne 'HASH') {
        shift;
        die "Invalid call of 'process' :", Dumper [@_];
    }

    # Parameter values take precedence
    if ($params->{string}) { $input_string = $params->{string}; }
    if ($params->{filename}) { $input_filename = $params->{filename}; }
    if ($params->{output_filename}) { $output_filename = $params->{output_filename};}
    if ($params->{to_stdout}) { $to_stdout = $params->{to_stdout};}
    if ($params->{is_fragment}) { $self->is_fragment(1);}
    if ($params->{xslt_params}) { $self->xslt_params( $params->{xslt_params} );}
    # warn Dumper $self->xslt_params;

    # the actual processing logic
    if ($input_string) {
        $output = $self->process_tei_string($input_string);
    } elsif ($input_filename && $input_filename ne "-") {
        if (! -e $input_filename ) {
            die "No such file or directory: " . $self->input_filename;
        }
        if (-d $input_filename) {
            $output = $self->process_dir;
        } else {
            $output = $self->process_one_file($input_filename);
        }
    } else {
        $output = $self->process_stdin();
    }

    # print to file if output_filename is specified
    if ($output_filename) {
        write_file( $output_filename, {binmode => ':utf8'}, $output);
    }

    # print to STDOUT if so specified
    if ($to_stdout) {
        print $output;
    }

    # $self->clear_input_filename;
    # $self->clear_input_string;
    # $self->clear_output_filename;
    return $output;
}
;
sub process_dir {
    my ($self)   = @_;
    my $glob_pat = $self->input_filename . '/*';
    my $output   = '';

    for my $fname ( glob $glob_pat ) {
        $output .= $self->process_one_file($fname);
    }
    return $output;
}

sub process_one_file {
    my ($self, $fname) = @_;
    open( my $fh, '<:utf8', $fname ) or die $!;
    my $tei_string = do { local $/; <$fh> };
    close $fh;
    my $result = $self->process_tei_string( $tei_string );
    return $result;
}

sub process_stdin {
    my ($self) = @_;
    my $tei_string = do { local $/; <STDIN> };
    my $result = $self->process_tei_string( $tei_string );
    return $result;
}

sub process_tei_string {
    my ($self, $tei_string) = @_;
    $tei_string = $self->pre_process( $tei_string );
    my $xml_doc = $self->libxml_parser->load_xml( string => $tei_string );
    my $result = $self->stylesheet->transform( $xml_doc, XML::LibXSLT::xpath_to_string( %{ $self->xslt_params } ) );
    die "XSLT croaked on input string" . $@ unless $result;
    $result = post_process( $self->stylesheet->output_as_chars($result) );
    return $result
}

sub pre_process {
    my ($self, $str) = @_;

    # Thu Oct 27 11:15:07 CEST 2011
    # Regexes von Frank Wiegand
    # $str =~ s{(</c>)\s+(<hi )}{$1$2}g;
    # $str =~ s/\s+<c /<c /g;
    # $str =~ s/(rendition=")\s*/$1/g;
    # $str =~ s/\R*(<supplied[^>]*>)\R*/$1/g;
    # $str =~ s/\R*(<\/supplied>)\R*/$1/g;
    # $str =~ s{(</c></hi>)\R*(<hi rendition="#(?:c|et|right)"><c )}{$1$2}g;
    # warn $str;


    if ($self->is_fragment) {
        $str = $TEI_BEFORE . $str . $TEI_AFTER;
    }

    # strip all char (TEI:c)
    $str =~ s/\R*<c>//g;
    $str =~ s/\R*<c [^>]+?>//g;
    $str =~ s!</c>!!g;
    # fold newlines into one a single newline
    $str =~ s/\R\R+/\n/g;
    # strip last newline in every text node, i.e.
    # "<hi>the end
    # </hi>"
    # should become
    # <hi>the end</hi>
    # and NOT
    # <hi>the end </hi>
    $str =~ s/\R*</</g;
    # now replace all remaining (significant) newlines with spaces
    $str =~ s/\R/\x20/g;

    # $str = do {
        # open2(my $fh_read, my $fh_write, 'xmllint --noblanks -');
        # print $fh_write $str;
        # close $fh_write;
        # local $/;
        # <$fh_read>;
    # };
    # my ($fh, $XMLTMP) = tempfile('dta2txt_xmllint.XXXX', TMPDIR=>1, UNLINK=>1, SUFFIX=>'xml');
    # print $fh $str;
    # $str = qx{xmllint --noblanks $XMLTMP};
    # warn Dumper $str;
    # sleep;
    return $str;
}

sub post_process {
    my $str = shift;
    # Replace FORMFEED placeholder with ASCII FORM FEED character
    $str =~ s/\x20*!!FORMFEED!!\x20*/\f\n/g;
    # fold lines consisting only of whitespace to empty line
    $str =~ s/^\x20*$//xmsg;
    # Fold more than 3 consecutive newlines into 3 newlines (i.e. no
    # more than 2 empty lines)
    $str =~ s/\n\n\n+/\n\n\n/smxg;
    # fold multiple spaces within the text into one
    # $str =~ s/(?<=[^\s])\x20{2,}(?=[^\s])/\x20/smxg;
    # fold multiple spaces into one
    $str =~ s/\x20\x20+/\x20/xmsg;
    # remove all whitespace after tab
    $str =~ s/\t\x20*/\t/g;
    # $str =~ s/([^\x20])\x20{2,}([^\x20])/$1 $2/smxg;

    # remove leading and trailing whitespace
    $str =~ s/^\x20//xsmg;
    $str =~ s/\x20$//xsmg;
    return $str;
}


sub BUILD {
    my ($self) = @_;
    my $stylesheet = XML::LibXSLT->new->parse_stylesheet_file( $self->xslt );
    $self->stylesheet($stylesheet);
}
1;

