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
    var font = UIFont.systemFontOfSize(16)
    
    var showBorder = false
    var useLigature = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupString("just test for the effect Zapfino")
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
        setupString("just test for the effect Zapfino")
    }
    
    @IBAction func toggleLigature(sender: UIButton) {
        useLigature = !useLigature
        setupString("just test for the effect Zapfino", useLigature: useLigature)
        animation()
    }
    
    @IBAction func tapButton(sender: AnyObject) {
        animation()
    }
    
    @IBAction func toggleShowBorder(sender: UISwitch) {
        showBorder = sender.on
        display()
        animation()
    }
    
    var showLineBorder = false
    @IBAction func toggleLineBorder(sender: UISwitch) {
        showLineBorder = sender.on
        linelayers.forEach {
            if self.showLineBorder {
                $0.borderColor = UIColor.blueColor().CGColor
                $0.borderWidth = 1 / UIScreen.mainScreen().scale
            } else {
                $0.borderColor = UIColor.clearColor().CGColor
                $0.borderWidth = 0
            }
        }
    }
    
    private func animation() {
        for var i = 0; i < layers.count; i++ {
            let l = layers[i]
            let duration = (Double(arc4random() % 100) / 200.0) + 0.5
            let delay = Double(arc4random() % 100) / 100.0
            l.opacity = 0
            let finalFrame = l.frame
            l.frame = CGRect(origin: CGPoint(x: CGFloat(arc4random() % 375), y: CGFloat(arc4random() % 550)), size: finalFrame.size)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * delay)), dispatch_get_main_queue(), { () -> Void in
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                CATransaction.setAnimationDuration(duration)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
                l.opacity = 1
                l.frame = finalFrame
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
        linelayers.forEach { $0.removeFromSuperlayer() }
        linelayers.removeAll(keepCapacity: true)
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
    }

    private func setupString(string: String, useLigature: Bool = true) {
        let attri = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)])
        if !useLigature {
            attri.addAttribute(NSLigatureAttributeName, value: 0, range: NSMakeRange(0, attri.length))
        }
        textStorage.setAttributedString(attri)
    }
    
    private func display() {
        removeOldLayers()
        guard let textStorage = layoutManager.textStorage else { return }
        layoutManager.ensureLayoutForTextContainer(layoutManager.textContainers[0])
        let gc = layoutManager.numberOfGlyphs
        let origin = CGPoint(x: 20, y: 200)
        for var i = 0; i < gc; {
            var r = NSMakeRange(i, 1)
            // 为了拿到实际的glyphRange, 调用之后, r的length就会根据实际情况变化, 不一定是1
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            if let _ = textStorage.attribute(NSAttachmentAttributeName, atIndex: charRange.location, effectiveRange: nil) as? NSTextAttachment {
                // TODO: handle attachment
            } else {
                // textStorage在使用钱会fixAttributed, 所以font信息一定会有
                let font = textStorage.attribute(NSFontAttributeName, atIndex: charRange.location, effectiveRange: nil) as! UIFont
                let ctfont = CTFontCreateWithName(font.fontName, font.pointSize, nil)
                
                // 得到r对应的glyph
                let glyph = layoutManager.CGGlyphAtIndex(r.location, isValidIndex: nil)
                
                // 调用CoreText的方法来获得对应的glyph的绘制矩形. 这个矩形是上下文无关的
                // glyphRect的坐标系是CoreText的坐标系
                var glyphRect = getGlyphRectsForGlyphs([glyph], forFont: ctfont)[0]
                
                let location = layoutManager.locationForGlyphAtIndex(r.location)
                
                // boundingRect返回的是glyph在textContainer的location(boundingRect.origin),
                // glyph的advance (boundingRect.width)和当前行的行高(boundingRect.height)
                let boundingRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
                
                // 把glyphRect转换到UIKit的坐标系
                glyphRect.origin.x += boundingRect.origin.x
                glyphRect.origin.y = boundingRect.origin.y + location.y - glyphRect.origin.y - glyphRect.height
                glyphRect.origin.x += origin.x
                glyphRect.origin.y += origin.y
                
                createLayer(glyph, frame: glyphRect, font: font)
                var rect = boundingRect
                rect.origin.x += origin.x
                rect.origin.y += origin.y + 100
                let text = (textStorage.string as NSString).substringWithRange(charRange)
                createTextLayer(text, frame: rect, font: font)
            }
            i += r.length
        }
        layoutManager.enumerateLineFragmentsForGlyphRange(NSMakeRange(0, gc)) { (line, usedRect, tc, range, _) -> Void in
            var l1 = line
            l1.origin.x += origin.x
            l1.origin.y += origin.y
            self.createLineLayer(l1)
            l1.origin.y += 100
            self.createLineLayer(l1)
        }
    }
    
    private func createLayer(glyph: CGGlyph, frame: CGRect, font: UIFont) {
        let textLayer = SingleGlyphLayer(glyph: glyph, font: font)
        textLayer.frame = frame
        textLayer.opacity = 0
        if showBorder {
            textLayer.borderColor = UIColor.redColor().CGColor
            textLayer.borderWidth = 1 / UIScreen.mainScreen().scale
        }
        textLayer.contentsScale = UIScreen.mainScreen().scale
        view.layer.addSublayer(textLayer)
        layers.append(textLayer)
    }
    
    private func createTextLayer(text: String, frame: CGRect, font: UIFont) {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.font = CGFontCreateWithFontName(font.fontName)
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = UIColor.blackColor().CGColor
        textLayer.opacity = 0
        textLayer.opaque = false
        textLayer.masksToBounds = false
        if showBorder {
            textLayer.borderColor = UIColor.redColor().CGColor
            textLayer.borderWidth = 1 / UIScreen.mainScreen().scale
        }
        textLayer.contentsScale = UIScreen.mainScreen().scale
        view.layer.addSublayer(textLayer)
        textLayer.setNeedsDisplay()
        layers.append(textLayer)
    }
    
    var linelayers = [CALayer]()
    private func createLineLayer(frame: CGRect) {
        let layer = CALayer()
        layer.frame = frame
        if showLineBorder {
            layer.borderColor = UIColor.blueColor().CGColor
            layer.borderWidth = 1 / UIScreen.mainScreen().scale
        }
        view.layer.addSublayer(layer)
        linelayers.append(layer)
    }
}

extension TextAnimationViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        display()
    }
}
