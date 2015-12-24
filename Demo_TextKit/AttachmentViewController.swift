//
//  AttachmentViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/7/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class AttachmentViewController: UIViewController {

    let attachment = NSTextAttachment()
    let attachment2 = NSTextAttachment()
    let image = UIImage(named: "1")
    var textView: UITextView!
    let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        attachment.image = UIImage(named: "test")
        attachment2.image = image
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutable = NSMutableAttributedString(string: "just test", attributes: [NSFontAttributeName: textView.font!])
        mutable.appendAttributedString(attachmentString)
        mutable.appendAttributedString(NSAttributedString(string: "the effect, add more character to generate a new line", attributes: [NSFontAttributeName: textView.font!]))
        mutable.appendAttributedString(NSAttributedString(attachment: attachment2))
        let para = NSMutableParagraphStyle()
        para.lineSpacing = 0
        mutable.addAttribute(NSParagraphStyleAttributeName, value: para, range: NSMakeRange(0, mutable.length))
        textView.attributedText = mutable
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setup() {
        var x: CGFloat = 20
        let btn = UIButton(type: UIButtonType.System)
        btn.setTitle("Bottom", forState: .Normal)
        btn.tag = 0
        btn.sizeToFit()
        btn.frame = CGRect(origin: CGPoint(x: x, y: 20), size: btn.bounds.size)
        btn.addTarget(self, action: "changeAlignment:", forControlEvents: .TouchUpInside)
        view.addSubview(btn)
        x += btn.bounds.width + 20
        
        let btn2 = UIButton(type: UIButtonType.System)
        btn2.setTitle("Center", forState: .Normal)
        btn2.tag = 1
        btn2.sizeToFit()
        btn2.frame = CGRect(origin: CGPoint(x: x, y: 20), size: btn2.bounds.size)
        btn2.addTarget(self, action: "changeAlignment:", forControlEvents: .TouchUpInside)
        view.addSubview(btn2)
        x += btn2.bounds.width + 20
        
        let btn3 = UIButton(type: UIButtonType.System)
        btn3.setTitle("Top", forState: .Normal)
        btn3.tag = 2
        btn3.sizeToFit()
        btn3.frame = CGRect(origin: CGPoint(x: x, y: 20), size: btn3.bounds.size)
        btn3.addTarget(self, action: "changeAlignment:", forControlEvents: .TouchUpInside)
        view.addSubview(btn3)
        
        x += btn3.bounds.width + 20
        
        let btn4 = UIButton(type: UIButtonType.System)
        btn4.setTitle("Baseline", forState: .Normal)
        btn4.tag = 3
        btn4.sizeToFit()
        btn4.frame = CGRect(origin: CGPoint(x: x, y: 20), size: btn4.bounds.size)
        btn4.addTarget(self, action: "changeAlignment:", forControlEvents: .TouchUpInside)
        view.addSubview(btn4)
        
        let textView = UITextView(frame: CGRect(x: 20, y: 100, width: 335, height: 300))
        textView.scrollEnabled = false
        textView.editable = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.redColor().CGColor
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        view.addSubview(textView)
        self.textView = textView
        textView.layoutManager.delegate = self
        imageView.frame = CGRectZero
        imageView.animationDuration = 0.5
        imageView.animationImages = [UIImage(named: "1")!, UIImage(named: "2")!]
        imageView.startAnimating()
        textView.addSubview(imageView)
    }
    
    @objc private func changeAlignment(sender: UIButton) {
        let tag = sender.tag
        adjustAttachment(attachment, tag: tag)
        adjustAttachment(attachment2, tag: tag)
        textView.layoutManager.invalidateLayoutForCharacterRange(NSMakeRange(10, 1), actualCharacterRange: nil)
    }
    
    private func adjustAttachment(attachment: NSTextAttachment, tag: Int) {
        let font = textView.font!
        let size = attachment.image!.size
        let fontLineHeight = font.ascender - font.descender
        if tag == 0 {
            attachment.bounds = CGRect(x: 0, y: font.descender, width: size.width, height: size.height)
        } else if tag == 1 {
            attachment.bounds = CGRect(x: 0, y: ((fontLineHeight - size.height) / 2.0) + font.descender, width: size.width, height: size.height)
        } else if tag == 2 {
            attachment.bounds = CGRect(x: 0, y: font.ascender - size.height, width: size.width, height: size.height)
        } else if tag == 3 {
            attachment.bounds = CGRect(origin: CGPointZero, size: size)
        }
    }
}

extension AttachmentViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        let str = textView.attributedText
        let glyphIndex = layoutManager.glyphIndexForCharacterAtIndex(str.length - 1)
        let locationInLine = layoutManager.locationForGlyphAtIndex(glyphIndex)
        print(locationInLine)
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: textContainer!)
        print(boundingRect)
        let size = attachment2.image!.size
        var ret = CGRectZero
        ret.origin.x = textView.textContainerInset.left + boundingRect.origin.x
        ret.origin.y = textView.textContainerInset.top + boundingRect.origin.y + locationInLine.y - size.height
        ret.size = size
        imageView.frame = ret
    }
}
