<?xml version="1.0"?> 
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:TEI="http://www.tei-c.org/ns/1.0">
<xsl:output method="text" encoding="UTF-8" media-type="text/plain"/>
<!-- <xsl:strip-space elements="TEI:text TEI:front TEI:p TEI:role TEI:castItem TEI:sp TEI:list TEI:lg TEI:castList TEI:castGroup" /> -->
<xsl:preserve-space elements="*" />
<!-- <xsl:strip-space elements="TEI:castItem TEI:cast"/> -->

<!--=====================================-->
<!-- Parameters -->
<!--=====================================-->
<!-- show or hide page number indicator [%04d %d] -->
<xsl:param name="show_page_numbers">1</xsl:param>
<!-- show or hide !!FORMFEED!! -->
<xsl:param name="show_form_feed">1</xsl:param>
<xsl:param name="show_page_numbers_in_bogensignatur">0</xsl:param>
<xsl:param name="show_page_numbers_in_kolumnentitel">0</xsl:param>
<xsl:param name="show_sig_in_bogensignatur">1</xsl:param>
<xsl:param name="show_sig_in_kolumnentitel">1</xsl:param>
<xsl:param name="show_line_numbers">1</xsl:param>
<xsl:param name="show_bogensignatur">1</xsl:param>
<xsl:param name="show_kolumnentitel">1</xsl:param>
<xsl:param name="show_catchword">1</xsl:param>
<xsl:param name="show_newlines_in_cells">1</xsl:param>
<!-- Typographical or authentic footnote sigils -->
<xsl:param name="use_authentic_footnote_sign">1</xsl:param>

<!-- Character used to represent omitted characters -->
<xsl:param name="gap_char">_</xsl:param>

<!--=====================================-->
<!-- Global Variables -->
<!--=====================================-->
<!-- <xsl:variable name="max_page_number" select="//TEI:pb[last()]/@n"/> -->
<!-- <xsl:variable name="max_facs_number" select="format-number(substring(//TEI:pb[last()]/@facs, 2), '0000')"/> -->

<!--=====================================-->
<!-- Root Element, der Header ist nicht relevant fuer die Text-Ausgabe -->
<!--=====================================-->
<xsl:template match="TEI:TEI">
        <xsl:apply-templates select=".//TEI:text[not(descendant::TEI:text)]"/>
</xsl:template>
<xsl:template match="TEI:text">
    <xsl:apply-templates select="//TEI:pb" mode="seitenzahl" />
    <xsl:if test="$show_kolumnentitel = 1">
        <xsl:apply-templates select="//TEI:fw[@place='top']" mode="kolumnentitel" />
    </xsl:if>
    <xsl:apply-templates/>
    <!-- <xsl:text>&#xa;</xsl:text> -->
    <!-- first print the continued footnotes which are in <seg></seg> with @part="F" -->
    <xsl:apply-templates select="//TEI:note[@place='foot'][parent::TEI:seg[@part='F']]" mode="fussnote_am_ende_der_seite" />
    <xsl:apply-templates select="//TEI:note[@place='foot'][not(parent::TEI:seg[@part='F'])]" mode="fussnote_am_ende_der_seite" />
    <xsl:if test="$show_bogensignatur = 1">
        <xsl:apply-templates select="//TEI:fw[@place='bottom']" mode="bogensignatur" />
    </xsl:if>
    <xsl:apply-templates select="//TEI:pb" mode="seitenumbruch" />
</xsl:template>

