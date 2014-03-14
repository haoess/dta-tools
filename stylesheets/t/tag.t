use warnings;
use strict;

use Test::More tests => 20;

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
		<span\s+class="ph\s+dta-figure"\s+type="1"><img\s+src="http://dummy.org/dmmy.jpg"/><br/>\s+\[Abbildung\]\s* 
			<span\s+class="figdesc">HEAD</span><br/>\s*
			<p\s+class="dta-p">caption</p>\s*
		</span>}x );
like( process($xsl, 't/xml/head_lg.xml'), qr{		
	  <div>\s*
        <div\s+class="poem">\s*
          <div\s+class="head">DIE[ ]RABEN</div>\s*
          <br/>\s*
          <div\s+class="dta-lg">\s*
            <span\s+class="dta-l">v1a</span><br/>\s*
            <span\s+class="dta-l">v1b</span><br/>\s*
          </div>\s*
          <div\s+class="dta-lg">\s*
            <span\s+class="dta-l">v2a</span><br/>\s*
          </div>\s*
        </div>\s*
      </div>}x );
like( process($xsl, 't/xml/head_list.xml'), qr{		  
	<div>\s*
		<div\s+class="dta-list">\s*
			<div\s+class="dta-head">A</div>\s*
			<div\s+class="dta-list-item">AA</div>\s*
			<div\s+class="dta-list-item">AB</div>\s*
		</div>\s*
	</div>}x );
like( process($xsl, 't/xml/head_div.xml'), qr{
	<div>\s*
		<div\s+class="dta-head">HEAD</div><br/>\s*
		<p\s+class="dta-p">text3</p>\s*
	</div>}x );	

like( process($xsl, 't/xml/head_div_n.xml'), qr{
	<div>\s*
		<h6\s+class="dta-head">1.[ ]Kapitel<br/>Kapitelname</h6><br/>\s*
		<div>\s*
			<div\s+class="dta-head">p1</div><br/>\s*
			<p\s+class="dta-p">text1</p>\s*
		</div><br/>\s*
		<div>\s*
			<div\s+class="dta-head">p2</div><br/>\s*
			<p\s+class="dta-p">text2</p>\s*
		</div><br/>\s*
	</div>}x );	
like( process($xsl, 't/xml/head_no_lb.xml'), qr{
	<div>\s*
		HEAD[ ]text\s*
	</div>\s*
	<div>\s*
		HE<br/>AD[ ]text\s*
	</div>
}x );

# <castList>
like( process($xsl, 't/xml/castlist.xml'), qr{
	<div\s+class="castlist">\s*         
		<p\s+class="dta-p">Besetzung</p>\s*
	</div>}x );

# <castList/castItem>
like( process($xsl, 't/xml/castlist_castitem.xml'), qr{
	<div\s+class="castlist">\s*         
		<h2\s+class="head">Personen<br/></h2>\s*
		<div\s+class="castitem">\s*
			R1\s*
			R1desc\s*
			<span\s+class="dta-actor">A1</span>\s*
		</div><br/>\s*
	</div><br/>}x );

# <castGroup/castItem>
like( process($xsl, 't/xml/castgroup_castitem.xml'), qr{
	<table\s+class="dta-castgroup">
		<tr>
			<td\s+class="castitem">\s*
				R1a\s*<span\s+class="dta-actor">A3a</span>\s*
			</td>\s*
			<td\s+class="roledesc"\s+rowspan="2">\s*
				R1Desc\s*
			</td>\s*
		</tr>\s*
		<tr>\s*
			<td\s+class="castitem">\s*
				R1b\s*<span\s+class="dta-actor">A3b</span>\s*
			</td>\s*
		</tr>\s*
	</table><br/>}x );
	
# <spGrp>
like( process($xsl, 't/xml/spGrp_stagebefore.xml'), qr{
	<table><tr><td\s+style="vertical-align:middle"><div\s+class="stage">\s*
			<p\s+class="v">Sprechen\s+gleichzeitig</p>\s*
		</div></td><td\s+class="braced-base\s+braced-left"><div\s+class="dta-sp">\s*
			<span\s+class="speaker">\s+S1\s+</span>\s*
			<span\s+class="dta-in-sp">t1</span>\s*
			<span\s+class="stage">\s+to\s+S2\s+</span>\s+\s*
			<span\s+class="dta-in-sp">t2</span><br/>\s*
		</div><div\s+class="dta-sp">\s*
			<span\s+class="speaker">\s+S2\s+</span>\s*
			<span\s+class="stage">\s+to\s+S3\s+</span>\s*
			<span\s+class="dta-in-sp">t3</span><br/>\s*
		</div><div\s+class="dta-sp">\s*
			<span\s+class="speaker">\s+S3\s+</span>\s*
			<span\s+class="stage">\s+to\s+S1\s+</span>\s*
			<span\s+class="dta-in-sp">t4</span><br/>\s*
		</div></td></tr></table>\s*
	<br/>}x);
	
like( process($xsl, 't/xml/spGrp_stageafter.xml'), qr{
	<table><tr><td\s+class="braced-base\s+braced-right"><div\s+class="dta-sp">\s*
			<span\s+class="speaker">\s+<span\s+class="g">S1</span>\s+</span>\s*
			<span\s+class="dta-in-sp">t1</span>\s*
		</div><div\s+class="dta-sp">\s*
			<span\s+class="speaker">\s+<span\s+class="g">S2</span>\s+</span>\s*
			<span\s+class="dta-in-sp">t2</span>\s*
		</div></td><td\s+style="vertical-align:middle"><div\s+class="stage">gleichzeitig</div></td></tr></table>\s*
	<br/>}x);
	
# <figure>
like( process($xsl, 't/xml/figure.xml'), qr{
	<div>\s*
		<p\s+class="dta-p">text1</p><br/>\s*
		<div\s+class="phbl[ ]dta-figure"\s+type="1"\s+style="text-align:center">\s+\[Abbildung\]\s+</div>\s*
	</div>\s*
	<div>\s*
		<p\s+class="dta-p">text2</p>\s*
		<span\s+class="ph[ ]dta-figure"\s+type="2"><img\s+src="3"/><br/>\s+\[Abbildung\]\s+</span><br/>\s*
		<p\s+class="dta-p">text3</p>\s*
	</div>\s*
	<div>\s*
		<p\s+class="dta-p">text4</p><br/>\s*
		<div\s+class="phbl[ ]dta-figure"\s+type="3">\s+\[Musik\]\s+</div><br/>\s*
		<p\s+class="dta-p">text5</p>\s*
		<br/>\s*
	</div>\s*
	<div>\s*
		<p\s+class="dta-p">text4<br/>text5\s*
		<span\s+class="ph[ ]dta-figure"\s+type="4">\s+\[Abbildung]\s+</span><br/>\s*
		</p>\s*
		<p\s+class="dta-p">text6</p>\s*
		<br/>\s*
	</div>}x);
