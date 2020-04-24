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
    exclude-result-prefixes="xs a rng cm ci err xhtml ukm dc leg" expand-text="true"
    version="3.0">
    
    <doc xmlns="http://www.oxyegnxml.com/ns/doc/xsl">
        <p>The "include" mechanism is not using x:include as some processors will resolve those links even without requesting to do so when the schema is opened in other tools.</p>
        <p>The custom include markup is also more powerful than standard xInclude.</p>
        <p>The namespace for the custom include element is currently <code>xmlns:ci="http://macksol.co.uk/include"</code>.</p>
        <h1>Mandatory Attributes</h1>
        <p><code>href</code> - URI to the file that you want to include (or partially include) e.g. <code>href="uksi_20052087_en.xml" or href="schemaCommonNonEdit_xsd.html"</code>.</p>
        <p>If no path is specified then the folder used depends on the file extension:</p>
        <ul>
          <li>'.xml'=$gpSampleXmlFolder (e.g. to include examples of keying that illustrates how an element(s) is used</li>
          <li>'.html'=$gpOutputFolder (e.g. to include formatted annotations or an image map+image from the generated schema documentation in the user guide)</li>
          <li>'.htm'=$gpExtraDocFolder (e.g. to include some externally generated or manually keyed html documentation )</li>
        </ul>
        <p>OR</p>
        <p><code>id</code> - As an alternative to using <code>href</code> to specify URI to the file, you can use <code>id</code> to specify the what include(s) (or partially include(s)) should be automatically inserted based on the id look-up file (see below) e.g. <code>id="schemaLegislationMetadata-E-DepartmentCode"</code>.</p>
        <h1>Optional Attributes</h1>
        <ul>
          <li><code>fileref</code> - used to control the generation of a reference paragraph that is output to indicate where the content being embedded comes from. If the attribute is empty or is the word "no" then no reference is generated. If the attribute is missing or set to "yes" then default text is output that includes the <code>@href</code> value. Any other value is treated as the text to be output as the file reference.</li>
          <li><code>source</code> - used to indicate the nature of the content that can then be used to style the output. Current values are "example" (used to indicate the content is a source example) or "output" (used to indicate it reflects the rendered output). For embedded images the default is "output".</li>
          <li><code>show</code> - controls how the link is instantiated (adapted from x:link).Values also include:
            <ul>
              <li>new - creates a hyperlink to the content that will open in a new window</li>
              <li>replace - creates a hyperlink to the content that will replace the current content in the current window</li>
              <li>embed (default) - includes the content at the current point. If the content is XML then it will be embedded in a <code>pre</code> element to preserve space.</li>
              <li>showimage (default if the file extension is once of the supported image types) - includes the content using an html <code>img</code> element.</li>
            </ul>
          </li>
          <li><code>xpath</code> - describes which subset of the content (if the content is well formed HTML or XML) should be included using the standard XPath format when embedding content e.g. xpath="/*:Legislation/*:Metadata". Namespace prefixes can be used as log as they are declared in this XSLT. In order to more easily include images or annotations from the Oxygen-generated HTML documentation (and to ensure that complex and potentially changeable HTML paths are not hard coded into documentation) the user can utilise the following public functions:
            <ul>
              <li><code>cm:getImageFromTitle(contextNode, titleOfComponentInGeneratedDocumentation)</code> - e.g. to get the structure image map plus image for the "DocumentClassification" element we would use <code>href="schemaLegislationMetadata_xsd.html" xpath="cm:getImageFromTitle(.,'DocumentClassification')"</code></li>
              <li><code>cm:getImageFromId(contextNode, htmlIdOfComponentInGeneratedDocumentation)</code> - this performs the same role as above but uses the html id for the component that you want the structure image of (useful where the title is not simply the element/attribute/group name)</li>
              <li><code>cm:getAnnotationsFromTitle(contextNode, titleOfComponentInGeneratedDocumentation)</code> - e.g. to get the HTML annotation content of the "Year" element we would use <code>href="schemaLegislationMetadata_xsd.html" xpath="cm:getAnnotationsFromTitle(.,'Year')"</code></li>
              <li><code>cm:getAnnotationsFromId(contextNode, htmlIdOfComponentInGeneratedDocumentation)</code> - this performs the same role as above but uses the html id for the component that you want the annotation of (useful where the title is not simply the element/attribute/group name) e.g. <code>href="schemaLegislationMetadata_xsd.html" xpath="cm:getAnnotationsFromId(.,'AlternativeNumber_Value')"</code></li>
            </ul>
          </li>
          <li><code>xpathInner</code> - describes which <b>subset</b> of the <code>xpath</code> content (if the content is well-formed HTML or XML) should be included using the standard XPath format when embedding content. This is useful if you wanted to show the context of an element but not include all of its contents e.g. xpath="/*:Legislation/*:Metadata/*:SecondaryMetadata" xpathInner="*:Year|*:Number" will output the SecondaryMetadata element start and end but only output the Year and/or Number within it. If this attribute is used and <code>@fileref</code> is turned on the an extra paragraph is generated indicating that it is a partial sample.</li>
        </ul>
        <p>Any other attributes will be passed through to the HTML.</p>
        <p>This module also supports the generation a table of contents from <code>h1</code> headings of divs, where a <code>ci:toc</code> element is found.</p>
        <h1>id map file</h1>
        <p>While it is possible for schema developers to manually insert custom include elements inside the schema xs:documentation elements, it is easier to manage these (and keeps the schema annotations brief) if the custm includes are automatically injected via the id map file.</p>
        <p>When the code in genMoveAnnotations.xslt processes a schema element or attribute, it gathers the schema components' id. If the id attribute is present on the schema component then it is used otherwise an id is calculated based on the schema filename, the type of component and the component name (e.g. "schemaLegislationMetadata-E-AlternativeNumber").</p>
        <p>This id is then used as a key to a look-up in the id mapping file (finds an entry element in no namespace with the same id attribute) and all child custom include elements (or any other elements) are then included and processed. e.g. </p>
        <pre xml:space="preserve">
            &lt;entry id="schemaLegislationMetadata-E-DepartmentCode"&gt;
                &lt;ci:include href="uksi_20052087_en.xml" xpath="/*:Legislation/*:Metadata" fileref="Example taken from uksi_20052087_en (PDF p. 1, XML Ref. UG00202)"  source="example"/&gt;
                &lt;ci:include href="rgDepartmentCode.png" alt="Example taken from uksi_20052087_en (PDF p. 1, XML Ref. UG00202)" source="output"/&gt;
            &lt;/entry&gt;
        </pre>
        <h1>Other</h1>
        <p>The parameters used in this XSLT will be documented in the XProc "generateSchemaDoc.xpl"</p>
    </doc>
    
    <xsl:mode name="toc" on-no-match="shallow-skip"/>
    
    <xsl:param name="gpExtraDocFolder" as="xs:string"/>
    <xsl:param name="gpSampleXmlFolder" as="xs:string"/>
    <xsl:param name="gpOutputFolder" as="xs:string"/>
    <xsl:param name="gpSchemaIdMap" select="'schemaId2doc.map'" as="xs:string"/>
    <xsl:variable name="gvIdMap" select="document(concat($gpExtraDocFolder,'/',$gpSchemaIdMap))/*:idmap/*:entry" as="element()*"/>
    
    <xsl:variable name="gvIdTextStart" as="xs:string">
        <xsl:text>.//*[@*:id='</xsl:text>
    </xsl:variable>
    <xsl:variable name="gvIdTextEnd" as="xs:string">
        <xsl:text>']</xsl:text>
    </xsl:variable>
    
    <!-- ======== generate a Toc =========== -->
    <xsl:template match="ci:toc" priority="+1">
       <div class="contents" id="contents">
           <h1>Contents</h1>
            <xsl:apply-templates select="ancestor::body" mode="toc"/>
       </div>
    </xsl:template>
    
    <xsl:template match="ci:toc" mode="toc"/>
    
    <xsl:template match="div[@class='section']/h1" mode="toc">
        <p class="toc-{count(ancestor::div[@class='section'])}">
            <a href="#{if (@id) then @id else generate-id()}">
                <xsl:value-of select="."/>
            </a>
        </p>
    </xsl:template>
    
    <!--======= insert date automatically ===========-->
    
    <xsl:template match="ci:date" priority="+1">
       <xsl:value-of select="format-date(current-date(),'[D01]/[M01]/[Y0001]')"/>
    </xsl:template>
    
    <xsl:template match="ci:dateTime" priority="+1">
       <xsl:value-of select="format-dateTime(current-dateTime(),'[D01]/[M01]/[Y0001] [h1]:[m01]')"/>
    </xsl:template>
    
    <!-- ======== process includes  =========== -->
    
    <!-- so rather than have a ci that has already been resolved to one or more includes
        this is a reference to the map (easier to maintain in user guide -->
    <xsl:template match="ci:include[@id]" priority="+2">
        <xsl:variable name="vThisFileUri" select="base-uri(/)" as="xs:anyURI"/>
        <xsl:variable name="vComponentId" select="@id"/>
        <xsl:variable name="vMapEntry" select="$gvIdMap[@id=$vComponentId]" as="element()*"/>
        
        <xsl:apply-templates select="$vMapEntry/*">
            <xsl:with-param name="pThisFileUri" select="$vThisFileUri"/>
        </xsl:apply-templates>
    </xsl:template>
        
    <xsl:template match="ci:include" priority="+1">
        <xsl:variable name="pThisFileUri" select="base-uri(/)" as="xs:anyURI"/>
        <!--
            @show is either
            "new" open in target window
            "replace"  open in this window
            "embed"(default) - replace the link element with the content
            "showimage" - create an image reference
        -->  
        <xsl:variable name="vShow" as="xs:string?">
            <xsl:choose>
                <xsl:when test="(@show='showimage') or ends-with(@href,'.png') or ends-with(@href,'.jpg') or ends-with(@href,'.jpeg') or ends-with(@href,'.gif') or ends-with(@href,'.svg')">
                    <xsl:text>showimage</xsl:text>
                </xsl:when>
                <xsl:when test="@show">
                    <xsl:value-of select="@show"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>embed</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- either a URI or filename in default folder to a well formed XML file (including XHTML) -->
        <xsl:variable name="vFilename" as="xs:string">
            <xsl:choose>
                <xsl:when test="$vShow='showimage'">
                    <!-- exmaple output PNG we will just assume its local so no path change -->
                    <xsl:value-of select="@href"/>  
                </xsl:when>
                <xsl:when test="starts-with(@href, 'file:') or starts-with(@href, 'http:') or starts-with(@href, 'https:')">
                    <xsl:value-of select="@href"/>
                </xsl:when>
                <xsl:when test="ends-with(@href,'.xml')">
                    <xsl:value-of select="concat($gpSampleXmlFolder,'/',@href)"/>  
                </xsl:when>
                <xsl:when test="ends-with(@href,'.html')">
                    <!-- we will make sure generated Oxygen doc is .html so we can use that to know we look in output folder 
                    may be we should add an attribute to include element to link to this -->
                    <xsl:value-of select="concat($gpOutputFolder,'/',@href)"/>  
                </xsl:when>
                <xsl:otherwise>
                    <!-- if it is .htm file then presume it is a static piece of doc in extraDocs folder) -->
                    <xsl:value-of select="concat($gpExtraDocFolder,'/',@href)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="vFilename" select="if (contains($vFilename, '#')) then substring-before($vFilename, '#') else $vFilename" as="xs:string"/>
        <!-- 
        for any link type we only support 'idvalue' or '#idvalue' or user can add #idvalue to filename and this will only work on a file where @*:id='idvalue'
        otherwise a proper xpath will have to be constructed (and that will only work on embed not a web a link)
         -->
        <xsl:variable name="vXpath" as="xs:string?">
            <xsl:choose>
                <xsl:when test="($vShow = 'embed') and contains(@href, '#')">
                    <xsl:value-of select="concat($gvIdTextStart,substring-after(@href, '#'),$gvIdTextEnd)"/>
                </xsl:when>
                <xsl:when test="contains(@href, '#')">
                    <xsl:value-of select="concat('#',substring-after(@href, '#'))"/>
                </xsl:when>
                <xsl:when test="($vShow = 'embed') and starts-with(@xpath, '#')">
                    <xsl:value-of select="concat($gvIdTextStart,substring-after(@xpath, '#'),$gvIdTextEnd)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xpath"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- vXpathInsideSelector only applies to show="embed" -->
        <xsl:variable name="vXpathInsideSelector" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$vShow != 'embed'"/>
                <xsl:when test="starts-with(@xpathInner, '#')">
                    <xsl:value-of select="concat($gvIdTextStart,substring-after(@xpathInner, '#'),$gvIdTextEnd)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xpathInner"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>Need to {$vShow} {$vFilename} with selection {$vXpath} and optionally contents of {$vXpathInsideSelector} inside file {$pThisFileUri}</xsl:message>
        <xsl:choose>
            <xsl:when test="$vShow = 'showimage'">
                <img src="{$vFilename}">
                    <xsl:copy-of select="@*[not(local-name()=('id','href','show','source'))]"/>
                    <xsl:if test="(not(@class))">
                        <xsl:attribute name="class" select="if (@source) then @source else 'output'"/>
                    </xsl:if>
                </img>
            </xsl:when>
            <xsl:when test="$vShow='replace'">
                <a href="{concat($vFilename,$vXpath)}">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:when test="$vShow='new'">
                <a href="{concat($vFilename,$vXpath)}" target="_blank">
                    <xsl:apply-templates/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="vDoc" select="document($vFilename)" as="document-node()?"/>
                <xsl:variable name="vDocType" select="if (local-name($vDoc/*)='html') then 'html' else 'xml'" as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="$vDoc">
                        <xsl:try>
                            <xsl:variable name="vDocPart" as="node()*">
                                <!-- needs Saxon EE/PE or if using HE must be version 10 and above -->
                                <xsl:evaluate xpath="$vXpath" context-item="$vDoc"/>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$vDocPart">
                                    <xsl:choose>
                                        <xsl:when test="$vXpathInsideSelector">
                                            <xsl:for-each select="$vDocPart">
                                                <xsl:try>
                                                    <xsl:variable name="vDocPartSubContent" as="element()*">
                                                        <!-- needs Saxon EE/PE or if using HE must be version 10 and above -->
                                                        <xsl:evaluate xpath="$vXpathInsideSelector" context-item="."/>
                                                    </xsl:variable>
                                                    <xsl:choose>
                                                        <xsl:when test="$vDocPartSubContent">
                                                            <xsl:apply-templates select=".">
                                                                <xsl:with-param name="pDocType" select="$vDocType"/>
                                                                <xsl:with-param  name="pDocPartSubContent" select="$vDocPartSubContent"/>
                                                            </xsl:apply-templates>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:apply-templates select="$vDocPart">
                                                                <xsl:with-param name="pDocType" select="$vDocType"/>
                                                            </xsl:apply-templates>
                                                            <xsl:message>WARNING: found find included file {$vFilename} and resolved xPath {$vXpath} but could not find specified content {$vXpathInsideSelector} of that element so using whole part inside file {$pThisFileUri}</xsl:message>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                    <xsl:catch>
                                                        <xsl:message>ERROR  {$err:description}: evaluate failed on included file {$vFilename}  and resolved xPath {$vXpath} but could not find specified content {$vXpathInsideSelector} inside file {$pThisFileUri}</xsl:message>
                                                    </xsl:catch>
                                                </xsl:try>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:choose>
                                                <xsl:when test="($vDocType='html') and not($vDocPart/self::*) and not(@addPara='false')">
                                                    <p>
                                                        <xsl:apply-templates select="$vDocPart">
                                                            <xsl:with-param name="pDocType" select="$vDocType"/>
                                                        </xsl:apply-templates>
                                                    </p>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:apply-templates select="$vDocPart">
                                                        <xsl:with-param name="pDocType" select="$vDocType"/>
                                                    </xsl:apply-templates>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:message>ERROR: found included file {$vFilename} but cannot resolve xPath {$vXpath} inside file {$pThisFileUri}</xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:catch>
                                <xsl:message>ERROR {$err:description}: evaluate failed on included file {$vFilename} with xPath {$vXpath} inside file {$pThisFileUri}</xsl:message>
                            </xsl:catch>
                        </xsl:try>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>ERROR: cannot find included file {$vFilename} inside file {$pThisFileUri}</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <!-- Add file reference if requested or by default if we are embedding XML -->
        <xsl:if test="(@fileref and not(@fileref=('no',''))) or (not(@fileref) and ($vShow='embed') and ends-with(@href,'.xml'))">
            <p class="fileref">
                <b>Ref:</b>
                <xsl:text> </xsl:text>
                <xsl:choose>
                    <xsl:when test="@fileref and not(@fileref=('no','','yes'))">
                        <xsl:value-of select="@fileref"/>
                    </xsl:when>
                    <xsl:otherwise>{tokenize($vFilename,'/')[last()]}</xsl:otherwise>
                </xsl:choose>
            </p>
            <xsl:if test="$vXpathInsideSelector">
                <p class="fileref">
                    <b>Note:</b>
                    <xs:text> The content of this element has been reduced to make the example clearer.</xs:text>
                </p>
            </xsl:if>    
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:param  name="pDocType" select="'html'" as="xs:string"/>
        <!-- this is only populated if we are outputting part of an element -->
        <xsl:param  name="pDocPartSubContent" as="node()*"/>
        <xsl:param  name="pLevel" select="0" as="xs:integer"/>
        <xsl:param  name="pInitialIndent" select="''" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$pDocType='html'">
                <xsl:element name="{local-name()}">
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="if ($pDocPartSubContent) then $pDocPartSubContent else node()">
                        <xsl:with-param  name="pDocType" select="$pDocType"/>
                    </xsl:apply-templates>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$pLevel = 0">
                <!-- get the indent of the end element via the whitespace after end of first child -->
                <xsl:variable name="vInitialIndent" select="replace(*[last()]/following-sibling::text()[self::text()[normalize-space()=''] and (position() = last())],'\n','')" as="xs:string?"/>
                <xsl:variable name="vSampleXML" as="node()*">
                    <xsl:call-template name="outputEscapedStartElementName"/>
                    <xsl:choose>
                        <xsl:when test="$pDocPartSubContent">
                            <xsl:text>
</xsl:text>
                            <xsl:apply-templates select="$pDocPartSubContent">
                                <xsl:with-param name="pDocType" select="$pDocType"/>
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pInitialIndent" select="$vInitialIndent"/>
                            </xsl:apply-templates>
                            <xsl:text>
</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="node()">
                                <xsl:with-param name="pDocType" select="$pDocType"/>
                                <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                                <xsl:with-param name="pInitialIndent" select="$vInitialIndent"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="outputEscapedEndElementName"/>
                </xsl:variable>
                <!--<pre>TESTINDENTZ =<xsl:value-of select="string-to-codepoints($vInitialIndent)"/> END</pre>-->
                <pre xml:space="preserve"><xsl:sequence select="$vSampleXML"/></pre>
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:if test="($pLevel=1) and $pInitialIndent != ''">
                    <!-\- we measured the indent form the first child so we need to add in one tab here
                        IF there was a start indent-\->
                    <xsl:text>  </xsl:text>
                </xsl:if>-->
                 <xsl:call-template name="outputEscapedStartElementName"/>
                 <xsl:apply-templates select="node()">
                     <xsl:with-param name="pDocType" select="$pDocType"/>
                     <xsl:with-param name="pLevel" select="$pLevel + 1"/>
                     <xsl:with-param name="pInitialIndent" select="$pInitialIndent"/>
                 </xsl:apply-templates>
                 <!--<xsl:if test="($pLevel=1) and ($pInitialIndent != '') and contains(./text()[last()],'&#x09;')">
                    <!-\- we measured the indent form the first child so we need to add in one tab here
                    but NOT if the end element is on same line as start element-\->
                    <xsl:text>  </xsl:text>
                 </xsl:if>-->
                 <xsl:call-template name="outputEscapedEndElementName"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="outputEscapedStartElementName">
        <span class="tEl"><xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/></span>
        <xsl:for-each select="@*">
            <span class="tAN"><xsl:text> </xsl:text><xsl:value-of select="name()"/><xsl:text>=</xsl:text></span>
            <span class="tAV"><xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text></span>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="* or text()[normalize-space()]">
                <span class="tEl"><xsl:text>&gt;</xsl:text></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="tEl"><xsl:text>/&gt;</xsl:text></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="outputEscapedEndElementName">
        <xsl:if test="* or text()[normalize-space()]">
            <span class="tEl"><xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text></span>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="@*">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:param  name="pDocType" select="'html'" as="xs:string"/>
        <xsl:param  name="pLevel" select="0" as="xs:integer"/>
        <xsl:param  name="pInitialIndent" select="''" as="xs:string"/>
        <!--<xsl:variable name="vSmallerIndent" select="substring($pInitialIndent,1,string-length($pInitialIndent)-1)" as="xs:string?"/>-->
        <xsl:choose>
            <xsl:when test="$pDocType='html'">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <span class="tT">
                    <xsl:variable name="vValue" as="xs:string?">
                        <xsl:choose>
                            <xsl:when test="($pInitialIndent != '') and starts-with(.,$pInitialIndent)">
                                <!--<test t="1" this="{.}" pInitialIndent="{string-to-codepoints($pInitialIndent)}"/>-->
                                <xsl:value-of select="replace(.,concat('^',$pInitialIndent,'(.*)'),'$1')"/>
                            </xsl:when>
                            <xsl:when test="($pInitialIndent != '') and ends-with(.,$pInitialIndent)">
                                <!--<test t="2" this="{.}" pInitialIndent="{string-to-codepoints($pInitialIndent)}"/>-->
                                <xsl:value-of select="replace(.,concat('(.*)',$pInitialIndent,'$'),'$1')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <!--<test t="5" this="{.}" pInitialIndent="{string-to-codepoints($pInitialIndent)}" vSmallerIndent="{string-to-codepoints($vSmallerIndent)}"/>-->
                                <!--  do not use style="white-space:normal" loses indent as all space collapsed to one space -->
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- to stop indents getting too big, swap tabs for two spaces -->
                    <xsl:value-of select="replace($vValue,'\t','  ')"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="cm:getTableForComponentTitle" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:param name="pTitle" as="xs:string"/>
        <xsl:variable name="vTitle" select="normalize-space($pTitle)" as="xs:string"/>
        <xsl:sequence select="$pContextNode/root()//table[preceding-sibling::*[1]/self::div[@class='componentTitle' and (normalize-space(span[@class='qname']) = $vTitle)]]"/>   
    </xsl:function>
    
    <xsl:function name="cm:getAnnotationsFromTitle" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:param name="pTitle" as="xs:string"/>
        <xsl:variable name="vTitle" select="normalize-space($pTitle)" as="xs:string"/>
        <xsl:sequence select="cm:getTableForComponentTitle($pContextNode,$vTitle)/cm:getAnnotationFromTable(.)"/>   
    </xsl:function>
    
    <xsl:function name="cm:getImageFromTitle" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:param name="pTitle" as="xs:string"/>
        <xsl:variable name="vTitle" select="normalize-space($pTitle)" as="xs:string"/>
        <xsl:sequence select="cm:getTableForComponentTitle($pContextNode,$vTitle)//*:div[@id=concat('diagram_',$vTitle)]"/>   
    </xsl:function>
    
    <xsl:function name="cm:getAnnotationsFromId" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:param name="pId" as="xs:string"/>
        <xsl:sequence select="$pContextNode/root()//a[@id=$pId]/following-sibling::table[1]/cm:getAnnotationFromTable(.)"/>   
    </xsl:function>
    
    <xsl:function name="cm:getImageFromId" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:param name="pId" as="xs:string"/>
        <xsl:sequence select="$pContextNode/root()//a[@id=$pId]/following-sibling::table[1]//*:div[starts-with(@id,'diagram_')][1]"/>   
    </xsl:function>
    
    <xsl:function name="cm:getAnnotationFromTable" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:sequence select="$pContextNode//div[starts-with(@id,'annotations')]/div[@class='annotation']/node()"/>   
    </xsl:function>
</xsl:stylesheet>