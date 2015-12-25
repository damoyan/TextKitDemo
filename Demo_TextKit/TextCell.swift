//
//  TextCell.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/17/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var textView: TextView!
    @IBOutlet weak var grLabel: UILabel!
    @IBOutlet weak var seLabel: UILabel!
    
    var gestureRecognizer: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.delegate = self
        gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture:")
        textView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delaysTouchesBegan = true
    }
    
    override func prepareForReuse() {
        textView.selectable = false
    }

    func update(attriString: NSAttributedString, gs: Bool, se: Bool) {
        textView.attributedText = attriString
        gestureRecognizer.enabled = gs
        textView.selectable = se
        grLabel.text = "gesture: \(gs)"
        seLabel.text = "textView selectable: \(se)"
    }
    
    @objc private func handleGesture(gestureRecognizer: UITapGestureRecognizer) {
        let view = gestureRecognizer.view as! UITextView
        let location = gestureRecognizer.locationInView(view)
        let locInView = CGPointMake(location.x - view.textContainerInset.left, location.y - view.textContainerInset.top)
        let glyphIndex = view.layoutManager.glyphIndexForPoint(locInView, inTextContainer: view.textContainer)
        let glyphRect = view.layoutManager.boundingRectForGlyphRange(NSMakeRange(glyphIndex, 1), inTextContainer: view.textContainer)
        if glyphRect.contains(locInView) {
            let charIndex = view.layoutManager.characterIndexForPoint(locInView, inTextContainer: view.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if let s = textView.attributedText.attribute(NSLinkAttributeName, atIndex: charIndex, longestEffectiveRange: nil, inRange: NSMakeRange(0, textView.attributedText.length)) {
                if let url = s as? NSURL {
                    navigateToVC(url.absoluteString)
                } else if let string = s as? String {
                    navigateToVC(string)
                }
                return
            }
        }
    }
    
    @IBAction func toggleGesture(sender: UIButton) {
        gestureRecognizer.enabled = !gestureRecognizer.enabled
        if gestureRecognizer.enabled {
            sender.setTitle("disableGesture", forState: .Normal)
        } else {
            sender.setTitle("enableGesture", forState: .Normal)
        }
    }
    
    @IBAction func toggleSelectable(sender: UIButton) {
        textView.selectable = !textView.selectable
        if textView.selectable {
            sender.setTitle("disableSelectable", forState: .Normal)
        } else {
            sender.setTitle("enableSelectable", forState: .Normal)
        }
    }
    
    private func navigateToVC(string: String) {
        let vc = TextViewController.init(nibName: nil, bundle: nil)
        vc.text = string
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    var viewController: UIViewController? {
        var responder: UIResponder? = self.nextResponder()
        while responder != nil {
            if responder! is UIViewController {
                return responder as? UIViewController
            }
            responder = responder!.nextResponder()
        }
        return nil
    }
}

extension TextCell: UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        navigateToVC(URL.absoluteString)
        return false
    }
}
