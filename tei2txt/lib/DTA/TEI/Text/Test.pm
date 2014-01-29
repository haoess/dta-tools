package DTA::TEI::Text::Test;
use Moose;
use XML::LibXML;
use XML::LibXSLT;
use String::Diff;
use Data::Dumper;
use Error;
use DTA::TEI::Text::Transform;

extends 'DTA::TEI::Text::Transform';

# has 'xslt' => ( is => 'rw', init_arg => undef );
# has 'xslt_file' => ( is => 'ro', isa => 'Str', required => 0, init_arg => 'xslt', default => 'xslt/tei2txt.xsl' );
# has 'xml' => ( is => 'rw', init_arg => undef, );
# has 'xml_file' => ( is => 'ro', isa => 'Str', required => 1, init_arg => 'xml' );
has 'txt' => ( is => 'rw', isa => 'Str', init_arg => undef, );
has 'txt_file' => ( is => 'ro', isa => 'Str', required => 0, init_arg => 'txt' );
has 'result' => ( is => 'rw', init_arg => undef, );
# has 'minimal' => ( is => 'rw', isa => 'Bool', required => 0, default => 0, );
# has 'header' => ( is => 'rw', isa => 'Str', required => 0, default => 'templates/header.xmlt', );
# has 'footer' => ( is => 'rw', isa => 'Str', required => 0, default => 'templates/footer.xmlt', );
# has 'xslt_params' => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] } );

# sub process_xml {
    # my ($self) = @_;
    # my $result = $self->xslt->transform( $self->xml,
        # XML::LibXSLT::xpath_to_string( @{ $self->xslt_params } ) );
    # my $output = $self->xslt->output_as_chars($result);
    # return $output;
# }

sub diff {
    my $self = shift;
    my $soll = $self->txt;
    my $ist = $self->result;
    my $diff = String::Diff::diff_merge($soll, $ist);
    print "$diff\n";
}

sub equal {
    my $self = shift;
    return $self->result eq $self->txt;
}

sub BUILD {
    my $self = shift;

    my $txt_file = $self->txt_file;
    unless ( $txt_file ) {
        $txt_file = $self->input_filename;
        $txt_file =~ s/\.xml$/.txt/;
    }
    my $txt = '';
    if (-e $txt_file ) {
        open( my $fh, '<:utf8', $txt_file ) or die $!;
        $txt = do { local $/; <$fh> };
        close $fh;
        $txt =~ s/\n\Z//;    # Strip trailing newline
    }
    $self->txt($txt);
    $self->result( $self->process );
}

1;
__PACKAGE__->meta->make_immutable;
