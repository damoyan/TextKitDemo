//
//  CoreTextViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/18/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class CoreTextViewController: ViewController {

    let shortString = "just test for the effect."
    let longString = "just test for the effect j. "
    let longString2 = "just test for the effect. just test for the effect."
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var usedRectLabel: UILabel!
    
    var layers = [CALayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        textView.text = longString
        let mutable = NSMutableAttributedString(string: longString, attributes: [NSFontAttributeName: textView.font!])
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = UIImage(named: "test")
        attachment.bounds = CGRect(origin: CGPointZero, size: attachment.image!.size)
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttach = NSMutableAttributedString(attributedString: attachmentString)
        mutable.appendAttributedString(generateRunDelegate(mutableAttach, attachment.image!, textView.font!, NSMakeRange(0, 1)))
        mutable.appendAttributedString(NSAttributedString(string: longString2, attributes: [NSFontAttributeName: textView.font!]))
        textView.attributedText = mutable
        textView.layer.borderColor = UIColor.blackColor().CGColor
        textView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sliderValueChanged(slider)
        display()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let v = Int(sender.value)
        currentLabel.text = "lineFragmentPadding: \(v)"
        textView.textContainer.lineFragmentPadding = CGFloat(v)
        textView.sizeToFit()
        height.constant = textView.frame.size.height
    }
    
//    class RunDelegate: NSObject, NSCoding, NSCopying {
//        var ascent: CGFloat?
//        var descent: CGFloat?
//        var width: CGFloat?
//        
//        override init() {
//            super.init()
//        }
//        
//        required init?(coder aDecoder: NSCoder) {
//            ascent = aDecoder.decodeObjectForKey("ascent") as? CGFloat
//            descent = aDecoder.decodeObjectForKey("descent") as? CGFloat
//            width = aDecoder.decodeObjectForKey("width") as? CGFloat
//        }
//        
//        func encodeWithCoder(aCoder: NSCoder) {
//            aCoder.encodeObject(ascent, forKey: "ascent")
//            aCoder.encodeObject(descent, forKey: "descent")
//            aCoder.encodeObject(width, forKey: "width")
//        }
//        
//        func copyWithZone(zone: NSZone) -> AnyObject {
//            let one = RunDelegate()
//            one.ascent = self.ascent
//            one.descent = self.descent
//            one.width = self.width
//            return one
//        }
//    }
    
//    private func generateRunDelegate(image: UIImage, font: UIFont) -> CTRunDelegateRef {
//        var d = RunDelegate(image: image, andFont: font)
//        d.ascent = image.size.height + font.descender
//        d.descent = -font.descender
//        d.width = image.size.width
//        var cbs = CTRunDelegateCallbacks(version: kCTRunDelegateCurrentVersion, dealloc: { (p) -> Void in
//            
//            }, getAscent: { (p) -> CGFloat in
//                let d = UnsafeMutablePointer<RunDelegate>(p).memory
//                return d.ascent
//            }, getDescent: { (p) -> CGFloat in
//                let d = UnsafeMutablePointer<RunDelegate>(p).memory
//                return d.descent
//            }) { (p) -> CGFloat in
//                let d = UnsafeMutablePointer<RunDelegate>(p).memory
//                return d.width
//        }
//        return CTRunDelegateCreate(&cbs, &d)!
//    }
    
    private func display() {
        removeOldLayers()
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let textContainerInsets = textView.textContainerInset
        let lineFragmentPadding = textContainer.lineFragmentPadding
        addLayersForContainer(textContainer)
        
        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        let boundingRect = layoutManager.boundingRectForGlyphRange(NSMakeRange(0, layoutManager.numberOfGlyphs), inTextContainer: textContainer)
        usedRectLabel.text = "used rect: \(usedRect) \nboundingRect: \(boundingRect)"
        usedRectLabel.numberOfLines = 0
        
        // add bounding rect with gray color
        let cl = CALayer()
        cl.frame = CGRect(x: textContainerInsets.left + boundingRect.origin.x, y: textContainerInsets.top + boundingRect.origin.y, width: boundingRect.size.width, height: boundingRect.size.height)
        cl.borderColor = UIColor.grayColor().CGColor
        cl.borderWidth = 1 / UIScreen.mainScreen().scale
        layers.append(cl)
        textView.layer.addSublayer(cl)
        
        // add layer for each glyph
        let rects = getGlyphRectsForAttributedString(textView.textStorage, boundingWidth: textContainer.size.width - lineFragmentPadding - lineFragmentPadding).glyphUIKitRects
        for r in rects {
            let layer = CALayer()
            layer.borderColor = UIColor.redColor().CGColor
            layer.borderWidth = 1 / UIScreen.mainScreen().scale
            var rect = r
            rect.origin.x += textContainerInsets.left + lineFragmentPadding
            rect.origin.y += textContainerInsets.top
            layer.frame = rect
            layers.append(layer)
            textView.layer.addSublayer(layer)
        }
    }
    
    private func addLayersForContainer(textContainer: NSTextContainer) {
        let textContainerInsets = textView.textContainerInset
        let lineFragmentPadding = textContainer.lineFragmentPadding
        let cl = CALayer()
        cl.frame = CGRect(x: textContainerInsets.left, y: textContainerInsets.top, width: textContainer.size.width, height: textContainer.size.height)
        cl.borderColor = UIColor.greenColor().CGColor
        cl.borderWidth = 1 / UIScreen.mainScreen().scale
        layers.append(cl)
        textView.layer.addSublayer(cl)
        let containerLayer = CALayer()
        containerLayer.frame = CGRect(x: textContainerInsets.left + lineFragmentPadding, y: textContainerInsets.top, width: textContainer.size.width - (lineFragmentPadding * 2), height: textContainer.size.height)
        containerLayer.borderColor = UIColor.blueColor().CGColor
        containerLayer.borderWidth = 1 / UIScreen.mainScreen().scale
        layers.append(containerLayer)
        textView.layer.addSublayer(containerLayer)
    }
    
    private func removeOldLayers() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
    }
}