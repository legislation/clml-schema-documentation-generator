<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:deleteAndMakeFolder" name="deleteAndMakeFolder"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <p>Deletes a folder then recreates it</p>
      <p>Calabash is erroring on use of wildcard so using recursive delete of the folder BUT we mkdir the folder first as it also errors if it does not exist</p>
      <p>Following process failures (or file locks) you may get mkdir errors that will disappear if the process is re-run</p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true">
        <p:empty/>
    </p:output>
    
    <p:option required="true" name="pFolder"/>
    
    <p:import href="library-1.0.xpl"/>
    
    <cxf:mkdir>
      <p:with-option name="href" select="$pFolder"/>
      <p:with-option name="fail-on-error" select="'false'"/>
    </cxf:mkdir>
    <cxf:delete>
      <p:with-option name="href" select="$pFolder"/>
      <p:with-option name="recursive" select="'true'"/>
      <p:with-option name="fail-on-error" select="'false'"/>
    </cxf:delete>
    <cxf:mkdir>
      <p:with-option name="href" select="$pFolder"/>
      <p:with-option name="fail-on-error" select="'false'"/>
    </cxf:mkdir>
</p:declare-step>