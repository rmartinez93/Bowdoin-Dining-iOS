//
//  ViewController.swift
//  Bowdoin Dining for Mac
//
//  Created by Ruben on 5/14/15.
//
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    @IBOutlet var webView : WebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.mainFrameURL = "https://bowdoindining.meteor.com/"
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

