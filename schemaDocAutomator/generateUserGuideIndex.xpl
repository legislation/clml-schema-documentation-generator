<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:leg="http://www.legislation.gov.uk/namespaces/legislation" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="leg:generateUserGuideIndex" name="generateUserGuideIndex"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <h:p>Process index page (for sidebar) to produce index page for User Guide</h:p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:option required="true" name="pUserGuide"/>
    <p:option required="true" name="pReferenceGuide"/>
    <p:option required="true" name="pOutputFolder"/>
    
    <p:load name="generateUserGuideIndexXSLT" href="generateUserGuideIndex.xsl"/>
    <p:sink/>
    
    <p:load dtd-validate="false">
        <p:with-option name="href" select="concat($pOutputFolder,'/',substring-before($pReferenceGuide, '.html'), '.indexListcomp.html')"/>
    </p:load>
    <p:xslt name="runuserGuideIndexXSLT">
        <p:input port="parameters"><p:empty/></p:input>
        <p:input port="stylesheet">
            <p:pipe port="result" step="generateUserGuideIndexXSLT"/>
        </p:input>
        <p:with-param name="gpOutputFolder" select="$pOutputFolder"/>
        <p:with-param name="gpUserGuide" select="$pUserGuide"/>
    </p:xslt>
    <p:store name="userGuideIndexOut">
        <p:with-option name="href" select="concat($pOutputFolder,'/', substring-before($pReferenceGuide, '.html'), '.indexUserGuide.html')"/>
    </p:store>
    
</p:declare-step>