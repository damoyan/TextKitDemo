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
    var leftTextView: UITextView!
    var rightTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = UIRectEdge.None
        textStorage.appendAttributedString(NSAttributedString(string: displayString))
    }

    private func setupTextView() {
        textStorage.addLayoutManager(layoutManager)
        let leftTextContainer = NSTextContainer()
        leftTextContainer.widthTracksTextView = true
        leftTextContainer.heightTracksTextView = true
        let rightTextContainer = NSTextContainer()
        rightTextContainer.widthTracksTextView = true
        rightTextContainer.heightTracksTextView = true
        layoutManager.addTextContainer(leftTextContainer)
        layoutManager.addTextContainer(rightTextContainer)
        leftTextView = UITextView(frame: CGRectZero, textContainer: leftTextContainer)
        rightTextView = UITextView(frame: CGRectZero, textContainer: rightTextContainer)
        leftTextView.textAlignment = NSTextAlignment.Justified
        rightTextView.textAlignment = NSTextAlignment.Justified
        leftTextView.scrollEnabled = false
        rightTextView.scrollEnabled = false
        leftTextView.textContainerInset = UIEdgeInsetsZero
        rightTextView.textContainerInset = UIEdgeInsetsZero
        
        view.addSubview(leftTextView)
        view.addSubview(rightTextView)
        setupConstraint()
    }
    
    private func setupConstraint() {
        leftTextView.translatesAutoresizingMaskIntoConstraints = false
        rightTextView.translatesAutoresizingMaskIntoConstraints = false
        let leading = NSLayoutConstraint(item: leftTextView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        let horizontal = NSLayoutConstraint(item: leftTextView, attribute: .Trailing, relatedBy: .Equal, toItem: rightTextView, attribute: .Leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: rightTextView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: leftTextView, attribute: .Width, relatedBy: .Equal, toItem: rightTextView, attribute: .Width, multiplier: 1, constant: 0)
        let leftTop = NSLayoutConstraint(item: leftTextView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let rightTop = NSLayoutConstraint(item: rightTextView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let leftBottom = NSLayoutConstraint(item: leftTextView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        let rightBottom = NSLayoutConstraint(item: rightTextView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        view.addConstraints([leading, horizontal, trailing, width, leftTop, leftBottom, rightBottom, rightTop])
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

}
