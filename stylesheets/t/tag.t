use warnings;
use strict;

use Test::More tests => 66;

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
	
# <table>
like( process($xsl, 't/xml/table.xml'), qr{
	<table\s+class="dta-table">\s*
		<caption>\s*caption\s*</caption>\s*
		<tr>\s*
			<th\s+colspan="2">th12</th>\s*
			<th>th3</th>\s*
			<th>th4</th>\s*
		</tr>\s*
		<tr>\s*
			<td>td1a</td>\s*
			<td\s+style="padding-left:2em">td2a</td>\s*
			<td>td3a</td>\s*
			<td\s+rowspan="2">td4ab</td>\s*
		</tr>\s*
		<tr>\s*
			<td>td1b</td>\s*
			<td\s+style="text-align:center">td2b</td>\s*
			<td>td3b</td>\s*
		</tr>\s*
		<tr>\s*
			<td>td1c</td>\s*
			<td\s+style="text-align:right">td2c</td>\s*
			<td>td3c</td>\s*
			<td>td3d</td>\s*
		</tr>\s*
	</table>}x);	

# <gap>
like( process($xsl, 't/xml/gap.xml'), qr{	
	<div>\s*
		<p\s+class="dta-p">t1<span\s+class="gap">\[verlorenes[ ]Material[ ]&#x2013;[ ]1[ ]Seite[ ]fehlt\]</span>t1</p>\s*<p\s+class="dta-p">t2<span\s+class="gap">\[irrelevantes[ ]fremdsprachliches[ ]Material[ ]&#x2013;[ ]2[ ]Seiten[ ]fehlen\]</span>t2</p>\s*<p\s+class="dta-p">t3<span\s+class="gap">\[verlorenes[ ]irrelevantes[ ]unleserliches[ ]Material[ ]&#x2013;[ ]1[ ]Zeile[ ]fehlt\]</span>t3</p>\s*<p\s+class="dta-p">t4<span\s+class="gap">\[fremdsprachliches[ ]Material[ ]&#x2013;[ ]2[ ]Zeilen[ ]fehlen\]</span>t4</p>\s*<p\s+class="dta-p">t5<span\s+class="gap">\[unleserliches[ ]Material[ ]&#x2013;[ ]1[ ]Wort[ ]fehlt\]</span>t5</p>\s*<p\s+class="dta-p">t6<span\s+class="gap">\[fremdsprachliches[ ]Material[ ]&#x2013;[ ]2[ ]Wörter[ ]fehlen\]</span>t6</p>\s*<p\s+class="dta-p">t7<span\s+class="gap">\[fremdsprachliches[ ]Material[ ]&#x2013;[ ]1[ ]Zeichen[ ]fehlt\]</span>t7</p>\s*<p\s+class="dta-p">t8<span\s+class="gap">\[1[ ]Zeichen[ ]fehlt\]</span>t8</p>\s*<p\s+class="dta-p">t9<span\s+class="gap">\[fremdsprachliches[ ]Material\]</span>t9</p>\s*<p\s+class="dta-p">t10<span\s+class="gap">\[Wort[ ]fehlt\]</span>t10</p>\s*</div>}x);	
like( process($xsl, 't/xml/gap_simple.xml'), qr{	
	<div>\s*
		<p\s+class="dta-p">t1<span\s+class="gap">\[verlorenes[ ]Material[ ]&#x2013;[ ]1[ ]Seite[ ]fehlt\]</span>t1</p>\s*</div>}x);	

# <item>
like( process($xsl, 't/xml/item_simple_p_pb.xml'), qr{		
	<div\s+class="dta-list-item">i1</div><br/>\s*
	<p\s+class="dta-p"><span\s+class="dta-list-item">i2</span></p><br/>\s*
	<div\s+class="dta-list-item-noindent">i3ai3b</div><br/>}x);		
		
# <list>
like( process($xsl, 't/xml/list_simple.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">t1a<br/>t1b</div>\s*
		<div\s+class="dta-list-item">t2</div>\s*
	</div>}x);
like( process($xsl, 't/xml/list_leftbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">gemeinsamer[ ]Textbaustein[ ]vorn\s*
			<span\s+class="braced-base[ ]braced-left">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
			</span>\s*
		</div>\s*
	</div>}x);
like( process($xsl, 't/xml/list_rightbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">\s*
			<span\s+class="braced-base[ ]braced-right">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div>\s*
			</span>\s*
			gemeinsamer[ ]Textbaustein[ ]hinten</div><br/>\s*
	</div>}x);
like( process($xsl, 't/xml/list_leftrightbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">gemeinsamer[ ]Textbaustein[ ]vorn\s*
			<span\s+class="braced-base[ ]braced-left-right">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
			</span>\s*
			gemeinsamer[ ]Textbaustein[ ]hinten\s*
		</div>\s*
	</div>}x);
	
# <note>
# footnote
like( process($xsl, 't/xml/note_foot.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="fn-intext">\(a\)</span>[ ]text2</p>\s*
		<p\s+class="dta-p">text3<span\s+class="fn-intext">\(b\)</span>[ ]text4</p>\s*
		<p\s+class="dta-p">text5<span\s+class="fn-intext">\(c\)</span>[ ]text6</p>\s*	
	<div\s+class="footnotesep"/><div\s+class="footnote"><span\s+class="fn-sign">\(a\)</span>[ ]footnotea</div><div\s+class="footnote"><span\s+class="fn-sign">\(b\)</span>[ ]footnoteb</div><div\s+class="footnote">[ ]footnotebCont</div><div\s+class="footnote"><span\s+class="fn-sign">\(c\)</span>[ ]footnotec</div>}x);
	
# endnote
like( process($xsl, 't/xml/note_end.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="fn-sign">\(a\)</span>text2</p>\s*
	<p\s+class="dta-p">text3<span\s+class="fn-sign">\(b\)</span>text4</p>\s*
	<div\s+class="endnote\s+endnote-indent"><span\s+class="fn-sign">\(a\)</span>[ ]endnotea</div>\s*
	<div\s+class="endnote">endnotebendnotebCont</div>}x);	

# marginals
like( process($xsl, 't/xml/note_marginals.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="dta-marginal[ ]dta-marginal-left">marginalLeft</span>text2</p>\s*
	<p\s+class="dta-p">text3<span\s+class="dta-marginal[ ]dta-marginal-right">marginalRight</span>text4</p>}x);		

# <supplied>	
like( process($xsl, 't/xml/supplied.xml'), qr{<p class="dta-p">te<span class="dta-supplied">\[x\]</span>t</p>});

# <front> <body> <back>
like( process($xsl, 't/xml/frontBodyBack.xml'), qr{<p class="dta-p">front</p>\s*<p class="dta-p">body</p>\s*<p class="dta-p">back</p>});

# <titlePage>
like( process($xsl, 't/xml/titlepage.xml'), qr{<div class="titlepage">\s*<p class="dta-p">titlePage</p>\s*</div>});

# <titlePart>
like( process($xsl, 't/xml/titlepart.xml'), qr{<div class="titlepart titlepart-main">Title</div>});

# <docAuthor>
like( process($xsl, 't/xml/docauthor.xml'), qr{<div class="titlepage">\s*<span class="docauthor">author</span>\s*</div>});

# <docDate>
like( process($xsl, 't/xml/docdate.xml'), qr{<div class="titlepage">\s*date\s*</div>});

# <docEdition>
like( process($xsl, 't/xml/docedition.xml'), qr{<div class="titlepage">\s*edition\s*</div>});

# <docImprint>
like( process($xsl, 't/xml/docimprint.xml'), qr{<div class="titlepage">\s*imprint\s*</div>});

# <docTitle>
like( process($xsl, 't/xml/doctitle.xml'), qr{<div class="titlepage">\s*title\s*</div>});

# <publisher>
like( process($xsl, 't/xml/publisher.xml'), qr{<div class="titlepage">\s*<span class="dta-publisher">publisher</span>\s*</div>});

# <pubPlace>
like( process($xsl, 't/xml/pubplace.xml'), qr{<div class="titlepage">\s*place\s*</div>});

# <dateline>
like( process($xsl, 't/xml/dateline.xml'), qr{<span class="dta-dateline">content</span>});

# <opener>
like( process($xsl, 't/xml/opener.xml'), qr{<span class="dta-opener">content</span>});

# <salute>
like( process($xsl, 't/xml/salute.xml'), qr{<div class="dta-salute">content</div>});

# <closer>
like( process($xsl, 't/xml/closer.xml'), qr{<div class="dta-closer">content</div>}); 

# <signed>
like( process($xsl, 't/xml/signed.xml'), qr{content});

# <postscript>
like( process($xsl, 't/xml/postscript.xml'), qr{content});

# <role>
like( process($xsl, 't/xml/role.xml'), qr{content});

# <roleDesc>
like( process($xsl, 't/xml/roledesc.xml'), qr{content});

# <cit>
like( process($xsl, 't/xml/cit.xml'), qr{<span data-id="id" data-prev="prev-id" data-next="next-id" class="dta-cit">content</span>});

# <bibl>
like( process($xsl, 't/xml/bibl.xml'), qr{<span class="dta-bibl">content</span>}); 

# <epigraph>
like( process($xsl, 't/xml/epigraph.xml'), qr{<blockquote class="quote">content</blockquote>});

# <argument>
like( process($xsl, 't/xml/argument.xml'), qr{<div class="dta-argument">content</div>}); 

# <byline>
like( process($xsl, 't/xml/byline.xml'), qr{<div class="byline">content</div>}); 

# <milestone>
# rendition="#hr"
like( process($xsl, 't/xml/milestone_hr.xml'), qr{<hr/>});
# rendition="#hrRed"
like( process($xsl, 't/xml/milestone_hrred.xml'), qr{<hr class="red"/>});
# rendition="#hrBlue"
like( process($xsl, 't/xml/milestone_hrblue.xml'), qr{<hr class="blue"/>});

# <lb>
# not(@n)
like( process($xsl, 't/xml/lb.xml'), qr{<p class="dta-p">text1<br/>text2</p>});
# @n
like( process($xsl, 't/xml/lb_n.xml'), qr{<p class="dta-p">text1<span class="dta-lb-n">1</span><br/>text2</p>});

# <imprimatur>
like( process($xsl, 't/xml/imprimatur.xml'), qr{content});

# <space>
# @dim="horizontal"
like( process($xsl, 't/xml/space_horizontal.xml'), qr{&nbsp;&nbsp;&nbsp;});
# @dim="vertical"
like( process($xsl, 't/xml/space_vertical.xml'), qr{<br class="space"/>});

# <floatingText>
like( process($xsl, 't/xml/floatingtext.xml'), qr{<div class="dta-floatingtext">content</div>});

# <quote>
like( process($xsl, 't/xml/quote.xml'), qr{<q class="quote">content</q>});

# <hi> 
# not(@rend)
like( process($xsl, 't/xml/hi.xml'), qr{<p class="dta-p"><span class="aq b blue">content</span></p>});