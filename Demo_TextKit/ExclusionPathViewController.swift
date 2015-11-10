//
//  ExclusionPathViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/10/15.
//  Copyright (c) 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class ExclusionPathViewController: ViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var maskView: UIView!
    
    private var maskViewExclusionIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = true
        textView.text = displayString
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateExclusionPath(textView.textContainer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateExclusionPath(textContainer: NSTextContainer) {
        let size = textContainer.size
        var radius = size.width > size.height ? size.height / 2.0 : size.width / 2.0
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        let topHalf = UIBezierPath()
        topHalf.moveToPoint(CGPoint(x: 0, y: 0))
        topHalf.addLineToPoint(CGPoint(x: 0, y: center.y))
        if center.x > center.y {
            topHalf.addLineToPoint(CGPoint(x: center.x - radius, y: center.y))
        }
        topHalf.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI), endAngle: CGFloat(0), clockwise: true)
        if center.x > center.y {
            topHalf.addLineToPoint(CGPoint(x: size.width, y: center.y))
        }
        topHalf.addLineToPoint(CGPoint(x: size.width, y: 0))
        topHalf.closePath()
        
        let bottomHalf = UIBezierPath()
        bottomHalf.moveToPoint(CGPoint(x: 0, y: size.height))
        bottomHalf.addLineToPoint(CGPoint(x: 0, y: center.y))
        if center.x > center.y {
            bottomHalf.addLineToPoint(CGPoint(x: center.x - radius, y: center.y))
        }
        bottomHalf.addArcWithCenter(center, radius: radius, startAngle: CGFloat(M_PI), endAngle: CGFloat(0), clockwise: false)
        if center.x > center.y {
            bottomHalf.addLineToPoint(CGPoint(x: size.width, y: center.y))
        }
        bottomHalf.addLineToPoint(CGPoint(x: size.width, y: size.height))
        bottomHalf.closePath()
        
        textContainer.exclusionPaths = [topHalf, bottomHalf]
    }
    
    private func addMaskViewExclusionPath() {
        var rect = textView.convertRect(maskView.frame, fromView: view)
        rect.origin.x -= textView.textContainerInset.left
        rect.origin.y -= textView.textContainerInset.top
        let exPath = UIBezierPath(rect: rect)
        if let ex = textView.textContainer.exclusionPaths {
            if let i = maskViewExclusionIndex {
                textView.textContainer.exclusionPaths![i] = exPath
            } else {
                textView.textContainer.exclusionPaths!.append(exPath)
                maskViewExclusionIndex = textView.textContainer.exclusionPaths!.count - 1
            }
        } else {
            textView.textContainer.exclusionPaths = [exPath]
            maskViewExclusionIndex = 0
        }
    }
    
    @IBAction func handleGesture(sender: UIPanGestureRecognizer) {
        let point = sender.locationInView(view)
        maskView.center = point
        addMaskViewExclusionPath()
    }
}
