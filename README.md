## Introduction

This is a demo project for TextKit learning.

## Basic Concepts

#### Glyph

![Image Of Glyph Metrics](glyphterms_2x.png)

可以通过`CGContextShowGlyphsAtPositions()`来直接画`glyph`. 但是有几个点需要注意:

1. `CGContextShowGlyphsAtPositions()`里的`position`参数是指`glyph`的`origin`. (这里的`origin`并不是`rect.origin`, 而是在Glyph Metric图里面的`origin`. 可以理解为原点. 系统以这个点为坐标系原点来应用`CTFontGetBoundingRectsForGlyphs()`得到的`glyph`的boundingRect. 




## Lisence

MIT
