//
//  TextCell.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/17/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.textContainer.lineFragmentPadding = 0
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleGesture:")
        textView.addGestureRecognizer(gestureRecognizer)
    }
    
    func update(attriString: NSAttributedString) {
        textView.attributedText = attriString
    }
    
    @objc private func handleGesture(gestureRecognizer: UITapGestureRecognizer) {
        
    }
}
