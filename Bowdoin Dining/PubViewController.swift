//
//  PubViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//  Copyright (c) 2014 Ruben Martinez Jr. All rights reserved.
//

import UIKit

class PubViewController: UIViewController, UINavigationBarDelegate {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    var shareGesture : UIScreenEdgePanGestureRecognizer?
    @IBOutlet var MageesMenu : UIWebView!
    @IBOutlet var navBar     : UINavigationBar!
    
    override func viewDidLoad() {
        var url = NSBundle.mainBundle().URLForResource("magees-menu", withExtension: "pdf")
        var request = NSURLRequest(URL: url)
        
        //load menu
        self.MageesMenu.loadRequest(request)
        
        //fixes issue with bottom not showing, but keeps translucency
        self.MageesMenu.scrollView.contentInset.bottom = 50
        
        //sets navbar style
        self.navBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    //shares an invite to the currently browsed meal
    func inviteToMeal() {
        var invite = [AnyObject]()
        invite.append("Let's get a meal at the Pub?")
        
        let activityViewController = UIActivityViewController(activityItems: invite, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func dialPub() {
        var phoneNumberURL = "tel://2077253888"
        UIApplication.sharedApplication().openURL(NSURL(string: phoneNumberURL))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.window!.removeGestureRecognizer(shareGesture!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //sharing gesture
        self.shareGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "inviteToMeal")
        self.shareGesture!.edges = UIRectEdge.Left
        self.delegate.window!.addGestureRecognizer(self.shareGesture!)
    }

}

