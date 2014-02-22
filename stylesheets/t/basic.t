use warnings;
use strict;

use Test::More tests => 3;

use DTAStyleSheets qw( process );

my $stylesheet = 'dta-base.xsl';

like( process($stylesheet, 't/xml/comments.xml'), qr{<p class="dta-p">Das ist ein\s+Absatz</p>} );
like( process($stylesheet, 't/xml/utf8.xml'), qr{<p class="dta-p">U&#x0364;beraus wu&#x0364;n&#x017F;chenswerth.</p>} );
like( process($stylesheet, 't/xml/utf8_2.xml'), qr{&#xFFFC; ü u&#x0364; u&#x0364;} );
