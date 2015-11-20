//
//  CoreTextHelper.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/19/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

/// get rect of each glyph in the attributedString
func getGlyphRectsForAttributedString(attriString: NSAttributedString, boundingWidth width: CGFloat, needCharactersForGlyph need: Bool = false) -> (glyphCharacters: [String], glyphs: [CGGlyph], glyphRects: [CGRect]) {
    let stringLength = attriString.length
    // create frame and get the frame size
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringLength), nil, CGSize(width: width, height: CGFloat.max), nil)
    let framePath = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: frameSize), nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, stringLength), framePath, nil)
    // get line info
    let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
    let numberOfLines = lines.count
    let lineOrigins = getLineOrigins(frame, numberOfLines: numberOfLines)
    
    // handle each run in each line of the frame
    var glyphCharacters = [String]()
    var retGlyphs = [CGGlyph]()
    var ret = [CGRect]()
    for var i = 0; i < numberOfLines; i++ {
        let line = lines[i]
        let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
        for run in runs {
            // 1. get glyph count
            let numberOfGlyphs = CTRunGetGlyphCount(run)
            
            // 2. get all glyphs in run
            let glyphs = getGlyphsInRun(run, numberOfGlyphs: numberOfGlyphs)
            
            // 3. get font attribute for this run
            let attributes = (CTRunGetAttributes(run) as NSDictionary) as! [String: AnyObject]
            let font = attributes[NSFontAttributeName] as! UIFont
            
            // 4. get glyph rect for each glyph in run
            let glyphRects = getGlyphRectsForGlyphs(glyphs, font: CTFontCreateWithName(font.fontName, font.pointSize, nil))
            
            // 5. get glyph position for each glyph in run
            let glyphPositions = getGlyphPositionsInRun(run, numberOfGlyphs: numberOfGlyphs)
            
            // 6. covert glyph frame info from Core Text to UIKit, since they use different coordinates
            let rectsForUIKit = convertGlyphRectsFromCoreTextToUIKit(glyphRects, glyphPositions: glyphPositions, lineOrigin: lineOrigins[i], frameSize: frameSize)
            
            // 7. find the character of each glyph in run if needed
            if need {
                let stringRange = CTRunGetStringRange(run)
                let glyphCharactersInRun = getCorrespondingStringForGlyphsInRun(run, stringRange: NSMakeRange(stringRange.location, stringRange.length), string: attriString.string)
                glyphCharacters += glyphCharactersInRun
            }
            
            retGlyphs += glyphs
            ret += rectsForUIKit
        }
    }
    return (glyphCharacters, retGlyphs, ret)
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

/// get characters displayed by the glyph
func getCorrespondingStringForGlyphsInRun(run: CTRun, stringRange: NSRange, string: String) -> [String] {
    var ret = [String]()
    let count = CTRunGetGlyphCount(run)
    let indices = UnsafeMutablePointer<CFIndex>.alloc(count)
    CTRunGetStringIndices(run, CFRangeMake(0, count), indices)
    for var i = 0; i < count; i++ {
        let location = indices[i]
        let length = (i + 1) < count ? (indices[i + 1] - indices[i]) : (stringRange.location + stringRange.length - indices[i])
        let str = (string as NSString).substringWithRange(NSMakeRange(location, length))
        ret.append(str)
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