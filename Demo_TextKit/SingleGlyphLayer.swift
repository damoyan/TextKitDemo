//
//  SingleGlyphLayer.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/9/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

/// 用来画一个glyph
class SingleGlyphLayer: CALayer {
   
    let glyph: CGGlyph
    let cgfont: CGFont?
    let fontSize: CGFloat
    let glyphRect: CGRect
    
    init(glyph: CGGlyph, font: UIFont) {
        self.glyph = glyph
        self.cgfont = CGFontCreateWithFontName(font.fontName)
        self.fontSize = font.pointSize
        let ctfont = CTFontCreateWithName(font.fontName, font.pointSize, nil)
        var g = glyph; var r = CGRectZero
        CTFontGetBoundingRectsForGlyphs(ctfont, CTFontOrientation.Default, &g, &r, 1)
        self.glyphRect = r
        super.init()
    }

    override init(layer: AnyObject) {
        let l = layer as! SingleGlyphLayer
        self.glyph = l.glyph
        self.cgfont = l.cgfont
        self.fontSize = l.fontSize
        self.glyphRect = l.glyphRect
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        CGContextSaveGState(ctx)
        CGContextTranslateCTM(ctx, 0, bounds.height)
        CGContextScaleCTM(ctx, 1, -1)
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity)
        CGContextSetFont(ctx, cgfont)
        CGContextSetFontSize(ctx, fontSize)
        CGContextSetFillColorWithColor(ctx, UIColor.blackColor().CGColor)
        var position = CGPoint(x: -glyphRect.origin.x, y: -glyphRect.origin.y)
        var glyph = self.glyph
        CGContextShowGlyphsAtPositions(ctx, &glyph, &position, 1)
        CGContextRestoreGState(ctx)
    }
}
