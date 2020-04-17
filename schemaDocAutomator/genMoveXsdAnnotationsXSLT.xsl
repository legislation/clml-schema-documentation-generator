<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:cm="http:mackenziesolutions.co.uk"
     xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
      xmlns:ci="http://macksol.co.uk/include" xmlns:dc="http://purl.org/dc/elements/1.1/"
      xmlns:rng="http://relaxng.org/ns/structure/1.0" xpath-default-namespace="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs a rng cm ci dc" expand-text="true"
    version="3.0">
    
    <doc xmlns="http://www.oxyegnxml.com/ns/doc/xsl">
        <p>See the documentation in xsdGenMoveComments.xpl and top level Xproc file.</p>
        <p>This code prepares XSD content and annotations for later processing by adding Ids and smuggling DC description into an annotation element</p>
    </doc>
    <xsl:output indent="true" method="xml" />
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="gpExtraDocFolder" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDocAutomator/extraDocFolder'" as="xs:string"/>
    <xsl:param name="gpSchemaIdMap" select="'schemaId2doc.map'" as="xs:string"/>
    
    <xsl:variable name="gvIdMap" select="document(concat($gpExtraDocFolder,'/',$gpSchemaIdMap))/*:idmap/*:entry" as="element()*"/>
    
    <!-- if we need the schema/annotation/appinfo[dc:*] then this could be added to code below
    remember though that these also contain xsd:docuentation with file descriptions and change info -->
    
    <xsl:variable name="gvFileID" as="xs:string">
        <xsl:choose>
            <xsl:when test="string(ancestor::schema/@id) != ''">
                <xsl:value-of select="ancestor::schema/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="tokenize(substring-before(base-uri(/),'.'),'/')[last()]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:template match="annotation" priority="+1">
        <xsl:variable name="vId" select="cm:makeId(..)" as="xs:string?"/>
        <xsl:variable name="vMapEntry" select="$gvIdMap[@id=$vId]" as="element()*"/>
        <!-- any appinfo content that we think relates to documentation, we will move this to annotation custom content so Oxygen keeps it -->
        <xsl:variable name="vAppInfoDocs" select="appinfo[@source=('example','output','doc') or .//ci:include]" as="element()*"/>
        <!-- other appInfo stay in place -->
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- other appInfo or any existing xsd:documentation should stay in place -->
            <xsl:apply-templates select="* except $vAppInfoDocs"/>
            <!-- we do not really want all the schemas dc metadata to appear in the documentation but it is useful
                to have the description output for the file -->
            <xsl:if test="appinfo/dc:description">
                <xsd:documentation>
                    <xsl:value-of select="appinfo/dc:description"/>
                </xsd:documentation>
            </xsl:if>
            <!-- there is extra documentation information inside the schema so use it -->
            <!--<xsl:message>id is {$vId} $gvIdMap={count($gvIdMap)} $vMapEntry={count($vMapEntry)} </xsl:message>-->
            <xsl:for-each select="$vAppInfoDocs">
                <xsd:documentation>
                    <ci:appInfo>
                        <xsl:apply-templates select="@*,node()"/>
                    </ci:appInfo>
                </xsd:documentation>
            </xsl:for-each>
            <!-- there is a mapped entry in the look-up file so use that -->
            <xsl:if test="$vMapEntry">
                <xsd:documentation>
                    <xsl:copy-of select="$vMapEntry/*"/>
                </xsd:documentation>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- this does not attempt to make unique ids where local elements or attributes or types have same names as other local elements or attributes
    If we really need that then we could start to add in path information but it is probably unnecessary and in the meantime
    the schema author can disambiguate by adding a fixed id. -->
    <xsl:function name="cm:makeId" as="xs:string?">
        <xsl:param name="pNode" as="node()"/>
        <xsl:if test="$pNode/parent::schema and (local-name($pNode)=('element','group','attribute','attributeGroup','complexType','simpleType')) and 
            ($pNode/@*:id or $pNode/@*:name)">
            <xsl:value-of>
                <xsl:value-of select="$gvFileID"/>
                <xsl:text>-</xsl:text>
                <xsl:choose>
                    <xsl:when test="$pNode/self::element">
                        <xsl:text>E-</xsl:text>
                    </xsl:when>
                    <xsl:when test="$pNode/self::group">
                        <xsl:text>G-</xsl:text>
                    </xsl:when>
                    <xsl:when test="$pNode/self::attribute">
                        <xsl:text>A-</xsl:text>
                    </xsl:when>
                    <xsl:when test="$pNode/self::attributeGroup">
                        <xsl:text>AG-</xsl:text>
                    </xsl:when>
                    <xsl:when test="$pNode/self::complexType">
                        <xsl:text>CT-</xsl:text>
                    </xsl:when>
                    <xsl:when test="$pNode/self::simpleType">
                        <xsl:text>ST-</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="$pNode/@*:id">
                        <xsl:value-of select="$pNode/@*:id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pNode/@*:name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:value-of>
        </xsl:if>
    </xsl:function>
    
    
</xsl:stylesheet>