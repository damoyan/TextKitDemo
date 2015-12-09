//
//  CoreTextViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/18/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextViewLayoutController: ViewController {

    let shortString = "just test for the effect."
    let longString = "just test for the effect j. "
    let longString2 = "just test for the Zapfino effect. just test for the effect."
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var usedRectLabel: UILabel!
    
    var layers = [CALayer]()
    let imageSize = CGSizeMake(20, 20)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mutable = NSMutableAttributedString(string: longString, attributes: [NSFontAttributeName: textView.font!])
        let attachment = NSTextAttachment(data: nil, ofType: nil)
        attachment.image = UIImage(named: "test")
        attachment.bounds = CGRect(origin: CGPointZero, size: attachment.image!.size)
        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: -10), size: imageSize)
        let attachmentString = NSAttributedString(attachment: attachment)
        mutable.appendAttributedString(attachmentString)
        mutable.appendAttributedString(attachmentString)
        mutable.appendAttributedString(NSAttributedString(string: longString2, attributes: [NSFontAttributeName: textView.font!]))
        textView.attributedText = mutable
        textView.layer.borderColor = UIColor.blackColor().CGColor
        textView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = true
        slider.value = 40
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
    
    private func display() {
        removeOldLayers()
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let textStorage = textView.textStorage
        let textContainerInsets = textView.textContainerInset
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
        let gc = layoutManager.numberOfGlyphs
        for var i = 0; i < gc; {
            var r = NSMakeRange(i, 1)
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            let font = textStorage.attribute(NSFontAttributeName, atIndex: charRange.location, effectiveRange: nil) as! UIFont
            let ctfont = CTFontCreateWithName(font.fontName, font.pointSize, nil)
            
            // glyphRect is based on CoreText Coordinator
            var glyphRect = getGlyphRectsForGlyphs([layoutManager.CGGlyphAtIndex(r.location, isValidIndex: nil)], forFont: ctfont)[0]
            // location是glyph的origin相对于当前行origin的偏移
            let location = layoutManager.locationForGlyphAtIndex(r.location)

            // boundingRect的origin是相对于textContainer的, 而不是当前行的
            let boundingRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
            
            if CGSizeEqualToSize(glyphRect.size, CGSizeZero) && boundingRect.width > 9.0 {
                glyphRect.size = imageSize
            }
            // rebase origin to textContainer
            glyphRect.origin.x += boundingRect.origin.x
            
            // boundingRect.origin.y + location.y: glyph的origin相对于textContainer的origin的位置
            // boundingRect.origin.y + location.y - glyphRect.origin.y: glyph图形左下角相对于textContainer的origin的位置
            // boundingRect.origin.y + location.y - glyphRect.origin.y - glyphRect.height: glyph的右上角相对于textContainer的origin的位置
            glyphRect.origin.y = boundingRect.origin.y + location.y - glyphRect.origin.y - glyphRect.height
            // rebase origin to text view
            glyphRect.origin.x += textContainerInsets.left
            glyphRect.origin.y += textContainerInsets.top
            addBorderLayer(glyphRect)
            i += r.length
        }
    }
    
    private func addBorderLayer(frame: CGRect) {
        let layer = CALayer()
        layer.borderColor = UIColor.redColor().CGColor
        layer.borderWidth = 1 / UIScreen.mainScreen().scale
        layer.frame = frame
        layers.append(layer)
        textView.layer.addSublayer(layer)
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