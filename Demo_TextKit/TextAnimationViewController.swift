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
    var layers = [CATextLayer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        setupString("just test for the effect, just test for the effect, just test for the effect, just test for the effect")
//        setupString(displayString)
//        label.attributedText = textStorage
        print(label.font)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textContainer.size = CGSize(width: label.bounds.size.width, height: CGFloat.max)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapButton(sender: AnyObject) {
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
                CATransaction.commit()
            })
        }
        
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
    }

    private func setupString(string: String) {
        //NSFontAttributeName: UIFont(name: "Papyrus", size: 16)!,
        // TimesNewRomanPS-ItalicMT
        let attri = NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont(name: "TimesNewRomanPS-ItalicMT", size: 16)!, NSForegroundColorAttributeName: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)])
        textStorage.setAttributedString(attri)
    }
    
    private func display() {
        layers.removeAll(keepCapacity: false)
        let range = layoutManager.glyphRangeForTextContainer(textContainer)
        let origin = CGPoint(x: 20, y: 200)
        for var i = range.location; i < NSMaxRange(range); {
            var r = NSMakeRange(i, 1)
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            let glyphRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
            
            let textForLayer = textStorage.attributedSubstringFromRange(charRange)
            var layerFrame: CGRect
            if layers.count == 0 {
                layerFrame = CGRectMake(origin.x + glyphRect.origin.x, origin.y + glyphRect.origin.y, glyphRect.width, glyphRect.height)
            } else {
                layerFrame = CGRectMake(origin.x + glyphRect.origin.x - glyphRect.width, origin.y + glyphRect.origin.y, glyphRect.width * 3, glyphRect.height)
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
            textLayer.contentsScale = UIScreen.mainScreen().scale
            view.layer.addSublayer(textLayer)
            layers.append(textLayer)
            i += r.length
        }
    }
}

extension TextAnimationViewController: NSLayoutManagerDelegate {
    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        display()
    }
    
//    func layoutManager(layoutManager: NSLayoutManager, textContainer: NSTextContainer, didChangeGeometryFromSize oldSize: CGSize) {
//        display()
//    }
}
