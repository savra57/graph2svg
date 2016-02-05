> 


> Link Test:

> [TestWiki#Element:\_osgr](TestWiki#Element:_osgr.md)

> [Last Attributes](TestWiki#Last/Attributes.md)

> [TestWiki#Last/Attributes](TestWiki#Last/Attributes.md)

> [TestWiki#/Last/Content\_Model/@attribute](TestWiki#/Last/Content_Model/@attribute.md)


# `msgr` #

MSGR (Multi-Series GRaph) schema is designed to represent data and graphs with multiple data series.
In order to explain some terms imagine a table. First row contains table headers (or column names)
while other rows contain numbers or date/time values each forming a data series.
In such table every column is called a category and the column name will be called
a category name. Category names are always drawn on the x axis (horizontal axis) and data series
are by default drawn as lines.

Optionally the table can have a header column. The header column names describes
each data series and are called series titles. Series titles would be used for graph legend.
Series titles should not be confused with the whole graph title which is only one a typed centred
on the top of the graph.

Of course the format of MSGR graph is not a table but an XML file. The root element is
[`msgr`](TestWiki#/msgr.md) which children are
  * optional element [title](TestWiki#/msgr/title.md) for the graph title
  * one element [names](TestWiki#/msgr/names.md) which contains [name](TestWiki#/msgr/names/name.md) elements for category names
  * and multiple [values](TestWiki#/msgr/values.md) elements each containing [value](TestWiki#/msgr/values/value.md) elements holding the data
Data series titles can be added as a sub-elements of [values](TestWiki#/msgr/values.md) and should be wrapped in a
[title](TestWiki#/msgr/values/title.md) element.

That would be describing the graph data however it doesn't say anything about how the data should be displayed.
By default without defining other attributes the above will be drown as a line graph where each data series
is depicted by a line. Category names are on the x axis, the values on y axis and the legend with series titles
is on the right. That can be changed by configuring additional attributes, usually on the `msgr` element or specifically
on `values` elements. It is a general principle that attributes of values element overrides the values of root
element. That allows for wide range of graph types including:
  * bar chart
  * area graph
  * sum or percentage graph
And many others.

Usually different attribute values can be combined freely. For example if
the attribute [pointType](TestWiki#/msgr/@pointType.md) is set to `circle` on the msgr element and
the first `values` element has attribute [lineType](TestWiki#/msgr/values/@lineType.md) set to `dash` the first
data series will be drawn as line with circles around each data point. Other series will be drawn
as solid lines because default value of the [lineType](TestWiki#/msgr/@lineType.md) attribute is
`solid` and they will also have circles.


## `/msgr` ##

Root element for MSGR graph.

| **Content** | , title?, names?, (values)+|
|:------------|:---------------------------|
| **Attributes** | TODO                       |

### `/msgr/@stacked` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, sum, percentage |
| **Default Value** | none    |



### `/msgr/@shift` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@fillArea` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | yes, no |
| **Default Value** | no      |



### `/msgr/@effect` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | 2D, 3D  |
| **Default Value** | 2D      |

> One from `2D` or `3D`. Draws either a
> plain area (2D) or a pseudo three dimensional bar or pie
> chart

### `/msgr/@colType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, block, cylinder, cone, pyramid, line |
| **Default Value** | block   |

> When the graphType is set to `norm`, selects the
> type of column to be generated. One from

  * none
  * block
  * cylinder
  * cone
  * pyramid
  * line

> The named shape is used to draw the vertical columns of
> the bar chart. The default value is 'block', a two or three
> dimentional square block

### `/msgr/@xAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor, both |
| **Default Value** | minor   |

> Specifies which type of division are used on the X axis. Select from

  * none - no 'tics' on the X axis
  * major - Show the major axis 'tics'
  * minor - Show only minor axis 'tics'
  * both - Show both major and minor 'tics'


### `/msgr/@xAxisPos` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | bottom, origin |
| **Default Value** | origin  |

### `/msgr/@xGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor, both |
| **Default Value** | none    |

> Specifies which grid values are to be used on the X
> axis. Select from [| major | minor | both](none.md). Causes
> appropriately dimensioned grid lines along the X axis


### `/msgr/@categoryGap` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@columnWd` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@lineType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, solid, dot, dash, longDash, dash-dot, longDash-dot, dash-dot-dot, longDash-dash, dash-dash-dot-dot |
| **Default Value** | none    |

> If present, specifies the type of line to be used to
> connect the peak values of the bar chart. Select, one from


  * none
  * solid
  * dot
  * dash
  * longDash
  * dash-dot
  * longDash-dot
  * dash-dot-dot
  * longDash-dash
  * dahs-dash-dot-dot



### `/msgr/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, minus, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** | none    |

> @FIXME. No visible effect? Leaves a gap in the top of
> the bar chart line? Is this attribute applicable to a bar chart?
> There is code to process it, though it seems not to
> work.

### `/msgr/@yAxisType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | auto, withZero, shifted, log, dateTime |
| **Default Value** | auto    |

> If the Y values do not start at zero, use this property
> to obtain a clearer graph. Select one from

  * auto - Let the software decide
  * withZero - Include a zero value
  * shifted - start at non-zero value as appropriate
  * log - use a log scale


### `/msgr/@yAxisLabelsFormat` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |



### `/msgr/@yAxisMin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@yAxisMax` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@yAxisStep` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@yAxisMarkCount` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@yAxisMarkDist` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@yAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, 1, 2, 4, 5, 10 |
| **Default Value** | 1       |

> Specify the major Y axis divisions. Numeric values are
> shown with this interval. Select from [none | 1 | 2 | 3 | 4 | 5
> | 10]. The default value is 1

### `/msgr/@yGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor |
| **Default Value** | none    |

> Specifies which grid values are to be used on the Y
> axis. Select from [| major | minor ](none.md). Causes appropriately
> dimensioned grid lines along the Y axis vertically


### `/msgr/@colorScheme` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | color, warm, cold, grey, black |
| **Default Value** | color   |

> Defines an appropriate color scheme for the
> graph. Select from [color| warm | cold | grey | black](.md).
> `grey` is very useful when printing in black and
> white.

### `/msgr/@legend` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, left, right, top, bottom |
| **Default Value** | none    |

> Specifies the position, on the graph, at which a repeat
> of the values range are repeated. Produces a block of text with
> the 'color' scheme and the appropriate 'names' used against each
> one. Select from [none|left|right|top|bottom]

### `/msgr/@legendMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@legendPictureWd` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@legendPictureHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@legendLineHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@legendGap` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@legendFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@graphMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@titleMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@titleFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@labelAngle` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/msgr/@labelFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/msgr/title` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/msgr/title/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/msgr/names` ##

| **Content** | (name)+|
|:------------|:-------|
| **Attributes** | TODO   |

## `/msgr/names/name` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

## `/msgr/values` ##

> The extent of each Y value. There must be one for each
> value in the 'name' list.

| **Content** | title?, (value)+|
|:------------|:----------------|
| **Attributes** | TODO            |

### `/msgr/values/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

> Specify what color to use for a value. Works well with a
> grey `colorScheme`, though be careful when mixing
> colors, if one specific value is to stand out.
> See
> W3C
> for more information. Use either the keywords (See
> W3C
> ,
> or one of the CSS alternatives, for which see


### `/msgr/values/@colType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, block, cylinder, cone, pyramid, line |
| **Default Value** |         |

> Selects the type of column to be generated. One from


  * none
  * block
  * cylinder
  * cone
  * pyramid
  * line

> The named shape is used to draw the vertical columns of
> the bar chart. The default value is 'block', a two or three
> dimentional square block

### `/msgr/values/@lineType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, solid, dot, dash, longDash, dash-dot, longDash-dot, dash-dot-dot, longDash-dash, dash-dash-dot-dot |
| **Default Value** |         |

> If present, specifies the type of line to be used to
> connect the peak values of the bar chart. Select, one from


  * none
  * solid
  * dot
  * dash
  * longDash
  * dash-dot
  * longDash-dot
  * dash-dot-dot
  * longDash-dash
  * dash-dash-dot-dot



### `/msgr/values/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, minus, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** |         |

> Defines the marker type to be used for extnts. No
> default. Select one from
> [none|point|cross|plus|minus|star|square|circle|triangle|rhomb|
> pyramid|squareF|circleF|triangleF|rhombF|pyramidF]. rhomb is a
> rhombus, those items suffixed 'F' are filled shapes

### `/msgr/values/@smooth` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | yes, no |
| **Default Value** | no      |

> When values are connected with a line (lineType
> property on the values element), the line may be smoothed
> using this property. Select from [yes|no]. Defaults to no

### `/msgr/values/@fillArea` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | yes, no |
| **Default Value** |         |

> For any set of values, the fillArea property joins the
> areas formed with the similar color (or shade of grey). Works
> best when the `effect` attribute on
> `msgr` is set to 2D. Select from [yes|no]. Defaults to no

### `/msgr/values/@startFrom` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | axis, last |
| **Default Value** |         |

> For a stacked graph, specify from what origin the bar
> should start. Select from [axis|last]. If
> `axis` is selected, the bar is started from the
> X axis. If `last` is selected, then one set of
> values is stacked on top of (starting where the previous one
> ended) the previous one. The default is `axis`


## `/msgr/values/title` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/msgr/values/title/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/msgr/values/value` ##

> A single value specifiying the extent of one 'name'. The
> name is the X axis label, the value is the Y extent.

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

## `/osgr` ##

| **Content** | , title?, names?, (values)+|
|:------------|:---------------------------|
| **Attributes** | TODO                       |

### `/osgr/@graphType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | pie, norm |
| **Default Value** | norm    |

> The type of graph. One of `pie` or
> `norm`. Draws either a PIE chart or a bar chart (when
> `norm` is selected.
> @FIXME. What happens to the labels / values when 'pie' is
> selected? They aren't shown?

### `/osgr/@smooth` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | yes, no |
| **Default Value** | no      |

> @FIXME. No visible effect on the bar chart? Is this
> attribute applicable?

### `/osgr/@labelIn` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, value, percent, name |
| **Default Value** | none    |

> Adds values, names or percentages to the bars or
> segments of the pie chart. Useful if accurate values are to be
> shown. Select from [none|value|percentage|name]. Names are used
> to label the segments of a pie chart.

### `/osgr/@labelOut` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, value, percent, name |
| **Default Value** | none    |

> Enables the placing of labels 'outside' a pie chart,
> opposite each segment. Specifies what kind of labels are
> needed. Select from [none|value|percent|name].

### `/osgr/@effect` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | 2D, 3D  |
| **Default Value** | 2D      |

> One from `2D` or `3D`. Draws either a
> plain area (2D) or a pseudo three dimensional bar or pie
> chart

### `/osgr/@colType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, block, cylinder, cone, pyramid, line |
| **Default Value** | block   |

> When the graphType is set to `norm`, selects the
> type of column to be generated. One from

  * none
  * block
  * cylinder
  * cone
  * pyramid
  * line

> The named shape is used to draw the vertical columns of
> the bar chart. The default value is 'block', a two or three
> dimentional square block

### `/osgr/@xAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor, both |
| **Default Value** | minor   |

> Specifies which type of division are used on the X axis. Select from

  * none - no 'tics' on the X axis
  * major - Show the major axis 'tics'
  * minor - Show only minor axis 'tics'
  * both - Show both major and minor 'tics'


### `/osgr/@xAxisPos` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | bottom, origin |
| **Default Value** | origin  |

### `/osgr/@xGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor, both |
| **Default Value** | none    |

> Specifies which grid values are to be used on the X
> axis. Select from [| major | minor | both](none.md). Causes
> appropriately dimensioned grid lines along the X axis


### `/osgr/@categoryGap` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@columnWd` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@lineType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, solid, dot, dash, longDash, dash-dot, longDash-dot, dash-dot-dot, longDash-dash, dash-dash-dot-dot |
| **Default Value** | none    |

> If present, specifies the type of line to be used to
> connect the peak values of the bar chart. Select, one from


  * none
  * solid
  * dot
  * dash
  * longDash
  * dash-dot
  * longDash-dot
  * dash-dot-dot
  * longDash-dash
  * dahs-dash-dot-dot



### `/osgr/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, minus, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** | none    |

> @FIXME. No visible effect? Leaves a gap in the top of
> the bar chart line? Is this attribute applicable to a bar chart?
> There is code to process it, though it seems not to
> work.

### `/osgr/@yAxisType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | auto, withZero, shifted, log, dateTime |
| **Default Value** | auto    |

> If the Y values do not start at zero, use this property
> to obtain a clearer graph. Select one from

  * auto - Let the software decide
  * withZero - Include a zero value
  * shifted - start at non-zero value as appropriate
  * log - use a log scale


### `/osgr/@yAxisLabelsFormat` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |



### `/osgr/@yAxisMin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@yAxisMax` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@yAxisStep` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@yAxisMarkCount` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@yAxisMarkDist` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@yAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, 1, 2, 4, 5, 10 |
| **Default Value** | 1       |

> Specify the major Y axis divisions. Numeric values are
> shown with this interval. Select from [none | 1 | 2 | 3 | 4 | 5
> | 10]. The default value is 1

### `/osgr/@yGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor |
| **Default Value** | none    |

> Specifies which grid values are to be used on the Y
> axis. Select from [| major | minor ](none.md). Causes appropriately
> dimensioned grid lines along the Y axis vertically


### `/osgr/@colorScheme` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | color, warm, cold, grey, black |
| **Default Value** | color   |

> Defines an appropriate color scheme for the
> graph. Select from [color| warm | cold | grey | black](.md).
> `grey` is very useful when printing in black and
> white.

### `/osgr/@legend` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, left, right, top, bottom |
| **Default Value** | none    |

> Specifies the position, on the graph, at which a repeat
> of the values range are repeated. Produces a block of text with
> the 'color' scheme and the appropriate 'names' used against each
> one. Select from [none|left|right|top|bottom]

### `/osgr/@legendMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@legendPictureWd` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@legendPictureHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@legendLineHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@legendGap` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@legendFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@graphMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@titleMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@titleFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@labelAngle` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/@labelFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/osgr/title` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/osgr/title/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/osgr/names` ##

| **Content** | (name)+|
|:------------|:-------|
| **Attributes** | TODO   |

## `/osgr/names/name` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

## `/osgr/values` ##

| **Content** | (value)+|
|:------------|:--------|
| **Attributes** | TODO    |

## `/osgr/values/value` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/osgr/values/value/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/osgr/values/value/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, minus, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** |         |

## `/xygr` ##

| **Content** | , , title?, (curve)+|
|:------------|:--------------------|
| **Attributes** | TODO                |

### `/xygr/@axesPos` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | left-bottom, origin |
| **Default Value** | origin  |

### `/xygr/@xAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, 1, 2, 4, 5, 10 |
| **Default Value** | 1       |

### `/xygr/@xGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor |
| **Default Value** | none    |

### `/xygr/@xAxisType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | auto, withZero, shifted, log, dateTime |
| **Default Value** | auto    |

### `/xygr/@xAxisLabelsFormat` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |



### `/xygr/@xAxisMin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@xAxisMax` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@xAxisStep` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@xAxisMarkCount` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@xAxisMarkDist` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@curveFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@lineType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, solid, dot, dash, longDash, dash-dot, longDash-dot, dash-dot-dot, longDash-dash, dash-dash-dot-dot |
| **Default Value** | none    |

> If present, specifies the type of line to be used to
> connect the peak values of the bar chart. Select, one from


  * none
  * solid
  * dot
  * dash
  * longDash
  * dash-dot
  * longDash-dot
  * dash-dot-dot
  * longDash-dash
  * dahs-dash-dot-dot



### `/xygr/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, minus, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** | none    |

> @FIXME. No visible effect? Leaves a gap in the top of
> the bar chart line? Is this attribute applicable to a bar chart?
> There is code to process it, though it seems not to
> work.

### `/xygr/@yAxisType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | auto, withZero, shifted, log, dateTime |
| **Default Value** | auto    |

> If the Y values do not start at zero, use this property
> to obtain a clearer graph. Select one from

  * auto - Let the software decide
  * withZero - Include a zero value
  * shifted - start at non-zero value as appropriate
  * log - use a log scale


### `/xygr/@yAxisLabelsFormat` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |



### `/xygr/@yAxisMin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@yAxisMax` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@yAxisStep` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@yAxisMarkCount` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@yAxisMarkDist` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@yAxisDivision` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, 1, 2, 4, 5, 10 |
| **Default Value** | 1       |

> Specify the major Y axis divisions. Numeric values are
> shown with this interval. Select from [none | 1 | 2 | 3 | 4 | 5
> | 10]. The default value is 1

### `/xygr/@yGrid` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, major, minor |
| **Default Value** | none    |

> Specifies which grid values are to be used on the Y
> axis. Select from [| major | minor ](none.md). Causes appropriately
> dimensioned grid lines along the Y axis vertically


### `/xygr/@colorScheme` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | color, warm, cold, grey, black |
| **Default Value** | color   |

> Defines an appropriate color scheme for the
> graph. Select from [color| warm | cold | grey | black](.md).
> `grey` is very useful when printing in black and
> white.

### `/xygr/@legend` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, left, right, top, bottom |
| **Default Value** | none    |

> Specifies the position, on the graph, at which a repeat
> of the values range are repeated. Produces a block of text with
> the 'color' scheme and the appropriate 'names' used against each
> one. Select from [none|left|right|top|bottom]

### `/xygr/@legendMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@legendPictureWd` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@legendPictureHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@legendLineHg` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@legendGap` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@legendFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@graphMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@titleMargin` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@titleFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@labelAngle` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/@labelFontSize` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/xygr/title` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/xygr/title/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/xygr/curve` ##

| **Content** | name?, (point)+|
|:------------|:---------------|
| **Attributes** | TODO           |

### `/xygr/curve/@lineType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, solid, dot, dash, longDash, dash-dot, longDash-dot, dash-dot-dot, longDash-dash, dash-dash-dot-dot |
| **Default Value** |         |

### `/xygr/curve/@smooth` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | yes, no |
| **Default Value** | no      |

### `/xygr/curve/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, line, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** |         |

### `/xygr/curve/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

## `/xygr/curve/name` ##

| **Content** | TEXT|
|:------------|:----|
| **Attributes** | TODO |

### `/xygr/curve/name/@x` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/curve/name/@y` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/curve/name/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/curve/name/@visibility` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, legend, graph, both |
| **Default Value** | both    |

## `/xygr/curve/point` ##

| **Content** | EMPTY|
|:------------|:-----|
| **Attributes** | TODO |

### `/xygr/curve/point/@x` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/curve/point/@y` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |

### `/xygr/curve/point/@pointType` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | Enumeration |
| **Values** | none, point, cross, plus, line, star, square, circle, triangle, rhomb, pyramid, squareF, circleF, triangleF, rhombF, pyramidF |
| **Default Value** |         |

### `/xygr/curve/point/@color` ###

| **Use** | Optional|
|:--------|:--------|
| **Type** | TEXT    |