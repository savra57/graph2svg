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

<xsl:function name="m:LineType"> <!-- return "dasharay" for given curve (line) type -->
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
<xsl:template name="m:drawCol"> <!-- draw a column -->
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
					<svg:path d="M{-$colW +0.5*$dpX},{-$hg*(1-$bW) -0.5*$dpY} {m:Arc($colW,0.5*$dpX,0)} 
						v{-$hg*($bW -$tW)} {m:Arc(-$colW,0.5*$dpX,1)} z"/>
					<svg:path d="M{-$colW +0.5*$dpX},{-$hg*(1-$tW) -0.5*$dpY} {m:Arc($colW,0.5*$dpX,0)} 
						{m:Arc(-$colW,0.5*$dpX,0)}" fill="{$color}"/>
				</xsl:when>
				<xsl:when test="$type = 'cone' ">  <!--3D cone, TODO: not exact--> 
					<svg:path d="M{-$colW*$bW +0.5*$dpX},{-$hg*(1-$bW) -0.5*$dpY} 
						{m:Arc($colW*$bW,0.5*$dpX*$bW,0)} 
						l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)} 
						{m:Arc(-$colW*$tW,0.5*$dpX*$tW,1)} z"/>
					<svg:path d="M{-$colW*$tW +0.5*$dpX},{-$hg*(1-$tW) -0.5*$dpY} 
						{m:Arc($colW*$tW,0.5*$dpX*$tW,0)} 
						{m:Arc(-$colW*$tW,0.5*$dpX*$tW,0)} " fill="{$color}"/>
				</xsl:when>
				<xsl:when test="$type = 'pyramid' ">  <!--3D pyramid, TODO: to draw tW=0 separately -->
					<svg:path d="M{-$colW*$bW +0.5*$dpX*(1-$bW)},{-$hg*(1-$bW) -0.5*$dpY*(1-$bW)}
						h{2*$colW*$bW} 
						l{-$colW*($bW -$tW) +0.5*$dpX*($bW -$tW)},{-$hg*($bW -$tW) -0.5*$dpY*($bW -$tW)}
						h{-2*$colW*$tW} z"/>
					<svg:path d="M{$colW*$bW +0.5*$dpX*(1-$bW)},{-$hg*(1-$bW) -0.5*$dpY*(1-$bW)}
						l{$dpX*$bW},{-$dpY*$bW}
						l{-$colW*($bW -$tW) -0.5*$dpX*($bW -$tW)},{-$hg*($bW -$tW)+0.5*$dpY*($bW -$tW)}
						l{-$dpX*$tW},{$dpY*$tW} z"/>
					<svg:path d="M{-$colW*$tW +0.5*$dpX*(1-$tW)},{-$hg*(1-$tW) -0.5*$dpY*(1-$tW)}
						h{2*$colW*$tW} 
						l{$dpX*$tW},{-$dpY*$tW}
						h{-2*$colW*$tW} z"/>
				</xsl:when>
				<xsl:when test="$type = 'line' "> <!-- 3D line -->
					<svg:path d="M{0},{-$hg*(1-$bW)} v{-$hg*($bW -$tW)}" stroke-width="2" 
						stroke-linecap = "butt" stroke="{$color}"/>
				</xsl:when>
				<xsl:otherwise> <!--3D block and other types-->
					<svg:path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
					<svg:path d="M{$colW},{-$hg*(1-$bW)} l{$dpX},{-$dpY} v{-$hg*($bW -$tW)} l{-$dpX},{$dpY} z"/>
					<svg:path d="M{-$colW},{-$hg*(1-$tW)} h{2*$colW} l{$dpX},{-$dpY} h{-2*$colW} z"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>  <!--2D a other types-->
			<xsl:choose>
				<xsl:when test="$type = 'cylinder' ">  <!--2D cylinder-->
					<svg:path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
				</xsl:when>
				<xsl:when test="$type = 'cone' ">  <!--2D cone -->
					<svg:path d="M{-$colW*$bW},{-$hg*(1-$bW)} h{2*$colW*$bW} l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)} h{-2*$colW*$tW} z"/>
				</xsl:when>
				<xsl:when test="$type = 'pyramid' ">  <!--2D pyramid -->
					<svg:path d="M{-$colW*$bW},{-$hg*(1-$bW)} h{2*$colW*$bW} l{-$colW*($bW -$tW)},{-$hg*($bW -$tW)} h{-2*$colW*$tW} z"/>
				</xsl:when>
				<xsl:when test="$type = 'line' "> <!-- 2D line -->
					<svg:path d="M{0},{-$hg*(1-$bW)} v{-$hg*($bW -$tW)}" stroke-width="2" 
						stroke-linecap = "butt" stroke="{$color}"/>
				</xsl:when>
				<xsl:otherwise> <!--2D block a other types -->
					<svg:path d="M{-$colW},{-$hg*(1-$bW)} h{2*$colW} v{-$hg*($bW -$tW)} h{-2*$colW} z"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- not used in xygr -->
<xsl:function name="m:Arc"> 	<!-- return SVG path drawing an half-ellips in positive direction -->
	<xsl:param name="dx"/>
	<xsl:param name="hg"/>
	<xsl:param name="sp"/>
	<xsl:value-of select="concat('a', math:abs($dx), ',', $hg, ' 0 0,', $sp, ' ', 2*$dx, ',0')"/>
