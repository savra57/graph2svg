<?xml version="1.0" encoding="windows-1250"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:m="http://graph2svg.googlecode.com"
	xmlns:gr="http://graph2svg.googlecode.com"
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:math="http://exslt.org/math"	
	extension-element-prefixes="math"
	exclude-result-prefixes="m math xs gr"
	version="2.0">
 
<xsl:variable name="pi"  select="3.14159265359"/>
<xsl:variable name="logDiv"  select="0.301, 0.176, 0.125, 0.097, 0.079, 0.067, 0.058, 0.051, 0.046"/>     <!-- log10(i) - log10(i-1)   pro i=2,3,..,10 -->


<!--******************************************************************************-->
<!--*********************************** common constants *************************-->
<!--******************************************************************************-->

<!-- Constants can be overwritten in some scripts -->

<xsl:variable name="titleMargin"  select="m:Att('titleMargin', 10)"/>
<xsl:variable name="titleFontSize"  select="m:Att('titleFontSize', 18)"/>
<xsl:variable name="labelFontSize"  select="m:Att('labelFontSize', 10)"/>
<xsl:variable name="labelFontWd"  select="0.68"/>  <!-- average length of letter divided a font high -->
<xsl:variable name="labelAngle"  select="m:Att('labelAngle', 25)"/>
<xsl:variable name="graphMargin"  select="m:Att('graphMargin', 15)"/>
<xsl:variable name="yAxisMarkDist"  select="m:Att('yAxisMarkDist', 25)"/>
<xsl:variable name="defaultMarkAutoCount"  select="11"/> <!-- automatic choice will try to be close to this values -->
<xsl:variable name="axesAutoCoef"  select="0.8"/>  <!-- coefficient used for decision weather to display 0 when automatically choosing axes range -->
<xsl:variable name="axesStroke-width" select="1"/>
<xsl:variable name="legendMargin"  select="m:Att('legendMargin', 15)"/>
<xsl:variable name="legendPictureWd"  select="m:Att('legendPictureWd', 28)"/>
<xsl:variable name="legendPictureHg"  select="m:Att('legendPictureHg', 20)"/>    <!-- height of the pictogram in the legend, have to be less then legendLineHg-->
<xsl:variable name="legendGap"  select="m:Att('legendGap', 5)"/>
<xsl:variable name="legendFontSize"  select="m:Att('legendFontSize', 10)"/>
<xsl:variable name="legendFontWd"  select="0.61"/>
<xsl:variable name="legendLineHg"  select="m:Att('legendLineHg', 24)"/>  <!-- high of a row in legend -->

<xsl:variable name="majorMarkLen"  select="3"/>  <!-- 1/2 of the length of major marks on axes -->
<xsl:variable name="majorMarkStroke-width" select="1"/>
<xsl:variable name="minorMarkLen" select="2"/>  <!-- 1/2 of the length of minor marks on axes-->
<xsl:variable name="minorMarkStroke-width" select="0.5"/>
<xsl:variable name="majorGridStroke-width" select="0.4"/>
<xsl:variable name="majorGridColor" select=" '#222' "/>
<xsl:variable name="minorGridStroke-width" select="0.2"/>
<xsl:variable name="minorGridColor" select=" '#111' "/>


<!-- color schemas definitions -->
<xsl:variable name="colorSchemeColor" select="('#14f', '#ff1', '#f0d', '#3f1', '#f33', '#1ff', '#bbb', '#13b', '#909', '#a81', '#090', '#b01', '#555')"/>  
<xsl:variable name="colorSchemeCold" select="('#07bbbb', '#09a317', '#19009f', '#9a0084', '#6efaff', '#88f917', '#a9a7f6', '#fbbbf3', '#002dff', '#ff00bf')"/>  
<xsl:variable name="colorSchemeWarm" select="('#d82914', '#f2ee15', '#21ab03', '#c5a712', '#a4005a', '#f17a2e', '#c9f581', '#ffbcc5', '#ffffc4', '#f8887f')"/>
<xsl:variable name="colorSchemeGrey" select="('#ccc', '#888', '#444', '#eee', '#aaa', '#666', '#222')"/>  
<xsl:variable name="colorSchemeBlack" select="('black')"/>


<!--******************************************************************************-->
<!--*********************************** common variables *************************-->
<!--******************************************************************************-->
<!-- 2D / 3D - for osgr and msgr -->
<xsl:variable name="depthX" select="if ($graph/@effect = '3D') then 8 else 0"/>
<xsl:variable name="depthY" select="if ($graph/@effect = '3D') then 8 else 0"/>

<xsl:variable name="yAxisDiv"  select="m:AxisDivision($graph/@yAxisDivision)"/>
<xsl:variable name="xAxisDiv"  select="m:AxisDivision($graph/@xAxisDivision)"/>


<!--******************************************************************************-->
<!--*********************************** SVG functions and templates **************-->
<!--******************************************************************************-->