<!--=====================================-->
<!-- entfernen aller ueberschuessigen leerzeichen (d.h. nach 'normalize-space() leerem text) -->
<!--=====================================-->
<!-- <xsl:template match="text()"> -->
    <!-- [> <xsl:variable name="previousEndedInWhiteSpace" select="contains(concat(../preceding-sibling::node()/text(), 'XXX'), ' XXX')"/> <] -->
    <!-- <xsl:variable ::*[0odeName" select="local-name(../*[1])"/> -->
    <!-- <xsl:value-of select="normalize-space(.)"/> -->
    <!-- <xsl:if test="$nodeName != 'lb' -->
        <!-- and $nodeName != 'pb' -->
        <!-- and $nodeName != 'table' -->
        <!-- and $nodeName != 'note' -->
        <!-- "> -->
        <!-- <xsl:if test="contains(concat(.,'^$%'),' ^$%')  -->
            <!-- or ../following-sibling::node()[1][self::text() and starts-with(.,' ')] -->
            <!-- "> -->
            <!-- <xsl:text> </xsl:text> -->
        <!-- </xsl:if> -->
    <!-- </xsl:if> -->
<!-- [> ALPHA-<xsl:value-of select="contains(concat(../preceding-sibling::node()/text(), 'XXX'), ' XXX')"/>-OMEGA <] -->
        <!-- [> <xsl:if test="not($previousEndedInWhiteSpace)"> <] -->
        <!-- [>     <xsl:text> </xsl:text> <] -->
        <!-- [> </xsl:if> <] -->
<!-- </xsl:template> -->

<!--=====================================-->
<!-- Characters c                        -->
<!-- Highlight hi                        -->
<!--=====================================-->
<!-- TODO spacing stimmt bei hi nicht immer. generische loesung schwierig -->
<!-- <xsl:template match="TEI:c"> -->
<!--     [> <xsl:text>Nothing to see here</xsl:text> <] -->
<!--     [> <xsl:if test="not(text())"> <] -->
<!--         [> <xsl:text>&#x20;</xsl:text> <] -->
<!--     [> </xsl:if> <] -->
<!--     <xsl:value-of select="." /> -->
<!-- </xsl:template> -->

<!--=====================================-->
<!-- Absaetze mit Leerzeile <p>          -->
<!--=====================================-->
<xsl:template match="TEI:p">
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="TEI:note[@place='left'] | TEI:note[@place='right']" mode="marginalia_nachgestellt"/>
</xsl:template>


<!--=====================================-->
<!-- Zeilenumbrueche lb cb -->
<!--=====================================-->
<xsl:template match="TEI:lb[not(@n)]">
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:lb[@n]">
    <xsl:if test="$show_line_numbers = 1">
        <xsl:text>&#x20;</xsl:text>
        <xsl:value-of select="@n"/>
    </xsl:if>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:cb">
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:cb | TEI:lb" mode="no_newline">
    <xsl:text>&#x20;</xsl:text>
</xsl:template>


<!--=====================================-->
<!-- Seitenumbrueche pb, aber nur das letzte in einer Reihe von leeren -->
<!--=====================================-->
<!-- TODO darueber muss ich noch nachdenken, wie ich die aufeinanderfolgenden "leeren" pbs rausbekomme ... -->
<xsl:template match="TEI:pb"/>
<xsl:template match="TEI:pb" mode="seitenumbruch">
    <!-- <xsl:text>&#xa;</xsl:text> -->
    <xsl:if test="$show_form_feed = 1">
        <xsl:text>!!FORMFEED!!</xsl:text>
    </xsl:if>
</xsl:template>
<xsl:template match="TEI:pb" mode="seitenzahl">
    <xsl:if test="$show_page_numbers = 1">
        <xsl:variable name="page_number" select="@n"/>
        <xsl:variable name="facs_number" select="format-number(substring(@facs, 3), '0000')"/>

        <xsl:text>[</xsl:text>

        <xsl:if test="$page_number">
            <xsl:value-of select="$page_number"/>
            <xsl:if test="$facs_number"><xsl:text>/</xsl:text></xsl:if>
        </xsl:if>

        <xsl:if test="$facs_number">
            <xsl:value-of select="$facs_number"/>
        </xsl:if>

        <xsl:text>]</xsl:text>
        <xsl:text>&#xa;</xsl:text>
    </xsl:if>
</xsl:template>

<!--=====================================-->
<!-- Fussnoten                           -->
<!--=====================================-->
<xsl:template match="TEI:note[@place='foot']"/>
<!-- Fussnoten im Text -->
<xsl:template match="TEI:note[@place='foot']">
    <xsl:if test="not(parent::TEI:seg[@part='F'])">
        <xsl:text>&#x20;</xsl:text>
        <xsl:choose>
            <xsl:when test="$use_authentic_footnote_sign = 0">
                <xsl:call-template name="translate_numbers_to_superscript">
                    <xsl:with-param name="number" select="1 + count(preceding::TEI:note[@place='foot'])"/>
                </xsl:call-template> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@n"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    <!-- <xsl:text>&#x20;</xsl:text> -->
</xsl:template> 
<!-- Fussnoten am Ende der Seite -->
<xsl:template match="TEI:note[@place='foot']" mode="fussnote_am_ende_der_seite" >
    <xsl:text>&#xa;</xsl:text>
    <xsl:choose>
        <xsl:when test="$use_authentic_footnote_sign = 0">
            <xsl:call-template name="translate_numbers_to_superscript">
                <xsl:with-param name="number" select="1 + count(preceding::TEI:note[@place='foot'])"/>
            </xsl:call-template> 
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@n"/>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&#x20;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>


<!--=====================================-->
<!-- Kolumnentitel und Bogensignaturen   -->
<!--=====================================-->
<xsl:template match="TEI:fw"/>
<xsl:template match="TEI:fw[@type='catch']">
    <xsl:if test='$show_catchword = 1'>
        <xsl:if test="ancestor::TEI:p">
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:if>
</xsl:template>

<xsl:template match="TEI:fw[@place='top']" mode="kolumnentitel">
    <xsl:choose>
        <xsl:when test="@type='page number' and $show_page_numbers_in_kolumnentitel = 0"/>
        <xsl:when test="@type='sig' and $show_sig_in_kolumnentitel = 0"/>
        <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template match="TEI:fw[@place='bottom']" mode="bogensignatur">
    <xsl:choose>
        <xsl:when test="@type='page number' and $show_page_numbers_in_bogensignatur = 0"/>
        <xsl:when test="@type='sig' and $show_sig_in_bogensignatur = 0"/>
        <xsl:when test="@type='catch'"/>
        <xsl:otherwise>
            <xsl:text>&#xa;</xsl:text>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!--=====================================-->
<!-- Endnoten -->
<!--=====================================-->
<!-- <xsl:template match="TEI:div"> -->
    <!-- <xsl:apply-templates/> -->
<!-- </xsl:template> -->
<xsl:template match="TEI:note[@place='end']">
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="translate_numbers_to_superscript">
        <xsl:with-param name="number" select="@n"/>
    </xsl:call-template>
    <xsl:text>&#x20;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Editorial notes -->
<!--=====================================-->
<xsl:template match="TEI:note[@type='editorial']" />


<!--=====================================-->
<!-- Tables                              -->
<!--=====================================-->
<xsl:template match="TEI:table">
    <xsl:apply-templates select="TEI:head" mode="table_head"/>
    <xsl:apply-templates select="TEI:row"/>
</xsl:template>
<xsl:template match="TEI:head" mode="table_head">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:row">
    <xsl:apply-templates select="TEI:cell"/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:cell[not(position()=last())]">
    <xsl:if test="$show_newlines_in_cells = 1">
        <xsl:apply-templates/>
    </xsl:if>
    <xsl:if test="$show_newlines_in_cells = 0">
        <xsl:apply-templates mode="no_newline"/>
    </xsl:if>
    <xsl:text>&#x9;</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Abbildungen                         -->
<!--=====================================-->
<xsl:template match="TEI:figure">
        <xsl:text>&#xa;</xsl:text>
    <xsl:text>[Abbildung</xsl:text>
    <xsl:if test="./TEI:head">
        <xsl:text>&#x9;</xsl:text>
        <xsl:apply-templates select="TEI:figure/TEI:figDesc"/>
        <xsl:apply-templates select="TEI:figure/TEI:p"/>
        <!-- <xsl:value-of select="./TEI:head"/> -->
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="TEI:figure/TEI:figDesc">
    <xsl:text>&#x9;</xsl:text>
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="TEI:figure/TEI:p">
    <xsl:if test="not(preceding-sibling::*[1][local-name() = 'lb'])">
        <xsl:text>&#x9;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
</xsl:template>

<!--=====================================-->
<!-- Listen                              -->
<!--=====================================-->
<xsl:template match="TEI:list">
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:item[not(position() = last())]">
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Choice                              -->
<!--=====================================-->
<xsl:template match="TEI:choice">
    <!-- fall 1 -->
    <xsl:if test="TEI:corr">
        <xsl:apply-templates select="TEI:corr"/>
    </xsl:if>
    <!-- fall 2 -->
    <xsl:if test="TEI:orig">
        <xsl:apply-templates select="TEI:orig"/>
    </xsl:if>
    <!-- fall 3 -->
    <xsl:if test="TEI:reg">
        <xsl:if test="not(TEI:orig)">
            <xsl:apply-templates select="TEI:reg"/>
        </xsl:if>
    </xsl:if>
    <!-- fall 4 -->
    <xsl:if test="TEI:abbr">
        <xsl:if test="TEI:expan">
            <xsl:apply-templates select="TEI:abbr"/>
        </xsl:if>
    </xsl:if>
    <!-- <xsl:if test="not(./orig)"></xsl:if> -->
</xsl:template>


<!--=====================================-->
<!-- Marginalia                          -->
<!--=====================================-->
<xsl:template match="TEI:note[@place='left'] | TEI:note[@place='right']" />
<xsl:template match="TEI:note[@place='left'] | TEI:note[@place='right']" mode="marginalia_nachgestellt">
    <xsl:if test="position() = 1">
        <xsl:text>&#xa;</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="not(position() = last())">
        <xsl:text>&#xa;</xsl:text>
    </xsl:if>
</xsl:template>

<!--=====================================-->
<!-- DRAMA                               -->
<!--=====================================-->
<!--=====================================-->
<!-- Castlist                            -->
<!--=====================================-->
<xsl:template match="TEI:castList">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="//TEI:roleDesc"/>
<!-- <xsl:template match="TEI:castList/TEI:head"> -->
    <!-- <xsl:apply-templates/> -->
    <!-- <xsl:text>&#xa;</xsl:text> -->
<!-- </xsl:template> -->
<xsl:template match="TEI:castGroup">
    <xsl:value-of select="normalize-space(TEI:roleDesc)"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
</xsl:template> 
<xsl:template match="TEI:castGroup/TEI:castItem">
    <xsl:text>&#x9;</xsl:text>
    <xsl:apply-templates/>
    <xsl:if test="name(following-sibling::*[1]) != 'lb'">
        <xsl:if test="name(following-sibling::*[1]) = 'castItem'">
            <xsl:text>&#xa;</xsl:text>
        </xsl:if>
    </xsl:if>
</xsl:template>
<xsl:template match="TEI:castItem">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="TEI:role">
    <xsl:apply-templates/>
    <xsl:text>&#x20;</xsl:text>
</xsl:template>
<xsl:template match="TEI:castItem/TEI:roleDesc">
    <xsl:apply-templates/>
    <xsl:text>&#x20;</xsl:text>
</xsl:template>
<xsl:template match="TEI:actor">
    <xsl:apply-templates/>
</xsl:template>
<xsl:template match="TEI:milestone">
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Dramenstruktur                      -->
<!--=====================================-->
<xsl:template match="TEI:head">
    <xsl:apply-templates/>
    <!-- <xsl:value-of select="text()"/> -->
    <!-- <xsl:text>&#xa;</xsl:text> -->
</xsl:template>
<xsl:template match="TEI:stage">
    <xsl:apply-templates/>
</xsl:template>

<!--=====================================-->
<!--Speaker Speakerline sp speaker       -->
<!--=====================================-->
<xsl:template match="TEI:sp">
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:sp/TEI:speaker">
    <xsl:apply-templates/>
    <xsl:text>&#x20;</xsl:text>
</xsl:template>
<xsl:template match="TEI:sp/TEI:stage">
    <xsl:apply-templates/>
    <xsl:text>&#x20;</xsl:text>
</xsl:template>
<xsl:template match="TEI:sp/TEI:p">
    <xsl:apply-templates/>
</xsl:template>


<!--=====================================-->
<!-- Formeln                             -->
<!--=====================================-->
<xsl:template match="TEI:formula">
    <xsl:text>[FORMEL]</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Gap Auslassungen                    -->
<!-- werden durch '_' ersetzt            -->
<!--=====================================-->
<xsl:template match="TEI:gap">
    <xsl:choose>
        <xsl:when test="@extent">
            <xsl:call-template name="output_gap">
                <xsl:with-param name="output" select="$gap_char" />
                <xsl:with-param name="recLevel" select="@extent"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:when test="@quantity">
            <xsl:call-template name="output_gap">
                <xsl:with-param name="output" select="$gap_char" />
                <xsl:with-param name="recLevel" select="@quantity"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$gap_char" />
            <xsl:text>&#x20;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template name="output_gap">
    <xsl:param name="output" />
    <xsl:param name="recLevel" />
    <xsl:value-of select="$output"/>
    <xsl:if test="$recLevel > 1">
        <xsl:call-template name="output_gap">
            <xsl:with-param name="output" select="$output" />
            <xsl:with-param name="recLevel" select="$recLevel - 1" />
        </xsl:call-template>
    </xsl:if>
</xsl:template>

<!--=====================================-->
<!-- Poeme Gedichte stanza               -->
<!--=====================================-->
<xsl:template match="TEI:lg">
    <!-- <xsl:value-of select="@type"/> -->
    <xsl:apply-templates/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>
<xsl:template match="TEI:lg[@type='poem']//TEI:head">
    <xsl:text>&#x9;</xsl:text>
    <xsl:apply-templates/>
    <!-- <xsl:text>&#xa;</xsl:text> -->
</xsl:template>
<xsl:template match="TEI:l">
    <xsl:apply-templates/>
    <xsl:text>&#x20;</xsl:text>
</xsl:template>

<!--=====================================-->
<!-- Supplied Editorial                  -->
<!--=====================================-->
<xsl:template match="TEI:supplied">
    <xsl:apply-templates/>
</xsl:template>

<!--=====================================-->
<!-- <space>                             -->
<!--=====================================-->
<xsl:template match="TEI:space">
    <xsl:text>&#x20;</xsl:text>
</xsl:template>



<!--=====================================-->
<!-- Helfer Templates -->
<!--=====================================-->
<!-- uebersetze normale nummern in hochgestellte -->
<xsl:template name="translate_numbers_to_superscript">
    <xsl:param name="number"/>
    <xsl:value-of select="translate(
            $number, 
            '0123456789()', 
            '&#x2070;&#xb9;&#xb2;&#xb3;&#x2074;&#x2075;&#x2076;&#x2077;&#x2078;&#x2079;&#x207d;&#x207e;'
        )"/>
</xsl:template>

</xsl:stylesheet>
