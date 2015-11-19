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
    let longString = "just test for the effect. just test for the effect. just test for the effect."
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layoutManager.delegate = self
        textView.text = longString
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = true
        sliderValueChanged(slider)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let textContainerInsets = textView.textContainerInset
        let lineFragmentPadding = textContainer.lineFragmentPadding
        let usedRect = layoutManager.usedRectForTextContainer(textContainer)
        print(usedRect)
        getGlyphRectsForAttributedString(textView.textStorage, boundingWidth: textContainer.size.width - lineFragmentPadding - lineFragmentPadding)
//        print("glyph range: \(layoutManager.numberOfGlyphs)")
    }
}

extension CoreTextViewController: NSLayoutManagerDelegate {
//    func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
//        display()
//    }
}