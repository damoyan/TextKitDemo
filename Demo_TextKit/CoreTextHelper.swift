//
//  CoreTextHelper.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/19/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

/// get rect of each glyph in the attributedString
public func getGlyphRectsForAttributedString(attriString: NSAttributedString, boundingWidth width: CGFloat, needCharactersForGlyph need: Bool = false) -> (glyphCharacters: [String], glyphs: [CGGlyph], glyphRects: [CGRect], glyphUIKitRects: [CGRect]) {
    
    let (frame, frameSize) = createFrame(attributedString: attriString, withboundingWidth: width)
    print(frameSize)
    // get line info
    let (lines, lineOrigins) = getLinesInfo(frame)
    let numberOfLines = lines.count
    
    // handle each run in each line of the frame
    var glyphCharacters = [String]()
    var retGlyphs = [CGGlyph]()
    var glyphRectRet = [CGRect]()
    var uikitRet = [CGRect]()
    for var i = 0; i < numberOfLines; i++ {
        let line = lines[i]
        let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
        for run in runs {
            // 1. get glyph count
            let numberOfGlyphs = CTRunGetGlyphCount(run)
            print("numberOfGlyphs: \(numberOfGlyphs)")
            
            // 2. get all glyphs in run
            let glyphs = getGlyphsInRun(run, numberOfGlyphs: numberOfGlyphs)
            print(glyphs)
            
            // if the run is attachment
            if numberOfGlyphs == 1 && glyphs.count == 1 && glyphs[0] == 1 {
                var position = CGPointZero
                CTRunGetPositions(run, CFRangeMake(0, 1), &position)
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                var leading: CGFloat = 0
                let width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading)
                print("position: \(position)")
                print("ascent: \(ascent)")
                print("descent: \(descent)")
                print("width: \(width)")
                let rect = CGRect(x: 0, y: 0, width: CGFloat(width), height: ascent - descent)
                let rectsForUIKit = convertGlyphRectsFromCoreTextToUIKit([rect], glyphPositions: [position], lineOrigin: lineOrigins[i], frameSize: frameSize)
                print(rectsForUIKit)
                glyphRectRet.append(rect)
                uikitRet += rectsForUIKit
            } else {
                // 4. get glyph rect for each glyph in run
                let glyphRects = getGlyphRectsForGlyphs(glyphs, inRun: run)
                print(glyphRects)
                
                // 5. get glyph position for each glyph in run
                let glyphPositions = getGlyphPositionsInRun(run, numberOfGlyphs: numberOfGlyphs)
                print(glyphPositions)
                
                // 6. covert glyph frame info from Core Text to UIKit, since they use different coordinates
                let rectsForUIKit = convertGlyphRectsFromCoreTextToUIKit(glyphRects, glyphPositions: glyphPositions, lineOrigin: lineOrigins[i], frameSize: frameSize)
                print(rectsForUIKit)
                
                // 7. find the character of each glyph in run if needed
                if need {
                    let stringRange = CTRunGetStringRange(run)
                    let glyphCharactersInRun = getCorrespondingStringForGlyphsInRun(run, stringRange: NSMakeRange(stringRange.location, stringRange.length), string: attriString.string)
                    glyphCharacters += glyphCharactersInRun
                }
                
                glyphRectRet += glyphRects
                uikitRet += rectsForUIKit
            }
            retGlyphs += glyphs
        }
    }
    return (glyphCharacters, retGlyphs, glyphRectRet, uikitRet)
}

/// get glyphs and corresponding rects based on CoreText coordinate
public func getGlyphsAndRects(attributedString attriString: NSAttributedString, withboundingWidth width: CGFloat) -> (glyphs: [CGGlyph], rects: [CGRect], positions: [CGPoint]) {
    let frameInfo = createFrame(attributedString: attriString, withboundingWidth: width)
    let (lines, lineOrigins) = getLinesInfo(frameInfo.frame)
    print("-----------\(lineOrigins)")
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

/// create frame and get the frame size(suggest frame size)
public func createFrame(attributedString attriString: NSAttributedString, withboundingWidth width: CGFloat) -> (frame: CTFrame, size: CGSize) {
    let d = NSDate()
    let stringLength = attriString.length
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    let frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, stringLength), nil, CGSize(width: width, height: CGFloat.max), nil)
    let framePath = CGPathCreateWithRect(CGRect(origin: CGPointZero, size: frameSize), nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, stringLength), framePath, nil)
    print("time: \(NSDate().timeIntervalSinceDate(d))")
    return (frame, frameSize)
}

private func CFRangeEqual(r1: CFRange, _ r2: CFRange) -> Bool {
    if r1.location == r2.location && r1.length == r2.length {
        return true
    }
    return false
}

/// create frame and get the frame size(calculate size)
public func createFrameInfo(attributedString attriString: NSAttributedString, withboundingWidth width: CGFloat) -> (frame: CTFrame, size: CGSize, attachmentsInfo: [NSTextAttachment: CGRect], height: CGFloat) {
    let d = NSDate()
    let totalRange = CFRangeMake(0, attriString.length)
    var frameSize = CGSize(width: width, height: 0)
    var attachments = [NSTextAttachment: CGRect]()
    let framesetter = CTFramesetterCreateWithAttributedString(attriString)
    var height: CGFloat = 1_000
    var frame: CTFrame!
    var realRange = CFRangeMake(0, 0)
    var isFinished = false
    while !isFinished {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let path = CGPathCreateWithRect(rect, nil)
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
        realRange = CTFrameGetVisibleStringRange(frame)
        if CFRangeEqual(realRange, totalRange) {
           isFinished = true
        } else {
            height *= 2
        }
    }
    print("time: \(NSDate().timeIntervalSinceDate(d))")
//    print("height: \(height)")
    let (lines, lineOrigins) = getLinesInfo(frame)
    var newOrigins = lineOrigins
    let numberOfLines = lines.count
    for var i = numberOfLines - 1; i >= 0; i-- {
        let line = lines[i]
        let originY = height - lineOrigins[i].y
        let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions(rawValue: 0))
//        print("CTLineGetBoundsWithOptions: \(bounds)")
        if i == numberOfLines - 1 { //last
           frameSize.height = originY - bounds.origin.y
        }
        newOrigins[i].y = frameSize.height - originY
//        print("lineOrigin:\(i) - \(newOrigins[i])")
        let runs = (CTLineGetGlyphRuns(line) as NSArray) as! [CTRun]
        for run in runs {
            if let attributes = (CTRunGetAttributes(run) as NSDictionary) as? [String: AnyObject], attachment = attributes[NSAttachmentAttributeName] as? NSTextAttachment {
                var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
                let width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading))
                let bounds = CGRect(x: 0, y: -descent, width: width, height: ascent + descent)
                var position = CGPointZero
                CTRunGetPositions(run, CFRangeMake(0, 1), &position)
                let rect = CGRect(x: lineOrigins[i].x + position.x, y: lineOrigins[i].y + position.y + bounds.origin.y, width: bounds.width, height: bounds.height)
//                print("Attachment rect: \(rect)")
//                print("******************************************************")
                attachments[attachment] = rect
            }
        }
//        print("===============================================================================================")
    }
//    print(frameSize)
    return (frame, frameSize, attachments, height)
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