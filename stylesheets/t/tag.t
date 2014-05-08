use warnings;
use strict;

use Test::More tests => 122;

use DTAStyleSheets qw( process );

my $xsl = 'dta-base.xsl';

#--- Document Structure Elements

### <front> <body> <back>
like( process($xsl, 't/xml/frontBodyBack.xml'), qr{
	<p\s+class="dta-p">front</p>\s*
	<p\s+class="dta-p">body</p>\s*
	<p\s+class="dta-p">back</p>}x);

### <pb>
# No transformation will be done.
like( process($xsl, 't/xml/pb.xml'), qr{});

### <titlePage>
like( process($xsl, 't/xml/titlepage.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		titlePage\s*
	</div>}x);

## Elements of Titlepage

### <docTitle>
like( process($xsl, 't/xml/doctitle.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-doctitle">title</span>\s*
	</div>}x);

### <titlePart>
like( process($xsl, 't/xml/titlepart.xml'), qr{<div class="dta-titlepart dta-titlepart-main">Title</div>});

### <byline>
like( process($xsl, 't/xml/byline.xml'), qr{<div class="dta-byline">content</div>}); 

### <docAuthor>
like( process($xsl, 't/xml/docauthor.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-docauthor">author</span>\s*
	</div>}x);

### <docEdition>
like( process($xsl, 't/xml/docedition.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-docedition">edition</span>\s*
	</div>}x);

### <docImprint>
like( process($xsl, 't/xml/docimprint.xml'), qr{<div class="dta-titlepage">\s*<span class="dta-docimprint">imprint</span>\s*</div>});

## Elements of Imprint

### <publisher>
like( process($xsl, 't/xml/publisher.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-docimprint">\s*
			<span\s+class="dta-publisher">publisher</span>\s*
		</span>\s*
	</div>}x);

### <pubPlace>
like( process($xsl, 't/xml/pubplace.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-docimprint">\s*
			<span\s+class="dta-pubplace">place</span>\s*
		</span>\s*
	</div>}x);

### <docDate>
like( process($xsl, 't/xml/docdate.xml'), qr{
	<div\s+class="dta-titlepage">\s*
		<span\s+class="dta-docdate">date</span>\s*
	</div>}x);

#--- Text Structure Elements 

### <lb>
# not(@n)
like( process($xsl, 't/xml/lb.xml'), qr{<p class="dta-p">text1<br/>text2</p>});
# @n
like( process($xsl, 't/xml/lb_n.xml'), qr{<p\s+class="dta-p">text1<span\s+class="dta-lb-n">1</span><br/>text2</p>});

### <cb>
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

### <space>
# @dim="horizontal"
like( process($xsl, 't/xml/space_horizontal.xml'), qr{&nbsp;&nbsp;&nbsp;});
# @dim="vertical"
like( process($xsl, 't/xml/space_vertical.xml'), qr{<br class="dta-space"/>});
	
### <milestone>
# @rendition="#hr"
like( process($xsl, 't/xml/milestone_hr.xml'), qr{<hr/>});
# @rendition="#hrRed"
like( process($xsl, 't/xml/milestone_hrred.xml'), qr{<hr class="dta-red"/>});
# @rendition="#hrBlue"
like( process($xsl, 't/xml/milestone_hrblue.xml'), qr{<hr class="dta-blue"/>});
	
### <div>
# simple
like( process($xsl, 't/xml/div_simple.xml'), qr{<div>content</div>});
# advertisement
like( process($xsl, 't/xml/div_advertisement.xml'), qr{<div class="dta-anzeige">Anzeige</div>});
# other type (the new class: "dta-_@type_")
like( process($xsl, 't/xml/div_otherType.xml'), qr{<div class="dta-edition">content</div>});
	
### <p>
like( process($xsl, 't/xml/p.xml'), qr{<p class="dta-p">X</p>} );

