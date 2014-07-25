//
//  PubViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit

class PubViewController: UIViewController, UINavigationBarDelegate {
    @IBOutlet var MageesMenu : UIWebView!
    @IBOutlet var navBar     : UINavigationBar!
    
    override func viewDidLoad() {
        var url = NSBundle.mainBundle().URLForResource("magees-menu", withExtension: "pdf")
        var request = NSURLRequest(URL: url)
        
        //load menu
        self.MageesMenu.loadRequest(request)
        
        //fixes issue with bottom not showing, but keeps translucency
        self.MageesMenu.scrollView.contentInset.bottom = 50
        
        //style
        self.navBar.barTintColor
            = UIColor(red: 0.36, green:0.36, blue:0.36, alpha:1)
        self.navBar.barStyle = UIBarStyle.Black
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    @IBAction func dialPub() {
        var phoneNumberURL = "tel://2077253888"
        UIApplication.sharedApplication().openURL(NSURL(string: phoneNumberURL))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

}