<!-- draw the SVG document description and the graph title -->
<xsl:template name="m:drawDescritptionAndTitle">
	<xsl:param name="width"/>
	
	<!-- SVG document description -->
	<svg:desc><xsl:value-of select="$graph/m:title"/></svg:desc>  

	<!-- type the graph title -->
	<svg:g>
	<xsl:if test="count($graph/m:title) &gt; 0">
		<svg:text x="{m:R($width div 2)}" y="{m:R($titleMargin + $titleFontSize)}" 
				text-anchor="middle"
				font-family="Verdana" font-size="{$titleFontSize}"
				fill="{if ($graph/m:title/@color) then $graph/m:title/@color else 'black'}" >
		<xsl:value-of select="$graph/m:title"/>
		</svg:text> 
	</xsl:if>
	</svg:g>
</xsl:template>

<!-- draw the frame around the whole grap -->
<xsl:template name="m:drawFrame">
	<xsl:param name="width"/>
	<xsl:param name="height"/>
	
	<svg:rect x="0.5" y="0.5" width="{m:R($width - 1)}" height="{m:R($height - 1)}"  
			stroke="black" fill="none" stroke-width="1"/> 
</xsl:template>

<!-- draw major and minor grid for X axis -->
<xsl:template name="m:drawXGrid">
	<xsl:param name="xAxisLStart"/>
	<xsl:param name="yAxisTStart"/>
	<xsl:param name="catGap"/>
	<xsl:param name="colWd"/>
	<xsl:param name="catWd"/>
	<xsl:param name="catCount"/>
	<xsl:param name="yAxisHg"/>
	<xsl:param name="originY"/>
	<xsl:param name="serCount"/>
	<xsl:param name="shift"/>
	
	<!-- minor grid of X axis -->
	<xsl:if test="($graph/@xGrid='minor' or $graph/@xGrid='both')">    
		<xsl:variable name="gXMinor"  select="	
				concat('M', m:R($xAxisLStart -0.5*$colWd -$catGap +$depthX), ',', $yAxisTStart +$yAxisHg -$depthY),
				for $a in (1 to $catCount) return (
					concat(' m', 2*$catGap+$colWd, ',', -$yAxisHg, ' l0,', $yAxisHg),
					if ($shift != 0) then (
						for $b in (2 to $serCount) return 
							concat(' m', $colWd*$shift, ',', -$yAxisHg, ' l0,', $yAxisHg)
					) else ' '
				),
				if ($graph/@effect = '3D') then (
					concat('M', $xAxisLStart +$catGap + $colWd div 2, ',', $originY),
					for $a in (1 to $catCount) return (
						for $b in (1 to $serCount -1) return 
							concat('l', $depthX, ',', -$depthY, ' m', $colWd*$shift -$depthX, ',', $depthY) ,
						concat('l', $depthX, ',', -$depthY, ' m', 2*$catGap+$colWd -$depthX, ',', $depthY)
					)
				) else ' '
				"/>
		<svg:path d="{$gXMinor}"  stroke="{$minorGridColor}" 
				stroke-width="{$minorGridStroke-width}" fill="none" />  
	</xsl:if>
	
	<!-- major grid of X axis -->
	<xsl:if test="($graph/@xGrid !='none' and $graph/@xGrid !='minor' )">    
		<xsl:variable name="gXMajor1"  select="
				concat('M', $xAxisLStart +$depthX, ',', $yAxisTStart -$depthY, ' l0,', $yAxisHg),
				for $a in (1 to $catCount) return (
					concat('m', $catWd, ',-', $yAxisHg, ' l0,', $yAxisHg)
				),
				if ($graph/@effect = '3D') then (
					concat('M', $xAxisLStart, ',', $originY, ' l', $depthX, ',', -$depthY),
					for $a in (1 to $catCount) return
						concat('m', $catWd -$depthX, ',', $depthX, ' l', $depthX, ',', -$depthY)
				) else ''
				"/>
		<svg:path d="{$gXMajor1}" stroke="{$majorGridColor}" 
				stroke-width="{$majorGridStroke-width}" fill="none"/>  
	</xsl:if>
</xsl:template>

