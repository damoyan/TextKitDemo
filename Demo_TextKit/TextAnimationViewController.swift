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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        setupString("just test for the effect")
//        setupString(displayString)
        label.attributedText = textStorage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("label: \(label.bounds.size)")
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
            println(delay)
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
        let attri = NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)])
        textStorage.setAttributedString(attri)
    }
    
    private func display() {
        let range = layoutManager.glyphRangeForTextContainer(textContainer)
        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        let origin = CGPoint(x: 20, y: 200)
        println("textContainer rect: \(usedRect)")
        for var i = range.location; i < NSMaxRange(range); {
            var r = NSMakeRange(i, 1)
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            let glyphRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
            
            let textForLayer = textStorage.attributedSubstringFromRange(charRange)
            var layerFrame = CGRectMake(origin.x + glyphRect.origin.x - glyphRect.width, origin.y + glyphRect.origin.y, glyphRect.width * 3, glyphRect.height)
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.mainScreen().scale
            textLayer.string = textForLayer//.string
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.frame = layerFrame
            textLayer.opacity = 0
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
