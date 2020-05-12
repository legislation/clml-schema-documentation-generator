<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:copyFiles" name="copyFiles"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <p>Copy files from input folder to output folder (and any subfolders)</p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:option required="true" name="pInputFolder"/>
    <p:option required="true" name="pOutputFolder"/>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="getFolderList.xpl"/>
    
    <p:choose>
      <p:when test="($pInputFolder != '') and ($pOutputFolder != '')">
        <!-- get list of files in input folder -->
        <cm:getFolderList>
          <p:with-option name="pFolderPath" select="$pInputFolder"/>
        </cm:getFolderList>
       <!-- <p:identity name="imagelist"/>
        <p:store href="file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDoc/imagelist.xml"/>
        <p:identity>
          <p:input port="source">
            <p:pipe port="result" step="imagelist"></p:pipe>
          </p:input>
        </p:identity>-->
        <p:filter select="//*:file"/> 
        <p:for-each name="iterateHTML" >
          <p:variable name="vFilename" select="/*/@relname"/>
          <cxf:copy fail-on-error="false">
              <p:with-option name="href" select="concat($pInputFolder, '/', $vFilename)"/>
              <p:with-option name="target" select="concat($pOutputFolder,'/', $vFilename)"/>
          </cxf:copy>
        </p:for-each>
      </p:when>
    </p:choose>
    
</p:declare-step>