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
 
<xsl:output method="xml" encoding="utf-8" indent="yes"/>
<!--doctype-public="-//W3C//DTD SVG 1.1//EN"
"doctype-system="http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"-->

<xsl:template name="m:msgr2svg">
	<xsl:variable name="gra">
		<ph>
		<xsl:apply-templates select="$graph/@*" mode="m:processValues">
			<xsl:with-param name="graph" select="$graph" tunnel="yes"/>
		</xsl:apply-templates>
		<xsl:attribute name="legend" select="
			if (($graph/@legend) = 'none') then 'none' else
			if (($graph/@legend) = 'left') then 'left' else
			if (($graph/@legend) = 'top') then 'top' else
			if (($graph/@legend) = 'bottom') then 'bottom' else 'right' "/>
		<xsl:apply-templates select="$graph/(*|text())" mode="m:processValues">
			<xsl:with-param name="graph" select="$graph" tunnel="yes"/>
		</xsl:apply-templates>
		</ph>
	</xsl:variable>
	<!--xsl:copy-of select="$gra/ph"/-->
	
	<!-- variable calculations-->
	
		<!-- X axis - categories -->
	<xsl:variable name="catGap" select="m:Att('categoryGap', 10)"/> 
	<xsl:variable name="colWd" select="m:Att('columnWd', 20)"/> 
	<xsl:variable name="catCount" as="xs:integer" select="count($gra/ph/names/name) cast as xs:integer"/> 
	<xsl:variable name="serCount" as="xs:integer" select="count($gra/ph/values) cast as xs:integer"/> 
	<xsl:variable name="shift" select="m:Att('shift', 0)"/>
	<xsl:variable name="catWd" select="2*$catGap+$colWd + ($serCount -1)*$shift*$colWd"/> 
	<xsl:variable name="xAxisWd" select="$catCount * $catWd"/>
	<xsl:variable name="maxXLabelWd" select="$labelFontSize * $labelFontWd *
			max(for $a in $gra/ph/names/name return string-length($a))"/>
	<xsl:variable name="xLabelRotation" select="if (0.9*$maxXLabelWd &gt;= $catWd) then $maxXLabelWd else 0"/>	
	
		<!-- Y axis -->
	<xsl:variable name="dataMaxY"  select="max($gra/ph/values/value)"/>	
	<xsl:variable name="dataMinY"  select="min($gra/ph/values/value)"/>
	<xsl:variable name="yAxisDim" select="m:CalculateAxisDimension($dataMinY, $dataMaxY, $gra/ph/@yAxisType, $gra/ph/@yAxisMin, $gra/ph/@yAxisMax, $gra/ph/@yAxisStep, $gra/ph/@yAxisMarkCount)"/>
	<xsl:variable name="yAxisStep" select="$yAxisDim[3]"/>
	<xsl:variable name="yAxisMin" select="$yAxisDim[1]"/>
	<xsl:variable name="yAxisMax" select="if ($gra/ph/@stacked='percentage' and $dataMaxY = 1) then 1 else $yAxisDim[2]"/>
	<xsl:variable name="yAxisLen" select="$yAxisMax - $yAxisMin"/>
	<xsl:variable name="yAxisMarkCount" select="round($yAxisLen div $yAxisStep) cast as xs:integer"/>
	<xsl:variable name="yAxisHg" select="$yAxisMarkCount * $yAxisMarkDist"/>
	<xsl:variable name="yKoef" select="- $yAxisHg div $yAxisLen"/>
	<xsl:variable name="originYShift" select="
			if ($gra/ph/@xAxisPos = 'bottom') then 0 else
			if ($yAxisMin &gt;= 0) then 0 else - min((- $yAxisMin, $yAxisLen)) * $yKoef "/>
	<xsl:variable name="maxYLabelWd" select="$labelFontSize * $labelFontWd *
			max(for $a in (0 to $yAxisMarkCount) return 
				string-length(string-join(m:FormatValue($yAxisMin + $a * $yAxisStep, $yAxisStep, $gra/ph/@yAxisType, $gra/ph/@yAxisLabelsFormat, $gra/ph/@stacked), ''))
			)"/>
		
		<!-- title and legend -->
	<xsl:variable name="titleHg"  select="if ($gra/ph/title) then 2*$titleMargin + $titleFontSize else 0"/>
	<xsl:variable name="legendWd"  select="
			if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (
				$legendMargin + $legendPictureWd + $legendGap  +
				$legendFontSize * $legendFontWd * 
				max(for $a in ($gra/ph/values/title, '') return string-length($a))
			) else 
			if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (
				2*$legendMargin + sum(
					for $a in ($gra/ph/values/title) return 
						string-length($a)*$legendFontSize*$legendFontWd +$legendPictureWd +$legendGap +$legendMargin) 
			) else 0			
			"/>	
	<xsl:variable name="legendHg"  select="
			if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then (
				2*$legendMargin +$legendLineHg * 
				count($gra/ph/values/title)
			) else 
			if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then (
				$legendMargin + $legendLineHg
			) else 0"/>
	<xsl:variable name="legendL"  select="if ($gra/ph/@legend = 'left') then $legendWd else 0"/>
	<xsl:variable name="legendR"  select="if ($gra/ph/@legend = 'right') then $legendWd else 0"/>
	<xsl:variable name="legendT"  select="if ($gra/ph/@legend = 'top') then $legendHg else 0"/>
	<xsl:variable name="legendB"  select="if ($gra/ph/@legend = 'bottom') then $legendHg else 0"/>
			
		<!-- the graph itself -->
	<xsl:variable name="yAxisTSpace"  select="$graphMargin + max(($labelFontSize div 2, $depthY))"/>  
	<xsl:variable name="yAxisBSpace"  select="$graphMargin + 
			max(($labelFontSize div 2, $labelFontSize + $majorMarkLen - $originYShift
					+ $xLabelRotation*math:sin($pi*$labelAngle div 180)))"/>	
	<xsl:variable name="xAxisLSpace"  select="$graphMargin + $maxYLabelWd "/>	
	<xsl:variable name="xAxisRSpace"  select="$graphMargin + 
		max((m:R($xLabelRotation*math:cos($pi*$labelAngle div 180)) -$catWd +$catGap, $depthX))"/>	
	<xsl:variable name="graphWd"  select="$xAxisLSpace + $xAxisWd + $xAxisRSpace"/>	
	<xsl:variable name="graphHg"  select="$yAxisTSpace + $yAxisHg + $yAxisBSpace"/>
	<xsl:variable name="xAxisLStart"  select="$legendL + $xAxisLSpace + 
			(if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then 
				max(($legendWd - $graphWd, 0)) div 2     else 0)"/>	
	<xsl:variable name="yAxisTStart"  select="$titleHg + $legendT + $yAxisTSpace + 
			(if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then 
				max(($legendHg - $graphHg, 0)) div 2     else 0)"/>	
	<xsl:variable name="originX"  select="$xAxisLStart"/>	
	<xsl:variable name="originY"  select="$yAxisTStart + $yAxisHg - $originYShift"/>	
	<!--xsl:variable name="xShift"  select="$xAxisLStart"/-->	
	<xsl:variable name="yShift"  select="$yAxisTStart + $yAxisHg - $yKoef * $yAxisMin"/>	
	<!--xsl:variable name="legendX"  select="(if ($gra/ph/@legend = 'right') then $graphWd else $legendMargin) + 
			(if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then 
				max(($graphWd - $legendWd, 0)) div 2
			else 0)"/>
	<xsl:variable name="legendY"  select="$titleHg + 
			(if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then 
				max(($graphHg - $legendHg, 0)) div 2 + $legendMargin  
			else (if ($gra/ph/@legend = 'bottom') then $graphHg else $legendMargin ))
			"/--> <!-- used only for control frame, using legendSX a SY instead -->
	<xsl:variable name="legendSX" select=" 
			if ($gra/ph/@legend = 'right' or $gra/ph/@legend = 'left') then (
				for $a in $gra/ph/values return
					(if ($gra/ph/@legend = 'right') then $graphWd else $legendMargin)
			) else
			if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (
				for $a in $gra/ph/values return (
					$legendMargin + 0.5*max(($graphWd - $legendWd, 0)) +
					sum(	for $b in $a/preceding-sibling::values[title] return 
								(string-length($b/title)*$legendFontSize*$legendFontWd 
								+$legendPictureWd +$legendGap +$legendMargin)
						  )
				)
			) else ''
			"/>
	<xsl:variable name="legendSY" select=" 
			if ($gra/ph/@legend = 'top' or $gra/ph/@legend = 'bottom') then (
				for $a in $gra/ph/values return (
					$titleHg + (if ($gra/ph/@legend = 'bottom') then $graphHg else $legendMargin) +0.5*$legendLineHg
				)
			) else
			if ($gra/ph/@legend != 'none' or $gra/ph/@legend = 'left') then (
				for $a in $gra/ph/values return
					$titleHg + 0.5*max(($graphHg - $legendHg, 0)) + $legendMargin +
					$legendLineHg * (count($a/preceding-sibling::values[title]) + 0.5)
			) else ''
			"/>
			
		<!-- whole window -->
	<xsl:variable name="width"  select="$legendL + $legendR + 
			(if ($gra/ph/@legend = 'top' or $gra/ph/@legend =  'bottom') then max(($graphWd, $legendWd)) else $graphWd)"/>	
	<xsl:variable name="height"  select="$titleHg +  $legendT + $legendB + 
			(if ($gra/ph/@legend = 'left' or $gra/ph/@legend =  'right') then max(($graphHg, $legendHg)) else $graphHg)"/>	
		<!-- selected color schema -->
	<xsl:variable name="colorSch" select="
			if ($gra/ph/@colorScheme = 'black') then $colorSchemeBlack else
			if ($gra/ph/@colorScheme = 'cold') then $colorSchemeCold else
			if ($gra/ph/@colorScheme = 'warm') then $colorSchemeWarm else
			if ($gra/ph/@colorScheme = 'grey') then $colorSchemeGrey else  $colorSchemeColor "/>

	<!-- start of SVG document -->
	<svg:svg viewBox="0 0 {m:R($width)} {m:R($height)}">
	
	<xsl:call-template name="m:drawDescritptionAndTitle">
		<xsl:with-param name="width" select="$width"/>
	</xsl:call-template>
	
	<!-- variables for axis and grids -->
	<xsl:variable name="LB" select="$gra/ph/@xAxisPos = 'bottom'"/>
	<xsl:variable name="mYpom"  select="				
			if ($LB) then 
				(0 to $yAxisMarkCount)
			else 
				if ($yAxisMin &gt; 0) then (1 to $yAxisMarkCount) else
				if ($yAxisMax &lt; 0) then (0 to $yAxisMarkCount - 1) else 
					(0 to $yAxisMarkCount)   "/>
	
	<!-- drawing of areas -->
	<xsl:if test="some $a in ($gra/ph/values/@fillArea, $gra/ph/@fillArea) satisfies ($a = 'yes')">
		<svg:g stroke-width="0.2" stroke="black" stroke-linejoin="round" >
		<xsl:for-each select="$gra/ph/values[./@fillArea = 'yes' or 
				(not (./@fillArea) and ($gra/ph/@fillArea = 'yes'))]"> 
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
			<xsl:variable name="aColor"  select="if (./@color) then (./@color) else $colorSch[$cn]"/>
			<xsl:variable name="pX"  select="$xAxisLStart +$catGap +($sn*$shift +0.5)*$colWd +$depthX"/>
			<xsl:variable name="lp"  select="min(($catCount, count(value)))"/>
			<xsl:variable name="v_"  select="preceding-sibling::values[1]"/>  <!-- last series -->
			<xsl:variable name="lp_"  select="min(($catCount, count($v_/value)))"/> <!-- usable length of the last series -->
			<xsl:variable name="pX_"  select="$xAxisLStart +$catGap +(($sn -1)*$shift +0.5)*$colWd +$depthX"/>
			<xsl:variable name="sk"  select="0.18"/>
			<xsl:variable name="ySh"  select="$yShift - $depthY"/>
			<xsl:variable name="line"  select="
				concat('M', m:R($pX), ',', m:R($ySh + $yKoef * value[1])), 
				for $a in (1 to $lp -1)  return 
					concat('L', m:R($pX +$a*$catWd),',', m:R($ySh + $yKoef *value[$a+1]))
				"/>
				<xsl:variable name="line"  select="
				concat('M', m:R($pX), ',', m:R($ySh + $yKoef * value[1])), 
				if (./@smooth = 'yes') then (
					(for $a in (1 to $lp -2)  return 
						concat(' S ', m:R($pX +$a*$catWd - 2*$catWd*$sk),
						',', m:R($ySh + $yKoef *(value[$a+1] - (value[$a+2] - value[$a])*$sk)),
						' ',  m:R($pX +$a*$catWd),',', m:R($ySh + $yKoef *value[$a+1]) )
					),
					concat (' S ', m:R($pX +($lp -1)*$catWd),',', m:R($ySh + $yKoef *value[$lp])),
					concat (m:R($pX +($lp -1)*$catWd),',', m:R($ySh + $yKoef *value[$lp]))
				) else (
					for $a in (1 to $lp -1)  return 
						concat('L', m:R($pX +$a*$catWd),',', m:R($ySh + $yKoef *value[$a+1]))
				),
				if ($sn = 0 or not (@startFrom='last' or $gra/ph/@stacked = 'sum' or $gra/ph/@stacked = 'percentage'))  then
					concat('L', m:R($pX +($lp -1)*$catWd),',', m:R($originY -$depthY), ' L', m:R($pX), ',', m:R($originY -$depthY), ' z')
				else
					concat('L', m:R($pX_ +($lp_ -1)*$catWd), ',', m:R($ySh + $yKoef * $v_/value[$lp_])), 
					if ($v_/@smooth = 'yes') then (
						(for $a in reverse(1 to $lp_ -2)  return 
							concat(' S ', m:R(m:R($pX_ +$a*$catWd + 2*$catWd*$sk)),
							',', m:R($ySh + $yKoef *($v_/value[$a+1] + ($v_/value[$a+2] - $v_/value[$a])*$sk)),
							' ',  m:R($pX_ +$a*$catWd),',', m:R($ySh + $yKoef *$v_/value[$a+1]) )
						),
						concat (' S ', m:R($pX_) ,',', m:R($ySh + $yKoef *$v_/value[1])),
						concat (m:R($pX_),',', m:R($ySh + $yKoef *$v_/value[1]))
					) else (
						for $a in reverse(0 to $lp_ -2)  return 
							concat('L', m:R($pX_ +$a*$catWd),',', m:R($ySh + $yKoef * $v_/value[$a+1]))
					)				
				" />
			<svg:path d="{$line}" fill="{$aColor}"/>
					<!-- areas in legend -->
			<xsl:if test="not ($gra/ph/@legend = 'none') and (title)">
				<svg:rect x="{m:R($legendSX[1+$sn])}" y="{m:R($legendSY[1+$sn] - 0.5*$legendPictureHg)}"
							width="{m:R($legendPictureWd)}" height="{m:R($legendPictureHg)}" fill="{$aColor}"/> 
				<svg:g stroke-width="4.5" fill="white" color="white" stroke="white" stroke-linecap="round"> 
				<xsl:call-template name="m:drawPoint">  
					<xsl:with-param name="type" select=" if (@pointType) then @pointType else
						if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
					<xsl:with-param name="x" select="$legendSX[1+$sn] + 0.5*$legendPictureWd"/>
					<xsl:with-param name="y" select="$legendSY[1+$sn]"/>
					<xsl:with-param name="color" select="inh"/>
				</xsl:call-template>
				</svg:g> 
				
			</xsl:if>
		</xsl:for-each>
		</svg:g>
	</xsl:if>
	
	<!-- major and minor grid for both axes -->
	<xsl:call-template name="m:drawXGrid">  
		<xsl:with-param name="xAxisLStart" select="$xAxisLStart"/>
		<xsl:with-param name="yAxisTStart" select="$yAxisTStart"/>
		<xsl:with-param name="catGap" select="$catGap"/>
		<xsl:with-param name="colWd" select="$colWd"/>
		<xsl:with-param name="catWd" select="$catWd"/>
		<xsl:with-param name="catCount" select="$catCount"/>
		<xsl:with-param name="yAxisHg" select="$yAxisHg"/>
		<xsl:with-param name="originY" select="$originY"/>
		<xsl:with-param name="serCount" select="$serCount"/>
		<xsl:with-param name="shift" select="$shift"/>
	</xsl:call-template>
	<xsl:call-template name="m:drawYGrid">  
		<xsl:with-param name="xAxisLStart" select="$xAxisLStart"/>
		<xsl:with-param name="yAxisTStart" select="$yAxisTStart"/>
		<xsl:with-param name="xAxisWd" select="$xAxisWd"/>
		<xsl:with-param name="yAxisHg" select="$yAxisHg"/>
		<xsl:with-param name="mYpom" select="$mYpom"/>
	</xsl:call-template>
	
	
	<!-- drawing of columns -->
		<!-- definition of gradients, used for filling of 3D columns -->
	<xsl:variable name="gradLBorder"  select="-0.7"/>
	<xsl:variable name="gradRBorder"  select="0.9"/>
	<xsl:if test="some $a in ($gra/ph/values/@colType, $gra/ph/@colType) satisfies ($a = 'cone' or $a = 'cylinder') "> 
		<svg:defs>
		<xsl:for-each select="$gra/ph/values[(@colType = 'cone') or (@colType = 'cylinder') or 
					(not (@colType) and  ($gra/ph/@colType = 'cone' or $gra/ph/@colType ='cylinder'))]">
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
			<xsl:variable name="cc"  select="if (./@color) then (./@color) else $colorSch[$cn]"/>
			<xsl:variable name="pomS"  select="if ($gra/ph/@effect = '3D') then -0.5*$depthX else 0"/>
			<svg:linearGradient id="lg{$sn}" x1="{$gradLBorder*$colWd -$pomS}"   y1="0"   
					x2="{$gradRBorder*$colWd -$pomS}" y2="0" gradientUnits="userSpaceOnUse">
			 <svg:stop offset="0" stop-color="#000"/>
			 <svg:stop offset="0.35" stop-color="{$cc}" />
			 <svg:stop offset="1" stop-color="#000"/>
			 </svg:linearGradient>
			</xsl:for-each>
		</svg:defs>
	</xsl:if>
		<!-- drawing of columns itselves -->
	<xsl:for-each select="$gra/ph/values">
		<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
		<xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
		<xsl:variable name="cc"  select="if (./@color) then (./@color) else $colorSch[$cn]"/>
		<xsl:variable name="pX"  select="$xAxisLStart +$catGap +($sn*$shift +0.5)*$colWd "/>
		
		<xsl:variable name="stacked"  select="
				if ($gra/ph/@stacked = 'sum' or $gra/ph/@stacked = 'percentage')
				then 1 else 0 "/>
		<xsl:if test="some $a in (./@colType, $gra/ph/@colType) satisfies $a != 'none'"> 
			<xsl:variable name="colT"  select="if (@colType) then @colType else 
						if ($gra/ph/@colType) then $gra/ph/@colType else 'none' "/>
			<svg:g stroke-width="0.4"  fill="{if ($colT = 'cone' or $colT = 'cylinder') then concat('url(#lg', $sn, ')') else $cc}" 
					stroke="black" stroke-linejoin="round"> 
			<xsl:for-each select="value[position() &lt;= $catCount]"> 
				<xsl:variable name="vn"  select="count(preceding-sibling::value)"/>
				<xsl:variable name="x" select="$pX + $vn*$catWd "/>
				<xsl:variable name="y" select="$originY"/>
				<svg:g transform="translate({m:R($x)}, {m:R($y - (
						if ($sn>0 and ($stacked or (../@startFrom='last'))) then 
							$originY - $yShift - $yKoef * ($gra/ph/values[$sn]/value[$vn+1])
						else 0 
					))})">
				<xsl:call-template name="m:drawCol"> <!-- dwaw a column -->
					<xsl:with-param name="type" select="$colT"/>
					<xsl:with-param name="effect" select="$gra/ph/@effect"/>
					<xsl:with-param name="color" select="$cc"/>
					<xsl:with-param name="hg" select="$originY - $yShift - $yKoef * (.) - (
							if ($sn>0 and ($stacked or (../@startFrom='last'))) then 
								($originY - $yShift - $yKoef * ($gra/ph/values[$sn]/value[$vn+1]))
							else 0 )"/>
					<xsl:with-param name="tW" select="
							if ($stacked) then
								(1 - ($originY -$yShift -$yKoef*($gra/ph/values[$sn+1]/value[$vn+1]))
									div ($originY -$yShift -$yKoef*($gra/ph/values[last()]/value[$vn+1])))
							else 0 "/>
					<xsl:with-param name="bW" select="
							if ($stacked and $sn>0) then
								(1 - ($originY -$yShift -$yKoef*($gra/ph/values[$sn]/value[$vn+1]))
									div ($originY -$yShift -$yKoef*($gra/ph/values[last()]/value[$vn+1])))
							else 1"/>
					<xsl:with-param name="colW" select="0.5*$colWd"/>
				</xsl:call-template>
				</svg:g>
			</xsl:for-each>
			<!-- column of a given type for the legend  -->
			<xsl:if test="not ($gra/ph/@legend = 'none') and (title)">
				<svg:g transform="translate({m:R($legendSX[1+$sn] + 0.5*$legendPictureWd)}, 
						{m:R($legendSY[1+$sn] +0.5*$legendPictureHg)})">
				<xsl:call-template name="m:drawColLegend"> <!-- draw a column-->
					<xsl:with-param name="type" select="$colT"/>
					<xsl:with-param name="effect" select="$gra/ph/@effect"/>
					<xsl:with-param name="color" select="$cc"/>
					<xsl:with-param name="colW" select="0.5*0.5*$colWd"/>
				</xsl:call-template>
				</svg:g>
			</xsl:if>
			</svg:g>
		</xsl:if>
	</xsl:for-each>
	
	<!-- major and minor marks for both axes -->
	<svg:g stroke="black"> 
	<xsl:if test="(not ($gra/ph/@xAxisDivision='none' or $gra/ph/@xAxisDivision='major'))">    <!-- minor marks for X axis  -->
		<xsl:variable name="mXMinor"  select="	
				concat('M', m:R($xAxisLStart +$catGap + $colWd div 2), ',', m:R($originY -$minorMarkLen)),
				for $a in (1 to $catCount) return (
					(for $b in (1 to $serCount -1) return 
						concat('l0,', m:R($minorMarkLen), ' m', m:R($colWd*$shift), ',-', m:R($minorMarkLen))), 
					concat('l0,', m:R($minorMarkLen), ' m', m:R(2*$catGap+$colWd), ',-', m:R($minorMarkLen))  )"/>
		<svg:path d="{$mXMinor}" stroke-width="{$minorMarkStroke-width}"/>  
	</xsl:if>
	<xsl:if test="($gra/ph/@xAxisDivision='major' or $gra/ph/@xAxisDivision='both' )">    <!--major marks for X axis-->
		<xsl:variable name="mXMajor"  select="	
				concat('M', m:R($xAxisLStart), ',', m:R($originY), ' l0,', m:R($majorMarkLen)),
				for $n in (2 to $catCount) return concat('m', m:R($catWd), ',-', m:R($majorMarkLen), ' l0,', m:R($majorMarkLen))"/>
		<svg:path d="{$mXMajor}" stroke-width="{$majorMarkStroke-width}"/>  
	</xsl:if>
	<xsl:if test="($yAxisDiv &gt; 1)">    <!-- minor marks for Y axis -->
		<xsl:variable name="mYMinor"  select="
			concat('M', m:R($originX -$minorMarkLen), ',', m:R($yAxisTStart +$yAxisHg -$mYpom[1]*$yAxisMarkDist), 
					' l', m:R(2*$minorMarkLen), ',0 '), 
			if ($gra/ph/@yAxisType='log') then (
				for $a in $mYpom[. != 1], $b in $logDiv return 
					concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist*$b), ' l', m:R(2*$minorMarkLen), ',0 ')
			) else (
				for $n in (for $a in (1 to $yAxisDiv) return $mYpom[. != 1]) return 
					concat('m-', m:R(2*$minorMarkLen), ',-', m:R($yAxisMarkDist div $yAxisDiv), ' l', m:R(2*$minorMarkLen), ',0 ')
			)"/>
		<svg:path d="{$mYMinor}"  stroke-width="{$minorMarkStroke-width}"/>   
	</xsl:if>
	<xsl:if test="($yAxisDiv &gt; 0)">    <!-- major marks for Y axis -->
		<xsl:variable name="mYMajor"  select="	
				concat('M', m:R($originX - $majorMarkLen), ',', m:R($yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist),
					' l', m:R(2 * $majorMarkLen), ',0 '),
				for $n in $mYpom[(.) != 1] return 
					concat('m-', m:R(2 * $majorMarkLen), ',-', m:R($yAxisMarkDist), ' l', m:R(2 * $majorMarkLen), ',0 ')
		"/>
		<svg:path d="{$mYMajor}"  stroke-width="{$majorMarkStroke-width}"/> 
	</xsl:if>
	</svg:g>
	
	<!-- X axis with labels -->
		<svg:line x1="{m:R($xAxisLStart)}" y1="{m:R($originY)}" 
					x2="{m:R($xAxisLStart + $xAxisWd)}" y2="{m:R($originY)}"
					stroke="black" stroke-width="{$axesStroke-width}"/> 
		<!-- X axis labels -->
	
	<xsl:if test="not ($xLabelRotation)">
		<svg:g text-anchor="middle" font-family="Verdana" font-size="{$labelFontSize}" fill="black"> 
		<xsl:for-each select="$gra/ph/names/name">
			<xsl:variable name="nn"  select="count(preceding-sibling::name)"/>
			<svg:text x="{m:R($xAxisLStart + ($nn +0.5)*$catWd)}" y="{m:R($originY + $majorMarkLen + $labelFontSize)}">
			<xsl:value-of select="."/>
			</svg:text>
		</xsl:for-each>
		</svg:g>
	</xsl:if>
	<xsl:if test="$xLabelRotation">
		<svg:g font-family="Verdana" font-size="{$labelFontSize}" fill="black"> 
		<xsl:for-each select="$gra/ph/names/name">
			<xsl:variable name="nn"  select="count(preceding-sibling::name)"/>
			<svg:g transform="translate({m:R($xAxisLStart + ($nn)*$catWd +$catGap)}, 
					{m:R($originY + $majorMarkLen + $labelFontSize)}) rotate({$labelAngle}) ">
			<svg:text>
			<xsl:value-of select="."/>
			</svg:text>
			</svg:g>
		</xsl:for-each>
		</svg:g>
	</xsl:if>
	
	
	<!-- Y axis with labels -->
	<svg:g stroke="black" stroke-width="{$axesStroke-width}"> 
	<xsl:if test="$mYpom[1] != 0">
		<svg:line stroke-dasharray="2,3"
				x1="{m:R($originX)}" y1="{m:R($yAxisTStart + $yAxisHg - $yAxisMarkDist)}" 
				x2="{m:R($originX)}" y2="{m:R($yAxisTStart + $yAxisHg)}" />    
	</xsl:if>
	<svg:line x1="{m:R($originX)}" y1="{m:R($yAxisTStart + $yAxisHg - $mYpom[1] * $yAxisMarkDist)}" 
					x2="{m:R($originX)}" y2="{m:R($yAxisTStart + $yAxisHg - $mYpom[last()]*$yAxisMarkDist)}"/>   
	<xsl:if test="$mYpom[last()] != $yAxisMarkCount">
		<svg:line stroke-dasharray="2,3"
			x1="{m:R($originX)}" y1="{m:R($yAxisTStart)}" 
			x2="{m:R($originX)}" y2="{m:R($yAxisTStart + $yAxisMarkDist)}"/>   
	</xsl:if>
	</svg:g>
		<!-- Y axis labels -->
	<xsl:if test="($yAxisDiv &gt; 0)">
		<svg:g text-anchor="end" font-family="Verdana" font-size="{$labelFontSize}" fill="black"> 
		<xsl:for-each  select="(for $a in ($mYpom[. &gt; -1]) return $yAxisMin + $a * $yAxisStep)"> 
			<svg:text x="{m:R(m:R($originX - $majorMarkLen - 3))}" y="{m:R(m:R($yShift + $yKoef*(.) + 0.35*$labelFontSize))}">
			<xsl:sequence select="m:FormatValue(., $yAxisStep, $gra/ph/@yAxisType, $gra/ph/@yAxisLabelsFormat, $gra/ph/@stacked)"/>
			</svg:text>
		</xsl:for-each> 
		</svg:g>	
	</xsl:if>
		
	
	<!-- drawing of curves -->
	<xsl:if test="not ($gra/ph/@lineType) or 
			(some $a in ($gra/ph/values/@lineType, $gra/ph/@lineType) satisfies (not ($a = 'none')))">
		<svg:g stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round" >
			<xsl:if test="$gra/ph/@lineType != 'solid'">
				<xsl:attribute name="stroke-dasharray" select="m:LineType($gra/ph/@lineType)"/>
			</xsl:if>
		<xsl:for-each select="$gra/ph/values[not (./@lineType = 'none') and 
				((./@lineType) or not ($gra/ph/@lineType = 'none'))]">  <!-- do until the the lineType is not none or if none wasn't inherited from graph -->
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
			<xsl:variable name="aColor"  select="if (./@color) then (./@color) else $colorSch[$cn]"/>
			<xsl:variable name="pX"  select="$xAxisLStart +$catGap +($sn*$shift +0.5)*$colWd"/>
			<xsl:variable name="lp"  select="min(($catCount, count(value)))"/>
			<xsl:variable name="sk"  select="0.18"/>
			<xsl:variable name="line"  select="
				concat('M', m:R($pX), ',', m:R($yShift + $yKoef * value[1])), 
				for $a in (1 to $lp -1)  return 
					concat('L', m:R($pX +$a*$catWd),',', m:R($yShift + $yKoef *value[$a+1]))
				"/>
				<xsl:variable name="line"  select="
				concat('M', m:R($pX), ',', m:R($yShift + $yKoef * value[1])), 
				if (./@smooth = 'yes') then (
					(for $a in (1 to $lp -2)  return 
						concat(' S ', m:R($pX +$a*$catWd - 2*$catWd*$sk),
						',', m:R($yShift + $yKoef *(value[$a+1] - (value[$a+2] - value[$a])*$sk)),
						' ',  m:R($pX +$a*$catWd),',', m:R($yShift + $yKoef *value[$a+1]) )
					),
					concat (' S ', m:R($pX +($lp -1)*$catWd),',', m:R($yShift + $yKoef *value[$lp])),
					concat (m:R($pX +($lp -1)*$catWd),',', m:R($yShift + $yKoef *value[$lp]))
				) else (
					for $a in (1 to $lp -1)  return 
						concat('L', m:R($pX +$a*$catWd),',', m:R($yShift + $yKoef *value[$a+1]))
				)" />
			<svg:path d="{$line}" stroke="{$aColor}">
				<xsl:if test="./@lineType">
					<xsl:attribute name="stroke-dasharray" select="m:LineType(./@lineType)"/>
				</xsl:if>
			</svg:path>
			<xsl:if test="not ($gra/ph/@legend = 'none') and (title)">
				<svg:path stroke="white" stroke-width="4.5"
							d="M{m:R($legendSX[1+$sn])},{m:R($legendSY[1+$sn])} l{m:R($legendPictureWd)},0"/>
				<svg:path stroke="{$aColor}" 
							d="M{m:R($legendSX[1+$sn])},{m:R($legendSY[1+$sn])} l{m:R($legendPictureWd)},0">
					<xsl:if test="./@lineType">
						<xsl:attribute name="stroke-dasharray" select="m:LineType(./@lineType)"/>
					</xsl:if>
				</svg:path>
			</xsl:if>
		</xsl:for-each>
		</svg:g>
	</xsl:if>
	
	<!-- draw points -->
	<xsl:for-each select="$gra/ph/values">
		<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
		<xsl:variable name="cn"  select="$sn mod count($colorSch)+1"/>
		<xsl:variable name="cc"  select="if (./@color) then (./@color) else $colorSch[$cn]"/>
		<xsl:variable name="pX"  select="$xAxisLStart +$catGap +($sn*$shift +0.5)*$colWd"/>
		<xsl:if test="some $a in (./@pointType, $gra/ph/@pointType) 
				satisfies $a != 'none'"> 
			<svg:g stroke-width="1.5" fill="none" color="{$cc}" stroke="{$cc}" stroke-linecap="round"> 
			<xsl:for-each select="value[position() &lt;= $catCount]">
				<xsl:variable name="vn"  select="count(preceding-sibling::value)"/>
				<xsl:call-template name="m:drawPoint">  <!-- draw a point (mark) of a given type -->
					<xsl:with-param name="type" select="
							if (../@pointType) then ../@pointType else
							if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
					<xsl:with-param name="x" select="m:R($pX + $vn*$catWd)"/>
					<xsl:with-param name="y" select="m:R($yShift + $yKoef * (.) )"/>
					<xsl:with-param name="color" select="inh"/>
				</xsl:call-template>
			</xsl:for-each>
			<!-- point of a given type for the legend -->
			<xsl:if test="not ($gra/ph/@legend = 'none') and (title)">
				<xsl:call-template name="m:drawPoint">  
					<xsl:with-param name="type" select="
							if (./@pointType) then ./@pointType else
							if ($gra/ph/@pointType) then $gra/ph/@pointType else 'none'"/>
					<xsl:with-param name="x" select="m:R($legendSX[1+$sn] + 0.5*$legendPictureWd)"/>
					<xsl:with-param name="y" select="m:R($legendSY[1+$sn])"/>
					<xsl:with-param name="color" select="inh"/>
				</xsl:call-template>
			</xsl:if>
			</svg:g>
		</xsl:if>
	</xsl:for-each>
	
	
	
	
	<!-- legend -->
	<xsl:if test="(not ($gra/ph/@legend = 'none'))">
		<svg:g text-anchor="start" font-family="Verdana" font-size="{$legendFontSize}" fill="black"> 
		<xsl:for-each select="$gra/ph/values[title]">
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<xsl:variable name="cn"  select="count(preceding-sibling::values) mod count($colorSch)+1"/>
			<xsl:variable name="cc"  select="if (./@color) then ./@color else $colorSch[$cn]"/>
			<svg:text x="{m:R($legendSX[1+$sn] + $legendPictureWd + $legendGap)}" 	
					y="{m:R($legendSY[1+$sn] + 0.35* $legendFontSize)}" fill="{$cc}">
				<xsl:value-of select="title"/>
			</svg:text>
		</xsl:for-each> 		
		</svg:g>	
	</xsl:if>

	<xsl:call-template name="m:drawFrame">
		<xsl:with-param name="width" select="$width"/>
		<xsl:with-param name="height" select="$height"/>
	</xsl:call-template>
	
	
	<!-- debuging prints -->
	<!-- 
	<svg:text x="{$originX}" y="{$originY - 15}" font-family="Verdana" font-size="{$labelFontSize}">
		<xsl:text>MMM</xsl:text>
		<xsl:sequence select="string-join(m:FormatValue($yAxisMin + 2 * $yAxisStep, $yAxisStep, $gra/ph/@yAxisType, $gra/ph/@yAxisLabelsFormat, $gra/ph/@stacked), '')"/>
		<xsl:text>MMM</xsl:text>
		<xsl:value-of select="string-length(string-join(m:FormatValue($yAxisMin + $yAxisMarkCount * $yAxisStep, $yAxisStep, $gra/ph/@yAxisType, $gra/ph/@yAxisLabelsFormat, $gra/ph/@stacked), ''))"/>
		<xsl:text>MMM</xsl:text>
		<xsl:value-of select="string-join((for $a in (0 to string-length(string(4000))) return ' '), 'x')"/>
		<xsl:text>MMM</xsl:text>
	</svg:text>
	-->
	<!-- debuging frames -->
	<!-- 
	<svg:rect x="1" y="1" width="{$width - 2}" height="{$titleHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<svg:rect x="{$legendL + 1}" y="{$titleHg + $legendT +1}" width="{$graphWd - 2}" height="{$graphHg - 2}"  
			stroke="red" fill="none" stroke-width="1"/> 
	<svg:rect x="{$legendX - $legendMargin + 1}" y="{$legendY - $legendMargin + 1}" width="{$legendWd - 2}" height="{$legendHg - 2}"  
			stroke="blue" fill="none" stroke-width="1"/> 
	<svg:rect x="0.5" y="{$titleMargin}" width="{$width - 0.5}" height="{$titleFontSize}"  
			stroke="grey" fill="none" stroke-width="1"/> 
	<xsl:if test="(not ($gra/ph/@legend = 'none'))">
		<xsl:for-each select="$gra/ph/values[title]">
			<xsl:variable name="sn"  select="count(preceding-sibling::values)"/>
			<svg:rect x="{$legendSX[$sn+1]}" y="{$legendSY[$sn+1] -0.5*$legendLineHg}" width="{$legendPictureWd}" height="{$legendLineHg}"
					stroke="red" fill="none" stroke-width="1"/> 
		</xsl:for-each> 		
	</xsl:if>
	-->
	
	</svg:svg>
</xsl:template>

</xsl:stylesheet>
