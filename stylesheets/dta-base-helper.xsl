<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:dta="urn:dta" 
  exclude-result-prefixes="dta tei">
  

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

  
  
  <xsl:template name="addClass">
    <xsl:param name="value"/>
    <xsl:attribute name="class">
      <xsl:value-of select="$value"/>
      <xsl:text> </xsl:text>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>