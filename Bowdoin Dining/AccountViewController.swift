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
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //tell VC to watch for success notifications from User obj
        NotificationCenter.default.addObserver(self,
            selector: #selector(AccountViewController.accountDidLoad(_:)),
            name: NSNotification.Name(rawValue: "AccountFinishedLoading"),
            object: nil)
        
        //tell VC to watch for success notifications from User obj
        NotificationCenter.default.addObserver(self,
            selector: #selector(AccountViewController.transactionsDidLoad(_:)),
            name: NSNotification.Name(rawValue: "TransactionsFinishedLoading"),
            object: nil)
        
        //tell VC to watch for failure notifications from User obj
        NotificationCenter.default.addObserver(self,
            selector: #selector(AccountViewController.dataLoadingFailed(_:)),
            name: NSNotification.Name(rawValue: "UserLoadingFailed"),
            object: nil)
        
        //load user data
        self.loadUserData(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
        super.viewWillDisappear(animated)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.topAttached
    }
    
    @IBAction func userDidLogin(_ segue : UIStoryboardSegue) {

    }
    
    @IBAction func userCancelledLogin(_ segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func userReturnedFromTransactions(_ segue : UIStoryboardSegue) {
        
    }
    
    @IBAction func loadUserData(_ sender : AnyObject) {
        self.meals.text   = "N/A"
        self.points.text  = "N/A"
        self.balance.text = "N/A"
        self.timeStamp.text = ""
        self.navBar.topItem!.rightBarButtonItem!.isEnabled = false
        self.navBar.topItem!.leftBarButtonItem!.isEnabled  = false
        self.recent.isEnabled = false
        
        if self.delegate.user == nil || self.delegate.user!.loggedIn == false {
            let userDefaults = UserDefaults.standard
            let username     = userDefaults.object(forKey: "bowdoin_username") as? String
            let password     = userDefaults.object(forKey: "bowdoin_password") as? String
            
            //if we have user info saved, download their data
            if username != nil && password != nil {
                self.loadingData.startAnimating()
                let downloadQueue = DispatchQueue(label: "Download queue", attributes: []);
                downloadQueue.async {
                    //in new thread, load user info if not loaded or if force-reloaded
                    self.delegate.user = User(username: username!, password: password!)
                    self.delegate.user?.loadAccountData()
                }
            }
            //else, ask for user credentials
            else {
                self.navBar.topItem!.rightBarButtonItem!.isEnabled = true
                self.navBar.topItem!.leftBarButtonItem!.isEnabled  = false
                self.recent.isEnabled = false
            }
        } else {
            self.delegate.user!.loadAccountData()
        }
    }
    
    @IBAction func loadTransactionData() {
        self.delegate.user!.loadTransactionData()
    }
    
    @objc func dataLoadingFailed(_ notification : Notification) {
        //refresh onscreen info
        DispatchQueue.main.async {
            let alert = UIAlertView(title: "Account Error",
                message: "Sorry, your account data could not be loaded at this time. Please try again later.",
                delegate: self,
                cancelButtonTitle: "OK")
            alert.show()
        }
        self.delegate.user = nil
    }
    
    //Transaction data loaded
    @objc func transactionsDidLoad(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.delegate.user!.dataLoaded {
                let transactionsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
                self.present(transactionsVC, animated: true, completion: nil)
            }
        }
    }
    
    //Balance/Polar Points/Meals loaded
    @objc func accountDidLoad(_ notification : Notification) {
        //refresh onscreen info
        DispatchQueue.main.async {
            if self.delegate.user!.dataLoaded {
                self.loadingData.stopAnimating()
                self.navBar.topItem!.rightBarButtonItem!.isEnabled = false
                self.navBar.topItem!.leftBarButtonItem!.isEnabled  = true
                self.recent.isEnabled = true
                
                self.view.setNeedsDisplay()
                
                self.meals.text   = NSString(format: "%i",    self.delegate.user!.mealsLeft!) as String
                self.points.text  = NSString(format: "$%.2f", self.delegate.user!.polarPoints!) as String
                self.balance.text = NSString(format: "$%.2f", self.delegate.user!.cardBalance!) as String                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd 'at' hh:mm a"
                self.timeStamp.text = "Last Updated: \(dateFormatter.string(from: Date()))"
            }
        }
    }
}
