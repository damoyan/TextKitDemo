//
//  TwoColumnViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/10/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TwoColumnViewController: ViewController {
    
    let textStorage = NSTextStorage(string: "")
    let layoutManager = NSLayoutManager()
    var leftTextView: UITextView?
    var rightTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = UIRectEdge.None
        setupTextView()
        textStorage.appendAttributedString(NSAttributedString(string: displayString))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = view.bounds.size
        leftTextView!.frame = CGRect(x: 0, y: 0, width: size.width / 2.0, height: size.height)
        leftTextView!.textContainer.size = leftTextView!.bounds.size
        rightTextView!.frame = CGRect(x: CGRectGetMaxX(leftTextView!.frame), y: 0, width: size.width / 2.0, height: size.height)
        rightTextView!.textContainer.size = rightTextView!.bounds.size
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupTextView() {
        textStorage.addLayoutManager(layoutManager)
        let leftTextContainer = NSTextContainer()
        let rightTextContainer = NSTextContainer()
        layoutManager.addTextContainer(leftTextContainer)
        layoutManager.addTextContainer(rightTextContainer)
        leftTextView = UITextView(frame: CGRectZero, textContainer: leftTextContainer)
        rightTextView = UITextView(frame: CGRectZero, textContainer: rightTextContainer)
        leftTextView!.textAlignment = NSTextAlignment.Justified
        rightTextView!.textAlignment = NSTextAlignment.Justified
        leftTextView!.scrollEnabled = false
        rightTextView!.scrollEnabled = false
        leftTextView!.textContainerInset = UIEdgeInsetsZero
        rightTextView!.textContainerInset = UIEdgeInsetsZero
        
        view.addSubview(leftTextView!)
        view.addSubview(rightTextView!)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

}
