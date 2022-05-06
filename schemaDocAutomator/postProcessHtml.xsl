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
        <p>This XSLT post-processes Oxygen XSD documentation html (or any user guide HTML) for user guide and help content.</p>
        <p>The code in this file will manipulate the Oxygen generated frame and navigation contents to best suit our needs.</p>
        <p>The code will also match on the correct point in Oxygens component table where we want to insert source or example content in place of Oxygens auto-generated instance mark-up (which is not helpful).</p>
        <p>The code in the included file "processIncludes.xsl" will process the custom includes in the documentation.</p>
        <p>For a description of the custom include mechanism and its attributes please refer to the documentation in "processIncludes.xsl"</p>
    </doc>
    
    <xsl:output indent="false" method="xhtml" encoding="UTF-8" />
    
    <xsl:mode name="toc" on-no-match="shallow-skip"/>
    
    <xsl:param name="gpGenerateConfigIDpara" select="'false'" as="xs:string"/>
    <xsl:param name="gpStartingURL" as="xs:string"/>
    <xsl:param name="gpUserGuide" as="xs:string?"/>
    <xsl:param name="gpReferenceGuide" as="xs:string"/>
    <xsl:param name="gpDocFilesSubFolder" as="xs:string?"/>
    
    <xsl:include href="processIncludes.xsl"/>
    
    <xsl:template match="/">
        <!--<xsl:message>Processing {base-uri(.)}</xsl:message>-->
        <xsl:apply-templates/>
        <!--<xsl:message>END Processing {base-uri(.)}</xsl:message>-->
    </xsl:template>
    
    <xsl:template match="comment()"/>
    
    <!-- PA 5/5/22: support reprocessing of sidebar ToC for user guide -->
    <xsl:template match="head">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates/>
            
            <xsl:if test="ends-with(document-uri(root()), concat('/', $gpUserGuide))">
                <script type="text/javascript">
                var userGuideIndexPage = '<xsl:value-of select="substring-before($gpReferenceGuide, '.html')"/>.indexUserGuide.html';
                if (!!parent.indexFrame) {{
                  if (!(parent.indexFrame.location.pathname.endsWith(userGuideIndexPage))) {{
                    parent.indexFrame.location = userGuideIndexPage;
                  }}
                }}
                </script>
            </xsl:if>
            
            <xsl:if test="matches(document-uri(root()), '(\.index[a-zA-Z]+|schHierarchy)\.html?$')">
                <script type="text/javascript">
                var startIndexPage = '<xsl:value-of select="substring-before($gpReferenceGuide, '.html')"/>.indexListcomp.html';
                var userGuideIndexPage = '<xsl:value-of select="substring-before($gpReferenceGuide, '.html')"/>.indexUserGuide.html';
                
                document.addEventListener('DOMContentLoaded', function() {{
                    var startPageLink = document.getElementById('startPageLink');
                    var userGuideLink = document.getElementById('userGuideLink');
                    
                    startPageLink.addEventListener('click', function(e) {{
                        if (!(window.location.pathname.endsWith(startIndexPage))) {{
                            window.location = startIndexPage;
                        }}
                    }});
                    userGuideLink.addEventListener('click', function(e) {{
                        if (!(window.location.pathname.endsWith(userGuideIndexPage))) {{
                            window.location = userGuideIndexPage;
                        }}
                    }});
                }});
                </script>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <!-- PA 6/5/22: add support for doc files sub-folder -->
    <xsl:template match="link[@rel='stylesheet']">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except @href"/>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$gpDocFilesSubFolder and ends-with(document-uri(root()), concat('/', $gpReferenceGuide))">
                        <xsl:value-of select="concat($gpDocFilesSubFolder, '/', @href)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- PA 6/5/22: add support for doc files sub-folder -->
    <xsl:template match="script[@src]">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@* except @src"/>
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="$gpDocFilesSubFolder and ends-with(document-uri(root()), concat('/', $gpReferenceGuide))">
                        <xsl:value-of select="concat($gpDocFilesSubFolder, '/', @src)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@src"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="script">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="frame[@name='mainFrame']">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <!-- PA 6/5/22: add support for doc files sub-folder -->
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="$gpDocFilesSubFolder">
                        <xsl:value-of select="concat($gpDocFilesSubFolder, '/', $gpStartingURL)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$gpStartingURL"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <!-- showing toc be namespace by default gives users most useful element list -->
    <xsl:template match="frame[@name='indexFrame']">
        <xsl:variable name="vDefaultIndexPage" select="concat(substring-before($gpReferenceGuide,'.html'),'.indexListcomp.html')"/>
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <!-- PA 6/5/22: add support for doc files sub-folder -->
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="$gpDocFilesSubFolder">
                        <xsl:value-of select="concat($gpDocFilesSubFolder, '/', $vDefaultIndexPage)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$vDefaultIndexPage"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <!-- e.g. list by component
            <xsl:attribute name="src" select="'reference.indexListcomp.html'"/>
            or list by namespace
            <xsl:attribute name="src" select="'reference.indexListns.html'"/> -->
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class='annotation']">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <!-- we will not output links or content that are intend for the "instance" section of the documentation
                This could be a ci:include or ci:appInfo with the particular source attribute values -->
            <xsl:apply-templates select="node()[not(@source=('example','output')) and not(@class=('example','output'))]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="div[@class='section']/*[self::h2 or self::h3 or self::h4 or self::h5]">
        <xsl:copy copy-namespaces="no">
            <xsl:attribute name="id">
              <xsl:apply-templates select="." mode="generate-slug"/>
            </xsl:attribute>
            <!-- overwrite with original id if it has one -->
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- manipulate toc to pull list of elements to the top as its what most users will want 
    home.indexListns.html-->
    <xsl:template match="div[cm:isElementListContainer(.)]" priority="+1">
        <xsl:variable name="vElementToc" select="./div[cm:isElementToc(.)]" as="element()?"/>
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="$vElementToc"/>
            <xsl:apply-templates select="* except $vElementToc"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- add in link to user guide -->
    <xsl:template match="h2[.='Table of Contents']" priority="+1">
        <xsl:next-match/>
        <!-- replace with a parameter -->
				<!-- PA 5/5/22: Add link to return to start page -->
        <p>
            <a href="{$gpStartingURL}" target="mainFrame" id="startPageLink">Start Page</a> | 
            <a href="{$gpUserGuide}" target="mainFrame" id="userGuideLink">User Guide</a></p>
    </xsl:template>
    
    
    <!-- so (unlike above) Oxygen has NOT made an Instance row in the table and so 
    we need to insert one-->
    <xsl:template match="tr[cm:isSourceRow(.)]" priority="+1">
        <xsl:variable name="vNewInstanceContent" as="node()*">
            <xsl:call-template name="insertExampleAndOutput"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$vNewInstanceContent[self::* or text()[normalize-space()]]">
                <!--  there is some content ot insert so create a new instance row with that content -->
                <xsl:variable name="vName" select="substring-after(td[1]//input[starts-with(@id,'button_source_')]/@id,'button_source_')" as="xs:string"/>
                <tr>
                    <td class="firstColumn" rowspan="1" colspan="1">
                       <div class="floatLeft"><b>Instance</b></div>
                       <div class="floatRight"><input id="button_instance_{$vName}" type="image" src="img/btM.gif" value="-" onclick="switchState('instance_{$vName}');" class="control"/></div>
                    </td>
                    <td rowspan="1" colspan="1">
                       <div id="instance_{$vName}" style="display:block">
                          <table style="table-layout:fixed;white-space:pre-wrap;white-space:-moz-pre-wrap;white-space:-pre-wrap;white-space: -o-pre-wrap;word-wrap: break-word;_white-space:pre;" class="preWrapContainer">
                             <tr>
                                <td width="100%" rowspan="1" colspan="1">
                                    <xsl:sequence select="$vNewInstanceContent"/>
                                </td>
                             </tr>
                          </table>
                       </div>
                    </td>
                 </tr>
            </xsl:when>
            <xsl:otherwise>
                <!-- we will just output the normal instance row here -->
                <xsl:apply-templates select="(preceding-sibling::tr[cm:isInstanceRow(.)]|following-sibling::tr[cm:isInstanceRow(.)])[1]" mode="outputOriginal"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- now process the current (Source) row -->
        <xsl:next-match/>
    </xsl:template>
    
    <!-- I have found that sometimes oxygen outputs the source row before the attributes row for some tables
        this used to mean we ended up with two of these (the original and the one stuck in by code above that allows for where there is no source row at all
        I would rather it always appear at the same position (after attributes) so we will kill the initial match and always insert using template above
        Where we DO want to output original instance we need to match using the specific mode -->
    <xsl:template match="tr[cm:isInstanceRow(.)]" />
    
    <xsl:template match="tr[cm:isInstanceRow(.)]" mode="outputOriginal">
        <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- = check for broken internal links = -->
    <xsl:template match="a[starts-with(@href, '#')]">
        <xsl:variable name="vAnchor" select="substring(@href, 2)"/>
        <xsl:choose>
            <xsl:when test="key('kId', $vAnchor, root(.))">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="vAnchorAltRegex" select="string-join(('', tokenize($vAnchor, '(-| )+'), ''), '.*')"/>
                <xsl:variable name="vAlternatives">
                    <xsl:sequence select="(//div[@class='section']/*[self::h2 or self::h3 or self::h4 or self::h5]|//*[@id])/leg:getNodeId(.)[matches(., $vAnchorAltRegex)]"/>
                </xsl:variable>
                <xsl:message terminate="yes">
                    <xsl:text>ERROR: Broken internal link with anchor </xsl:text>
                    <xsl:value-of select="@href"/>
                    <xsl:text> at </xsl:text>
                    <xsl:value-of select="path(.)"/>
                    <xsl:choose>
                        <xsl:when test="$vAlternatives">
                            <xsl:text>. Perhaps you meant to use one of the following anchors: </xsl:text>
                            <xsl:value-of select="string-join($vAlternatives, ', ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>. Check the anchor and try again.</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- change any static links to the reference guide to the name supplied 
        in order to save the user form manually changing for every version if 
        the reference filename contains version  -->
    <xsl:template match="a/@href[starts-with(.,'reference.html') and $gpReferenceGuide]" priority="+1">
        <xsl:attribute name="href">
            <!-- PA 6/5/22: add support for doc files sub-folder -->
            <xsl:value-of select="concat(if ($gpDocFilesSubFolder) then '../' else '', $gpReferenceGuide)"/>
            <xsl:if test="contains(.,'#')">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="substring-after(.,'#')"/>
            </xsl:if>
        </xsl:attribute>
    </xsl:template>
    
    <!-- change any static links to the user guide to the name supplied 
        in order to save the user form manually changing for every version if 
        the user filename contains version  -->
    <xsl:template match="a/@href[starts-with(.,'userguide.html') and $gpUserGuide]" priority="+1">
        <xsl:attribute name="href">
            <xsl:value-of select="$gpUserGuide"/>
            <xsl:if test="contains(.,'#')">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="substring-after(.,'#')"/>
            </xsl:if>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="insertExampleAndOutput">
        <!-- to do add proper logic and function 
        ancestor::table[@class='rt']/preceding-sibling
        -->
        <xsl:variable name="vInstanceAnnotations" select="cm:getAnnotationFromInstance(.)[(@source=('example','output')) or (@class=('example','output'))]" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$vInstanceAnnotations">
                <xsl:for-each select="$vInstanceAnnotations">
                    <xsl:choose>
                        <xsl:when test="self::ci:include">
                            <xsl:apply-templates select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$gpGenerateConfigIDpara='true'">
                <div>
                    <p>
                        <xsl:variable name="vComponentTitleDiv" select="cm:getComponentTitleDiv(.)" as="element()?"/>
                        <xsl:variable name="vType" select="normalize-space($vComponentTitleDiv/text())" as="xs:string?"/>
                        <xsl:variable name="vName" select="normalize-space($vComponentTitleDiv/span[@class='qname'])" as="xs:string?"/>
                        <xsl:variable name="vId" as="xs:string?">
                            <xsl:choose>
                                <xsl:when test="not($vType = ('Element','Attribute')) or not($vName)"/>
                                <xsl:otherwise>
                                    <xsl:variable name="vFilename" select="tokenize(base-uri(/),'/')[last()]"/>
                                    <xsl:value-of>
                                        <xsl:value-of select="substring-before($vFilename, '_xsd')"/>
                                        <xsl:text>-</xsl:text>
                                        <xsl:value-of select="if ($vType = 'Element') then 'E' else 'A'"/>
                                        <xsl:text>-</xsl:text>
                                        <xsl:value-of select="$vName"/>
                                    </xsl:value-of>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:text>No example XML or source image configured</xsl:text>
                        <xsl:if test="$vId">
                            <xsl:text> - this can be added using the schemaId2doc.map file using id </xsl:text>
                            <xsl:value-of select="$vId"/>
                        </xsl:if>
                    </p>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="cm:isSourceRow" as="xs:boolean" visibility="public">
        <xsl:param name="pTr" as="element()"/>
        <xsl:sequence select="exists($pTr[(normalize-space(string-join(td[1]//text(),''))='Source') and not(ancestor::div[@id='global_controls'])])"/> 
    </xsl:function>
    
    <xsl:function name="cm:isInstanceRow" as="xs:boolean" visibility="public">
        <xsl:param name="pTr" as="element()"/>
        <xsl:sequence select="exists($pTr[(normalize-space(string-join(td[1]//text(),''))='Instance') and not(ancestor::div[@id='global_controls'])])"/> 
    </xsl:function>
    
    <xsl:function name="cm:isElementListContainer" as="xs:boolean" visibility="public">
        <xsl:param name="pDiv" as="element()"/>
        <xsl:sequence select="exists($pDiv[self::div/ancestor::div[@class='toc'] and child::div[@class='horizontalLayout']])"/>   
    </xsl:function>
    
    <xsl:function name="cm:isElementToc" as="xs:boolean" visibility="public">
        <xsl:param name="pDiv" as="element()"/>
        <xsl:sequence select="exists($pDiv[self::div[(@class='horizontalLayout') and .//div[(@class='componentGroupTitle') and (.='Elements')]]])"/>   
    </xsl:function>
    
    <xsl:function name="cm:isInstancePre" as="xs:boolean" visibility="public">
        <xsl:param name="pPre" as="element()*"/>
        <xsl:sequence select="exists($pPre[self::pre]/ancestor::div[starts-with(@id,'instance_')])"/>   
    </xsl:function>
    
    <xsl:function name="cm:getAnnotationFromInstance" as="node()*" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:sequence select="$pContextNode/ancestor::table[preceding-sibling::*[1]/self::div/@class='componentTitle']/cm:getAnnotationFromTable(.)"/>   
    </xsl:function>
    
    <xsl:function name="cm:getComponentTitleDiv" as="element()?" visibility="public">
        <xsl:param name="pContextNode" as="node()"/>
        <xsl:sequence select="$pContextNode/ancestor::table[preceding-sibling::*[1]/self::div[@class='componentTitle']]/preceding-sibling::*[1]/self::div[@class='componentTitle']"/>   
    </xsl:function>
</xsl:stylesheet>
