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
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        attachment.image = UIImage(named: "test")
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutable = NSMutableAttributedString(string: "just test", attributes: [NSFontAttributeName: textView.font!])
        mutable.appendAttributedString(attachmentString)
        mutable.appendAttributedString(NSAttributedString(string: "the effect, add more character to generate a new line", attributes: [NSFontAttributeName: textView.font!]))
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
    }
    
    @objc private func changeAlignment(sender: UIButton) {
        let tag = sender.tag
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
        textView.layoutManager.invalidateLayoutForCharacterRange(NSMakeRange(10, 1), actualCharacterRange: nil)
    }
}
