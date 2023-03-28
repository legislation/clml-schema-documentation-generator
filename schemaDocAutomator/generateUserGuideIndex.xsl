<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cm="http://macksol.co.uk"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0" xmlns:err="http://www.w3.org/2005/xqt-errors"
    xmlns:ci="http://macksol.co.uk/include" xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs a rng cm ci err xhtml dc leg ukm" expand-text="true"
    version="3.0">
    <doc xmlns="http://www.oxyegnxml.com/ns/doc/xsl">
        <p>This XSLT generates an index page for the User Guide from its ToC (post-processing) and an existing index page.</p>
    </doc>
    
    <xsl:output indent="false" method="xhtml" encoding="UTF-8" />
    
    <xsl:param name="gpUserGuide" as="xs:string"/>
    <xsl:param name="gpReferenceGuide" as="xs:string"/>
    <xsl:param name="gpOutputFolder" as="xs:string"/>
    
    <xsl:template match="node()">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="head">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <link rel="stylesheet" href="toc.css" type="text/css"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class='toc']">
        <xsl:variable name="vUserGuideToC" select="doc(concat($gpOutputFolder,'/',$gpUserGuide))//nav[@id='contents']"/>
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="$vUserGuideToC" mode="reprocessUserGuideToCForIndex"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()" mode="reprocessUserGuideToCForIndex">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="nav[@id='contents']//a" mode="reprocessUserGuideToCForIndex">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except @href"/>
            <xsl:attribute name="href" select="concat($gpUserGuide, '#', substring-after(@href, '#'))"/>
            <xsl:attribute name="target">_top</xsl:attribute>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
