<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cm="http:mackenziesolutions.co.uk"
     xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
      xmlns:ci="http://macksol.co.uk/include"
      xmlns:rng="http://relaxng.org/ns/structure/1.0"
    exclude-result-prefixes="xs a rng cm ci" expand-text="true"
    version="3.0">
    
    <doc xmlns="http://www.oxyegnxml.com/ns/doc/xsl">
        <p>Process the an XSD file (that has previously been converted by Trang from RNG and has therefore lost its comments) and
            try to find the original annotations in the RNG file with the same name in order to reinsert the comments.</p>
        <p>Note: This only works for named or global structures.</p>
        <p>This code was developed as part of a prototype to prove this is possible. It can therefore be expected that this code will have to be further developed.</p>
    </doc>
    
    <xsl:output indent="true" method="xml"/>
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="gpRNGfilename" select="if (ends-with(base-uri(/),'.xs')) then concat(substring-before(base-uri(/),'.xs'),'.rng') else concat(substring-before(base-uri(/),'.xsd'),'.rng')" as="xs:string"/>
    <xsl:variable name="gvRNG" select="document($gpRNGfilename)" as="document-node()"/>
    <xsl:variable name="gvRNGdoc" as="element()*">
        <xsl:apply-templates  select="$gvRNG//a:documentation" mode="rng"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <!--<xsl:message>Copying comments from {$gpRNGfilename}</xsl:message>-->
        <xsl:apply-templates/>
<!--         or debug
-->        <!--<test>
            <xsl:copy-of select="$gvRNGdoc"/>
            <xsl:apply-templates/>
        </test>--> 
    </xsl:template>
    
    <xsl:template match="xs:schema">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <!-- copy any RNG documentation elements that are children of grammar or start elements 
            To do: add clean up at this stage and work out what goes in appinfo vs documentation-->
            <xsl:call-template name="makeAnnotation">
                <xsl:with-param name="pRNDannots" select="$gvRNGdoc[@rngpath = ('/grammar','/start')]"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- some plain text will have been copied through but others not so we will regenerate all -->
    <xsl:template match="xs:annotation"/>
    
    <xsl:template match="*" priority="-1">
        <xsl:copy>
            <xsl:variable name="vXsdPath" select="cm:getRNGPathForXsd(.)"/>
            <xsl:variable name="vMatchingRNGdoc" as="element()*">
                <!-- create xsd doc for "exact" matches -->
                <xsl:sequence select="$gvRNGdoc[@rngpath=$vXsdPath]"/>
                <!-- create xsd doc for global element definitions that originally were part of a global rng define
                rng path would be 
                /group[@name='common']/element[@name='reuseme']
                that turn into xsd
                /element[@name='reuseme']
                -->
                <xsl:if test="self::xs:element/parent::xs:schema">
                    <xsl:sequence select="$gvRNGdoc[concat('/',replace(@rngpath,'/group.+/',''))=$vXsdPath]"/>
                </xsl:if>
            </xsl:variable>
            <!-- for debug  -->
            <!--<xsl:attribute name="xsdpath" select="$vXsdPath"/>-->
            <xsl:copy-of select="@*"/>
            <xsl:call-template name="makeAnnotation">
                <xsl:with-param name="pRNDannots" select="$vMatchingRNGdoc"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template name="makeAnnotation">
        <xsl:param name="pRNDannots" as="element()*"/>
        <xsl:if test="$pRNDannots">
            <xsl:element name="xsd:annotation">
                <xsl:for-each select="$pRNDannots">
                    <xsl:element name="xsd:documentation">
                        <xsl:copy-of select="@* except @rngpath"/>
                        <xsl:copy-of select="node()"/>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- so we have an annotation with more to it than just text
    and that content may have been dropped during Trang conversion from RNG to XSD
    so we will 
    a) match on its parent
    b) add an attribute to it to define its parents simplified path so we can understand the context
    c) inject or replace the documentation into the schema at the most relevant point
    -->
    <xsl:template match="a:documentation" mode="rng">
        <xsl:copy>
            <xsl:attribute name="rngpath" select="cm:getRngPath(..)"/>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="cm:getRngPath" as="xs:string">
        <xsl:param name="pDocumentionElement" as="element()"/>
        <xsl:value-of>
            <xsl:text>/</xsl:text>
            <xsl:for-each select="$pDocumentionElement/ancestor::*[local-name()=('element','attribute','define')]">
                <xsl:value-of select="if (local-name()='define') then 'group' else local-name()"/>
                <xsl:if test="@name">
                    <xsl:value-of select="concat($gvStartNameText,@name,$gvEndNameText)"/>
                </xsl:if>
                <xsl:text>/</xsl:text>
            </xsl:for-each>
            <xsl:value-of select="if (local-name($pDocumentionElement)='define') then 'group' else local-name($pDocumentionElement)"/>
            <xsl:if test="$pDocumentionElement/@name">
                <xsl:value-of select="concat($gvStartNameText, $pDocumentionElement/@name,$gvEndNameText)"/>
            </xsl:if>
        </xsl:value-of>
    </xsl:function>
    
    <!-- currently code is very similar as for RNG path but we might have to customise it more later
    Currently we are just recording the path of NAMED elements that we think we need to support documentation for
    so that it is then easier to match the path of where we need to inject it into the XSD schema 
    If we need to inject documentation into the middle of definitions (inside the elements that control sequences, choices etc
    then we need to enhance this and be able to accurately predict how that will be in schema (or at least put the documentation into a nearby appropriate place).
    All of this would be unnecessary if there was just a way to smuggle ids across from RNG structures into XSD when converted (but there is not)
    We may also have to ad code to populate doc for xsd attributeGroups created from defintions
    --> 
    <xsl:variable name="gvStartNameText">[@name='</xsl:variable>
    <xsl:variable name="gvEndNameText">']</xsl:variable>
    <xsl:function name="cm:getRNGPathForXsd" as="xs:string">
        <xsl:param name="pElement" as="element()"/>
        <xsl:value-of>
            <xsl:text>/</xsl:text>
            <xsl:for-each select="$pElement/ancestor::*[local-name()=('element','attribute','group')]">
                <xsl:value-of select="local-name()"/>
                <xsl:if test="@name">
                    <xsl:value-of select="concat($gvStartNameText,@name,$gvEndNameText)"/>
                </xsl:if>
                <xsl:text>/</xsl:text>
            </xsl:for-each>
            <xsl:value-of select="local-name($pElement)"/>
            <xsl:if test="$pElement/@name">
                <xsl:value-of select="concat($gvStartNameText,$pElement/@name,$gvEndNameText)"/>
            </xsl:if>
        </xsl:value-of>
    </xsl:function>
</xsl:stylesheet>