<!-- draw major and minor grid for Y axis -->
<xsl:template name="m:drawYGrid">
	<xsl:param name="xAxisLStart"/>
	<xsl:param name="yAxisTStart"/>
	<xsl:param name="xAxisWd"/>
	<xsl:param name="yAxisHg"/>
	<xsl:param name="mYpom"/>
	
	<!-- minor grid of Y axis -->
	<xsl:if test="$graph/@yGrid = 'minor' or $graph/@yGrid = 'both' "> 
		<xsl:variable name="gYMinor"  select="
			concat('M', m:R($xAxisLStart), ',', m:R($yAxisTStart+$yAxisHg - $mYpom[1]*$yAxisMarkDist)),
			(if ($graph/@effect = '3D') then concat('l', m:R($depthX), ',', m:R(-$depthY)) else ''),
			concat(' l', m:R($xAxisWd), ',0 '),
			if ($graph/@yAxisType='log') then (
				for $a in $mYpom[. != 1], $b in $logDiv return (
					if ($graph/@effect = '3D') then
						concat('m', m:R(-$xAxisWd -$depthX), ',', m:R($depthY -$yAxisMarkDist * $b),
								' l', m:R($depthX), ',', m:R(-$depthY), ' l', m:R($xAxisWd), ',0 ')
					else
						concat('m-', m:R($xAxisWd), ',-', m:R($yAxisMarkDist * $b), ' l', m:R($xAxisWd), ',0 ')
				)
			) else (
				for  $a in $mYpom[. != 1], $b in (1 to $yAxisDiv) return (
					if ($graph/@effect = '3D') then
						concat('m', m:R(-$xAxisWd -$depthX), ',', m:R($depthY -$yAxisMarkDist div $yAxisDiv),
								'l', m:R($depthX), ',', m:R(-$depthY), ' l', m:R($xAxisWd), ',0 ')
					else
						concat('m-', m:R($xAxisWd), ',-', m:R($yAxisMarkDist div $yAxisDiv), ' l', m:R($xAxisWd), ',0 ')
				)
			) "/>
		<svg:path d="{$gYMinor}" stroke="{$minorGridColor}" 
				stroke-width="{$minorGridStroke-width}" fill="none" />    
	</xsl:if>
	
	<!-- major grid of Y axis -->
	<xsl:if test="($graph/@yGrid = 'major' or $graph/@yGrid = 'minor') 
			and ($yAxisDiv &gt; 0) ">    
		<xsl:variable name="gYMajor"  select="
				concat('M', m:R($xAxisLStart), ',', m:R($yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist)),
				(if ($graph/@effect = '3D') then concat('l', m:R($depthX), ',', m:R(-$depthY)) else ''),
				concat(' l', m:R($xAxisWd), ',0 '),
				for $n in $mYpom[. != 1] return (
					if ($graph/@effect = '3D') then
						concat('m', m:R(-$xAxisWd -$depthX), ',', m:R($depthY -$yAxisMarkDist),
								' l', m:R($depthX), ',', m:R(-$depthY), ' l', m:R($xAxisWd), ',0 ')
					else
						concat('m-', m:R($xAxisWd), ',-', m:R($yAxisMarkDist), ' l', m:R($xAxisWd), ',0 ')
				) " />
		<svg:path d="{$gYMajor}" stroke="{$majorGridColor}" 
				stroke-width="{$majorGridStroke-width}" fill="none" />    
	</xsl:if>
</xsl:template>

<!-- return "dash-array" for given curve (line) type -->
<xsl:function name="m:LineType">
	<xsl:param name="t"/>
	<xsl:value-of select="
		if ($t='dot') then '0.2,3' else 
		if ($t='dash') then '8,3' else 
		if ($t='longDash') then '14,3' else 
		if ($t='dash-dot') then '6,3,0.2,3' else 
		if ($t='longDash-dot') then '14,3,0.2,3' else 
		if ($t='dash-dot-dot') then '6,3,0.2,3,0.2,3' else 
		if ($t='dash-dash-dot-dot') then '6,3,6,3,0.2,3,0.2,3' else 
		if ($t='longDash-dash') then '14,3,6,3' else 'none'"/>
</xsl:function>

