<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
  version="1.0">

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>

<xsl:strip-space elements="*" />

<xsl:template match="tei:titlePage[@type='main']"><xsl:value-of select="preceding::tei:pb[1]/@facs"/>: [Titelseite]</xsl:template>

<xsl:template match="tei:div">
  <xsl:text>&#x0a;</xsl:text>
  <xsl:call-template name="spaces">
    <xsl:with-param name="count" select="count(ancestor::tei:div)"/>
  </xsl:call-template>
  <xsl:value-of select="preceding::tei:pb[1]/@facs"/>: <xsl:choose>
    <xsl:when test="tei:head//text()">
      <xsl:apply-templates select="tei:head" mode="head"/>
    </xsl:when>
    <xsl:otherwise>[Kapitel]</xsl:otherwise>
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
<xsl:template match="tei:teiHeader | tei:cit | tei:closer | tei:dateline | tei:div[@type='imprint' or @type='dedication'] | tei:fw | tei:head | tei:l | tei:list | tei:milestone | tei:note | tei:p | tei:salute | tei:sic | tei:sp | tei:stage | tei:titlePage"/>

<xsl:template match="text()"><xsl:value-of select="normalize-space(translate(.,'&#x0a;',' '))"/></xsl:template>

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
