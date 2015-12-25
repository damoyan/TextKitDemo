//
//  CustomDrawViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 12/25/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class CustomDrawViewController: UIViewController {

    let textStorage = NSTextStorage(string: "")
    let layoutManager = CustomLayoutManager()
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        textView.attributedText = NSAttributedString(string: displayString)
    }
    
    private func setup() {
        let textContainer = NSTextContainer()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        let f = CGRect(x: 20, y: 20, width: 300, height: 300)
        textView = UITextView(frame: f, textContainer: textContainer)
        textContainer.lineBreakMode = .ByTruncatingTail
        textView.scrollEnabled = false
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.layer.borderWidth = 1 / UIScreen.mainScreen().scale
        textView.textContainerInset = UIEdgeInsetsZero
        view.addSubview(textView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
