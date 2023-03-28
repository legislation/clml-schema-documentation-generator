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
    <p:option required="true" name="pAdditionalHtmlSubFolder"/>
    <p:option required="true" name="pStartURL"/>
    <p:option required="false" name="pUserGuide" select="''"/>
    <p:option required="true" name="pReferenceGuide"/>
    <p:option required="true" name="pOxygenOutputFolder"/>
    <p:option required="true" name="pOxySettingsFilename"/>
    <p:option required="true" name="pOxygenPath"/>
    <p:option required="true" name="pOutputFolder"/>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="getFolderList.xpl"/>
    <p:import href="copyFiles.xpl"/>
    
    <p:load name="postProcessHtmlXSLT" href="postProcessHtml.xsl"/>
    <p:sink/>
    
    <p:group>
        <!-- PA 11/3/22 - the XProc p:exec step treats space as an arg separator by default even if quoted, so quoting won't be sufficient -->
        <!--<p:variable name="vQuote" select="'&quot;'"/>-->
        <p:variable name="vTab" select="'&#9;'"/>
        
        <!-- PA 11/3/22 - removing the substitution of / here to ensure Unix compatibility -->
        <!-- PA 28/3/23 - fixing substitution for Unix systems -->
        <p:variable name="vInputSchemaFileNoExt" select="substring-before($pInputSchemaFile,'.')"/>
        <p:variable name="vInputFolderLocalPath" select="concat(replace(replace($pTempFolder,'file:/([A-Za-z]:/)','$1'),'file:',''),'/xsd/',$vInputSchemaFileNoExt,'.xsd')"/>
      
        <!-- PA 11/3/22 - removing the substitution of / here to ensure Unix compatibility
        <p:variable name="vOxygenPath" select="replace(substring-after($pOxygenPath,'file:/'),'/','\\')"/>
        <p:variable name="vSettingsFolderLocalPath" select="replace($pWorkingDirectoryPath,'/','\\')"/> -->
        <p:variable name="vOxygenPath" select="substring-after($pOxygenPath,'file:/')"/>
        <p:variable name="vSettingsFolderLocalPath" select="$pWorkingDirectoryPath"/>
        
        <!-- PA 11/3/22 - the XProc p:exec step treats space as an arg separator by default even if quoted, so quoting won't be sufficient
          (see https://www.w3.org/TR/xproc/#c.exec) - using multiple quotes here was breaking paths with spaces on my machine
        <p:variable name="vOxygenPathQuotes" select='concat($vQuote,$vOxygenPath,$vQuote)'/>
        <p:variable name="vInputFolderLocalPathQuotes" select='concat($vQuote, $vInputFolderLocalPath, $vQuote)'/> -->
        <p:variable name="vSettingsTempFilename" select="concat(replace(substring-before(xs:string(current-dateTime()),'.'),':',''),'.xml')"/>
        <p:variable name="vSettingsTempFullPath" select="concat('file:/', $vSettingsFolderLocalPath, '/', $vSettingsTempFilename)"/>
      
        <!-- PA 11/3/22 - changing launchOxygen script call to enable cross-platform compatibility
          The XProc p:exec step treats space as an arg separator by default even if quoted, so quoting won't be sufficient
          (see https://www.w3.org/TR/xproc/#c.exec) so using the tab character as a separator instead - note that we have to concat together
          strings that should be part of the *same* argument
        <p:variable name="vOxyArgs" select="string-join(('/C', 'CALL', 'launchOxygen.bat', $vInputFolderLocalPath, concat('-cfg:', $vSettingsFolderLocalPath, '/',$vSettingsTempFilename),$vOxygenPathQuotes), $vTab)"/>  -->
        <p:variable name="vOxyArgs" select="string-join(($vInputFolderLocalPath, concat('-cfg:', $vSettingsFolderLocalPath, '/',$vSettingsTempFilename),$vOxygenPath), $vTab)"/>
         
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
          <cx:message>
            <p:with-option name="message" select="concat('!!!! vOxygenPath ',$vOxygenPath, ' vOxyArgs ', $vOxyArgs)"/>
          </cx:message>
          <p:string-replace match="/serialized/serializableOrderedMap/entry/xsdDocumentationOptions/field[@name='unexpandedOutputFile']/String/text()">
            <p:with-option name="replace" select="concat('&quot;',$pOxygenOutputFolder,'/',$pReferenceGuide,'&quot;')"/>
          </p:string-replace>
          <p:store>
            <p:with-option name="href" select="$vSettingsTempFullPath"/>
          </p:store>
        </p:group>
        <!--<p:try>-->
          <p:group>
            <!-- PA 11/3/22 - changing launchOxygen script call to enable cross-platform compatibility -->
            <p:try name="xsd2html">
              <p:group>
                <p:output port="result"><p:pipe port="result" step="xsd2htmlwin"/></p:output>
                <p:exec name="xsd2htmlwin" source-is-xml="false" result-is-xml="false">
                  <p:with-option name="command" select="'cmd.exe'"/>
                  <p:with-option name="cwd" select="$pWorkingDirectoryPath"/>
                  <p:with-option name="args" select="string-join(('/C','CALL','launchOxygen.bat',$vOxyArgs), $vTab)"/>
                  <p:with-option name="arg-separator" select="$vTab"/>
                  <p:input port="source"><p:empty/></p:input>
                </p:exec>
              </p:group>
              <p:catch>
                <p:output port="result"><p:pipe port="result" step="xsd2htmlother"/></p:output>
                <p:exec name="xsd2htmlother" source-is-xml="false" result-is-xml="false">
                  <p:with-option name="command" select="'sh'"/>
                  <p:with-option name="cwd" select="$pWorkingDirectoryPath"/>
                  <p:with-option name="args" select="string-join(('launchOxygen.sh', $vOxyArgs), $vTab)"/>
                  <p:with-option name="arg-separator" select="$vTab"/>
                  <p:input port="source"><p:empty/></p:input>
                </p:exec>
              </p:catch>
            </p:try>
            <!-- PA 11/3/22 - outputting the stdout using cx:message makes it easier to debug -->
            <cx:message>
              <p:with-option name="message" select=".">
                <p:pipe port="result" step="xsd2html"/>
              </p:with-option>
            </cx:message>
          </p:group>
          <p:group>
            
            <!-- PA 5/5/2022 copy additional HTML to intermediate output folder, after generation to avoid that overwriting anything -->
            <cm:copyFiles>
              <p:with-option name="pInputFolder" select="concat($pExtraDocFolder,'/',$pAdditionalHtmlSubFolder)"/>
              <p:with-option name="pOutputFolder" select="$pOxygenOutputFolder"/>
            </cm:copyFiles>
          
            <cm:getFolderList>
              <p:with-option name="pFolderPath" select="$pOxygenOutputFolder"/>
            </cm:getFolderList>
            <p:identity name="oxyFileList"/>
        
            <p:filter select="//*:file[ends-with(@name,'.html') or ends-with(@name,'.htm')]"/> 
            <p:for-each name="iterateHTML" >
              <p:variable name="vHTMLfilename" select="/*/@relname"/>
              <p:variable name="vOutputPath" select="concat($pOutputFolder,'/', $vHTMLfilename)"/>
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
                <p:with-option name="href" select="$vOutputPath"/>
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
              <p:with-option name="href" select="$vSettingsTempFullPath"/>
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