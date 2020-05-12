<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:generateHTMLdoc" name="generateHTMLdoc"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <p>Generate HTML documentation form input using Oxygen scripts.</p>
      <p>The Oxygen settings file is configurable.</p>
      <p><b>NOTE</b> : we want to use the settings so we can customise the output as much as possible without development.
      Unfortunately the output path and filename is part of the settings and MUST be used rather than specified as another argument (if settings file is used).
      To get around this we open up the setting file like a template, finding the path
      /serialized/serializableOrderedMap/entry/xsdDocumentationOptions/field[@name='unexpandedOutputFile']/String
      element and populate it, save it to a temp folder then use that.</p>
      <p><b>Note</b> : The settign values should not be chnaged without good reason and lots of testing. By changing the output contents you risk breaking the HTML post process. Also, when trying the various chunkign (split) options for the HTML I found that other splitting options tried on on the CLML schema resulted in Oxygen accidentally tidying up too many temp files and deleted lost of required html files.</p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true"/>
    
    <p:option required="true" name="pInputSchemaFile"/>
    <p:option required="true" name="pTempFolder"/>
    <p:option required="true" name="pWorkingDirectoryPath"/>
    <p:option required="true" name="pExtraDocFolder"/>
    <p:option required="true" name="pSampleXmlFolder"/>
    <p:option required="true" name="pStartURL"/>
    <p:option required="false" name="pUserGuide" select="''"/>
    <p:option required="true" name="pReferenceGuide"/>
    <p:option required="true" name="pOxygenOutputFolder"/>
    <p:option required="true" name="pOxySettingsFilename"/>
    <p:option required="true" name="pOutputFolder"/>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="getFolderList.xpl"/>
    
    <p:load name="postProcessHtmlXSLT" href="postProcessHtml.xsl"/>
    <p:sink/>
    
    <p:group>
        <p:variable name="vInputSchemaFileNoExt" select="substring-before($pInputSchemaFile,'.')"/>
        <p:variable name="vInputFolderWinPath" select="replace(concat(substring-after($pTempFolder,'file:/'),'/xsd/',$vInputSchemaFileNoExt,'.xsd'),'/','\\')"/>
        <p:variable name="vOutputFolderWinPath" select="replace(substring-after($pOxygenOutputFolder,'file:/'),'/','\\')"/>
        <p:variable name="vSettingsFolderWinPath" select="replace($pWorkingDirectoryPath,'/','\\')"/>
        <p:variable name="vSettingsTempFilename" select="concat(replace(substring-before(xs:string(current-dateTime()),'.'),':',''),'.xml')"/>
        <p:variable name="vOxyArgs" select="concat('/C CALL launchOxygen.bat ',$vInputFolderWinPath,' -cfg:',$vSettingsFolderWinPath,'\',$vSettingsTempFilename)"/>
         
      <!-- using an exported settings file is handy and makes it easy for people to configure,
          however the filename/path is stored in the file as
          <field name="unexpandedOutputFile">
					<String>file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDocAutomator/oxygenOutput/home.html</String>
				</field>
				so we will load the settings file, set the path to the file, store it as a temporary file the use it and delete it
         -->
        <p:group>
          <p:load>
            <p:with-option name="href" select="$pOxySettingsFilename"/>
          </p:load>
          <p:string-replace match="/serialized/serializableOrderedMap/entry/xsdDocumentationOptions/field[@name='unexpandedOutputFile']/String/text()">
            <p:with-option name="replace" select="concat('&quot;',$pOxygenOutputFolder,'/',$pReferenceGuide,'&quot;')"/>
          </p:string-replace>
          <p:store>
            <p:with-option name="href" select="$vSettingsTempFilename"/>
          </p:store>
        </p:group>
        <!--<p:try>-->
          <p:group>
            <p:exec name="xsd2html" command="cmd.exe" source-is-xml="false" result-is-xml="false" cx:show-stderr="true">
              <p:with-option name="cwd" select="$pWorkingDirectoryPath"/>
              <p:with-option name="args" select="$vOxyArgs"/>
                <p:input port="source"><p:empty/></p:input>
            </p:exec>
            <p:sink/>
          
            <cm:getFolderList>
              <p:with-option name="pFolderPath" select="$pOxygenOutputFolder"/>
            </cm:getFolderList>
            <p:identity name="oxyFileList"/>
        
            <p:filter select="//*:file[ends-with(@name,'.html') or ends-with(@name,'.htm')]"/> 
            <p:for-each name="iterateHTML" >
              <p:variable name="vHTMLfilename" select="/*/@relname"/>
              <p:variable name="vFullPathInputHTML" select="concat($pOxygenOutputFolder, '/', $vHTMLfilename)"/>
              <cx:message>
                  <p:with-option name="message" select="concat('HTML post processing ',$vFullPathInputHTML)"/>
              </cx:message>
              <p:load name="xhtmInput">
                  <p:with-option name="href" select="$vFullPathInputHTML"/>
              </p:load>
              <p:xslt name="runHtmlXSLT">
                  <p:input port="parameters"><p:empty/></p:input>
                  <p:input port="stylesheet">
                      <p:pipe port="result" step="postProcessHtmlXSLT"/>
                  </p:input>
                  <p:with-param name="gpExtraDocFolder" select="$pExtraDocFolder"/>
                  <p:with-param name="gpSampleXmlFolder" select="$pSampleXmlFolder"/>
                  <p:with-param name="gpOutputFolder" select="$pOutputFolder"/>
                  <p:with-param name="gpStartingURL" select="$pStartURL"/>
                  <p:with-param name="gpUserGuide" select="$pUserGuide"/>
                  <p:with-param name="gpReferenceGuide" select="$pReferenceGuide"/>
              </p:xslt>
              <p:store name="htmlOut">
                <p:with-option name="href" select="concat($pOutputFolder,'/', $vHTMLfilename)"/>
              </p:store>
            </p:for-each>
            
            <!-- move the CSS and image folder to the final output -->  
            <p:identity>
              <p:input port="source">
                <p:pipe port="result" step="oxyFileList"/>
              </p:input>
            </p:identity>
            <p:filter select="//*:file[not(ends-with(@name,'.html') or ends-with(@name,'.htm'))]"/>
            <p:for-each name="iterateOther">
              <p:variable name="vFilename" select="/*/@relname"/>
              <p:variable name="vFullPathInput" select="concat($pOxygenOutputFolder, '/', $vFilename)"/>
              <cx:message>
                  <p:with-option name="message" select="concat('Moving ',$vFullPathInput, ' to ', $pOutputFolder, '/', $vFilename)"/>
              </cx:message>
              <cxf:move>
                  <p:with-option name="href" select="$vFullPathInput"/>
                  <p:with-option name="target" select="concat($pOutputFolder, '/', $vFilename)"/>
              </cxf:move>
            </p:for-each>
          
            <cxf:delete>
              <p:with-option name="href" select="$vSettingsTempFilename"/>
            </cxf:delete>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
          </p:group>
          <!--<p:catch>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
            <cx:message message="Error generating HTML documentation"/>
          </p:catch>-->
        <!--</p:try>-->
  </p:group>
    
</p:declare-step>