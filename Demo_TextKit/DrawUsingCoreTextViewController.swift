//
//  DrawUsingCoreTextViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/3/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class DrawUsingCoreTextViewController: ViewController {

    override func viewDidLoad() {
        let font = UIFont(name: "Zapfino", size: 16)!
        let longString = "just test for the effect j. "
        let longString2 = "just test for the effect. just test for the effect."
        let mutable = NSMutableAttributedString(string: longString, attributes: [NSFontAttributeName: font])
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = UIImage(named: "test")
        attachment.bounds = CGRect(origin: CGPointZero, size: attachment.image!.size)
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttach = NSMutableAttributedString(attributedString: attachmentString)
        mutable.appendAttributedString(generateRunDelegate(mutableAttach, attachment.image!, font, NSMakeRange(0, 1)))
        mutable.appendAttributedString(NSAttributedString(string: longString2, attributes: [NSFontAttributeName: font]))
        let v = CoreTextView(frame: CGRect(x: 20, y: 100, width: 320, height: 450))
        v.attributedString = mutable
        v.backgroundColor = UIColor.grayColor()
        view.addSubview(v)
    }
}

class CoreTextView: UIView {
    
    var attributedString: NSAttributedString?
    
    override func drawRect(rect: CGRect) {
        if let attriString = attributedString, context = UIGraphicsGetCurrentContext() {
            
            let (frame, size) = createFrame(attributedString: attriString, withboundingWidth: bounds.width)
            
            CGContextTranslateCTM(context, 0, size.height)
            CGContextScaleCTM(context, 1, -1)
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity)
            
            CTFrameDraw(frame, context)
        }
    }
}