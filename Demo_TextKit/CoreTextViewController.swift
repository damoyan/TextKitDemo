//
//  CoreTextViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/18/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class CoreTextViewController: ViewController {

    let string = "just test for the effect."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        display()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func display() {
        let f = UIFont.systemFontOfSize(16)
        let font = CTFontCreateWithName(f.fontName, 16, nil)
        var chars: UnsafeMutablePointer<UniChar> = nil
        CFStringGetCharacters(string, CFRangeMake(0, NSString(string: string).length), chars)
        print(chars)
    }
}
