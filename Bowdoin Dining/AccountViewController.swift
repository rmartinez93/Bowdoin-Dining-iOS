//
//  AccountViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/22/14.
//
//

import Foundation
import UIKit

class AccountViewController : UIViewController, UINavigationBarDelegate {
    @IBOutlet var navBar       : UINavigationBar!
    @IBOutlet var loadingData  : UIActivityIndicatorView!
    @IBOutlet var meals        : UILabel!
    @IBOutlet var balance      : UILabel!
    @IBOutlet var points       : UILabel!
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        //tell VC to watch for notifications from User obj
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "userDidLoad:",
            name: "UserFinishedLoading",
            object: nil)
        
        //navbar style
        self.navBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //if user's data has not been loaded, load their data
        if self.delegate.user != nil {
            self.delegate.user = User()
        }
        if !self.delegate.user!.dataLoaded {
            self.reloadData(UIButton())
        }
        
    }
    
    @IBAction func userDidLogin(segue : UIStoryboardSegue) {
        self.navBar.topItem.rightBarButtonItem.enabled = false;
    }
    
    @IBAction func userCancelledLogin(segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func reloadData(sender : AnyObject) {
        self.points.text = "N/A"
        self.meals.text = "N/A"
        self.balance.text = "N/A"
        self.loadingData.startAnimating()
        self.navBar.topItem.leftBarButtonItem.enabled = false;
        self.navBar.topItem.rightBarButtonItem.enabled = false;
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var username     = userDefaults.objectForKey("bowdoin_username") as? NSString
        var password     = userDefaults.objectForKey("bowdoin_password") as? NSString
        
        //if we have user info saved, download their data
        if username != nil && password != nil {
            var downloadQueue = dispatch_queue_create("Download queue", nil);
            dispatch_async(downloadQueue) {
                //in new thread, load user info
                if self.delegate.user != nil {
                    self.delegate.user!.loadDataFor(username!, password: password!)
                }
            }
        }
        //else, ask for user credentials
        else {
            self.navBar.topItem.leftBarButtonItem.enabled = false
            self.navBar.topItem.rightBarButtonItem.enabled = true
            self.loadingData.stopAnimating()
        }
    }
    
    func userDidLoad(notification : NSNotification) {
        //update our copy of the user with new info
        var userInfo = notification.userInfo as NSDictionary
        self.delegate.user = userInfo.objectForKey("User") as? User
        
        //refresh onscreen info
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingData.stopAnimating()
            self.navBar.topItem.leftBarButtonItem.enabled = true
            self.navBar.topItem.rightBarButtonItem.enabled = false
            
            self.view.setNeedsDisplay()
            self.points.text  = NSString(format: "$%.2f", self.delegate.user!.polarPoints!)
            self.meals.text   = NSString(format: "%i",    self.delegate.user!.mealsLeft!)
            self.balance.text = NSString(format: "$%.2f", self.delegate.user!.cardBalance!)
        }
    }
}