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

    my $xmlDocument    = $xmlParser->parse_file( $xml );
    my $xsltStylesheet = $xmlParser->parse_file( $xslt );

    my $xsltTransformer = $xsltProcessor->parse_stylesheet( $xsltStylesheet );
    my $results = $xsltTransformer->transform( $xmlDocument );

    my $out = $xsltTransformer->output_string( $results );
    for ( $out ) {
        s{\Q<?xml version="1.0" encoding="utf-8"?>\E\s+}{}g;
        s{^\s+|\s+$}{}g;
        s{ +}{ }g;
    }
    return $out;
}

1;
