//: Playground - noun: a place where people can play

import UIKit

let fontName = "Zapfino"
let cgfont = CGFontCreateWithFontName(fontName)!
let ctfont = CTFontCreateWithGraphicsFont(cgfont, 16, nil, nil)

// get charactes of the string
let string = "just test for the effect."
let length = NSString(string: string).length
var chars: UniChar = 0
let res = withUnsafeMutablePointer(&chars) { (p) -> [UniChar] in
    CFStringGetCharacters(string, CFRangeMake(0, length), p)
    var ret: [UniChar] = []
    var x = p
    for var i = 0; i < length; i++ {
        ret.append(x.memory)
        x = x.successor()
    }
    return ret
}

// get glyphs for the string of ctfont
var gs: CGGlyph = 0
var glyphs = [CGGlyph]()
for var i = 0; i < res.count; i++ {
    var c = res[i]
    let g = withUnsafeMutablePointers(&gs, &c) { (p1, p2) -> CGGlyph in
        if !CTFontGetGlyphsForCharacters(ctfont, p2, p1, 1) {
            print("false")
        }
        return p1.memory
    }
    glyphs.append(g)
}

// get glyph rect
let count = glyphs.count
var rect:CGRect = CGRectZero
var rects = [CGRect]()
for var i = 0; i < glyphs.count; i++ {
    var g = glyphs[i]
    let r = withUnsafeMutablePointers(&rect, &g, { (p0, p1) -> CGRect in
        CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, 1)
        return p0.memory
    })
    rects.append(r)
}

let attriString = NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont(name: fontName, size: 16)!])
let textView = UITextView()
textView.textContainerInset = UIEdgeInsetsZero
textView.textContainer.lineFragmentPadding = 0
textView.scrollEnabled = false
textView.attributedText = attriString
textView.sizeToFit()
let w = textView.frame.width

let framesetter = CTFramesetterCreateWithAttributedString(attriString)
var path = CGPathCreateMutable()
CGPathAddRect(path, nil, CGRect(x: 0, y: 0, width: w, height: CGFloat.max))
let size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, attriString.length), nil, CGSizeMake(w, CGFloat.max), nil)
let framePath = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: size.width, height: size.height), nil)
let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attriString.length), framePath, nil)
var lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
var pp: CGPoint = CGPointZero
let origin = withUnsafeMutablePointer(&pp) { (p) -> CGPoint in
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), p)
    return p.memory
}

for var i = 0; i < lines.count; i++ {
    let line = lines[i]
    
    let range = CTLineGetStringRange(line)
    let start = range.location
    let end = range.location + range.length
    for var j = 0; j < end; j++ {
        let offset = CTLineGetOffsetForStringIndex(line, j, nil)
        rects[j].origin.x += offset
        //todo: no y position because there is only one line
        rects[j].origin.y += origin.y
    }
}

for rect in rects {
    let layer = CALayer()
    layer.borderColor = UIColor.redColor().CGColor
    layer.borderWidth = 1 / UIScreen.mainScreen().scale
    layer.frame = rect
    textView.layer.addSublayer(layer)
}





let view = UIView(frame: textView.bounds)
view.addSubview(textView)
//var g = glyphs[0]
//withUnsafeMutablePointers(&rects, &glyphs[0]) { (p0, p1) -> Void in
//    CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, count)
//}




















