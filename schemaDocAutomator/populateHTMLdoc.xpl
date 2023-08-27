<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:populateHTMLdoc" name="populateHTMLdoc"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <h:p>Process HTML template/shell and update its content pulling in other static files or content generated from the Oxygen script</h:p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:option required="true" name="pHtmlFilename"/>
    <p:option required="true" name="pExtraDocFolder"/>
    <p:option required="true" name="pSampleXmlFolder"/>
    <p:option required="true" name="pReferenceGuide"/>
    <p:option required="true" name="pUserGuide"/>
    <p:option required="true" name="pOutputFolder"/>
    <p:option required="true" name="pSchemaMapFile"/>
    <p:option required="true" name="pGenerateConfigIDpara"/>
    
    <p:load name="postProcessHtmlXSLT" href="postProcessHtml.xsl"/>
    <p:sink/>
    
    <p:load dtd-validate="false">
      <p:with-option name="href" select="concat($pExtraDocFolder,'/',$pHtmlFilename)"/>
    </p:load>
    <p:xslt name="runuserGuideXSLT">
        <p:input port="parameters"><p:empty/></p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="postProcessHtmlXSLT"/>
        </p:input>
        <p:with-param name="gpExtraDocFolder" select="$pExtraDocFolder"/>
        <p:with-param name="gpSampleXmlFolder" select="$pSampleXmlFolder"/>
        <p:with-param name="gpOutputFolder" select="$pOutputFolder"/>
        <p:with-param name="gpSchemaIdMap" select="$pSchemaMapFile"/>
        <p:with-param name="gpGenerateConfigIDpara" select="$pGenerateConfigIDpara"/>
        <p:with-param name="gpReferenceGuide" select="$pReferenceGuide"/>
        <p:with-param name="gpUserGuide" select="$pUserGuide"/>
    </p:xslt>
    <!-- PA 15/5/23: have to set an XHTML 1.0 Transitional doctype here:
        * Can't use HTML5 because Calabash apparently chokes when outputting HTML
        * XHTML 1.0 Strict and 1.1 don't allow (i)frames -->
    <p:store name="userGuideOut">
      <p:with-option name="href" select="concat($pOutputFolder,'/', $pHtmlFilename)"/>
      <p:with-option name="doctype-public" select="'-//W3C//DTD XHTML 1.0 Transitional//EN'"/>
      <p:with-option name="doctype-system" select="'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'"/>
    </p:store>
    
</p:declare-step>