</xsl:function>

<xsl:template name="m:drawPoint">  <!--draw a point (mark) of a given type -->
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
			<svg:circle cx="{$x}" cy="{$y}" r="{$poS}" fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'cross' ">
			<svg:path d="M {$x},{$y} m {- $crS},{- $crS} l {2 * $crS},{2 * $crS} m 0,{- 2 * $crS} l {- 2 * $crS},{2 * $crS}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'plus' ">
			<svg:path d="M {$x},{$y} m {- $plS},0 l {2 * $plS},0 m {- $plS},{- $plS} l 0,{2 * $plS}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'minus' ">
			<svg:path d="M{$x},{$y} m{-$miS},0 h{2*$miS}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'star'">
			<svg:path d="M {$x},{$y} m 0,{- $stS} l 0,{2 * $stS} m {- $stS * 0.87},{- $stS * 1.5} l {$stS * 1.73},{$stS}
					m {- $stS * 1.73},0 l {$stS * 1.73},{-$stS}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<!--xsl:when test="$type = 'star2'">
			<svg:path d="M {$x},{$y} m {- $stS},0 l {2 * $stS},0 m {- $stS * 1.5},{- $stS * 0.87} l {$stS},{$stS * 1.73}
					m 0,{- $stS * 1.73} l {-$stS},{$stS * 1.73}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when-->
		<xsl:when test="$type = 'square'">
			<svg:path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'circle'">
			<svg:circle cx="{$x}" cy="{$y}" r="{$ciS}">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'triangle'">
			<svg:path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'rhomb'">
			<svg:path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'pyramid'">
			<svg:path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'squareF'">
			<svg:path d="M {$x},{$y} m {- $sqS},{- $sqS} l {2 * $sqS},0 l 0,{2 * $sqS} l {- 2 * $sqS},0 z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'circleF'">
			<svg:circle cx="{$x}" cy="{$y}" r="{$ciS}" fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:circle>
		</xsl:when>
		<xsl:when test="$type = 'triangleF'">
			<svg:path d="M {$x},{$y} m {$trS},{- $trS * 0.58} l {-2 * $trS},0 l {$trS},{$trS * 1.73} z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'rhombF'">
			<svg:path d="M {$x},{$y} m 0,{- $rhS} l {$rhS},{$rhS} l {- $rhS},{$rhS} l {- $rhS},{- $rhS} z"
					fill="currentColor">
				<xsl:if test="($color != 'inh')">
					<xsl:attribute name="stroke" select="$color"/>
					<xsl:attribute name="color" select="$color"/>
				</xsl:if>
			</svg:path>
		</xsl:when>
		<xsl:when test="$type = 'pyramidF'">
			<svg:path d="M {$x},{$y} m {$trS},{$trS * 0.58} l {-2 * $trS},0 l {$trS},{- $trS * 1.73} z"
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

<xsl:function name="m:GMax"> <!-- truncates up the maximum (of an axis) to the whole axis steps -->
	<xsl:param name="max"/>
	<xsl:param name="step"/>

<xsl:variable name="pom" select="$step * ceiling($max div $step)"/>
	<xsl:value-of select="
			if (($pom = 0)  or (($pom > 0) and ($pom != $max))) then $pom else ($pom +$step) "/>
</xsl:function>

<xsl:function name="m:Step"> <!-- returns a lenght of axes step -->
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
		<!--xsl:variable name="st">
		<xsl:choose>
			<xsl:when test="$cif &lt; 1.6"><xsl:value-of select="1"/></xsl:when>
			<xsl:when test="$cif &lt; 2.2"><xsl:value-of select="2"/></xsl:when>
			<xsl:when test="$cif &lt; 4"><xsl:value-of select="2.5"/></xsl:when>
			<xsl:when test="$cif &lt; 9"><xsl:value-of select="5"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="10"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="pom" select="$st"/>
	<xsl:value-of select="$pom * math:power(10, $rad)"/-->
</xsl:function>

<!-- rounds the value on same number of decimal places as has the step, used for printing values on axes -->
<xsl:function name="m:Round"> 
	<xsl:param name="val"/>
	<xsl:param name="step"/>

	<xsl:variable name="rad" select="floor(m:Log10($step))"/>
	<xsl:variable name="pom" select="round($val * math:power(10, - $rad +1)) * math:power(10, $rad - 1)"/>
	<xsl:value-of select="if ($pom != 0) then format-number($pom, '#.##############') else $pom"/>
</xsl:function>

<!-- rounds the value on 2 decimal places, used for coordinates -->
<xsl:function name="m:R"> 
	<xsl:param name="val"/>
	<xsl:value-of select="round($val * 100) div 100"/>
</xsl:function>

<!-- calculate logarithm to the base 10 -->
<xsl:function name="m:Log10"> 
	<xsl:param name="val"/>
	<xsl:variable name="const" select="0.43429448190325182765112891891661"/>     <!--log_10 (e)-->
	<xsl:value-of select="$const*math:log($val)"/>
</xsl:function>
</xsl:stylesheet>