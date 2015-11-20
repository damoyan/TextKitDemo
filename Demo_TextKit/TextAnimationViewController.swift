//
//  TextAnimationViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/10/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextAnimationViewController: ViewController {

    @IBOutlet weak var label: UILabel!
    
    let textStorage = NSTextStorage()
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer()
    var layers = [CALayer]()
//    var font = UIFont(name: "Zapfino", size: 16)!
    // UIFont(name: "TimesNewRomanPS-ItalicMT", size: 16)!
    var font = UIFont.systemFontOfSize(16)
    
    var showBorder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupString("just test for the effect")
        label.font = font
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textContainer.size = CGSize(width: label.bounds.size.width, height: CGFloat.max)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func toggleFont(sender: AnyObject) {
        if font.fontName == "Zapfino" {
            font = UIFont.systemFontOfSize(16)
        } else {
            font = UIFont(name: "Zapfino", size: 16)!
        }
        label.font = font
        setupString("just test for the effect")
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        animation()
    }
    
    @IBAction func toggleShowBorder(sender: UISwitch) {
        showBorder = sender.on
        display()
        animation()
    }
    
    private func animation() {
        for var i = 0; i < layers.count; i++ {
            let l = layers[i]
            let duration = (Double(arc4random() % 100) / 200.0) + 0.5
            let delay = Double(arc4random() % 100) / 100.0
            l.opacity = 0
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay)), dispatch_get_main_queue(), { () -> Void in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
                l.opacity = 1
                l.setNeedsDisplay()
                CATransaction.commit()
            })
        }
    }
    
    private func removeOldLayers() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll(keepCapacity: true)
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
    }

    private func setupString(string: String) {
        let attri = NSAttributedString(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)])
        textStorage.setAttributedString(attri)
    }
    
    private func display() {
        removeOldLayers()
        let gc = layoutManager.numberOfGlyphs
        let origin = CGPoint(x: 20, y: 200)
        for var i = 0; i < gc; {
            var r = NSMakeRange(i, 1)
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            let textForLayer = textStorage.attributedSubstringFromRange(charRange)
            let glyphRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
            createLayer(textForLayer, glyphRect: glyphRect, origin: origin)
            i += r.length
        }
    }
    
    private func createLayer(textForLayer: NSAttributedString, glyphRect: CGRect, origin: CGPoint) {
        var layerFrame: CGRect
        if layers.count == 0 {
            layerFrame = CGRectMake(origin.x + glyphRect.origin.x, origin.y + glyphRect.origin.y, glyphRect.width, glyphRect.height)
        } else {
            if !showBorder {
                layerFrame = CGRectMake(origin.x + glyphRect.origin.x - (glyphRect.width * 5), origin.y + glyphRect.origin.y, glyphRect.width * 11, glyphRect.height)
            } else {
                layerFrame = CGRectMake(origin.x + glyphRect.origin.x, origin.y + glyphRect.origin.y, glyphRect.width, glyphRect.height)
            }
        }
        let textLayer = CATextLayer()
        /// if set `string` with NSAttributedString, we still need to set the `font` and `fontSize` property
        /// or the characters displayed will be a little bolder than original font.
        /// note: when set NSAttributedString without font attribute to NSTextStorage, it will automatically add NSFontAttribute with default font.
        textLayer.string = textForLayer
        if let font = textForLayer.attribute(NSFontAttributeName, atIndex: 0, effectiveRange: nil) as? UIFont {
            textLayer.font = CTFontCreateWithName(font.fontName, font.pointSize, nil)
            textLayer.fontSize = font.pointSize
        }
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.foregroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor
        textLayer.frame = layerFrame
        textLayer.opacity = 0
        textLayer.wrapped = true
        if showBorder {
            textLayer.borderColor = UIColor.redColor().CGColor
            textLayer.borderWidth = 1 / UIScreen.mainScreen().scale
        }
        textLayer.contentsScale = UIScreen.mainScreen().scale
        view.layer.addSublayer(textLayer)
        layers.append(textLayer)
    }
}

extension TextAnimationViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        display()
    }
}
