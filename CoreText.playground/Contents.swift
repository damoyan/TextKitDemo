//: Playground - noun: a place where people can play

import UIKit

let fontName = "Zapfino"
let font = UIFont(name: fontName, size: 16)!
let cgfont = CGFontCreateWithFontName(fontName)!
let ctfont = CTFontCreateWithGraphicsFont(cgfont, 16, nil, nil)

// get charactes of the string
let string = "just test for the effect. just test for the effect."
//let length = NSString(string: string).length
//var chars: UniChar = 0
//let res = withUnsafeMutablePointer(&chars) { (p) -> [UniChar] in
//    CFStringGetCharacters(string, CFRangeMake(0, length), p)
//    var ret: [UniChar] = []
//    var x = p
//    for var i = 0; i < length; i++ {
//        ret.append(x.memory)
//        x = x.successor()
//    }
//    return ret
//}
//
//// get glyphs for the string of ctfont
//var gs: CGGlyph = 0
//var glyphs = [CGGlyph]()
//for var i = 0; i < res.count; i++ {
//    var c = res[i]
//    let g = withUnsafeMutablePointers(&gs, &c) { (p1, p2) -> CGGlyph in
//        if !CTFontGetGlyphsForCharacters(ctfont, p2, p1, 1) {
//            print("false")
//        }
//        return p1.memory
//    }
//    glyphs.append(g)
//}

// get glyph rect
func getGlyphRectsForGlyphs(glyphs: [CGGlyph], font: CTFont) -> [CGRect] {
    var rect:CGRect = CGRectZero
    var rects = [CGRect]()
    for var i = 0; i < glyphs.count; i++ {
        var g = glyphs[i]
        let r = withUnsafeMutablePointers(&rect, &g, { (p0, p1) -> CGRect in
            CTFontGetBoundingRectsForGlyphs(font, CTFontOrientation.Default, p1, p0, 1)
            return p0.memory
        })
        rects.append(r)
    }
    return rects
}
//let count = glyphs.count
//var rect:CGRect = CGRectZero
//var rects = [CGRect]()
//for var i = 0; i < glyphs.count; i++ {
//    var g = glyphs[i]
//    let r = withUnsafeMutablePointers(&rect, &g, { (p0, p1) -> CGRect in
//        CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, 1)
//        return p0.memory
//    })
//    rects.append(r)
//}
//var rects = getGlyphRectsForGlyphs(glyphs, font: ctfont)

let attriString = NSAttributedString(string: string, attributes: [NSFontAttributeName: font])
let textView = UITextView()
textView.textContainerInset = UIEdgeInsetsZero
textView.textContainer.lineFragmentPadding = 0
textView.scrollEnabled = false
textView.attributedText = attriString
textView.sizeToFit()
let w = textView.frame.width

// calculate the frame when the string is rendered
let framesetter = CTFramesetterCreateWithAttributedString(attriString)
//var path = CGPathCreateMutable()
//CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: w, height: CGFloat.max))
let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attriString.length), nil, CGSizeMake(w, CGFloat.max), nil)
let framePath = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: size.width, height: size.height), nil)
let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attriString.length), framePath, nil)
var lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
var pp: CGPoint = CGPointZero
let origin = withUnsafeMutablePointer(&pp) { (p) -> CGPoint in
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), p)
    return p.memory
}

//for var i = 0; i < lines.count; i++ {
//    let line = lines[i]
//    
//    let range = CTLineGetStringRange(line)
//    let start = range.location
//    let end = range.location + range.length
//    for var j = 0; j < end; j++ {
//        let offset = CTLineGetOffsetForStringIndex(line, j, nil)
//        rects[j].origin.x += offset
//        //todo: no y position because there is only one line
//        rects[j].origin.y += origin.y
//    }
//}

// add layer rect to display
//for rect in rects {
//    let layer = CALayer()
//    layer.borderColor = UIColor.redColor().CGColor
//    layer.borderWidth = 1 / UIScreen.mainScreen().scale
//    layer.frame = rect
//    textView.layer.addSublayer(layer)
//}


// find CTRun
var runRects = [CGRect]()
let runs = (CTLineGetGlyphRuns(lines[0]) as NSArray) as! [CTRun]
print(runs.count)
for var rIndex = 0; rIndex < runs.count; rIndex++ {
    let run = runs[rIndex]
    let gc = CTRunGetGlyphCount(run)
    
    var gir: CGGlyph = 0
    let glyphsInRun = withUnsafeMutablePointer(&gir, { (p) -> [CGGlyph] in
        CTRunGetGlyphs(run, CFRangeMake(0, 0), p)
        var ret = [CGGlyph]()
        var pv = p
        for var x = 0; x < gc; x++ {
            ret.append(pv.memory)
            pv = pv.successor()
        }
        return ret
    })
    let dic = CTRunGetAttributes(run)
    print(dic)
    var glyphRectsInRun = getGlyphRectsForGlyphs(glyphsInRun, font: ctfont)
    
    var glyphPositions = [CGPoint]()
    for var x = 0; x < gc; x++ {
        var gp: CGPoint = CGPointZero
        let p = withUnsafeMutablePointer(&gp, { (p) -> CGPoint in
            CTRunGetPositions(run, CFRangeMake(x, 1), p)
            return p.memory
        })
        glyphPositions.append(p)
        glyphRectsInRun[x].origin.x += p.x + origin.x
        let y = glyphRectsInRun[x].origin.y
        let h = glyphRectsInRun[x].height
        glyphRectsInRun[x].origin.y = textView.frame.height - (origin.y + y) - h
//        let y = font.ascender - glyphRectsInRun[x].height
//        glyphRectsInRun[x].origin.y = y > 0 ? y : 0
    }
    
    for rect in glyphRectsInRun {
        let layer = CALayer()
        layer.borderColor = UIColor.redColor().CGColor
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        layer.frame = rect
        textView.layer.addSublayer(layer)
    }
}

let view = UIView(frame: textView.bounds)
view.addSubview(textView)
//var g = glyphs[0]
//withUnsafeMutablePointers(&rects, &glyphs[0]) { (p0, p1) -> Void in
//    CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, count)
//}




















