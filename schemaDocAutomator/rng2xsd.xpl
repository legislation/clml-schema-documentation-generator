<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cm="http://macksol.co.uk" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
    xmlns:cx="http://xmlcalabash.com/ns/extensions" type="cm:rng2xsd" name="rng2xsd"
    xmlns:xh="http://www.w3.org/1999/xhtml" version="1.0">
    
    <p:documentation>
      <h:p>Prototype conversion of an RNG file to an XSD file then attempts to copy structured (xhtml or custom) comments over as these are dropped by Trang</h:p>
    </p:documentation>
    
    <p:input port="source" sequence="true" >
        <p:empty/>
    </p:input>
    
    <p:output port="result" sequence="true"/>
    
    <p:option required="true" name="pInputFolderUri"/>
    <p:option required="true" name="pInputSchemaFile"/>
    <p:option required="true" name="pTempFolder"/>
    <p:option required="true" name="pWorkingDirectoryPath"/>
    
    <p:import href="library-1.0.xpl"/>
    <p:import href="getFolderList.xpl"/>
    
    <p:load name="copyCommentXSLT" href="copyDocFromRNGtoConvertedXSD.xsl"/>
    <p:sink/>
    
    <p:try>
        <p:group>
            <p:group>
                <p:variable name="vInputSchemaFileNoExt" select="substring-before($pInputSchemaFile,'.')"/>
                <p:variable name="vInputFolderWinPath" select="replace(substring-after($pInputFolderUri,'file:/'),'/','\\')"/>
                <p:variable name="vTrangArgs" select="concat('/C CALL trang.bat',' ',$vInputFolderWinPath,'\',$pInputSchemaFile,' ',$pTempFolder,'\rng2xsd\',$vInputSchemaFileNoExt,'.xsd')"/>
                <!-- this is really picky if it is to work
                a) need to set cwd to the current directory using windows path
                b) need to set input schema file path using windows path
                c) need to specify output path using windows relative folder only 
                -->
                    
                <p:exec name="rng2xsdbat" command="cmd.exe" source-is-xml="false" result-is-xml="false" cx:show-stderr="true">
                    <p:with-option name="cwd" select="$pWorkingDirectoryPath"/>
                    <p:with-option name="args" select="$vTrangArgs"/>
                    <p:input port="source"><p:empty/></p:input>
                </p:exec>
             </p:group>
            
              <!-- so now we need to run the XSLT that transfers structured documentation for source RNG to XSD
                (as Trang does not support this)
              So first get the list of  files in sub folders -->
              <cm:getFolderList>
                <p:with-option name="pFolderPath" select="concat($pTempFolder,'/rng2xsd')"/>
              </cm:getFolderList>
                  
              <p:filter select="//*:file[ends-with(@name,'.xsd') or ends-with(@name,'.xs')]"/> 
              <p:for-each name="iterate" >
                    <p:variable name="vInputXSD" select="/*/@relname"/>
                    <p:variable name="vFullPathInputXSD" select="concat($pTempFolder,'/rng2xsd/',$vInputXSD)"/>
                    <cx:message>
                        <p:with-option name="message" select="concat('Copying comments using ',$vFullPathInputXSD, ' to ', concat($pTempFolder,'/xsd/',$vInputXSD))"/>
                    </cx:message>
                    <p:load name="xsdInput">
                        <p:with-option name="href" select="$vFullPathInputXSD"/>
                    </p:load>
                    <p:xslt name="runCopyCommentXSLT">
                        <p:input port="parameters"><p:empty/></p:input>
                        <p:input port="stylesheet">
                            <p:pipe port="result" step="copyCommentXSLT"/>
                        </p:input>
                        <p:with-param name="gpRNGfilename" select="concat($pInputFolderUri,'/', if (ends-with($vInputXSD,'.xs')) then substring-before($vInputXSD,'.xs') else substring-before($vInputXSD,'.xsd'), '.rng')"/>
                    </p:xslt>
                    <p:store name="xsdWithComments">
                      <p:with-option name="href" select="concat($pTempFolder,'/xsd/',$vInputXSD)"/>
                    </p:store>
              </p:for-each>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
        </p:group>
        <p:catch>
            <p:identity>
              <p:input port="source">
                <p:empty/>
              </p:input>
            </p:identity>
            <cx:message message="Error converting from RNG to XSD"/>
        </p:catch>
    </p:try>
</p:declare-step>