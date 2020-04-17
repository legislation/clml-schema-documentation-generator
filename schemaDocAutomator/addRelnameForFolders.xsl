<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cm="http:mackenziesolutions.co.uk"
     xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
      xmlns:ci="http://macksol.co.uk/include" xmlns:xhtml="http://www.w3.org/1999/xhtml"
      xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs a rng cm ci" expand-text="true"
    version="3.0">
    
    <doc xmlns="http://www.oxyegnxml.com/ns/doc/xsl">
        <p>process the folder XML file and add relative name @relname attribute so that we can keep sub folder structures</p>
    </doc>
  
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:variable name="vBasefolder" select="(//*:directory)[1]/@*[local-name()='base']"/>
    <xsl:variable name="vSubfolder" select="tokenize($vBasefolder,'/')[last()-1]"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*:file">
        <xsl:copy>
          <xsl:attribute name="relname">
            <xsl:choose>
              <xsl:when test="count(ancestor::*:directory) gt 1">
                <xsl:value-of select="concat(substring-after(ancestor::*:directory[1]/@*[local-name()='base'],$vBasefolder),@name)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="*|@*|text()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>