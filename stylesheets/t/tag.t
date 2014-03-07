use warnings;
use strict;

use Test::More tests => 9;

use DTAStyleSheets qw( process );

my $xsl = 'dta-base.xsl';

# <cb>
like( process($xsl, 't/xml/cb.xml'), qr{
    <p\s+class="dta-p">a</p>\s*
    <span\s+class="dta-cb">\[Beginn[ ]Spaltensatz\]</span>\s*
    <p\s+class="dta-p">\s*
    S1\s*
    <span\s+class="dta-cb">\[Spaltenumbruch\]</span>\s*
    S2\s*
    </p>\s*
    <span\s+class="dta-cb">\[Ende[ ]Spaltensatz\]</span>\s*
    <p\s+class="dta-p">b</p>}x );

# <div>
like( process($xsl, 't/xml/div_simple.xml'), qr{<div>\s*<p class="dta-p">Das ist ein Absatz.</p>\s*</div>} );

# <formula>
like( process($xsl, 't/xml/formula.xml'), qr{<span class="ph formula-1" onclick="editFormula\(1\)" style="cursor:pointer"> \[Formel 1\] </span>} );
like( process($xsl, 't/xml/formula_tex.xml'), qr{<span class="formula"><img.*?\s+src="http://.*?/%5Cfrac%7B1%7D%7B2%7D"/></span>} );
like( process($xsl, 't/xml/formula_utf8.xml'), qr{http://.*?/%FC%20%2B%20%3F} );

# <lg>
like( process($xsl, 't/xml/lg.xml'), qr{<div class="dta-lg">\s*<span class="dta-l">V1</span>\s*<br/>\s*<span class="dta-l">V2</span>\s*<br/>\s*</div>} );
like( process($xsl, 't/xml/lg2.xml'), qr{<div class="dta-lg">\s*<div class="dta-l et"><span>V1</span></div>\s*<br/>\s*<div class="dta-l et aq"><span>V2</span></div>\s*<br/>\s*</div>} );

# <p>
like( process($xsl, 't/xml/p.xml'), qr{<p class="dta-p">X</p>} );

# <head>
like( process($xsl, 't/xml/head_figure.xml'), qr{
		<span\s+class="ph\s+dta-figure"\s+type="1"><img\s+src="http://dummy.org/dmmy.jpg"/><br/>\s+[Abbildung]\s* 
			<span\s+class="figdesc">HEAD</span><br/>\s*
			<p\s+class="dta-p">caption</p>\s*
		</span>}x );
