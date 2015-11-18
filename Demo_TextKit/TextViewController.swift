//
//  TextViewController.swift
//  Demo_TextKit
//
//  Created by Yu Pengyang on 11/18/15.
//  Copyright © 2015 Yu Pengyang. All rights reserved.
//

import UIKit

class TextViewController: ViewController {

    var label: UILabel!
    var text: String!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Link"
        view.backgroundColor = UIColor.whiteColor()
        label = UILabel()
        label.text = text
        view.addSubview(label)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        label.center = view.center
    }
}
