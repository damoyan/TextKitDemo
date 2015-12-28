//
//  CustomLayoutManager.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/25/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

protocol AttachmentInfoDelegate: NSLayoutManagerDelegate {
    func layoutManagerShouldGenerateAttachmentInfo(layoutManager: NSLayoutManager) -> Bool
    func layoutManager(layoutManager: NSLayoutManager, shouldGenerateInfoForAttachment attachment: NSTextAttachment) -> Bool
    func layoutManager(layoutManager: NSLayoutManager, didGetFrame frame: CGRect, forAttachment attachment: NSTextAttachment)
}

extension AttachmentInfoDelegate {
    func layoutManagerShouldGenerateAttachmentInfo(layoutManager: NSLayoutManager) -> Bool {
        return false
    }
    
    func layoutManager(layoutManager: NSLayoutManager, shouldGenerateInfoForAttachment attachment: NSTextAttachment) -> Bool {
        return false
    }
    
    /// `frame` is in `textContainer` coordinator, if using in `textView`, you should translate to `textView` coordinator
    func layoutManager(layoutManager: NSLayoutManager, didGetFrame frame: CGRect, forAttachment attachment: NSTextAttachment) {
    }
}

class CustomLayoutManager: NSLayoutManager {
    
    override func drawBackgroundForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        super.drawBackgroundForGlyphRange(glyphsToShow, atPoint: origin)
        // 这个context是UITextView的, 但是layoutManager所有的位置信息都是相对于textContainer的, 并没有
        // 考虑textContainerInsets. 所以这里需要注意.
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let rect = boundingRectForGlyphRange(glyphsToShow, inTextContainer: textContainers[0])
        guard !CGSizeEqualToSize(rect.size, CGSizeZero) else { return }
        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let radius = rect.width > rect.height ? rect.height / 2 : rect.width / 2
        CGContextSaveGState(context)
        CGContextSetFillColorWithColor(context, UIColor.grayColor().CGColor)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        path.closePath()
        path.fill()
        CGContextRestoreGState(context)
    }
    
    override func drawGlyphsForGlyphRange(glyphsToShow: NSRange, atPoint origin: CGPoint) {
        super.drawGlyphsForGlyphRange(glyphsToShow, atPoint: origin)
        
//        enumerateLineFragmentsForGlyphRange(glyphsToShow) { (_, rect, _, _, _) -> Void in

//            guard !CGSizeEqualToSize(rect.size, CGSizeZero) else { return }
//            CGContextSaveGState(context)
//            CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
//            let origin = rect.origin
//            let path = UIBezierPath()
//            path.lineWidth = 2
//            let startP = CGPoint(x: origin.x, y: origin.y + rect.height - 2)
//            path.moveToPoint(startP)
//            let endP = CGPoint(x: startP.x + rect.width, y: startP.y)
//            path.addLineToPoint(endP)
//            path.stroke()
//            CGContextRestoreGState(context)
//        }
    }
    
    override func drawStrikethroughForGlyphRange(glyphRange: NSRange, strikethroughType strikethroughVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
        super.drawStrikethroughForGlyphRange(glyphRange, strikethroughType: strikethroughVal, baselineOffset: baselineOffset, lineFragmentRect: lineRect, lineFragmentGlyphRange: lineGlyphRange, containerOrigin: containerOrigin)
    }
    
    override func drawUnderlineForGlyphRange(glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
        super.drawUnderlineForGlyphRange(glyphRange, underlineType: underlineVal, baselineOffset: baselineOffset, lineFragmentRect: lineRect, lineFragmentGlyphRange: lineGlyphRange, containerOrigin: containerOrigin)
    }
}
