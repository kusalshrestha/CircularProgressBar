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
        progressView.title = "Wholeness \n Score"
        progressView.showStepsAroundCircle = true
//        progressView.gradientStartColor = UIColor ( red: 0.3681, green: 0.5123, blue: 0.4753, alpha: 1.0 )
//        progressView.gradientMidColor = UIColor ( red: 0.674, green: 0.9678, blue: 0.5098, alpha: 1.0 )
//        progressView.gradientEndColor = UIColor ( red: 0.702, green: 1.0, blue: 0.3624, alpha: 1.0 )
    }

    @IBAction func progressWidthChange(sender: UISlider) {
        progressView.linearProgress = CGFloat(sender.value)
    }
    
}

