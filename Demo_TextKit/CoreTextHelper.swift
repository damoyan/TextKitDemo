//
//  CoreTextHelper.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/19/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

/// get rect of each glyph in the attributedString
func getGlyphRectsForAttributedString(attriString: NSAttributedString, boundingWidth width: CGFloat) -> [CGRect] {
    let stringLength = attriString.length
    // create frame
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringLength), nil, CGSize(width: width, height: CGFloat.max), nil)
    let framePath = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: frameSize), nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, stringLength), framePath, nil)
    // get line info
    let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
    let numberOfLines = lines.count
    let lineOrigins = getLineOrigins(frame, numberOfLines: numberOfLines)
    
    //
    var ret = [CGRect]()
    for var i = 0; i < numberOfLines; i++ {
        let line = lines[i]
        let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
        for run in runs {
            let numberOfGlyphs = CTRunGetGlyphCount(run)
            let glyphs = getGlyphsInRun(run, numberOfGlyphs: numberOfGlyphs)
            let attributes = (CTRunGetAttributes(run) as NSDictionary) as! [String: AnyObject]
            let font = attributes[NSFontAttributeName] as! UIFont
            let glyphRects = getGlyphRectsForGlyphs(glyphs, font: CTFontCreateWithName(font.fontName, font.pointSize, nil))
            let glyphPositions = getGlyphPositionsInRun(run, numberOfGlyphs: numberOfGlyphs)
            let rectsForUIKit = convertGlyphRectsFromCoreTextToUIKit(glyphRects, glyphPositions: glyphPositions, lineOrigin: lineOrigins[i], frameSize: frameSize)
            ret += rectsForUIKit
            print(glyphRects)
        }
    }
    return ret
}

/// get origin of each line in thes text frame
func getLineOrigins(frame: CTFrame, numberOfLines nol: CFIndex) -> [CGPoint] {
    var ret = [CGPoint]()
    for var i = 0; i < nol; i++ {
        var pp: CGPoint = CGPointZero
        let origin = withUnsafeMutablePointer(&pp) { (p) -> CGPoint in
            CTFrameGetLineOrigins(frame, CFRangeMake(i, 1), p)
            return p.memory
        }
        ret.append(origin)
    }
    return ret
}

/// get glyphs of the run
func getGlyphsInRun(run: CTRun, numberOfGlyphs nog: CFIndex) -> [CGGlyph] {
    var ret = [CGGlyph]()
    for var x = 0; x < nog; x++ {
        var gir: CGGlyph = 0
        let r = withUnsafeMutablePointer(&gir, { (p) -> CGGlyph in
            CTRunGetGlyphs(run, CFRangeMake(x, 1), p)
            return p.memory
        })
        ret.append(r)
    }
    return ret
}

/// get glyph position in the run rect
func getGlyphPositionsInRun(run: CTRun, numberOfGlyphs nog: CFIndex) -> [CGPoint] {
    var ret = [CGPoint]()
    for var x = 0; x < nog; x++ {
        var gp: CGPoint = CGPointZero
        let p = withUnsafeMutablePointer(&gp, { (p) -> CGPoint in
            CTRunGetPositions(run, CFRangeMake(x, 1), p)
            return p.memory
        })
        ret.append(p)
    }
    return ret
}

/// Core Text's coordinate defers from UIKit.
///
func convertGlyphRectsFromCoreTextToUIKit(glyphRects: [CGRect], glyphPositions: [CGPoint], lineOrigin: CGPoint, frameSize: CGSize) -> [CGRect] {
    var ret = glyphRects
    for var i = 0; i < glyphRects.count; i++ {
        let position = glyphPositions[i]
        let y = glyphRects[i].origin.y
        let height = glyphRects[i].height
        ret[i].origin.x += position.x + lineOrigin.x
        ret[i].origin.y = frameSize.height - y - height - lineOrigin.y
    }
    return ret
}

/// get glyphs bounding rect for the given glyphs
///
/// Note: the origin of returned rect is based on CoreText coordinate.
/// Y axis is from bottom to top. you should convert it to UIKit coordinate.
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