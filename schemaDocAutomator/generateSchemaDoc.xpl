<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xo="http://xmlopen.org/xproc" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
  
  <p:documentation>
    <h:p>Top-level XProc script to run to produce schem documentation.</h:p>
    <h:p>Prepares schemas, ingests mapped content and Generates HTML schema documentation using Oxygen.</h:p>
    <h:p>Script will:</h:p>
    <h:ul>
     <h:li>convert from RNG (if source is specified as RNG in param) using Trang (this will have to be tailored to final RNG structure and costume annotations when available))</h:li>
     <h:li>It will then pull comments form RNG into XSD as these are not kept in all cases (and any custom or xhtml elements are lost) when Trang is run</h:li>
     <h:li>manipulate XSD comments and pull in custom include link references to other content by looking up fixed or auto-generated schema ids in a map file</h:li>
     <h:li>Run oxygen script with configured settings to create XHTML plus navigation images</h:li>
     <h:li>Post process the XHTML to resolve custom includes and to manipulate frame and navigation</h:li>
     <h:li>Post process will also optionally process any user guide file (passed as a parameter) including any contents and generating a table of contents from <h:code>h1</h:code> headings of divs, where a <h:code>ci:toc</h:code> element is found.</h:li>
    </h:ul>
    <h:p>For a description of the HTML manipulation please refer to the documentation in "postProcessHTML.xslt"</h:p>
    <h:p>For a description of the custom include mechanism, its attributes and the id map file please refer to the documentation in "processIncludes.xsl"</h:p>
    <h:h1>XProc Parameters</h:h1>
    <h:p>While the following parameters are not mandatory (as they have defaults specified in the <code>select</code> attribute) it is better to pass the min from Oxygen or a calling bat file.</h:p>
    <h:ul>
      <h:li>pWorkingDirectoryPath - the path to the directory where all of the code and temp folders live. This needs to be specified to provide context when launching the bat files that convert schemas or call Oxygen.</h:li>
      <h:li>pInputFolderUri - the URI to the folder location where the schema to be document lives (schemas can be spread across sub-folders)</h:li>
      <h:li>pInputSchemaFile - the relative path from pInputFolderUri to the top-level schema that we are documenting.</h:li>
      <h:li>pStartURL - the HTML output file (and optionally id within that file) that should shown as the initial content of the main page in the generated reference guide help</h:li>
      <p:li>pGenerateConfigIDpara - if this is set to the string 'true' AND if no custom includes have been specified for a component of type 'source' or 'output' then a helpful message is generated instead of the auto-generated XML instance. Set to 'false; while developing or updating documentation then set to 'false' for final customer facing build.</p:li>
      <h:li>pTempFolder - the URI where temporary files are created. Note: sub-folders are used to store different files for different stages. As these may be useful when debugging, these are kept until the process is run again.</h:li>
      <h:li>pExtraDocFolder - the URI to where additional material that will be processed is held. This includes the user guide XHTML skeleton, the linkmap and any static HTML that may be dynamically included. </h:li>
      <h:li>pSampleXmlFolder - the URI for the folder where XML source samples are held (and whose contents will be included using the custom include mechanism)</h:li>
      <h:li>pHtmlAssetsFolder - the name of the SUB folder (of pExtraDocFolder) that will contain additional content that needs to be copied to the final folder (e.g. images of rendered examples). This sub folder will be created in the output folder. Keeping this folder structure the same in input and output means that the user guide author will be able to view the images in the editor and the references will still be correct in the final output.</h:li>
      <h:li>pSchemaMapFile - the name of the map file in the pExtraDocFolder folder for this schema that associates includes with element ids.</h:li>
      <h:li>pReferenceGuide - the name of the reference guide XHTML Frame file to be created in the pOutputFolder.</h:li>
      <h:li>pUserGuide - the name of the user guide skeleton XHTML to be processed after the reference guide has been created. This is also the filename that the final HTML output file for the user guide will use. If this is empty then no user guide will be processed and no link to the user guide created in the reference guide navigation.</h:li>
      <h:li>pOxySettingsFilename - the name of the Oxygen XSD generation settings file.</h:li>
      <h:li>pOxygenOutputFolder - the URI of the folder to which Oxygen output will be written (note: this folder is cleaned out at the start of processing)</h:li>
      <h:li>pOutputFolder - the URI of the folder to which the final output will be written by this script (note: this folder is cleaned out at the start of processing)</h:li>
    </h:ul>
    <h:h1>Other Configuration</h:h1>
    <h:p>This software has been tested with oXygen XML Editor 21.0, build 2019022207</h:p>
    <h:p>As the XSLT is XSLT3, a suitable version of Saxon is required. As the XSLTs use the <code>xsl:evaluate</code> element then a Porfessional (PE) version or Enterprise (EE) version or any version after v10 is required.</h:p>
    <h:p>If the Oxygen schema documentation is to be run in a scheduled automatic fashion then a script licence is required. see <a href="https://www.oxygenxml.com/oxygen_scripting.html">https://www.oxygenxml.com/oxygen_scripting.html</a>.</h:p>
    <h:p><h:b>The launchOxygen.bat and trang.bat files must be edited so that the paths used internally are correct for the deployed environment.</h:b></h:p>
  </p:documentation>
  
  <p:option required="false" name="pWorkingDirectoryPath" select="'C:/Users/colin/schemaDoc/schemaDocAutomator'"/>
  
  <!--Prototype test of RNG
  <p:option required="false" name="pInputFolderUri" select="'./testRngInput'"/>
  <p:option required="false" name="pInputSchemaFile" select="'a.rng'"/>
  <p:option required="false" name="pReferenceGuide" select="'a-reference.html'"/>
  <p:option required="false" name="pStartURL" select="'a.html#Legislation'"/>-->
  
  <p:option required="false" name="pInputFolderUri" select="'file:/C:/Users/colin/unified-master-schema'"/>
  <p:option required="false" name="pInputSchemaFile" select="'schema/legislation.xsd'"/>
  <p:option required="false" name="pExtraDocFolder" select="'file:/C:/Users/colin/unified-master-schema/schemaDoc/CLMLfiles/extraDocFolder'"/>
  <p:option required="false" name="pHtmlAssetsSubFolder" select="'img'"/>
  <p:option required="false" name="pSampleXmlFolder" select="'file:/C:/Users/colin/unified-master-schema/schemaDoc/CLMLfiles/sampleXML'"/>
  <p:option required="false" name="pSchemaMapFile" select="'schemaId2doc.map'"/>
  <p:option required="false" name="pReferenceGuide" select="'CLMLreferenceGuide-v2-1.html'"/>
  <p:option required="false" name="pStartURL" select="'schemaLegislationCore_xsd.html#Legislation'"/>
  <p:option required="false" name="pUserGuide" select="'CLMLuserGuide-v2-1.html'"/>
  
  <p:option required="false" name="pTempFolder" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDoc/temp/schemaTempFolder'"/>
  <p:option required="false" name="pOxygenOutputFolder" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDoc/temp/oxygenOutput'"/>
  <p:option required="false" name="pOutputFolder" select="'file:/C:/Users/colin/Documents/newco/TSO/TNA/schemaDoc/finalOutput'"/>
  
  <p:option required="false" name="pOxySettingsFilename" select="'oxygenSettings.xml'"/>
  
  <p:option required="false" name="pGenerateConfigIDpara" select="'false'"/>

  <p:input port="source" sequence="true" >
        <p:empty/>
  </p:input>
  <p:output port="result" sequence="true" />
  
  <p:import href="deleteAndMakeFolder.xpl"/>
  <p:import href="rng2xsd.xpl"/>
  <p:import href="xsdGenMoveComments.xpl"/>
  <p:import href="generateHTMLdoc.xpl"/>
  <p:import href="populateHTMLdoc.xpl"/>
  <p:import href="copyFiles.xpl"/>
  
  <!--<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>-->
  <p:import href="library-1.0.xpl"/>
  
 
  <p:group>
     <!-- need to clear out temp and output folders-->
     <xo:deleteAndMakeFolder>
       <p:with-option name="pFolder" select="concat($pTempFolder,'/rng2xsd')"/>
     </xo:deleteAndMakeFolder>
     <xo:deleteAndMakeFolder>
       <p:with-option name="pFolder" select="$pOxygenOutputFolder"/>
     </xo:deleteAndMakeFolder>
     <xo:deleteAndMakeFolder>
       <p:with-option name="pFolder" select="$pOutputFolder"/>
     </xo:deleteAndMakeFolder>
     <p:choose>
       <p:when test="ends-with($pInputSchemaFile,'rng')">
         <xo:rng2xsd>
           <p:with-option name="pInputFolderUri" select="$pInputFolderUri"/>
           <p:with-option name="pInputSchemaFile" select="$pInputSchemaFile"/>
           <p:with-option name="pTempFolder" select="$pTempFolder"/>
           <p:with-option name="pWorkingDirectoryPath" select="$pWorkingDirectoryPath"/>
         </xo:rng2xsd>
         <!-- to do ensure that any file or element or attribute ids in RNG custom markup are treated like schema element ids and then
           add linkmap processing like we do for xsd files (by re-using a common XSLT) -->
       </p:when>
       <p:otherwise>
         <xo:xsdGenMoveComments>
           <p:with-option name="pInputFolderUri" select="$pInputFolderUri"/>
           <p:with-option name="pTempFolder" select="$pTempFolder"/>
           <p:with-option name="pExtraDocFolder" select="$pExtraDocFolder"/>
           <p:with-option name="pSchemaMapFile" select="$pSchemaMapFile"/>
         </xo:xsdGenMoveComments>
       </p:otherwise>
     </p:choose>
    
    <xo:generateHTMLdoc>
      <p:with-option name="pInputSchemaFile" select="$pInputSchemaFile"/>
      <p:with-option name="pTempFolder" select="$pTempFolder"/>
      <p:with-option name="pWorkingDirectoryPath" select="$pWorkingDirectoryPath"/>
      <p:with-option name="pExtraDocFolder" select="$pExtraDocFolder"/>
      <p:with-option name="pSampleXmlFolder" select="$pSampleXmlFolder"/>
      <p:with-option name="pStartURL" select="$pStartURL"/>
      <p:with-option name="pUserGuide" select="$pUserGuide"/>
      <p:with-option name="pReferenceGuide" select="$pReferenceGuide"/>
      <p:with-option name="pOxygenOutputFolder" select="$pOxygenOutputFolder"/>
      <p:with-option name="pOxySettingsFilename" select="$pOxySettingsFilename"/>
      <p:with-option name="pOutputFolder" select="$pOutputFolder"/>
    </xo:generateHTMLdoc>
     
    <!-- now process the user guide-->
    <xo:populateHTMLdoc>
      <p:with-option name="pHtmlFilename" select="$pUserGuide"/>
      <p:with-option name="pExtraDocFolder" select="$pExtraDocFolder"/>
      <p:with-option name="pSampleXmlFolder" select="$pSampleXmlFolder"/>
      <p:with-option name="pReferenceGuide" select="$pReferenceGuide"/>
      <p:with-option name="pOutputFolder" select="$pOutputFolder"/>
      <p:with-option name="pSchemaMapFile" select="$pSchemaMapFile"/>
      <p:with-option name="pGenerateConfigIDpara" select="$pGenerateConfigIDpara"/>
    </xo:populateHTMLdoc>
       
    <!-- then copy any supporting files into the output -->
    <xo:copyFiles>
      <p:with-option name="pInputFolder" select="concat($pExtraDocFolder,'/',$pHtmlAssetsSubFolder)"/>
      <p:with-option name="pOutputFolder" select="concat($pOutputFolder,'/',$pHtmlAssetsSubFolder)"/>
    </xo:copyFiles>
  </p:group>
  
</p:declare-step>