### <head>
# head in <figure>
like( process($xsl, 't/xml/head_figure.xml'), qr{
		<div\s+class="dta-phbl\s+dta-figure"\s+type="1">\s*
			<img\s+src="http://dummy.org/dmmy.jpg"/><br/>\s+\[Abbildung\]\s* 
			<span\s+class="dta-figdesc">HEAD</span><br/>\s*
			<p\s+class="dta-p">caption</p>\s*
		</div>}x );
# head in <lg>
like( process($xsl, 't/xml/head_lg.xml'), qr{		
	  <div>\s*
        <div\s+class="dta-poem">\s*
          <div\s+class="dta-head">DIE[ ]RABEN</div>\s*
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
		</div>\s*
	</div>}x );	
like( process($xsl, 't/xml/head_no_lb.xml'), qr{
	<div>\s*
		HEAD[ ]text\s*
	</div>\s*
	<div>\s*
		HE<br/>AD[ ]text\s*
	</div>
}x );

### <imprimatur>
like( process($xsl, 't/xml/imprimatur.xml'), qr{<span class="dta-imprimatur">content</span>});

### <argument>
like( process($xsl, 't/xml/argument.xml'), qr{<div class="dta-argument">content</div>}); 

### <trailer>
like( process($xsl, 't/xml/trailer.xml'), qr{<p class="dta-p">p</p>\s*<span class="dta-trailer">content</span>});
	
## Elements in Letters

### <dateline>
like( process($xsl, 't/xml/dateline.xml'), qr{<span class="dta-dateline">content</span>});

### <salute>
like( process($xsl, 't/xml/salute.xml'), qr{<div class="dta-salute">content</div>});

### <opener>
like( process($xsl, 't/xml/opener.xml'), qr{<span class="dta-opener">content</span>});

### <closer>
like( process($xsl, 't/xml/closer.xml'), qr{<div class="dta-closer">content</div>}); 

### <signed>
like( process($xsl, 't/xml/signed.xml'), qr{<span class="dta-signed">content</span>});

### <postscript>
like( process($xsl, 't/xml/postscript.xml'), qr{<span class="dta-postscript">content</span>});

## Elements in Dramas

### <castList>
like( process($xsl, 't/xml/castlist.xml'), qr{
	<div\s+class="dta-castlist">\s*         
		<p\s+class="dta-p">Besetzung</p>\s*
	</div>}x );

### <castList/castItem>
like( process($xsl, 't/xml/castlist_castitem.xml'), qr{
	<div\s+class="dta-castlist">\s*         
		<h2\s+class="dta-head">Personen<br/></h2>\s*
		<div\s+class="dta-castitem">\s*
			<span\s+class="dta-role">R1</span>\s*
			<span\s+class="dta-roledesc">R1desc</span>\s*
			<span\s+class="dta-actor">A1</span>\s*
		</div><br/>\s*
	</div><br/>}x );

### <castGroup/castItem>
like( process($xsl, 't/xml/castgroup_castitem.xml'), qr{
	<table\s+class="dta-castgroup">
		<tr>
			<td\s+class="dta-castitem">\s*
				<span\s+class="dta-role">R1a</span>\s*
				<span\s+class="dta-actor">A3a</span>\s*
			</td>\s*
			<td\s+rowspan="2">\s*
				<span\s+class="dta-roledesc">R1Desc</span>\s*
			</td>\s*
		</tr>\s*
		<tr>\s*
			<td\s+class="dta-castitem">\s*
				<span\s+class="dta-role">R1b</span>\s*
				<span\s+class="dta-actor">A3b</span>\s*
			</td>\s*
		</tr>\s*
	</table><br/>}x );
	
### <actor>
like( process($xsl, 't/xml/actor.xml'), qr{<span class="dta-actor">content</span>});

### <speaker>
like( process($xsl, 't/xml/speaker.xml'), qr{<span class="dta-speaker"> content </span>});
	
