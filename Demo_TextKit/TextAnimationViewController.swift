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
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapButton(sender: AnyObject) {
    }
    
    private func setup() {
        textContainer.lineFragmentPadding = 0
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.delegate = self
    }

    private func setupString(string: String) {
        let attri = NSAttributedString(string: string, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)])
        textStorage.setAttributedString(attri)
    }
    
    private func display() {
        let range = layoutManager.glyphRangeForTextContainer(textContainer)
        let rect = layoutManager.usedRectForTextContainer(textContainer)
        println("textContainer rect: \(rect)")
        for var i = range.location; i < NSMaxRange(range); {
            var r = NSMakeRange(i, 1)
            let charRange = layoutManager.characterRangeForGlyphRange(r, actualGlyphRange: &r)
            let glyphRect = layoutManager.boundingRectForGlyphRange(r, inTextContainer: textContainer)
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
