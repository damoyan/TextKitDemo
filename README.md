## Introduction

This is a demo project for TextKit learning.

This demo is built on XCode7.1 with Swift2.0

## Basic Concepts

#### Glyph

![Image Of Glyph Metrics](glyphterms_2x.png)

可以通过`CGContextShowGlyphsAtPositions()`来直接画`glyph`. 但是有几个点需要注意:

1. `CGContextShowGlyphsAtPositions()`里的`position`参数是指`glyph`的`origin`. (这里的`origin`是在上图里面的`origin`. 可以理解为坐标原点.)
2. 这个方法在画`glyph`的时候, 是以`position`为原点, 在`glyph`的boundingRect区域去画`glyph`的.

## NSLayoutManager

TextKit通过这个类提供文字的排版服务, 但是这个类有几个方法和属性的值有问题

#### numberOfGlyphs

这个属性应该返回文本对应的`glyph`的数量, 但是在实践中发现, 实际上返回的是文本的长度. 也就是说当`glyph`和文字不是一一对应的时候, 这个属性的值是错误的.

#### boundingRectForGlyphRange()

这个函数返回的rect实际上并不是`glyph`的实际占用大小. (它返回的宽度是`advance`, 高度是行高. 从表现看像是这两个值, 但是我没有验证.) 所以要获取`glyph`的实际占用大小, 还是要用CoreText的API.

#### characterRangeForGlyphRange()/glyphRangeForCharacterRange()

和上面的`numberOfGlyphs`一样, 这两个函数的返回值一样有问题. 只适用于`glyph`和`character`是一一对应的这种情况. 当不是一一对应时, 返回值都有问题. 两个函数返回的`range`的`length`实际上都是`glyph`对应的`character`的`length`. 比如在`Zapfino`字体中, `the`对应一个`glyph`, 返回的`glyphrange`的`length`应该是1, 但是实际是3. 这样导致我去获取对应的`glyph`的时候拿到的并不是`the`对应的那个`glyph`, 而是`t`, `h`, `e`这三个`character`分别对应的三个`glyph`

#### usedRectForTextContainer()/boundingRectForGlyphRange:InTextContainer()

如果都是获取`textContainer`里面所有`glyph`的`rect`, 这两个函数的返回值是不一定相等的. `boundingRect...`函数的`width`实际上是`textContainer.size.width` - 2 * `lineFragmentPadding`. 而`usedRect...`的`width`通常比这个值要大. 因为`glyph`很可能会画到`boundingRect`的外面. (你可以通过给UILabel设置一种Italic的字体看出来, 首字母会被切断.) 而`usedRect...`拿到的就是文本所占据的`size`.

## Tips

1. 当`textStorage`发生变化的时候会trigger `layoutManager`重新layout. 比如`textStorage.setAttributedString()`等类似操作

## Lisence

MIT