<!-- not used in xygr -->
<!-- draw a column -->
<xsl:template name="m:drawCol">
	<xsl:param name="type"/>
	<xsl:param name="effect"/>
	<xsl:param name="color"/>
	<xsl:param name="hg"/>
	<xsl:param name="tW"/>
	<xsl:param name="bW"/>
	<xsl:param name="dpX"/>
	<xsl:param name="dpY"/>
	<xsl:param name="colW"/>
	<xsl:choose>
		<xsl:when test="$effect = '3D'">  <!--3D-->
			<xsl:choose>
				<xsl:when test="$type = 'cylinder' ">  <!--3D cylinder-->
					<svg:path d="M{m:R(-$colW +0.5*$dpX)},{m:R(-$hg*(1-$bW) -0.5*$dpY)} {m:R(m:Arc($colW,0.5*$dpX,0))} 
						v{m:R(-$hg*($bW -$tW))} {m:R(m:Arc(-$colW,0.5*$dpX,1))} z"/>
					<svg:path d="M{m:R(-$colW +0.5*$dpX)},{m:R(-$hg*(1-$tW) -0.5*$dpY)} {m:R(m:Arc($colW,0.5*$dpX,0))} 
						{m:R(m:Arc(-$colW,0.5*$dpX,0))}" fill="{$color}"/>
				</xsl:when>
				<xsl:when test="$type = 'cone' ">  <!--3D cone, TODO: not exact--> 
					<svg:path d="M{m:R(-$colW*$bW +0.5*$dpX)},{m:R(-$hg*(1-$bW) -0.5*$dpY)} 
						{m:R(m:Arc($colW*$bW,0.5*$dpX*$bW,0))} 
						l{m:R(-$colW*($bW -$tW))},{m:R(-$hg*($bW -$tW))} 
						{m:R(m:Arc(-$colW*$tW,0.5*$dpX*$tW,1))} z"/>
					<svg:path d="M{m:R(-$colW*$tW +0.5*$dpX)},{m:R(-$hg*(1-$tW) -0.5*$dpY)} 
						{m:R(m:Arc($colW*$tW,0.5*$dpX*$tW,0))} 
						{m:R(m:Arc(-$colW*$tW,0.5*$dpX*$tW,0))} " fill="{$color}"/>
				</xsl:when>
				<xsl:when test="$type = 'pyramid' ">  <!--3D pyramid, TODO: to draw tW=0 separately -->
					<svg:path d="M{m:R(-$colW*$bW +0.5*$dpX*(1-$bW))},{m:R(-$hg*(1-$bW) -0.5*$dpY*(1-$bW))}
						h{m:R(2*$colW*$bW)} 
						l{m:R(-$colW*($bW -$tW) +0.5*$dpX*($bW -$tW))},{m:R(-$hg*($bW -$tW) -0.5*$dpY*($bW -$tW))}
						h{m:R(-2*$colW*$tW)} z"/>
					<svg:path d="M{m:R($colW*$bW +0.5*$dpX*(1-$bW))},{m:R(-$hg*(1-$bW) -0.5*$dpY*(1-$bW))}
						l{m:R($dpX*$bW)},{m:R(-$dpY*$bW)}
						l{m:R(-$colW*($bW -$tW) -0.5*$dpX*($bW -$tW))},{m:R(-$hg*($bW -$tW)+0.5*$dpY*($bW -$tW))}
						l{m:R(-$dpX*$tW)},{m:R($dpY*$tW)} z"/>
					<svg:path d="M{m:R(-$colW*$tW +0.5*$dpX*(1-$tW))},{m:R(-$hg*(1-$tW) -0.5*$dpY*(1-$tW))}
						h{m:R(2*$colW*$tW)} 
						l{m:R($dpX*$tW)},{m:R(-$dpY*$tW)}
						h{m:R(-2*$colW*$tW)} z"/>
				</xsl:when>
				<xsl:when test="$type = 'line' "> <!-- 3D line -->
					<svg:path d="M{m:R(0)},{m:R(-$hg*(1-$bW))} v{m:R(-$hg*($bW -$tW))}" stroke-width="2" 
						stroke-linecap = "butt" stroke="{$color}"/>
				</xsl:when>
				<xsl:otherwise> <!--3D block and other types-->
					<svg:path d="M{m:R(-$colW)},{m:R(-$hg*(1-$bW))} h{m:R(2*$colW)} v{m:R(-$hg*($bW -$tW))} h{m:R(-2*$colW)} z"/>
					<svg:path d="M{m:R($colW)},{m:R(-$hg*(1-$bW))} l{m:R($dpX)},{m:R(-$dpY)} v{m:R(-$hg*($bW -$tW))} l{m:R(-$dpX)},{m:R($dpY)} z"/>
					<svg:path d="M{m:R(-$colW)},{m:R(-$hg*(1-$tW))} h{m:R(2*$colW)} l{m:R($dpX)},{m:R(-$dpY)} h{m:R(-2*$colW)} z"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>  <!--2D a other types-->
			<xsl:choose>
				<xsl:when test="$type = 'cylinder' ">  <!--2D cylinder-->
					<svg:path d="M{m:R(-$colW)},{m:R(-$hg*(1-$bW))} h{m:R(2*$colW)} v{m:R(-$hg*($bW -$tW))} h{m:R(-2*$colW)} z"/>
				</xsl:when>
				<xsl:when test="$type = 'cone' ">  <!--2D cone -->
					<svg:path d="M{m:R(-$colW*$bW)},{m:R(-$hg*(1-$bW))} h{m:R(2*$colW*$bW)} l{m:R(-$colW*($bW -$tW))},{m:R(-$hg*($bW -$tW))} h{m:R(-2*$colW*$tW)} z"/>
				</xsl:when>
				<xsl:when test="$type = 'pyramid' ">  <!--2D pyramid -->
					<svg:path d="M{m:R(-$colW*$bW)},{m:R(-$hg*(1-$bW))} h{m:R(2*$colW*$bW)} l{m:R(-$colW*($bW -$tW))},{m:R(-$hg*($bW -$tW))} h{m:R(-2*$colW*$tW)} z"/>
				</xsl:when>
				<xsl:when test="$type = 'line' "> <!-- 2D line -->
					<svg:path d="M{0},{m:R(-$hg*(1-$bW))} v{m:R(-$hg*($bW -$tW))}" stroke-width="2" 
						stroke-linecap = "butt" stroke="{$color}"/>
				</xsl:when>
				<xsl:otherwise> <!--2D block a other types -->
					<svg:path d="M{m:R(-$colW)},{m:R(-$hg*(1-$bW))} h{m:R(2*$colW)} v{m:R(-$hg*($bW -$tW))} h{m:R(-2*$colW)} z"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- not used in xygr -->
