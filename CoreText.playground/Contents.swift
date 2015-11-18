//: Playground - noun: a place where people can play

import UIKit


let cgfont = CGFontCreateWithFontName("Helvetica")!
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

let textView = UITextView()
textView.textContainerInset = UIEdgeInsetsZero
textView.textContainer.lineFragmentPadding = 0
textView.scrollEnabled = false
textView.attributedText = NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont(name: "Helvetica", size: 16)!])
textView.sizeToFit()
let view = UIView(frame: textView.bounds)
view.addSubview(textView)
//var g = glyphs[0]
//withUnsafeMutablePointers(&rects, &glyphs[0]) { (p0, p1) -> Void in
//    CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, p1, p0, count)
//}

