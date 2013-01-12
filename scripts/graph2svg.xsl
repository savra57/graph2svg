<?xml version="1.0" encoding="windows-1250"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
	xmlns:m="http://graph2svg.googlecode.com"
	xmlns:gr="http://graph2svg.googlecode.com"
	>
<xsl:variable name="graph" select="./gr:*"/>

<xsl:include href="graph2svg_common.xsl"/>

<xsl:include href="osgr2svg.xsl"/>
<xsl:include href="msgr2svg.xsl"/>
<xsl:include href="xygr2svg.xsl"/>

<xsl:output method="xml" encoding="utf-8"/>

<xsl:template match="gr:osgr">
	<xsl:call-template name="m:osgr2svg"/>
</xsl:template>

<xsl:template match="gr:msgr">
	<xsl:call-template name="m:msgr2svg"/>
</xsl:template>

<xsl:template match="gr:xygr">
	<xsl:call-template name="m:xygr2svg"/>
</xsl:template>

</xsl:stylesheet>