<!-- return SVG path drawing an half-ellipse in positive direction -->
<xsl:function name="m:Arc">
	<xsl:param name="dx"/>
	<xsl:param name="hg"/>
	<xsl:param name="sp"/>
	<xsl:value-of select="concat('a', math:abs($dx), ',', $hg, ' 0 0,', $sp, ' ', 2*$dx, ',0')"/>
</xsl:function>

<!--draw a point (mark) of a given type -->
<xsl:template name="m:drawPoint">
	<xsl:param name="type"/>
	<xsl:param name="x" select="0"/>
	<xsl:param name="y" select="0"/>
	<xsl:param name="color" select="black"/>

	<xsl:variable name="poS" select="1.5"/>
	<xsl:variable name="crS" select="3"/>
	<xsl:variable name="plS" select="4"/>
	<xsl:variable name="miS" select="3"/>
	<xsl:variable name="stS" select="4"/>
	<xsl:variable name="sqS" select="3"/>
	<xsl:variable name="ciS" select="4"/>
	<xsl:variable name="trS" select="4"/>
	<xsl:variable name="rhS" select="4"/>
	
	<xsl:choose>
		<xsl:when test="$type = 'point'">
			<svg:circle cx="{m:R($x)}" cy="{m:R($y)}" r="{m:R($poS)}" fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'cross' ">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R(- $crS)},{m:R(- $crS)} l {m:R(2 * $crS)},{m:R(2 * $crS)} m 0,{m:R(- 2 * $crS)} l {m:R(- 2 * $crS)},{m:R(2 * $crS)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'plus' ">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R(- $plS)},0 l {m:R(2 * $plS)},0 m {m:R(- $plS)},{m:R(- $plS)} l 0,{m:R(2 * $plS)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'minus' ">
			<svg:path d="M{m:R($x)},{m:R($y)} m{m:R(-$miS)},0 h{m:R(2*$miS)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'star'">
			<svg:path d="M {m:R($x)},{m:R($y)} m 0,{m:R(- $stS)} l 0,{m:R(2 * $stS)} m {m:R(- $stS * 0.87)},{m:R(- $stS * 1.5)} l {m:R($stS * 1.73)},{m:R($stS)}
					m {m:R(- $stS * 1.73)},0 l {m:R($stS * 1.73)},{m:R(-$stS)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<!--xsl:when test="$type = 'star2'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R(- $stS)},0 l {m:R(2 * $stS)},0 m {m:R(- $stS * 1.5)},{m:R(- $stS * 0.87)} l {m:R($stS)},{m:R($stS * 1.73)}
					m 0,{m:R(- $stS * 1.73)} l {m:R(-$stS)},{m:R($stS * 1.73)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when-->
		<xsl:when test="$type = 'square'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R(- $sqS)},{m:R(- $sqS)} l {m:R(2 * $sqS)},0 l 0,{m:R(2 * $sqS)} l {m:R(- 2 * $sqS)},0 z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'circle'">
			<svg:circle cx="{m:R($x)}" cy="{m:R($y)}" r="{m:R($ciS)}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'triangle'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R($trS)},{m:R(- $trS * 0.58)} l {m:R(-2 * $trS)},0 l {m:R($trS)},{m:R($trS * 1.73)} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'rhomb'">
			<svg:path d="M {m:R($x)},{m:R($y)} m 0,{m:R(- $rhS)} l {m:R($rhS)},{m:R($rhS)} l {m:R(- $rhS)},{m:R($rhS)} l {m:R(- $rhS)},{m:R(- $rhS)} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'pyramid'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R($trS)},{m:R($trS * 0.58)} l {m:R(-2 * $trS)},0 l {m:R($trS)},{m:R(- $trS * 1.73)} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'squareF'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R(- $sqS)},{m:R(- $sqS)} l {m:R(2 * $sqS)},0 l 0,{m:R(2 * $sqS)} l {m:R(- 2 * $sqS)},0 z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'circleF'">
			<svg:circle cx="{m:R($x)}" cy="{m:R($y)}" r="{m:R($ciS)}" fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'triangleF'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R($trS)},{m:R(- $trS * 0.58)} l {m:R(-2 * $trS)},0 l {m:R($trS)},{m:R($trS * 1.73)} z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'rhombF'">
			<svg:path d="M {m:R($x)},{m:R($y)} m 0,{m:R(- $rhS)} l {m:R($rhS)},{m:R($rhS)} l {m:R(- $rhS)},{m:R($rhS)} l {m:R(- $rhS)},{m:R(- $rhS)} z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'pyramidF'">
			<svg:path d="M {m:R($x)},{m:R($y)} m {m:R($trS)},{m:R($trS * 0.58)} l {m:R(-2 * $trS)},0 l {m:R($trS)},{m:R(- $trS * 1.73)} z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:otherwise> </xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- return a normalized value of an axis attribute -->
<xsl:function name="m:AxisDivision">
	<xsl:param name="axisDivAtt"/>
	<xsl:value-of select="
			if ($axisDivAtt = 'none') then -1 else
			if ($axisDivAtt = '1') then 1 else
			if ($axisDivAtt = '2') then 2 else
			if ($axisDivAtt = '4') then 4 else
			if ($axisDivAtt = '5') then 5 else
			if ($axisDivAtt = '10') then 10 else 1    "/>	
</xsl:function>

<!--******************************************************************************-->
<!--***************** step calculation functions - supports dateTime *************-->
<!--******************************************************************************-->

<!-- depending on the axis type will calculate minumum maximum and step sizes for the axis
return a sequence: Min Max Step -->
<xsl:function name="m:CalculateAxisDimension">
	<xsl:param name="dataMin"/> 
	<xsl:param name="dataMax"/>
	<xsl:param name="axisType"/>
	<xsl:param name="userMin"/>
	<xsl:param name="userMax"/>
	<xsl:param name="userStep"/>
	<xsl:param name="userMarkCount"/>
	
	<xsl:variable name="dataDif" select="$dataMax - $dataMin"/>
	
	<xsl:variable name="viewMin" select="
			if ($userMin) then $userMin else
			if ($axisType = 'shifted') then $dataMin else 
			(if ($axisType = 'withZero') then min(($dataMin, 0)) else 
			(if ((0 &lt; $dataMin) and  ($dataMin &lt; $dataDif * $axesAutoCoef)) then 0 else $dataMin))"/>
			
	<xsl:variable name="viewMax" select="
			if ($userMax) then $userMax else
			if ($axisType = 'shifted') then $dataMax else 
			(if ($axisType = 'withZero') then max(($dataMax, 0)) else 
			(if ((- $dataDif * $axesAutoCoef &lt; $dataMax) and ($dataMax &lt; 0)) then 0 else $dataMax))"/>
	
	<xsl:variable name="useMarkCount" select="if ($userMarkCount) then $userMarkCount else $defaultMarkAutoCount"/>
	<xsl:variable name="axisStep" select="
			if ($userStep) then $userStep else
				m:StepAT($viewMax - $viewMin, $useMarkCount, $axisType)"/>
	
	<xsl:variable name="axisMax" select="m:GMax($viewMax, $axisStep, $userMax)"/>
	<xsl:variable name="axisMin" select="- m:GMax(- $viewMin, $axisStep, $userMin)"/>
	
	<xsl:sequence select="($axisMin, $axisMax, $axisStep)"/>
</xsl:function>

<!-- truncates up the maximum (of an axis) to the whole axis steps, sometimes add one more -->
<xsl:function name="m:GMax"> 
	<xsl:param name="max"/>
	<xsl:param name="step"/>
	<xsl:param name="userMax"/>

	<xsl:variable name="pom" select="$step * ceiling($max div $step)"/>
	
	<!-- adds one more step if: 
			1) the max is <0 (i.e. max is negative, so we won't be in the shifted area)
			2) the data max is same as the axis max but not 0 
	-->
	<xsl:value-of select="
			if (($pom = 0)  or (($pom > 0) and ($pom != $max or $userMax))) then $pom else ($pom + $step) "/>
</xsl:function>

<xsl:function name="m:Step10Base"> 
	<xsl:param name="dif"/>
	<xsl:param name="count"/>

	<xsl:variable name="ps" select="($dif) div $count"/>
	<xsl:variable name="rad" select="floor(m:Log10($ps))"/>
	<xsl:variable name="cif" select="$ps div math:power(10, $rad)"/>
	<xsl:variable name="st" select="
		if ($cif &lt; 1.6) then 1 else
		if ($cif &lt; 2.2) then 2 else
		if ($cif &lt; 4) then 2.5 else
		if ($cif &lt; 9) then 5 else 10"/>
	<xsl:value-of select="$st * math:power(10, $rad)"/>
</xsl:function>

<xsl:function name="m:Step10Base2"> 
	<xsl:param name="dif"/>
	<xsl:param name="count"/>

	<xsl:variable name="ps" select="($dif) div $count"/>
	<xsl:variable name="rad" select="floor(m:Log10($ps))"/>
	<xsl:variable name="cif" select="$ps div math:power(10, $rad)"/>
	<xsl:variable name="st" select="
		if ($cif &lt; 1.33333) then 1 else
		if ($cif &lt; 2.22222) then 2 else
		if ($cif &lt; 3.33333) then 2.5 else
		if ($cif &lt; 6.66667) then 5 else 10"/>
	<xsl:value-of select="$st * math:power(10, $rad)"/>
</xsl:function>


<xsl:function name="m:Step10BaseInteger">
	<xsl:param name="step"/>
	
	<xsl:variable name="rad" select="floor(m:Log10($step))"/>
	<xsl:variable name="cif" select="$step div math:power(10, $rad)"/>
	<xsl:variable name="st" select="
		if ($cif &lt; 1.33333) then 1 else
		if ($cif &lt; 2.85714) then 2 else
		if ($cif &lt; 6.66667) then 5 else 10"/>
	<xsl:value-of select="$st * math:power(10, $rad)"/>
</xsl:function>


<xsl:function name="m:Step24Base">
	<xsl:param name="step"/>
	
	<xsl:value-of select="
		if ($step &lt; 1.33333) then 1 else
		if ($step &lt; 2.4) then 2 else
		if ($step &lt; 3.42857) then 3 else
		if ($step &lt; 4.8) then 4 else
		if ($step &lt; 6.85714) then 6 else
		if ($step &lt; 9.6) then 8 else
		if ($step &lt; 16) then 12 else 24"/>
</xsl:function>


<xsl:function name="m:Step60Base">
	<xsl:param name="step"/>
	
	<xsl:value-of select="
		if ($step &lt; 1.33333) then 1 else
		if ($step &lt; 2.4) then 2 else
		if ($step &lt; 3.42857) then 3 else
		if ($step &lt; 4.44444) then 4 else
		if ($step &lt; 5.45455) then 5 else
		if ($step &lt; 7.5) then 6 else
		if ($step &lt; 10.90909) then 10 else
		if ($step &lt; 13.33333) then 12 else
		if ($step &lt; 17.14286) then 15 else
		if ($step &lt; 24) then 20 else
		if ($step &lt; 40) then 30 else 60"/>
</xsl:function>

<!-- returns a lenght of axes step, works for dateTime axeType -->
<xsl:function name="m:StepAT">
	<xsl:param name="dif"/>
	<xsl:param name="count"/>
	<xsl:param name="axisType"/>

	<xsl:choose>
		<xsl:when test="$axisType='log'">
			<xsl:value-of select="1"/>
		</xsl:when>
		<xsl:when test="starts-with($axisType,'dateTime')">
			<xsl:variable name="ps" select="($dif) div $count"/>
			
			<xsl:variable name="days" select="$ps div 86400"/>
			<xsl:variable name="hours" select="($ps mod 86400) div 3600"/>
			<xsl:variable name="minutes" select="($ps mod 3600) div 60"/>
			<xsl:variable name="seconds" select="$ps mod 60"/>
			<xsl:value-of select="
					if ($days &gt; 1) then round($days)*86400 else
					if ($hours &gt; 1) then m:Step24Base($hours)*3600 else
					if ($minutes &gt; 1) then m:Step60Base($minutes)*60 else
					m:Step60Base($seconds)
				"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="m:Step10Base(if ($dif != 0) then $dif else 0.0000001, $count)"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<!-- Rounds the value on the same number of decimal places as has the step. Then formats the number
accorging to format defined or a default format. 
format examples:
DateTime: 
	http://www.w3.org/TR/xslt20/#date-time-examples 
numbers:
	http://www.w3schools.com/xsl/func_formatnumber.asp
-->
<xsl:function name="m:FormatValue"> 
	<xsl:param name="val"/>
	<xsl:param name="step"/>
	<xsl:param name="axisType"/>
	<xsl:param name="axisFormat"/>
	<xsl:param name="stacked"/>
	
	<xsl:choose>
		<xsl:when test="$axisType='log'">
			<xsl:value-of select="'10'"/>
			<svg:tspan font-size="{m:R(0.75*$labelFontSize)}" dy="{m:R(-0.4*$labelFontSize)}">
				<xsl:value-of select="$val"/>
			</svg:tspan>
		</xsl:when>
		<xsl:when test="starts-with($axisType,'dateTime')">
			<xsl:variable name="dateTime" select="xs:dateTime('0001-01-01T00:00:00') + m:NumberToDuration($val)"/>
			
			<xsl:variable name="days" select="$step div 86400"/>
			<xsl:variable name="hours" select="($step mod 86400) div 3600"/>
			<xsl:variable name="minutes" select="($step mod 3600) div 60"/>
			<xsl:variable name="seconds" select="$step mod 60"/>
			<xsl:variable name="defaultFormat" select="
					if ($days &gt; 1) then '[Y0001]-[M01]-[D01]' else
					if ($hours &gt; 1) then '[D01]. [H01]:[m01]' else
					if ($minutes &gt; 1) then '[H01]:[m01]' else
					'[m01]:[s01]'
				"/>
			<xsl:variable name="useFormat" select="if ($axisFormat) then $axisFormat else $defaultFormat"/>
			<xsl:variable name="tokens" select="tokenize($useFormat, '~')"/>
			<xsl:value-of select="format-dateTime($dateTime, $tokens[1], $tokens[2], $tokens[3], $tokens[4])"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="rad" select="floor(m:Log10($step))"/>
			<xsl:variable name="pom" select="round($val * math:power(10, - $rad +1)) * math:power(10, $rad - 1)"/>
			<xsl:variable name="useFormat" select="
					if ($axisFormat) then $axisFormat 
					else if ($stacked='percentage') then ' ##%'
					else '#.##############'"/>
			<xsl:value-of select="if ($pom != 0 or $stacked='percentage') then format-number($pom, $useFormat) else $pom"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="m:ProcessValue">
	<xsl:param name="axisType"/>
	<xsl:param name="val"/>
	
	<xsl:choose>
		<xsl:when test="$axisType='log'">
			<xsl:value-of select="m:Log10(if (($val) != 0) then math:abs($val) else 1) "/>
		</xsl:when>
		<xsl:when test="starts-with($axisType,'dateTime')">
			<xsl:variable name="timeZero" select="xs:dateTime('0001-01-01T00:00:00')"/>     
			<xsl:value-of select="m:DurationToNumber(xs:dateTime($val) - $timeZero)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$val"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="m:NumberToDuration" as="xs:dayTimeDuration">
	<xsl:param name="num"/>
	<xsl:value-of select="xs:dayTimeDuration('PT1S') * $num"/>
</xsl:function>

<xsl:function name="m:DurationToNumber">
	<xsl:param name="dur"/>
	<xsl:value-of select="$dur div xs:dayTimeDuration('PT1S')"/>
</xsl:function>


<!--******************************************************************************-->
<!--******************************************* general helper functions *********-->
<!--******************************************************************************-->

<!-- calculate logarithm to the base 10 -->
<xsl:function name="m:Log10"> 
	<xsl:param name="val"/>
	<xsl:variable name="const" select="0.43429448190325182765112891891661"/>     <!--log_10 (e)-->
	<xsl:value-of select="$const*math:log($val)"/>
</xsl:function>

<!-- rounds the given value on 2 decimal places, used for SVG coordinates -->
<xsl:function name="m:R"> 
	<xsl:param name="val"/>
	<xsl:value-of select="format-number($val, '#.##')"/>
</xsl:function>

<!-- returns the main node attribute value or the specified default value if the attribute is undefined -->
<xsl:function name="m:Att">
	<xsl:param name="attributeName"/>
	<xsl:param name="defaultValue"/>
	<xsl:value-of select="m:DefaultValue($graph/@*[local-name() = $attributeName], $defaultValue)"/>
</xsl:function>

<!-- returns the node value if the node exists the default value otherwise -->
<xsl:function name="m:DefaultValue">
	<xsl:param name="attributeNode"/>
	<xsl:param name="defaultValue"/>
	<xsl:value-of select="if ($attributeNode) then $attributeNode else $defaultValue"/> <!-- attribute::*[local-name() = $attributeName]"/>  -->
</xsl:function>


<!--******************************************************************************-->
<!--***************** value pre-processing for all scripts ************************-->
<!--******************************************************************************-->

<!-- process values for msgr and osgr -->
<xsl:template match="gr:value" mode="m:processValues">
	<xsl:param name="graph" tunnel="yes"/>
	<value>
	<xsl:apply-templates select="@*|*" mode="m:processValues"/>
	<xsl:variable name="pos" select="count(preceding-sibling::gr:value)+1"/>
	<xsl:value-of select="
		if ($graph/@stacked='sum') then 
				sum((../preceding-sibling::gr:values/gr:value[$pos], .)) else
		if ($graph/@stacked='percentage') then (
				sum((../preceding-sibling::gr:values/gr:value[$pos], .)) div sum(../../gr:values/gr:value[$pos]) ) else
		m:ProcessValue($graph/@yAxisType, .)"/>
	</value>
</xsl:template>

<!-- process values of x and y attributes for xygr -->
<xsl:template match="@x" mode="m:processValues">
	<xsl:param name="graph" tunnel="yes"/>
	<xsl:attribute name="x" select="m:ProcessValue($graph/@xAxisType, .)"/>
</xsl:template>
<xsl:template match="@y" mode="m:processValues">
	<xsl:param name="graph" tunnel="yes"/>
	<xsl:attribute name="y" select="m:ProcessValue($graph/@yAxisType, .)"/>
</xsl:template>


<xsl:template match="@xAxisMin|@xAxisMax" mode="m:processValues">
	<xsl:param name="graph" tunnel="yes"/>
	<xsl:attribute name="{local-name(.)}" select="m:ProcessValue($graph/@xAxisType, .)"/>
</xsl:template>
<xsl:template match="@yAxisMin|@yAxisMax" mode="m:processValues">
	<xsl:param name="graph" tunnel="yes"/>
	<xsl:attribute name="{local-name(.)}" select="m:ProcessValue($graph/@yAxisType, .)"/>
</xsl:template>

<!-- copy gr element -->
<xsl:template match="gr:*"  mode="m:processValues"> 
	<xsl:element name="{local-name(.)}">
		<xsl:apply-templates select="@*|*|text()" mode="m:processValues"/>
	</xsl:element>
</xsl:template>

<!-- copies attributes, text and other elements -->
<xsl:template match="*|text()|@*" mode="m:processValues">  
	<xsl:copy-of select="."/>
</xsl:template>

</xsl:stylesheet>
