//
//  CoreTextHelper.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/19/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

/// get rect of each glyph in the attributedString
public func getGlyphRectsForAttributedString(attriString: NSAttributedString, boundingWidth width: CGFloat, needCharactersForGlyph need: Bool = false) -> (glyphCharacters: [String], glyphs: [CGGlyph], glyphRects: [CGRect]) {
    
    let (frame, frameSize) = createFrame(attributedString: attriString, withboundingWidth: width)
    
    // get line info
    let (lines, lineOrigins) = getLinesInfo(frame)
    let numberOfLines = lines.count
    
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
            
            // 4. get glyph rect for each glyph in run
            let glyphRects = getGlyphRectsForGlyphs(glyphs, inRun: run)
            
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

/// get glyphs and corresponding rects based on CoreText coordinate
public func getGlyphsAndRects(attributedString attriString: NSAttributedString, withboundingWidth width: CGFloat) -> (glyphs: [CGGlyph], rects: [CGRect], positions: [CGPoint]) {
    let frameInfo = createFrame(attributedString: attriString, withboundingWidth: width)
    let (lines, lineOrigins) = getLinesInfo(frameInfo.frame)
    let numberOfLines = lines.count
    
    var glyphRet = [CGGlyph]()
    var rectRet = [CGRect]()
    var positionRet = [CGPoint]()
    for var i = 0; i < numberOfLines; i++ {
        let line = lines[i]
        let lineOrigin = lineOrigins[i]
        let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
        for run in runs {
            let numberOfGlyphs = CTRunGetGlyphCount(run)
            
            let glyphs = getGlyphsInRun(run, numberOfGlyphs: numberOfGlyphs)
            glyphRet += glyphs
            
            let glyphRects = getGlyphRectsForGlyphs(glyphs, inRun: run)
            rectRet += glyphRects
            
            let glyphPositions = getGlyphPositionsInRun(run, numberOfGlyphs: numberOfGlyphs)
            for var j = 0; j < numberOfGlyphs; j++ {
                var position = glyphPositions[j]
                position.x += lineOrigin.x
                position.y += lineOrigin.y
                positionRet.append(position)
            }
        }
    }
    return (glyphRet, rectRet, positionRet)
}

/// create frame and get the frame size
public func createFrame(attributedString attriString: NSAttributedString, withboundingWidth width: CGFloat) -> (frame: CTFrame, size: CGSize) {
    let stringLength = attriString.length
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringLength), nil, CGSize(width: width, height: CGFloat.max), nil)
    let framePath = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: frameSize), nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, stringLength), framePath, nil)
    return (frame, frameSize)
}

/// get lines array and orogin for the given frame
public func getLinesInfo(frame: CTFrame) -> (lines: [CTLine], lineOrigins: [CGPoint]) {
    let lines = (CTFrameGetLines(frame) as NSArray) as! [CTLine]
    let numberOfLines = lines.count
    let lineOrigins = getLineOrigins(frame, numberOfLines: numberOfLines)
    return (lines, lineOrigins)
}

/// get origin of each line in thes text frame
public func getLineOrigins(frame: CTFrame, numberOfLines nol: CFIndex) -> [CGPoint] {
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
public func getGlyphsInRun(run: CTRun, numberOfGlyphs nog: CFIndex) -> [CGGlyph] {
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
public func getGlyphPositionsInRun(run: CTRun, numberOfGlyphs nog: CFIndex) -> [CGPoint] {
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
public func getCorrespondingStringForGlyphsInRun(run: CTRun, stringRange: NSRange, string: String) -> [String] {
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
public func getGlyphRectsForGlyphs(glyphs: [CGGlyph], inRun run: CTRun) -> [CGRect] {
    let attributes = (CTRunGetAttributes(run) as NSDictionary) as! [String: AnyObject]
    let uifont = attributes[NSFontAttributeName] as! UIFont
    let font = CTFontCreateWithName(uifont.fontName, uifont.pointSize, nil)
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
public func convertGlyphRectsFromCoreTextToUIKit(glyphRects: [CGRect], glyphPositions: [CGPoint], lineOrigin: CGPoint, frameSize: CGSize) -> [CGRect] {
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