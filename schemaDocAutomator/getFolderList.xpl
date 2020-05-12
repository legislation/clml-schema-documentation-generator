<?xml version="1.0" encoding="UTF-8"?>

<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step"  xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:getFolderList" name="getFolderList"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
        <h:p>Gets a recursive folder list then post process it so that sub-folder paths are easily accessible using @relname</h:p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" primary="true">
        <p:pipe port="result" step="xsltFolderList"/>
    </p:output>
    
    <p:option required="true" name="pFolderPath"/>
    
    <p:import href="recursive-directory-list.xpl"/>
    
    <p:load href="addRelnameForFolders.xsl"/>
    <p:identity name="addRelnameXSLT"/>
    <p:sink/>
    
    <cm:recursive-directory-list depth="-1" name="getconvertedXSDList">
        <p:with-option name="path" select="$pFolderPath"/>
    </cm:recursive-directory-list>
    
    <!-- Colin: Add relative paths to relname attribute so we can keep subfolders in output if we transform data -->
    <p:xslt name="xsltFolderList">
      <p:input port="parameters"><p:empty/></p:input>
      <p:input port="stylesheet">
          <p:pipe port="result" step="addRelnameXSLT"/>
      </p:input>
    </p:xslt>
</p:declare-step>