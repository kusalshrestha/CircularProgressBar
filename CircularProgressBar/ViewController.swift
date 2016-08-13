//
//  ViewController.swift
//  CircularProgressBar
//
//  Created by Kusal Shrestha on 7/17/16.
//  Copyright © 2016 Kusal Shrestha. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var progressView: SKProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.linearProgress = 0

    }

    @IBAction func progressWidthChange(sender: UISlider) {
        progressView.linearProgress = CGFloat(sender.value)
    }
    
}

