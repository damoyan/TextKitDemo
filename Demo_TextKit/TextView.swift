//
//  TextView.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/18/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextView: UITextView {
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        self.resignFirstResponder()
        return false
    }

//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        selectedTextRange = nil
//        let locInView = CGPointMake(point.x - textContainerInset.left, point.y - textContainerInset.top)
//        let glyphIndex = layoutManager.glyphIndexForPoint(locInView, inTextContainer: textContainer)
//        let glyphRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: textContainer)
//        if CGRectContainsPoint(glyphRect, point) {
//            let charIndex = layoutManager.characterIndexForPoint(point, inTextContainer: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//            var range: NSRange = NSRange()
//            if let _ = textStorage.attribute(NSLinkAttributeName, atIndex: charIndex, effectiveRange: &range)
//            {
//                return true
//            }
//        }
//        return false
//    }

}
