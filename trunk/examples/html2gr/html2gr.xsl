<?xml version="1.0" encoding="windows-1250"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:m="http://graph2svg.googlecode.com"
	xmlns:gr="http://graph2svg.googlecode.com"
	exclude-result-prefixes="m xh" version="2.0">
	
<xsl:include href="msgr2svg.xsl"/>

<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<xsl:param name="tabNum" select="1"/> <!--poradi tabulky ve vstupnim souboru kterou pozadujeme-->
<xsl:param name="dataCols" select="2 to 12"/> <!--v kterych sloupcich jsou data - sekvence-->
<xsl:param name="dataRows" select="3 to 6"/> <!--v kterych radcich jsou data - sekvence-->
<xsl:param name="titlesCol" select="1"/> <!--v kterem sloupci jsou nazvy datovych rad (legenda)-->
<xsl:param name="namesRow" select="2"/> <!--v kterem radku je rada jmen (x-ova osa)-->
<xsl:param name="grTitleRow" select="1"/> <!--v kterem radku je nadpis celeho grafu-->
<xsl:param name="grTitleCol" select="1"/> <!--v kterem sloupci je nadpis celeho grafu-->


<xsl:template match="/">
	<xsl:variable name="graph">
		<xsl:apply-templates select="(//xh:table)[$tabNum]"/>
	</xsl:variable>
	<xsl:call-template name="m:msgr2svg">
		<xsl:with-param name="graph" select="$graph/gr:msgr"/>
	</xsl:call-template>
	<!--xsl:apply-templates select="(//xh:table)[$tabNum]"/-->
</xsl:template>

<xsl:template match="xh:table">
	<xsl:variable name="rows" select="(xh:tr|xh:tbody/xh:tr|xh:thead/xh:tr|xh:tfoot/xh:tr)"/> 
	<gr:msgr pointType="cross">
	<gr:title><xsl:value-of select="(m:row2seq($rows[$grTitleRow]))[$grTitleCol]"/></gr:title>
	<gr:names>
	<xsl:for-each select="(m:row2seq($rows[$namesRow]))[position() = $dataCols]">
		<gr:name>
		<xsl:value-of select="."/>
		</gr:name>
	</xsl:for-each>
	</gr:names>
	<xsl:for-each select="$rows[position() = $dataRows]">
		<gr:values>
		<title> <xsl:value-of select="m:row2seq(.)[$titlesCol]"/> 	</title>
		<xsl:for-each select="m:row2seq(.)[position() = $dataCols]">
			<gr:value>
			<xsl:value-of select="translate(., ',+', '.')"/>
			</gr:value>
		</xsl:for-each>
		</gr:values>
	</xsl:for-each>
	</gr:msgr>
</xsl:template>

<xsl:function name="m:row2seq"> 
	<xsl:param name="row"/>
	<xsl:sequence select="
			for $a in $row/(xh:td|xh:th) return
				if ($a/@colspan) then (
					(for $b in (1 to $a/@colspan) return $a)
				) else $a"/>
</xsl:function>

</xsl:stylesheet>

