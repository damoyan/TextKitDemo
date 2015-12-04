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
//        let font = UIFont(name: "Zapfino", size: 16)!
        let font = UIFont.systemFontOfSize(16)
//        NSProprietaryStringEncoding
        
        let longString = try! NSString(contentsOfFile: NSBundle.mainBundle().pathForResource("YYTextView", ofType: "txt")!, encoding: NSUTF8StringEncoding)
        let longString2 = "jjust test for the effect.\njust test for the effect."
        let mutable = NSMutableAttributedString(string: longString as String, attributes: [NSFontAttributeName: font])
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = UIImage(named: "test")
        attachment.bounds = CGRect(origin: CGPointZero, size: attachment.image!.size)
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttach = NSMutableAttributedString(attributedString: attachmentString)
        mutable.appendAttributedString(generateRunDelegate(mutableAttach, attachment.image!, font, NSMakeRange(0, 1)))
        mutable.appendAttributedString(NSAttributedString(string: longString2, attributes: [NSFontAttributeName: font]))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.paragraphSpacing = 20
        style.paragraphSpacingBefore = 30
        mutable.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, mutable.length))
        mutable.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSMakeRange(0, mutable.length))
        
        
        let scrollView = UIScrollView(frame: CGRect(x: 20, y: 100, width: 320, height: 450))
        let (frame, size, attachments, height) = createFrameInfo(attributedString: mutable, withboundingWidth: scrollView.bounds.width)
//        let (frame, size) = createFrame(attributedString: mutable, withboundingWidth: scrollView.bounds.width)
        let f = CGRect(x: 0, y: 0, width: scrollView.bounds.width, height: height)
        let v = CoreTextView(frame: f)
        v.ctframe = frame
        v.attachments = attachments
        v.ctheight = height
        v.backgroundColor = UIColor.clearColor()
        scrollView.backgroundColor = UIColor.grayColor()
        scrollView.contentSize = size
        scrollView.addSubview(v)
        view.addSubview(scrollView)
        v.setNeedsDisplay()
    }
}

class CoreTextView: UIView {
    
    var ctframe: CTFrame?
    var attachments: [NSTextAttachment: CGRect]?
    var ctheight: CGFloat!
    
    override func drawRect(rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext(), frame = ctframe {
            
//           let (frame, size)  = createFrame(attributedString: attriString, withboundingWidth: bounds.width)
//            CGContextTranslateCTM(context, 0, size.height)
//            getGlyphsAndRects(attributedString: attriString, withboundingWidth: bounds.width)
            let height = bounds.height
            CGContextTranslateCTM(context, 0, height)
            CGContextScaleCTM(context, 1, -1)
            
            CGContextSetTextMatrix(context, CGAffineTransformIdentity)
            CTFrameDraw(frame, context)
            
            if let attachments = attachments {
                for (attachment, rect) in attachments {
                    let frame = CGRect(x: rect.origin.x, y: height - rect.origin.y - rect.height, width: rect.width, height: rect.height)
                    let view = UIImageView(frame: frame)
                    view.image = attachment.image
    //                let view = UIView(frame: frame)
    //                view.backgroundColor = UIColor.greenColor()
                    addSubview(view)
                }
            }
        }
    }
}