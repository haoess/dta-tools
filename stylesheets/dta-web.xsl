<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:dta="urn:dta"
  exclude-result-prefixes="dta tei"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:import href="dta-base.xsl"/>

<xsl:output
  method="html" media-type="text/html"
  cdata-section-elements="script style"
  indent="no"
  encoding="utf-8"/>

<xsl:template match='tei:text[not(descendant::tei:text)]'>
  <xsl:apply-templates/>
  <xsl:apply-templates select='//tei:fw[@place="bottom"][@type="catch" and not(parent::tei:note)]' mode="signatures"/>
  <xsl:if test='//tei:note[@place="foot"]'>
    <xsl:choose>
      <xsl:when test='//tei:seg[@part="M" or @part="F"]/tei:note[@place="foot"]'>
        <div class="footnotesep-long"></div>
      </xsl:when>
      <xsl:otherwise>
        <div class="footnotesep"></div>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select='//tei:seg[@part="M" or @part="F"]/tei:note[@place="foot"]' mode="footnotes"/>
    <xsl:apply-templates select='//tei:note[@place="foot" and string-length(@prev)!=0]' mode="footnotes"/>
    <xsl:apply-templates select='//tei:note[@place="foot" and not(parent::tei:seg[@part="M" or @part="F"]) and string-length(@prev)=0]' mode="footnotes"/>
  </xsl:if>
  <xsl:apply-templates select='//tei:fw[@place="bottom"][@type="sig"]' mode="signatures"/>
</xsl:template>

<xsl:template match='tei:supplied'><xsl:apply-templates/></xsl:template>

</xsl:stylesheet>
