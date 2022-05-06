<?xml version="1.0" encoding="UTF-8"?>
<!--
XSpec copyright (c) 2008-2017 Jeni Tennison

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:test-helper="x-urn:xspec:helper:ws-only-text:test-helper"
	xmlns:worker="x-urn:xspec:helper:ws-only-text:test-helper:worker"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:output encoding="UTF-8" indent="no" method="xml"/>
	
	<xsl:accumulator name="should-collapse-whitespace-start" initial-value="true()">
		<xsl:accumulator-rule match="//text()">
			<xsl:choose>
				<xsl:when test="not(preceding::text()[normalize-space()])">
					<xsl:sequence select="true()"/>
				</xsl:when>
				<xsl:when test="not(preceding-sibling::text()[normalize-space()]) and matches(worker:apply-whitespace-normalization((preceding::text())[1], true(), false()), ' $')">
					<xsl:sequence select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:accumulator-rule>
	</xsl:accumulator>
	
	<!--
		This test helper function just removes whitespace-only text nodes from the input document.
		All the other nodes are kept intact.
	-->
	<xsl:function as="document-node()" name="test-helper:remove-whitespace-only-text">
		<xsl:param as="document-node()" name="input-document" />

		<xsl:apply-templates mode="worker:remove-whitespace-only-text" select="$input-document" />
	</xsl:function>

	<!--
		mode="worker:remove-whitespace-only-text"
		This mode does the real job.
		
		Note:
		- Use a dedicated mode to avoid clashes with the test target stylesheet.
		- You can't use @on-no-match="shallow-copy". The test target stylesheet may have
		  xsl:template[@mode = '#all'].
	-->
	<xsl:mode name="worker:remove-whitespace-only-text" on-multiple-match="fail" on-no-match="fail" />

	<!-- Identity template -->
	<xsl:template as="node()" match="attribute() | document-node() | node()"
		mode="worker:remove-whitespace-only-text">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!-- Discard whitespace-only text nodes -->
	<xsl:template as="empty-sequence()" match="text()[not(normalize-space())]" priority="+10"
		mode="worker:remove-whitespace-only-text" />
	
	<!-- This test helper follows as closely as possible the HTML inline formatting context
	     whitespace normalisation rules. -->
	<xsl:function as="document-node()" name="test-helper:normalize-whitespace-like-html">
		<xsl:param as="document-node()" name="input-document" />
		
		<xsl:apply-templates mode="worker:normalize-whitespace-like-html" select="$input-document" />
	</xsl:function>
	
	<!-- This test helper transforms the element using other available templates then applies
		whitespace normalisation. -->
	<xsl:template as="document-node()" name="test-helper:transform-and-normalize-whitespace-like-html">
		<xsl:variable name="pre-whitespace">
			<!-- PA 30/4/22: by default apply-templates selects children, so select="." necessary to retain context item -->
			<xsl:apply-templates select="."/>
		</xsl:variable>
		<xsl:apply-templates mode="worker:normalize-whitespace-like-html" select="$pre-whitespace" />
	</xsl:template>
	
	<!-- Identity template -->
	<xsl:template as="node()" match="attribute() | document-node() | node()"
		mode="worker:normalize-whitespace-like-html">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>
	
	<!-- PA 30/4/22 TODO: fix so this matches XML formatting rules? -->
	<xsl:template as="text()" match="text()" priority="+5" 
		mode="worker:normalize-whitespace-like-html">
		<xsl:variable name="collapse-start" select="accumulator-before('should-collapse-whitespace-start')"/>
		<xsl:variable name="collapse-end" select="not(following::text()[normalize-space()]) or not(following-sibling::*) or not(parent::*/text()[normalize-space()])"/>
		
		<xsl:message>$collapse-start is <xsl:value-of select="$collapse-start"/> at text node “<xsl:value-of select="."/>”</xsl:message>
		
		<xsl:value-of select="worker:apply-whitespace-normalization(., $collapse-start, $collapse-end)"/>
	</xsl:template>
	
	<xsl:function as="text()" name="worker:apply-whitespace-normalization">
		<xsl:param as="text()" name="input-node"/>
		<xsl:param as="xs:boolean" name="collapse-start"/>
		<xsl:param as="xs:boolean" name="collapse-end"/>
		
		<xsl:choose>
			<xsl:when test="$input-node/ancestor::pre or $input-node/ancestor::*[@xml:space][1]/@xml:space = 'preserve'">
				<xsl:sequence select="$input-node"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="result" select="replace($input-node, '[ \t]+(\r\n|\r|\n)[ \t]+', '$1')"/>
				<xsl:variable name="result" select="replace($result, '\t', ' ')"/>
				<xsl:variable name="result" select="replace($result, '(\r\n|\r|\n)', ' ')"/>
				<xsl:variable name="result" select="replace($result, '  +', ' ')"/>
				<xsl:variable name="result" select="if ($collapse-start) then replace($result, '^ +', '') else $result"/>
				<xsl:variable name="result" select="if ($collapse-end) then replace($result, ' +$', '') else $result"/>
				<xsl:value-of select="$result"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>