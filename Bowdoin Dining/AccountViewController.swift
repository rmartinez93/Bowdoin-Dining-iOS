//
//  AccountViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/22/14.
//
//

import Foundation
import UIKit

class AccountViewController : UIViewController, UINavigationBarDelegate, UserDelegate {
    @IBOutlet var navBar       : UINavigationBar!
    @IBOutlet var loadingData  : UIActivityIndicatorView!
    @IBOutlet var meals        : UILabel!
    @IBOutlet var balance      : UILabel!
    @IBOutlet var points       : UILabel!
    @IBOutlet var recent       : UIButton!
    @IBOutlet var timeStamp: UILabel!
    var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //tell VC to watch for success notifications from User obj
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "accountDidLoad:",
            name: "AccountFinishedLoading",
            object: nil)
        
        //tell VC to watch for success notifications from User obj
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "transactionsDidLoad:",
            name: "TransactionsFinishedLoading",
            object: nil)
        
        //tell VC to watch for failure notifications from User obj
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "userLoadingFailed:",
            name: "UserLoadingFailed",
            object: nil)
        
        //load user data
        self.loadUserData(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.TopAttached
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
        
        if self.delegate.user == nil || self.delegate.user!.loggedIn == false {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let username     = userDefaults.objectForKey("bowdoin_username") as? String
            let password     = userDefaults.objectForKey("bowdoin_password") as? String
            
            //if we have user info saved, download their data
            if username != nil && password != nil {
                self.loadingData.startAnimating()
                let downloadQueue = dispatch_queue_create("Download queue", nil);
                dispatch_async(downloadQueue) {
                    //in new thread, load user info if not loaded or if force-reloaded
                    self.delegate.user = User(username: username!, password: password!)
                    self.delegate.user?.loadAccountData()
                }
            }
            //else, ask for user credentials
            else {
                self.navBar.topItem!.rightBarButtonItem!.enabled = true
                self.navBar.topItem!.leftBarButtonItem!.enabled  = false
                self.recent.enabled = false
            }
        } else {
            self.delegate.user!.loadAccountData()
        }
    }
    
    @IBAction func loadTransactionData() {
        self.delegate.user!.loadTransactionData()
    }
    
    func dataLoadingFailed(notification : NSNotification) {
        //refresh onscreen info
        dispatch_async(dispatch_get_main_queue()) {
            let alert = UIAlertView(title: "Account Error",
                message: "Sorry, your account data could not be loaded at this time. Please try again later.",
                delegate: self,
                cancelButtonTitle: "OK")
            alert.show()
        }
        self.delegate.user = nil
    }
    
    //Transaction data loaded
    func transactionsDidLoad(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.delegate.user!.dataLoaded {
                let transactionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TransactionsViewController") as! TransactionsViewController
                self.presentViewController(transactionsVC, animated: true, completion: nil)
            }
        }
    }
    
    //Balance/Polar Points/Meals loaded
    func accountDidLoad(notification : NSNotification) {
        //refresh onscreen info
        dispatch_async(dispatch_get_main_queue()) {
            if self.delegate.user!.dataLoaded {
                self.loadingData.stopAnimating()
                self.navBar.topItem!.rightBarButtonItem!.enabled = false
                self.navBar.topItem!.leftBarButtonItem!.enabled  = true
                self.recent.enabled = true
                
                self.view.setNeedsDisplay()
                
                self.meals.text   = NSString(format: "%i",    self.delegate.user!.mealsLeft!) as String
                self.points.text  = NSString(format: "$%.2f", self.delegate.user!.polarPoints!) as String
                self.balance.text = NSString(format: "$%.2f", self.delegate.user!.cardBalance!) as String                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd 'at' hh:mm a"
                self.timeStamp.text = "Last Updated: \(dateFormatter.stringFromDate(NSDate()))"
            }
        }
    }
}