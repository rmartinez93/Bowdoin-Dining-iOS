//
//  AccountViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/22/14.
//
//

import Foundation

class AccountViewController : UIViewController {
    @IBOutlet var loginButton  : UIButton!
    @IBOutlet var reloadButton : UIButton!
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
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //show status bar
        UIApplication.sharedApplication().statusBarHidden = false;
        
        //if user's data has not been loaded, load their data
        if(!self.delegate.user.dataLoaded) {
            self.reloadData(UIButton())
        }
        
    }
    
    @IBAction func userDidLogin(segue : UIStoryboardSegue) {
        self.loginButton.hidden = true;
    }
    
    @IBAction func userCancelledLogin(segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func reloadData(sender : UIButton) {
        self.points.text = "N/A"
        self.meals.text = "N/A"
        self.balance.text = "N/A"
        self.loadingData.startAnimating()
        self.reloadButton.hidden = true
        self.loginButton.hidden = true
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var username     = userDefaults.objectForKey("bowdoin_username") as? NSString
        var password     = userDefaults.objectForKey("bowdoin_password") as? NSString
        
        //if we have user info saved, download their data
        if username && password {
            var downloadQueue = dispatch_queue_create("Download queue", nil);
            dispatch_async(downloadQueue) {
                //in new thread, load user info
                self.delegate.user.loadDataFor(username!, password: password!)
            }
        }
        //else, ask for user credentials
        else {
            self.loginButton.hidden = false;
            self.reloadButton.hidden = true;
            self.loadingData.stopAnimating()
        }
    }
    
    func userDidLoad(notification : NSNotification) {
        //update our copy of the user with new info
        var userInfo = notification.userInfo as NSDictionary
        self.delegate.user = userInfo.objectForKey("User") as User
        
        //refresh onscreen info
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingData.stopAnimating()
            self.reloadButton.hidden = false
            self.reloadButton.enabled = true
            self.loginButton.hidden = true
            self.view.setNeedsDisplay()
            self.points.text = NSString(format: "$%.2f", self.delegate.user.polarPoints)
            self.meals.text = NSString(format: "%i", self.delegate.user.mealsLeft)
            self.balance.text = NSString(format: "$%.2f", self.delegate.user.cardBalance)
        }
    }
}