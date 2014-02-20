<?xml version="1.0" encoding="utf-8"?>

<!--perhaps a PROBLEM: xpath-default-namespace is an XSLT 2.0 feature -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:dta="urn:dta" exclude-result-prefixes="dta tei"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <xsl:include href="uri-encode.xsl"/>
  <xsl:output method="xml" cdata-section-elements="script style" indent="no" encoding="utf-8"/>

  <xsl:template match="tei:teiHeader"/>



  <xsl:template match="tei:text[not(descendant::tei:text)]">
    <xsl:apply-templates/>
    <xsl:if test='//tei:note[@place="foot"]'>
      <div class="footnotesep"/>
      <xsl:apply-templates select='//tei:note[@place="foot"]' mode="footnotes"/>
    </xsl:if>
    <xsl:apply-templates select='//tei:fw[@place="bottom"]' mode="signatures"/>
  </xsl:template>


  <!-- TODO: implement class=dta-back -->
  <xsl:template match="tei:back">
    <xsl:element name="div">
      <xsl:attribute name="class">dta-back</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- <xsl:template match="tei:body"/>  -->

  <xsl:template match="tei:cb">
    <span class="dta-cb">
      <xsl:choose>
        <xsl:when test="@type='start'">[Beginn Spaltensatz]</xsl:when>
        <xsl:when test="@type='end'">[Ende Spaltensatz]</xsl:when>
        <xsl:otherwise>[Spaltenumbruch]</xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <!-- column breaks, EXPERIMENTAL -->
  <!--
<img src="static/images/cb.png" alt="Spaltenumbruch" title="Spaltenumbruch" /></xsl:template>
<xsl:template match='tei:cb'>
  <xsl:if test='.. = (//tei:cb)[1]/.. and .. = (//tei:cb)[last()]/..'>
    <xsl:choose>
      <xsl:when test='count( (//tei:cb)[1] | . ) = 1'>
        <xsl:text disable-output-escaping="yes">
          &lt;table class="dta-columntext"&gt;
            &lt;tr&gt;
              &lt;td&gt;
        </xsl:text>
      </xsl:when>
      <xsl:when test='@type="end"'>
        <xsl:text disable-output-escaping="yes">
              &lt;/td&gt;
            &lt;/tr&gt;
          &lt;/table&gt;
        </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text disable-output-escaping="yes">
          &lt;/td&gt;
          &lt;td style="border-left:1px solid #666"&gt;
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template name="close-cb">
  <xsl:if test='tei:cb and (not(tei:cb[last()][@type]) or tei:cb[last()][@type!="end"]) and (//tei:cb)[1]/.. = (//tei:cb)[last()]/..'>
    <xsl:text disable-output-escaping="yes">
          &lt;/td&gt;
        &lt;/tr&gt;
      &lt;/table&gt;
    </xsl:text>
  </xsl:if>
