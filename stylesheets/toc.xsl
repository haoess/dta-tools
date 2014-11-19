<?xml version="1.0" encoding="UTF-8"?>

<!--
  XSLT stylesheet to generate a table of contents for DTABf compatible
  texts. Due to limited features in XSLT 1.0 and my lack of XSL skills,
  the output of this script should be piped through the bundled perl
  script (fixtoc.pl), which fixes white spaces anomalies, normalizes
  older german characters to modern transliteration, and dehyphenates
  words in headings.

  Author: Frank Wiegand <wiegand@bbaw.de>, 2014.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  version="1.0">

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:template match="tei:titlePage[@type='main']">
  <xsl:text>&#x0a;</xsl:text>
  <xsl:choose>
    <xsl:when test="preceding::tei:pb">
      <xsl:value-of select="preceding::tei:pb[1]/@facs"/>
    </xsl:when>
    <xsl:otherwise>#f0001</xsl:otherwise>
  </xsl:choose>
  <xsl:text>: [Titelseite]</xsl:text>
</xsl:template>

<xsl:template match="tei:div">
  <xsl:text>&#x0a;</xsl:text>
  <xsl:call-template name="spaces">
    <xsl:with-param name="count" select="count(ancestor::tei:div)"/>
  </xsl:call-template>
  <xsl:choose>
    <xsl:when test="preceding::tei:pb">
      <xsl:value-of select="preceding::tei:pb[1]/@facs"/>
    </xsl:when>
    <xsl:otherwise>#f0001</xsl:otherwise>
  </xsl:choose>
  <xsl:text>: </xsl:text>
  <xsl:choose>
    <xsl:when test="tei:head[1]//text()">
      <xsl:apply-templates select="tei:head[1]" mode="head"/>
    </xsl:when>
    <xsl:when test="@type='abbreviations'">[Abkürzungsverzeichnis]</xsl:when>
    <xsl:when test="@type='act'">[Akt]</xsl:when>
    <xsl:when test="@type='advertisement'">[Anzeige]</xsl:when>
    <xsl:when test="@type='appendix'">[Anhang]</xsl:when>
    <xsl:when test="@type='bibliography'">[Bibliographie]</xsl:when>
    <xsl:when test="@type='chapter'">[Kapitel]</xsl:when>
    <xsl:when test="@type='contents'">[Inhaltsverzeichnis]</xsl:when>
    <xsl:when test="@type='copyright'">[Hinweise zum Copyright]</xsl:when>
    <xsl:when test="@type='corrigenda'">[Druckfehlerverzeichnis]</xsl:when>
    <xsl:when test="@type='dedication'">[Widmung]</xsl:when>
    <xsl:when test="@type='diaryEntry'">[Tagebucheintrag]</xsl:when>
    <xsl:when test="@type='edition'">[Abdruck]</xsl:when>
    <xsl:when test="@type='figures'">[Abbildungsverzeichnis]</xsl:when>
    <xsl:when test="@type='frontispiece'">[Frontispiz]</xsl:when>
    <xsl:when test="@type='imprint'">[Impressum]</xsl:when>
    <xsl:when test="@type='imprimatur'">[Druckerlaubnis]</xsl:when>
    <xsl:when test="@type='index'">[Register]</xsl:when>
    <xsl:when test="@type='letter'">[Brief]</xsl:when>
    <xsl:when test="@type='poem'">[Gedicht]</xsl:when>
    <xsl:when test="@type='postface'">[Nachwort]</xsl:when>
    <xsl:when test="@type='preface'">[Vorwort]</xsl:when>
    <xsl:when test="@type='recipe'">[Rezept]</xsl:when>
    <xsl:when test="@type='scene'">[Szene]</xsl:when>
    <xsl:otherwise>[Abschnitt]</xsl:otherwise>
  </xsl:choose>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:head" mode="head">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:lb">
  <xsl:text>&#x20;</xsl:text>
</xsl:template>

<!-- nodes to be ignored -->
<xsl:template match="tei:bibl | tei:byline | tei:castItem | tei:cit | tei:closer | tei:dateline | tei:div[@type='imprint' or @type='dedication'] | tei:docAuthor | tei:docDate | tei:docImprint | tei:figure | tei:fw | tei:head | tei:l | tei:list | tei:milestone | tei:note | tei:opener | tei:quote | tei:p | tei:roleDesc | tei:salute | tei:sic | tei:signed | tei:sp | tei:stage | tei:table | tei:teiHeader | tei:titlePage | tei:titlePart | tei:trailer"/>

<xsl:template match="text()"><xsl:value-of select="translate(.,'&#x0a;',' ')"/></xsl:template>

<xsl:template name="spaces">
  <xsl:param name="count" select="1"/>
  <xsl:if test="$count > 0">
    <xsl:text> </xsl:text>
    <xsl:call-template name="spaces">
      <xsl:with-param name="count" select="$count - 1"/>
      </xsl:call-template>
    </xsl:if>  
  </xsl:template>
</xsl:stylesheet>