### <role>
like( process($xsl, 't/xml/role.xml'), qr{<span class="dta-role">content</span>});

### <roleDesc>
like( process($xsl, 't/xml/roledesc.xml'), qr{content});	
	
### <stage>
like( process($xsl, 't/xml/stage.xml'), qr{<div class="dta-stage">content</div>});
		
### <sp>
# sp_p_single
like( process($xsl, 't/xml/sp_p_single.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-p-in-sp">line1</span></p></div>});
# sp_stage_single
like( process($xsl, 't/xml/sp_stage_single.xml'), qr{<div class="dta-sp"><span class="dta-stage">stage1</span></div>});
# sp_stage_before_p
like( process($xsl, 't/xml/sp_stage_before_p.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line1</span></p></div>});
# sp_stage_behind_p
like( process($xsl, 't/xml/sp_stage_behind_p.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-p-in-sp">line1</span> <span class="dta-stage">stage1</span></p></div>});
# sp_stage_embedded
like( process($xsl, 't/xml/sp_stage_embedded.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-p-in-sp">line1</span> <span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line2</span></p></div>});
# sp_stage_embedded2
like( process($xsl, 't/xml/sp_stage_embedded2.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-p-in-sp">line1</span> <span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line2</span><span class="dta-stage">stage2</span></p></div>});
# sp_stage_embedded3
like( process($xsl, 't/xml/sp_stage_embedded3.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line1</span><span class="dta-stage">stage2</span> <span class="dta-p-in-sp">line2</span></p></div>});
# linebreaks
like( process($xsl, 't/xml/sp_stage_p_lb.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line1</span></p><br/><span class="dta-stage">stage2</span><br/><p class="dta-sp-p"><span class="dta-p-in-sp">line2</span></p></div>});
# sp_p_p
like( process($xsl, 't/xml/sp_p_p.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-p-in-sp">line1</span></p><p class="dta-sp-p"><span class="dta-p-in-sp">line2</span></p></div>});		
# sp_stage_p_p_p_stage
like( process($xsl, 't/xml/sp_stage_p_p_p_stage.xml'), qr{<div class="dta-sp"><p class="dta-sp-p"><span class="dta-stage">stage1</span> <span class="dta-p-in-sp">line1</span></p><p class="dta-sp-p"><span class="dta-p-in-sp">line2</span></p><p class="dta-sp-p"><span class="dta-p-in-sp">line3</span> <span class="dta-stage">stage2</span></p></div>});		
		
### <spGrp>
# stage before the speech acts
like( process($xsl, 't/xml/spGrp_stagebefore.xml'), qr{
<table>\s*
	<tr>\s*
		<td\s+style="vertical-align:middle">
			<div\s+class="dta-stage\s+rightBraced">\s*
				<p\s+class="dta-p\s+v">Sprechen\s+gleichzeitig</p>\s*
			</div>
		</td>
		<td\s+class="dta-braced-base\s+dta-braced-left">
			<div\s+class="dta-sp">\s*
				<span\s+class="dta-speaker">\s+S1\s+</span>\s*
				<p\s+class="dta-sp-p">\s*
					<span\s+class="dta-p-in-sp">t1</span>\s*
					<span\s+class="dta-stage">to\s+S2</span>\s*
					<span\s+class="dta-p-in-sp">t2</span>\s*
				</p>\s*
				<br/>\s*
			</div>
			<div\s+class="dta-sp">\s*
				<span\s+class="dta-speaker">\s+S2\s+</span>\s*
				<p\s+class="dta-sp-p">\s*
					<span\s+class="dta-stage">to\s+S3</span>\s*
					<span\s+class="dta-p-in-sp">t3</span>\s*
				</p>\s*
				<br/>\s*
			</div>\s*
			<div\s+class="dta-sp">\s*
				<span\s+class="dta-speaker">\s+S3\s+</span>\s*
				<p\s+class="dta-sp-p">\s*									
					<span\s+class="dta-stage">to\s+S1</span>\s*
					<span\s+class="dta-p-in-sp">t4</span>\s*
				</p>\s*
				<br/>\s*
			</div>\s*
		</td>\s*
	</tr>\s*
</table>\s*
<br/>}x);
# stage after the speech acts
like( process($xsl, 't/xml/spGrp_stageafter.xml'), qr{
	<table><tr><td\s+class="dta-braced-base\s+dta-braced-right"><div\s+class="dta-sp">\s*
			<span\s+class="dta-speaker">\s+S1\s+</span>\s*
			<p\s+class="dta-sp-p">\s*
				<span\s+class="dta-p-in-sp">t1</span>\s*
			</p>\s*
		</div><div\s+class="dta-sp">\s*
			<span\s+class="dta-speaker">\s+S2\s+</span>\s*
			<p\s+class="dta-sp-p">\s*
				<span\s+class="dta-p-in-sp">t2</span>\s*
			</p>\s*
		</div></td><td\s+style="vertical-align:middle"><div\s+class="dta-stage\s+leftBraced">gleichzeitig</div></td></tr></table>\s*
	<br/>}x);
	
## Elements in Poems	

### <l>
# simple
like( process($xsl, 't/xml/l.xml'), qr{<span class="dta-l">V</span>});
# @rendition contains _#c_, _#et_ or _#right_
like( process($xsl, 't/xml/l2.xml'), qr{<div class="dta-l et"><span>V</span></div>});

### <lg>
# simple
like( process($xsl, 't/xml/lg.xml'), qr{
	<div\s+class="dta-lg">\s*
		<span\s+class="dta-l">V1</span><br/>\s*
		<span\s+class="dta-l">V2</span><br/>\s*
	</div>}x );
# @type="poem"
like( process($xsl, 't/xml/lg2.xml'), qr{
	<div\s+class="dta-poem">\s*
		<span\s+class="dta-l">V1</span><br/>\s*
		<span\s+class="dta-l">V2</span><br/>\s*
	</div>}x);

## Elements concerning Citations

### <cit>
like( process($xsl, 't/xml/cit.xml'), qr{<span data-id="id" data-prev="prev-id" data-next="next-id" class="dta-cit">content</span>});

### <bibl>
like( process($xsl, 't/xml/bibl.xml'), qr{<span class="dta-bibl">content</span>}); 

### <listBibl>
like( process($xsl, 't/xml/listbibl.xml'), qr{
	<div\s+class="dta-list-bibl">\s*
		<span\s+class="dta-bibl">bibl1</span>\s* 
		<span\s+class="dta-bibl">bibl2</span>\s*
	</div>}x);

### <epigraph>
like( process($xsl, 't/xml/epigraph.xml'), qr{<blockquote class="dta-quote">content</blockquote>});

## Elements concerning Notes

### <note>
# footnote
like( process($xsl, 't/xml/note_foot.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="dta-fn-intext">\(a\)</span>[ ]text2</p>\s*
		<p\s+class="dta-p">text3<span\s+class="dta-fn-intext">\(b\)</span>[ ]text4</p>\s*
		<p\s+class="dta-p">text5<span\s+class="dta-fn-intext">\(c\)</span>[ ]text6</p>\s*	
	<div\s+class="dta-footnotesep"/><div\s+class="dta-footnote"><span\s+class="dta-fn-sign">\(a\)</span>[ ]footnotea</div><div\s+class="dta-footnote"><span\s+class="dta-fn-sign">\(b\)</span>[ ]footnoteb</div><div\s+class="dta-footnote">[ ]footnotebCont</div><div\s+class="dta-footnote"><span\s+class="dta-fn-sign">\(c\)</span>[ ]footnotec</div>}x);
	
# endnote
like( process($xsl, 't/xml/note_end.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="dta-fn-sign">\(a\)</span>text2</p>\s*
	<p\s+class="dta-p">text3<span\s+class="dta-fn-sign">\(b\)</span>text4</p>\s*
	<div\s+class="dta-endnote\s+dta-endnote-indent"><span\s+class="dta-fn-sign">\(a\)</span>[ ]endnotea</div>\s*
	<div\s+class="dta-endnote">endnotebendnotebCont</div>}x);	

# marginals
like( process($xsl, 't/xml/note_marginals.xml'), qr{	
	<p\s+class="dta-p">text1<span\s+class="dta-marginal[ ]dta-marginal-left">marginalLeft</span>text2</p>\s*
	<p\s+class="dta-p">text3<span\s+class="dta-marginal[ ]dta-marginal-right">marginalRight</span>text4</p>}x);		

## Floats
# These elements interrupt the running text.
	
### <floatingText>
like( process($xsl, 't/xml/floatingtext.xml'), qr{<div class="dta-floatingtext">content</div>});
	
### <list>
like( process($xsl, 't/xml/list_simple.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">t1a<br/>t1b</div>\s*
		<div\s+class="dta-list-item">t2</div>\s*
	</div>}x);
like( process($xsl, 't/xml/list_leftbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">gemeinsamer[ ]Textbaustein[ ]vorn\s*
			<span\s+class="dta-braced-base[ ]dta-braced-left">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
			</span>\s*
		</div>\s*
	</div>}x);
like( process($xsl, 't/xml/list_rightbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">\s*
			<span\s+class="dta-braced-base[ ]dta-braced-right">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div>\s*
			</span>\s*
			gemeinsamer[ ]Textbaustein[ ]hinten</div><br/>\s*
	</div>}x);
like( process($xsl, 't/xml/list_leftrightbraced.xml'), qr{	
	<div\s+class="dta-list">\s*
		<div\s+class="dta-list-item">gemeinsamer[ ]Textbaustein[ ]vorn\s*
			<span\s+class="dta-braced-base[ ]dta-braced-left-right">\s*
				<div\s+class="dta-list-item">Element[ ]1[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]2[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
				<div\s+class="dta-list-item">Element[ ]n[ ]der[ ]geklammerten[ ]Liste</div><br/>\s*
			</span>\s*
			gemeinsamer[ ]Textbaustein[ ]hinten\s*
		</div>\s*
	</div>}x);

### <item>
like( process($xsl, 't/xml/item_simple_p_pb.xml'), qr{		
	<div\s+class="dta-list-item">i1</div><br/>\s*
	<p\s+class="dta-p"><span\s+class="dta-list-item">i2</span></p><br/>\s*
	<div\s+class="dta-list-item-noindent">i3ai3b</div><br/>}x);		

### <table>
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

### <fw>
# @place="top" (@type="header")
like( process($xsl, 't/xml/fw_top.xml'), qr{<p class="dta-p"><div class="dta-fw-top dta-fw-header">content</div></p>});
# @place="bottom" and @type="sig"
like( process($xsl, 't/xml/fw_bottom_sig.xml'), qr{<p class="dta-p"/>\s*<div class="dta-fw-bottom-sig">content</div>});
# @place="bottom" and @type="catch"
like( process($xsl, 't/xml/fw_bottom_catch.xml'), qr{<p class="dta-p"/>\s*<div class="dta-fw-bottom-catch">content</div>});
# @place="bottom" and @type="pageNum"
like( process($xsl, 't/xml/fw_bottom_pagenum.xml'), qr{<p class="dta-p"/>});

	
### <figure>
# simple
like( process($xsl, 't/xml/figure_simple.xml'), qr{<div class="dta-phbl dta-figure" type="1"> \[Abbildung\] </div>});
# @rendition="#c"
like( process($xsl, 't/xml/figure_center.xml'), qr{<div class="dta-phbl dta-figure" type="1" style="text-align:center"> \[Abbildung\] </div>});
# @type="notatedMusic"
like( process($xsl, 't/xml/figure_music.xml'), qr{<div class="dta-phbl dta-figure" type="1"> \[Musik\] </div>});
# @facs
like( process($xsl, 't/xml/figure_facs.xml'), qr{<div class="dta-phbl dta-figure" type="1"><img src="3"/><br/> \[Abbildung\] </div>});
# figure/figDesc
like( process($xsl, 't/xml/figure_figdesc.xml'), qr{<div class="dta-phbl dta-figure" type="1"> \[Abbildung content\] </div>});
# div vs. span: <figure/><lb/><figure/><figure/><lb/><figure/><lb/><figure/>
like( process($xsl, 't/xml/figure_div_span.xml'), qr{
	<div\s+class="dta-phbl[ ]dta-figure"\s+type="1">[ ]\[Abbildung\][ ]</div><br/>\s*
	<span\s+class="dta-ph[ ]dta-figure"\s+type="2">[ ]\[Abbildung\][ ]</span>\s*
	<span\s+class="dta-ph[ ]dta-figure"\s+type="3">[ ]\[Abbildung\][ ]</span><br/>\s*
	<div\s+class="dta-phbl[ ]dta-figure"\s+type="4">[ ]\[Abbildung\][ ]</div><br/>\s*
	<div\s+class="dta-phbl[ ]dta-figure"\s+type="5">[ ]\[Abbildung\][ ]</div>}x); 
	
#--- Phrase Structure Elements	
	
### <hi> 
# @rendition and not(@rend)
like( process($xsl, 't/xml/hi.xml'), qr{<p class="dta-p"><span class="aq b blue">content</span></p>});
# @rend
like( process($xsl, 't/xml/hi_rend.xml'), qr{<p class="dta-p"><span title="quer" class="dta-rend">content</span></p>});
# @rend and @rendition
like( process($xsl, 't/xml/hi_rend_rendition.xml'), qr{<p class="dta-p"><span title="quer" class="dta-rend aq b blue">content</span></p>});	
	
### <formula>
like( process($xsl, 't/xml/formula.xml'), qr{<span class="dta-ph dta-formula-1" onclick="editFormula\(1\)" style="cursor:pointer"> \[Formel 1\] </span>} );
like( process($xsl, 't/xml/formula_tex.xml'), qr{<span class="dta-formula"><img style="vertical-align:middle; -moz-transform:scale\(0.7\); -webkit-transform:scale\(0.7\); transform:scale\(0.7\)" src="http://dinglr.de/formula/%5Cfrac%7B1%7D%7B2%7D"/></span>} );
like( process($xsl, 't/xml/formula_utf8.xml'), qr{<span class="dta-formula"><img style="vertical-align:middle; -moz-transform:scale\(0.7\); -webkit-transform:scale\(0.7\); transform:scale\(0.7\)" src="http://dinglr.de/formula/%FC%20%2B%20%3F"/></span>});

### <foreign>
# no content, @xml:lang="he"
like( process($xsl, 't/xml/foreign_no_content_he.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material" xml:lang="he">FM: hebräisch</span></p>});
# no content, @xml:lang="zh"
like( process($xsl, 't/xml/foreign_no_content_zh.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material" xml:lang="zh">FM: zh</span></p>});
# no content, not(@xml:lang)
like( process($xsl, 't/xml/foreign_no_content_no_lang.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material"/></p>});
# content, @xml:lang="he"
like( process($xsl, 't/xml/foreign_content_he.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material" xml:lang="he">content</span></p>});
# content, @xml:lang="zh"
like( process($xsl, 't/xml/foreign_content_zh.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material" xml:lang="zh">content</span></p>});
# content, not(@xml:lang)
like( process($xsl, 't/xml/foreign_content_no_lang.xml'), qr{<p class="dta-p"><span class="dta-foreign" title="fremdsprachliches Material">content</span></p>});

### <q>
like( process($xsl, 't/xml/q.xml'), qr{<q class="dta-quote">content</q>});

### <quote>
like( process($xsl, 't/xml/quote.xml'), qr{<q class="dta-quote">content</q>});

### <ref>
like( process($xsl, 't/xml/ref.xml'), qr{<p class="dta-p"><span class="dta-ref" data-target="#f0001">ref</span></p>});

### <date>
like( process($xsl, 't/xml/date.xml'), qr{<span class="dta-date">content</span>});

## Elements concerning Names
	
### <name>
like( process($xsl, 't/xml/name.xml'), qr{<span class="dta-name">content</span>});

### <orgName>
like( process($xsl, 't/xml/orgname.xml'), qr{<span class="dta-orgname">content</span>});

### <persName>
like( process($xsl, 't/xml/persname.xml'), qr{<span class="dta-persname">content</span>});

### <placeName>
like( process($xsl, 't/xml/placename.xml'), qr{<span class="dta-placename">content</span>});

#--- Other Structure Elements

## Editorial Elements

### <supplied>	
like( process($xsl, 't/xml/supplied.xml'), qr{<p class="dta-p">te<span class="dta-supplied">\[x\]</span>t</p>});

### <gap>
# lost_page		
like( process($xsl, 't/xml/gap_lost_page.xml'), qr{<span class="dta-gap">\[verlorenes Material &#x2013; 1 Seite fehlt\]</span>});
# fm_insignificant_pages		
like( process($xsl, 't/xml/gap_fm_insignificant_pages.xml'), qr{<span class="dta-gap">\[irrelevantes fremdsprachliches Material &#x2013; 2 Seiten fehlen\]</span>});
# illegible_insignificant_lost_line	
like( process($xsl, 't/xml/gap_illegible_insignificant_lost_line.xml'), qr{<span class="dta-gap">\[verlorenes irrelevantes unleserliches Material &#x2013; 1 Zeile fehlt\]</span>});
# fm_lines	
like( process($xsl, 't/xml/gap_fm_lines.xml'), qr{<span class="dta-gap">\[fremdsprachliches Material &#x2013; 2 Zeilen fehlen\]</span>});
# illegible_word
like( process($xsl, 't/xml/gap_illegible_word.xml'), qr{<span class="dta-gap">\[unleserliches Material &#x2013; 1 Wort fehlt\]</span>});
# fm_words
like( process($xsl, 't/xml/gap_fm_words.xml'), qr{<span class="dta-gap">\[fremdsprachliches Material &#x2013; 2 Wörter fehlen\]</span>});
# fm_char
like( process($xsl, 't/xml/gap_fm_char.xml'), qr{<span class="dta-gap">\[fremdsprachliches Material &#x2013; 1 Zeichen fehlt\]</span>});
# char
like( process($xsl, 't/xml/gap_char.xml'), qr{<span class="dta-gap">\[1 Zeichen fehlt\]</span>});
# fm
like( process($xsl, 't/xml/gap_fm.xml'), qr{<span class="dta-gap">\[fremdsprachliches Material\]</span>});
# word
like( process($xsl, 't/xml/gap_word.xml'), qr{<span class="dta-gap">\[Wort fehlt\]</span>});	
	
### <choice>
# reg and orig
like( process($xsl, 't/xml/choice_reg.xml'), qr{<p class="dta-p"><span title="Original: orig" class="dta-reg">reg</span></p>});
# abbr and expand
like( process($xsl, 't/xml/choice_abbr.xml'), qr{<p class="dta-p"><span title="expan" class="dta-abbr">abbr</span></p>});
# corr and sic
like( process($xsl, 't/xml/choice_corr.xml'), qr{<p class="dta-p"><span title="Schreibfehler: sic" class="dta-corr">corr</span></p>});
#corr(empty) and sic
like( process($xsl, 't/xml/choice_corr_empty.xml'), qr{<p class="dta-p"><span title="Schreibfehler: sic" class="dta-corr">\[\&\#x2026;\]</span></p>});
	











