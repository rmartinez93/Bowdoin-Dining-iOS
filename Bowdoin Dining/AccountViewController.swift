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
    @IBOutlet var recent       : UIButton!
    @IBOutlet var timeStamp: UILabel!
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver("UserFinishedLoading")
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //load user data
        if self.delegate.user == nil || self.delegate.user!.loggedIn == false {
            self.loadUserData(self)
        }
    }
    
    @IBAction func userDidLogin(segue : UIStoryboardSegue) {

    }
    
    @IBAction func userCancelledLogin(segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func userReturnedFromTransactions(segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func loadUserData(sender : AnyObject) {
        self.meals.text   = "N/A"
        self.points.text  = "N/A"
        self.balance.text = "N/A"
        self.timeStamp.text = ""
        self.navBar.topItem!.rightBarButtonItem!.enabled = false
        self.navBar.topItem!.leftBarButtonItem!.enabled  = false
        self.recent.enabled = false
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var username     = userDefaults.objectForKey("bowdoin_username") as? String
        var password     = userDefaults.objectForKey("bowdoin_password") as? String
        
        //if we have user info saved, download their data
        if username != nil && password != nil {
            self.loadingData.startAnimating()
            var downloadQueue = dispatch_queue_create("Download queue", nil);
            dispatch_async(downloadQueue) {
                //in new thread, load user info if not loaded or if force-reloaded
                self.delegate.user = User(username: username!, password: password!)
                self.delegate.user!.loadData()
            }
        }
        //else, ask for user credentials
        else {
            self.navBar.topItem!.rightBarButtonItem!.enabled = true
            self.navBar.topItem!.leftBarButtonItem!.enabled  = false
            self.recent.enabled = false
        }
    }
    
    func userDidLoad(notification : NSNotification) {
        //refresh onscreen info
        dispatch_async(dispatch_get_main_queue()) {
            if self.delegate.user!.dataLoaded {
                self.loadingData.stopAnimating()
                self.navBar.topItem!.rightBarButtonItem!.enabled = false
                self.navBar.topItem!.leftBarButtonItem!.enabled  = true
                self.recent.enabled = true
                
                self.view.setNeedsDisplay()
                
                self.meals.text   = NSString(format: "%i",    self.delegate.user!.mealsLeft!)
                self.points.text  = NSString(format: "$%.2f", self.delegate.user!.polarPoints!)
                self.balance.text = NSString(format: "$%.2f", self.delegate.user!.cardBalance!)
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd 'at' hh:mm a"
                self.timeStamp.text = "Last Updated: \(dateFormatter.stringFromDate(NSDate()))"
            }
        }
    }
}