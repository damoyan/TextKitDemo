//: Playground - noun: a place where people can play

import UIKit

class TextLayer: CALayer {
    
    var text: NSString!
    var glyphRect: CGRect!
    var font: UIFont!
    
    init(text: NSString, glyphRect: CGRect, font: UIFont) {
        self.text = text
        self.glyphRect = glyphRect
        self.font = font
        super.init()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        super.drawInContext(ctx)
        CGContextSaveGState(ctx)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        let rect = CGRect(origin: CGPointZero, size: glyphRect.size)
        text.drawWithRect(rect, options: NSStringDrawingOptions(rawValue: 0), attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor()], context: nil)
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
    }
}

class View: UIView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
        let s: NSString = "j"
        s.drawInRect(CGRect(x: 0, y: 0, width: 15, height: 20), withAttributes: [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(16)])
        CGContextStrokePath(context)
    }
}

let fontName = "Zapfino"
let font = UIFont(name: fontName, size: 16)!
let cgfont = CGFontCreateWithFontName(fontName)!
let ctfont = CTFontCreateWithGraphicsFont(cgfont, 16, nil, nil)

// get charactes of the string
let string = "just test for the effect. Zapfino just test for the effect."
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
func getCorrespondingStringForGlyphsInRun(run: CTRun, stringRange: NSRange, string: String) -> [String] {
    var ret = [String]()
    let count = CTRunGetGlyphCount(run)
    let stringIndices = UnsafeMutablePointer<CFIndex>.alloc(count)
    CTRunGetStringIndices(run, CFRangeMake(0, count), stringIndices)
    for var i = 0; i < count; i++ {
        let location = stringRange.location + stringIndices[i]
        let length = (i + 1) < count ? (stringIndices[i + 1] - stringIndices[i]) : (stringRange.location + stringRange.length - stringIndices[i])
        let str = (string as NSString).substringWithRange(NSMakeRange(location, length))
        ret.append(str)
    }
    return ret
}

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
    
    // get characters of glyph
    let cfrange = CTRunGetStringRange(run)
    let characters = getCorrespondingStringForGlyphsInRun(run, stringRange: NSMakeRange(cfrange.location, cfrange.length), string: string)
    print(characters)
    
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

let view = UIView(frame: CGRect(origin: CGPointZero, size: CGSizeMake(textView.bounds.width, 500)))
view.backgroundColor = UIColor.whiteColor()
let tl = TextLayer(text: "j", glyphRect: CGRect(x: 10, y: 300, width: 50, height: 50), font: UIFont.systemFontOfSize(16))
tl.setNeedsDisplay()
view.layer.addSublayer(tl)
view.addSubview(textView)
//let vv = View()
//vv.frame = CGRect(x: 20, y: 200, width: 15, height: 20)
//vv.backgroundColor = UIColor.redColor()
//vv.setNeedsDisplay()
//view.addSubview(vv)
//var g = glyphs[0]
//withUnsafeMutablePointers(&rects, &glyphs[0]) { (p0, p1) -> Void in
//    CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, count)
//}




















