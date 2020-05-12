<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step"  xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:xsdGenMoveComments" name="xsdGenMoveComments"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <h:p>Processes all XSDs in advance of running schema documentation generation</h:p>
      <h:p>This process will</h:p>
      <h:ol>
          <h:li>take appinfo and move it into xsd:documentation so it is retained in html by oxygen</h:li>
          <h:li>will use element/attr id if it exists otherwise combine filename, E or A and local-name to use as a look-up into a id map xml file that will inject includes to extra information</h:li>
          <h:li>make sure that any of this stuff is not shown in help data</h:li>
      </h:ol>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:option required="true" name="pInputFolderUri"/>
    <p:option required="true" name="pTempFolder"/>
    <p:option required="true" name="pExtraDocFolder"/>
    <p:option required="true" name="pSchemaMapFile"/>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="getFolderList.xpl"/>
    
    <p:load name="genMoveXsdAnnotationsXSLT" href="genMoveXsdAnnotationsXSLT.xsl"/>
    <p:sink/>
    
    <cm:getFolderList>
        <p:with-option name="pFolderPath" select="$pInputFolderUri"/>
    </cm:getFolderList>
          
    <p:filter select="//*:file[ends-with(@name,'.xsd') or ends-with(@name,'.xs')]"/> 
    <p:for-each name="iterate" >
        <p:variable name="vInputXSD" select="/*/@relname"/>
        <p:variable name="vFullPathInputXSD" select="concat($pInputFolderUri,'/',$vInputXSD)"/>
        <cx:message>
            <p:with-option name="message" select="concat('Generating and moving comments from ',$vFullPathInputXSD, ' to ', concat($pTempFolder,'/xsd/',$vInputXSD))"/>
        </cx:message>
        <p:load name="xsdInput">
            <p:with-option name="href" select="$vFullPathInputXSD"/>
        </p:load>
        <p:xslt>
            <p:input port="parameters"><p:empty/></p:input>
            <p:input port="stylesheet">
                <p:pipe port="result" step="genMoveXsdAnnotationsXSLT"/>
            </p:input>
            <p:with-param name="gpExtraDocFolder" select="$pExtraDocFolder"/>
            <p:with-param name="gpSchemaIdMap" select="$pSchemaMapFile"/>
        </p:xslt>
        <p:store name="xsdWithMovedGenComments">
          <p:with-option name="href" select="concat($pTempFolder,'/xsd/',$vInputXSD)"/>
        </p:store>
    </p:for-each>
    
</p:declare-step>