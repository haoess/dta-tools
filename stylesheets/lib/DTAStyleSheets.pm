package DTAStyleSheets;

use XML::LibXML;
use XML::LibXSLT;

use Exporter 'import';
@EXPORT_OK = qw( process );

use warnings;
use strict;

sub process {
    my ( $xslt, $xml ) = @_;

    my $xmlParser     = XML::LibXML->new();
    my $xsltProcessor = XML::LibXSLT->new();

    XML::LibXSLT->register_function( 'urn:dta', 'urlencode', \&urlencode );

    my $xmlDocument    = $xmlParser->parse_file( $xml );
    my $xsltStylesheet = $xmlParser->parse_file( $xslt );

    my $xsltTransformer = $xsltProcessor->parse_stylesheet( $xsltStylesheet );
    my $results = $xsltTransformer->transform( $xmlDocument );

    my $out = $xsltTransformer->output_string( $results );
    return entities( $out );
}

sub entities {
    my $str = shift;
    utf8::decode( $str );
    $str =~ s{([^\x{01}-\x{ff}])}{sprintf "&#x%04X;", ord($1)}eg;
    return $str;
}

sub urlencode {
    my $str = shift;
    $str = uri_escape_utf8($str);
    for ( $str ) {
        s/&/&amp;/g;
        s/"/&quot;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
    }
    return $str;
}

1;