</xsl:template>
-->
  <!-- end column breaks -->

  <!-- TODO: just a DUMMY, implement! -->
  <xsl:template match="tei:cell">
    <xsl:element name="th">
      <xsl:attribute name="class">dta-cell</xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:choice">
    <xsl:choose>
      <xsl:when test="./tei:reg">
        <xsl:element name="span">
          <xsl:attribute name="title">Original: <xsl:value-of select="tei:orig"/></xsl:attribute>
          <xsl:attribute name="class">dta-reg</xsl:attribute>
          <xsl:apply-templates select="tei:reg"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="./tei:abbr">
        <xsl:element name="span">
          <xsl:attribute name="title">
            <xsl:value-of select="tei:expan"/>
          </xsl:attribute>
          <xsl:attribute name="class">dta-abbr</xsl:attribute>
          <xsl:apply-templates select="tei:abbr"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span">
          <xsl:attribute name="title">Schreibfehler: <xsl:value-of select="tei:sic"
            /></xsl:attribute>
          <xsl:attribute name="class">dta-corr</xsl:attribute>
          <xsl:apply-templates select="tei:corr"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:corr">
    <xsl:choose>
      <xsl:when test="not(string(.))">
        <xsl:text>[&#8230;]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='tei:fw[@place="top"]'>
    <div>
      <xsl:attribute name="class">fw-top fw-<xsl:value-of select="@type"/></xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match='tei:fw[@place="bottom"]' mode="signatures">
    <xsl:if test="not(@type='page number')">
      <xsl:element name="div">
        <xsl:attribute name="class">
          <xsl:choose>
            <xsl:when test='@type="sig"'> fw-bottom-sig </xsl:when>
            <xsl:when test='@type="catch"'> fw-bottom-catch </xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <xsl:template match='tei:fw[@place="bottom"]'/>

  <xsl:template match='tei:fw[@type="page number"]'/>

  <xsl:template match="tei:milestone">
    <xsl:if
      test="contains(@rendition, '#hrRed') or contains(@rendition, '#hrBlue') or contains(@rendition, '#hr')">
      <xsl:element name="hr">
        <xsl:choose>
          <xsl:when test="contains(@rendition, '#red') or contains(@rendition, '#hrRed')">
            <xsl:attribute name="class">red</xsl:attribute>
          </xsl:when>
          <xsl:when test="contains(@rendition, '#blue') or contains(@rendition, '#hrBlue')">
            <xsl:attribute name="class">blue</xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <!-- place holders -->
  <xsl:template match="tei:formula">
    <xsl:choose>
      <xsl:when test="@notation='TeX'">
        <xsl:element name="span">
          <xsl:attribute name="class">formula</xsl:attribute>
          <xsl:if test="@rendition='#c'">
            <xsl:attribute name="style">display:block; text-align:center</xsl:attribute>
          </xsl:if>
          <xsl:element name="img">
            <xsl:attribute name="style">vertical-align:middle; -moz-transform:scale(0.7);
              -webkit-transform:scale(0.7); transform:scale(0.7)</xsl:attribute>
            <!--          <xsl:choose>
            <xsl:when test="@rendition">
              <xsl:call-template name="applyRendition"/>
              <xsl:attribute name="src">
                <xsl:text>http://dinglr.de/formula/</xsl:text><xsl:value-of select="dta:urlencode(.)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>-->
            <xsl:attribute name="src">
              <xsl:text>http://dinglr.de/formula/</xsl:text>
              <xsl:call-template name="url-encode">
                <xsl:with-param name="str" select="string(.)"/>
              </xsl:call-template>
              <!-- <xsl:value-of select="custom:uriencode(string(.))"/>   -->
            </xsl:attribute>
            <!--            </xsl:otherwise>
          </xsl:choose>-->
          </xsl:element>
        </xsl:element>
      </xsl:when>
      <xsl:when test="string-length(.) &gt; 0">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span">
          <xsl:attribute name="class">ph formula-<xsl:value-of
              select="count(preceding::tei:formula)+1"/></xsl:attribute>
          <xsl:attribute name="onclick">editFormula(<xsl:value-of
              select="count(preceding::tei:formula)+1"/>)</xsl:attribute>
          <xsl:attribute name="style">cursor:pointer</xsl:attribute> [Formel <xsl:value-of
            select="count(preceding::tei:formula)+1"/>] </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='tei:g[@ref="#frac"]'>
    <xsl:variable name="enumerator" select="substring-before(., '/')"/>
    <xsl:variable name="denominator" select="substring-after(., '/')"/>
    <xsl:variable name="fraction" select="concat('\frac{', $enumerator, '}{', $denominator, '}')"/>
    <xsl:element name="img">
      <xsl:attribute name="style">vertical-align:middle; -moz-transform:scale(0.7);
        -webkit-transform:scale(0.7); transform:scale(0.7)</xsl:attribute>
      <xsl:attribute name="src">
        <!--<xsl:text>http://dinglr.de/formula/</xsl:text><xsl:value-of select="dta:urlencode($fraction)"/>-->
        <xsl:text>http://kaskade.dwds.de/dtaq/formula/preview/</xsl:text>
        <xsl:call-template name="url-encode">
          <xsl:with-param name="str" select="$fraction"/>
        </xsl:call-template>
        <!--
        <xsl:value-of select="custom:uriencode(string($fraction))"/>
         -->
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match='tei:g[@ref="#fric"]'>
    <xsl:variable name="enumerator" select="substring-before(., '/')"/>
    <xsl:variable name="denominator" select="substring-after(., '/')"/>
    <xsl:variable name="fraction"
      select="concat('\nicefrac{', $enumerator, '}{', $denominator, '}')"/>
    <xsl:element name="img">
      <xsl:attribute name="style">vertical-align:middle; -moz-transform:scale(0.7);
        -webkit-transform:scale(0.7); transform:scale(0.7)</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:text>http://dinglr.de/formula/</xsl:text>
        <xsl:call-template name="url-encode">
          <xsl:with-param name="str" select="$fraction"/>
        </xsl:call-template>
        <!-- 
        <xsl:value-of select="custom:uriencode(string($fraction))"/>
         -->
      </xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:figure">
    <xsl:choose>
      <xsl:when
        test="(local-name(preceding-sibling::node()[1]) = 'lb' and local-name(following-sibling::node()[1]) = 'lb') or @rendition='#c'">
        <xsl:element name="div">
          <xsl:attribute name="class">phbl dta-figure</xsl:attribute>
          <xsl:attribute name="type"><xsl:value-of select="count(preceding::tei:figure)+1"
            /></xsl:attribute>
          <xsl:if test="@rendition='#c'">
            <xsl:attribute name="style">text-align:center</xsl:attribute>
          </xsl:if>
          <xsl:if test="@facs">
            <xsl:element name="img">
              <xsl:attribute name="src"><xsl:value-of select="@facs"/></xsl:attribute>
            </xsl:element><br/>
          </xsl:if> [<xsl:choose>
            <xsl:when test="@type='notatedMusic'">Musik</xsl:when>
            <xsl:otherwise>Abbildung</xsl:otherwise>
          </xsl:choose>
          <xsl:if test="tei:figDesc"><xsl:text> </xsl:text><xsl:apply-templates select="tei:figDesc"
              mode="figdesc"/></xsl:if>] <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span">
          <xsl:attribute name="class">ph dta-figure</xsl:attribute>
          <xsl:attribute name="type"><xsl:value-of select="count(preceding::tei:figure)+1"
            /></xsl:attribute>
          <xsl:if test="@facs">
            <xsl:element name="img">
              <xsl:attribute name="src"><xsl:value-of select="@facs"/></xsl:attribute>
            </xsl:element><br/>
          </xsl:if> [<xsl:choose>
            <xsl:when test="@type='notatedMusic'">Musik</xsl:when>
            <xsl:otherwise>Abbildung</xsl:otherwise>
          </xsl:choose>
          <xsl:if test="tei:figDesc"><xsl:text> </xsl:text><xsl:apply-templates select="tei:figDesc"
              mode="figdesc"/></xsl:if>] <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:figDesc"/>
  <xsl:template match="tei:figDesc" mode="figdesc">
    <xsl:apply-templates/>
  </xsl:template>
  <!-- end place holders -->

  <!-- editorial notes -->
  <xsl:template match='tei:note[@type="editorial"]'/>

  <!-- footnotes -->
  <xsl:template match='tei:note[@place="foot"]'>
    <xsl:if test="string-length(@prev)=0">
      <span class="fn-intext">
        <xsl:value-of select="@n"/>
      </span>
      <!--
      <xsl:text> </xsl:text> warum?
    -->
    </xsl:if>
  </xsl:template>

  <xsl:template match='tei:note[@place="foot"]' mode="footnotes">
    <div class="footnote">
      <xsl:choose>
        <xsl:when test="string-length(@prev)!=0 or string-length(@sameAs)!=0"/>
        <xsl:otherwise>
          <span class="fn-sign">
            <xsl:value-of select="@n"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
      <!--<span class="fn-sign"><xsl:value-of select='@n'/></span>-->
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:apply-templates select='tei:fw[@place="bottom"][@type="catch"]' mode="signatures"/>
    </div>
  </xsl:template>
  <!-- end footnotes -->

  <!-- end notes -->

  <xsl:template match='tei:note[@place="end"]'>
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; 0">
        <xsl:choose>
          <xsl:when test="local-name(*[1])!='pb'">
            <div class="endnote endnote-indent">
              <span class="fn-sign">
                <xsl:value-of select="@n"/>
              </span>
              <xsl:text> </xsl:text>
              <xsl:apply-templates/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <div class="endnote">
              <xsl:apply-templates/>
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <span class="fn-sign">
          <xsl:value-of select="@n"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- end end notes -->

  <!-- marginals -->
  <xsl:template match='tei:note[@place="right" and not(@type)]'>
    <xsl:value-of select="@n"/>
    <span class="dta-marginal dta-marginal-right">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match='tei:note[@place="left" and not(@type)]'>
    <xsl:value-of select="@n"/>
    <span class="dta-marginal dta-marginal-left">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  <!-- end marginals -->

  <xsl:template match="tei:gap">
    <span class="gap">
      <xsl:text>[</xsl:text>
      <xsl:if test="@reason='lost'">verlorenes Material</xsl:if>
      <xsl:if test="@reason='insignificant'">irrelevantes Material</xsl:if>
      <xsl:if test="@reason='fm'">fremdsprachliches Material</xsl:if>
      <xsl:if test="@reason='illegible'">unleserliches Material</xsl:if>
      <xsl:if test="@unit">
        <xsl:text> – </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@unit">
          <xsl:if test="@quantity">
            <xsl:value-of select="@quantity"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@unit='pages' and @quantity!=1">Seiten</xsl:when>
            <xsl:when test="@unit='pages' and @quantity=1">Seite</xsl:when>
            <xsl:when test="@unit='lines' and @quantity!=1">Zeilen</xsl:when>
            <xsl:when test="@unit='lines' and @quantity=1">Zeile</xsl:when>
            <xsl:when test="@unit='words' and @quantity!=1">Wörter</xsl:when>
            <xsl:when test="@unit='words' and @quantity=1">Wort</xsl:when>
            <xsl:when test="@unit='chars'">Zeichen</xsl:when>
          </xsl:choose>
          <xsl:text> fehl</xsl:text>
          <xsl:if test="@quantity=1 or not(@quantity)">t</xsl:if>
          <xsl:if test="@quantity!=1">en</xsl:if>
        </xsl:when>
        <!--      <xsl:otherwise>
        <xsl:text> ...</xsl:text>
      </xsl:otherwise>-->
      </xsl:choose>
      <xsl:text>]</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:titlePage">
    <div class="titlepage">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:titlePart">
    <xsl:element name="div">
      <xsl:attribute name="class">titlepart titlepart-<xsl:value-of select="@type"/></xsl:attribute>
      <!--    <xsl:element name="div">
      <xsl:call-template name="applyRendition"/>-->
      <xsl:apply-templates/>
      <!--    </xsl:element>-->
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:docImprint">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:docAuthor">
    <span>
      <xsl:call-template name="applyRendition">
        <xsl:with-param name="class" select="'docauthor'"/> 
      </xsl:call-template>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:docDate">
    <!--  <xsl:call-template name="applyRendition"/>-->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:byline">
    <div>
      <xsl:call-template name="applyRendition">
        <xsl:with-param name="class" select="'byline'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:publisher">
    <xsl:element name="span">
      <xsl:attribute name="class">dta-publisher <xsl:choose>
          <xsl:when test="@rendition=''"/>
          <xsl:when test="contains(normalize-space(@rendition),' ')">
            <xsl:call-template name="splitRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(@rendition)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="findRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="@rendition"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:head">
    <xsl:choose>
      <xsl:when test="ancestor::tei:figure">
        <span class="figdesc">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="ancestor::tei:list or parent::tei:lg">
        <div class="dta-head">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when
        test="local-name(./*[position()=last()]) != 'lb' and local-name(following::*[1]) != 'lb'">
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="parent::tei:div/@n or parent::tei:div">
            <xsl:choose>
              <xsl:when test="parent::tei:div/@n > 6 or not(@n)">
                <div class="dta-head">
                  <xsl:apply-templates/>
                </div>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text disable-output-escaping="yes">&lt;h</xsl:text>
                <xsl:value-of select="parent::tei:div/@n"/>
                <xsl:text disable-output-escaping="yes"> class="dta-head"&gt;</xsl:text>
                <xsl:apply-templates/>
                <xsl:text disable-output-escaping="yes">&lt;/h</xsl:text>
                <xsl:value-of select="parent::tei:div/@n"/>
                <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="parent::tei:list">
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <h2>
              <xsl:apply-templates/>
            </h2>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- dramas -->
  <xsl:template match="tei:castList">
    <div class="castlist">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:castGroup">
    <table class="dta-castgroup">
      <xsl:for-each select="tei:castItem">
        <tr>
          <td class="castitem">
            <xsl:apply-templates select="tei:role"/>
          </td>
          <xsl:if test="position()=1">
            <xsl:element name="td">
              <xsl:attribute name="class">roledesc</xsl:attribute>
              <xsl:attribute name="rowspan">
                <xsl:value-of select="count(../tei:castItem)"/>
              </xsl:attribute>
              <xsl:apply-templates select="../tei:roleDesc"/>
            </xsl:element>
          </xsl:if>
          <xsl:if test="tei:actor">
            <td class="dta-actor">
              <xsl:apply-templates select="tei:actor"/>
            </td>
          </xsl:if>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <xsl:template match="tei:actor">
    <span class="dta-actor">
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:castItem[not(parent::tei:castGroup)]">
    <div class="castitem">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:castList/tei:head">
    <h2 class="head">
      <xsl:apply-templates/>
    </h2>
  </xsl:template>

  <xsl:template match="tei:role">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:speaker">
    <span class="speaker">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:stage">
    <xsl:choose>
      <xsl:when test="ancestor::tei:sp">
        <span class="stage">
          <xsl:text> </xsl:text>
          <xsl:apply-templates/>
          <xsl:text> </xsl:text>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <div class="stage">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- end dramas -->

  <!-- poems -->
  <xsl:template match='tei:lg[@type="poem"]/tei:head'>
    <div class="head">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match='tei:lg[@type="poem"]'>
    <div class="poem">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match='tei:lg[not(@type="poem")]'>
    <div class="dta-lg">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- end poems -->

  <!-- letters -->
  <xsl:template match="tei:salute">
    <xsl:element name="div">
      <xsl:attribute name="class">dta-salute <xsl:choose>
          <xsl:when test="@rendition=''"/>
          <xsl:when test="contains(normalize-space(@rendition),' ')">
            <xsl:call-template name="splitRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(@rendition)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="findRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="@rendition"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:dateline">
    <span>
      <xsl:call-template name="applyRendition">
        <xsl:with-param name="class" select="'dta-dateline'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:closer">
    <div>
      <xsl:call-template name="applyRendition">
        <xsl:with-param name="class" select="'dta-closer'"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  <!-- end letters -->

  <xsl:template match="tei:div">
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="@type='advertisment' or @type='advertisement'">
          <div class="dta-anzeige">
            <xsl:apply-templates/>
          </div>
        </xsl:when>
        <xsl:when test="@type">
          <xsl:attribute name="class">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <!-- assign no class if no type-attribute is given -->
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <!--  <xsl:call-template name="close-cb"/>-->
  </xsl:template>

  <xsl:template match="tei:sp">
    <div class="dta-sp">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:p">
    <xsl:choose>
      <xsl:when test="ancestor::tei:sp and name(preceding-sibling::*[2]) != 'p'">
        <span class="dta-in-sp">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when
        test="ancestor::tei:sp and local-name(preceding-sibling::node()[1]) != 'lb' and local-name(preceding-sibling::node()[1]) != 'pb'">
        <span class="dta-in-sp">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="ancestor::tei:sp and local-name(preceding-sibling::node()[1]) = 'lb'">
        <p class="dta-p-in-sp-really">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="descendant::tei:pb">
        <p>
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="@rendition">
        <p>
          <xsl:call-template name="applyRendition"/>
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:when test="@prev">
        <p class="dta-no-indent">
          <xsl:apply-templates/>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <p class="dta-p">
          <xsl:apply-templates/>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:argument">
    <div class="dta-argument">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="tei:l">
    <xsl:element name="div">
      <xsl:attribute name="class"> dta-l <xsl:choose>
          <xsl:when test="@rendition=''"/>
          <xsl:when test="contains(normalize-space(@rendition),' ')">
            <xsl:call-template name="splitRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(@rendition)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="findRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="@rendition"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:lb">
    <xsl:if test="@n">
      <span class="dta-lb-n">
        <xsl:apply-templates select="@n"/>
      </span>
    </xsl:if>
    <br/>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:pb"/>

  <xsl:template match="tei:floatingText">
    <xsl:element name="div">
      <xsl:attribute name="class"> dta-floatingtext <xsl:choose>
          <xsl:when test="@rendition=''"/>
          <xsl:when test="contains(normalize-space(@rendition),' ')">
            <xsl:call-template name="splitRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(@rendition)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="findRendition">
              <xsl:with-param name="value">
                <xsl:value-of select="@rendition"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- renditions -->
  <xsl:template match="tei:hi">
    <xsl:element name="span">
      <xsl:if test="@rendition">
        <xsl:call-template name="applyRendition"/>
      </xsl:if>
      <xsl:if test="@rend">
        <xsl:attribute name="class">dta-rend</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="applyRendition">
    <xsl:param name="class" select="'noClass'"/>
    <xsl:attribute name="class">
      <xsl:choose>
        <xsl:when test="$class = 'noClass'"/>
        <xsl:otherwise>
          <xsl:value-of select="$class"/>
          <xsl:if test="@rendition">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@rendition and contains(normalize-space(@rendition),' ')">
          <xsl:call-template name="splitRendition">
            <xsl:with-param name="value">
              <xsl:value-of select="normalize-space(@rendition)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="@rendition">
          <xsl:call-template name="findRendition">
            <xsl:with-param name="value">
              <xsl:value-of select="@rendition"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="splitRendition">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="$value=''"/>
      <xsl:when test="contains($value,' ')">
        <xsl:call-template name="findRendition">
          <xsl:with-param name="value">
            <xsl:value-of select="substring-before($value,' ')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text> </xsl:text>
        <xsl:call-template name="splitRendition">
          <xsl:with-param name="value">
            <xsl:value-of select="substring-after($value,' ')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="findRendition">
          <xsl:with-param name="value">
            <xsl:value-of select="$value"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="findRendition">
    <xsl:param name="value"/>
    <xsl:choose>
      <xsl:when test="starts-with($value,'#')">
        <xsl:value-of select="substring-after($value,'#')"/>
      </xsl:when>
      <!-- 
      <xsl:otherwise>
        <xsl:for-each select="document($value)">
          <xsl:apply-templates select="@xml:id"/>
          <xsl:text> </xsl:text>
        </xsl:for-each>
      </xsl:otherwise>
       -->
    </xsl:choose>
  </xsl:template>

  <!-- end renditions -->

  <xsl:template match="tei:cit">
    <span class="dta-cit">
      <xsl:if test="@xml:id">
        <xsl:attribute name="data-id">
          <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@prev">
        <xsl:attribute name="data-prev">
          <xsl:value-of select="@prev"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@next">
        <xsl:attribute name="data-next">
          <xsl:value-of select="@next"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="applyRendition"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:epigraph">
    <blockquote class="quote">
      <xsl:apply-templates/>
    </blockquote>
  </xsl:template>

  <xsl:template match="tei:quote">
    <q class="quote">
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <xsl:template match="tei:q">
    <q class="quote">
      <xsl:apply-templates/>
    </q>
  </xsl:template>

  <xsl:template match="tei:list">
    <xsl:choose>
      <xsl:when test='@rend="braced"'>
        <table class="list">
          <xsl:choose>
            <xsl:when test="tei:trailer">
              <xsl:for-each select="tei:item">
                <tr>
                  <td class="item-left">
                    <xsl:apply-templates/>
                  </td>
                  <xsl:if test="position()=1">
                    <xsl:element name="td">
                      <xsl:attribute name="class">dta-list-trailer</xsl:attribute>
                      <xsl:attribute name="rowspan">
                        <xsl:value-of select="count(../tei:item)"/>
                      </xsl:attribute>
                      <xsl:apply-templates select="../tei:trailer"/>
                    </xsl:element>
                  </xsl:if>
                </tr>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <!-- tei:head -->
              <xsl:for-each select="tei:item">
                <tr>
                  <xsl:if test="position()=1">
                    <xsl:element name="td">
                      <xsl:attribute name="class">dta-list-head</xsl:attribute>
                      <xsl:attribute name="rowspan">
                        <xsl:value-of select="count(../tei:item)"/>
                      </xsl:attribute>
                      <xsl:apply-templates select="../tei:head"/>
                    </xsl:element>
                  </xsl:if>
                  <td class="item-right">
                    <xsl:apply-templates/>
                  </td>
                </tr>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </table>
      </xsl:when>
      <xsl:when test='@rendition="#leftBraced"'>
        <span class="braced-base braced-left">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test='@rendition="#rightBraced"'>
        <span class="braced-base braced-right">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test='@rendition="#leftBraced #rightBraced"'>
        <span class="braced-base braced-left-right">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <div class="dta-list">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
    <!--  <xsl:call-template name="close-cb"/>-->
  </xsl:template>

  <xsl:template match="tei:item">
    <xsl:choose>
      <xsl:when test="ancestor::tei:p">
        <span class="dta-list-item">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="descendant::tei:pb">
        <div class="dta-list-item-noindent">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="dta-list-item">
          <xsl:apply-templates/>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:table">
    <xsl:choose>
      <xsl:when test="not(string(.)) or not(normalize-space(.))">
        <div class="gap">[Tabelle]</div>
      </xsl:when>
      <xsl:otherwise>
        <table class="dta-table">
          <xsl:if test="tei:head">
            <caption>
              <xsl:apply-templates select="tei:head"/>
            </caption>
          </xsl:if>
          <xsl:for-each select="tei:row">
            <tr>
              <xsl:for-each select="tei:cell">
                <xsl:choose>
                  <xsl:when test="../@role='label'">
                    <xsl:element name="th">
                      <xsl:apply-templates/>
                    </xsl:element>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="td">
                      <xsl:if test="@cols">
                        <xsl:attribute name="colspan">
                          <xsl:value-of select="@cols"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="@rows">
                        <xsl:attribute name="rowspan">
                          <xsl:value-of select="@rows"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:if test="@rendition='#c'">
                        <xsl:attribute name="style">text-align:center</xsl:attribute>
                      </xsl:if>
                      <xsl:if test="@rendition='#right'">
                        <xsl:attribute name="style">text-align:right</xsl:attribute>
                      </xsl:if>
                      <xsl:if test="@rendition='#et'">
                        <xsl:attribute name="style">padding-left:2em</xsl:attribute>
                      </xsl:if>
                      <xsl:apply-templates/>
                    </xsl:element>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:opener">
    <span class="dta-opener">
      <xsl:call-template name="applyRendition"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:trailer">
    <span class="dta-trailer">
      <xsl:call-template name="applyRendition"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="tei:ref">
    <xsl:element name="span">
      <xsl:attribute name="class">ref</xsl:attribute>
      <xsl:if
        test="starts-with(@target, '#f') or starts-with(@target, 'BrN3E.htm') or starts-with(@target, 'ZgZuE.htm')">
        <xsl:attribute name="target">
          <xsl:value-of select="@target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="starts-with(@target, 'http')">
        <xsl:attribute name="target">
          <xsl:value-of select="@target"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- Publikationstyp auflösen?? -->
  <xsl:template match="tei:bibl">
    <span class="dta-bibl">
      <xsl:call-template name="applyRendition"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match='tei:space[@dim="horizontal"]'>
    <xsl:text disable-output-escaping="yes">&amp;nbsp;&amp;nbsp;&amp;nbsp;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match='tei:space[@dim="vertical"]'>
    <br class="space"/>
    <!--  <div style="height:20px; float:"></div> -->
  </xsl:template>

  <xsl:template match="tei:supplied">
    <span class="dta-supplied">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
    </span>
    <!--<span class="dta-supplied"><xsl:apply-templates/></span>-->
  </xsl:template>

  <xsl:template match="tei:foreign">
    <xsl:choose>
      <!--<xsl:when test="not(*//text()) and @xml:lang">-->
      <xsl:when test="not(child::node()) and @xml:lang">
        <span class="dta-foreign" title="fremdsprachliches Material">FM: <xsl:choose>
            <xsl:when test="@xml:lang='he' or @xml:lang='heb' or @xml:lang='hbo'"
              >hebräisch</xsl:when>
            <xsl:when test="@xml:lang='el' or @xml:lang='grc' or @xml:lang='ell'"
              >griechisch</xsl:when>
            <xsl:otherwise><xsl:value-of select="@xml:lang"/></xsl:otherwise>
          </xsl:choose>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template name="addClass">
    <xsl:param name="value"/>
    <xsl:attribute name="class">
      <xsl:value-of select="$value"/>
      <xsl:text> </xsl:text>
    </xsl:attribute>
  </xsl:template>

  <!-- 
  <msxsl:script language="JScript" implements-prefix="custom">
    function uriencode(string) {
      return encodeURIComponent(string);
    }
  </msxsl:script>
 -->
</xsl:stylesheet>
