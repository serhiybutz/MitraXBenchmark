//
//  ViewController.swift
//  MitraXBenchmarkIOS
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var runButton: UIButton!

    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    @IBAction func runButtonAction(_ sender: Any) {
        textView.text = ""
        runButton.isEnabled = false
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        DispatchQueue.global().async {
            let resultLog = benchmark()
            DispatchQueue.main.sync {
                self.runButton.isEnabled = true
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                self.textView.text += resultLog
            }
        }
    }
}

