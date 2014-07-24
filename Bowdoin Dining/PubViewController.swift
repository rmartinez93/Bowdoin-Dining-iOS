//
//  PubViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit

class PubViewController: UIViewController {
    @IBOutlet var MageesMenu : UIWebView!
    
    override func viewDidLoad() {
        var url = NSBundle.mainBundle().URLForResource("magees-menu", withExtension: "pdf")
        var request = NSURLRequest(URL: url)

        self.MageesMenu.loadRequest(request)
        
        //fixes issue with last item not showing, but keeps translucency
        self.MageesMenu.scrollView.contentInset.bottom = 50
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
    }

}

