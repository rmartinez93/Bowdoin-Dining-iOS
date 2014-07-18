//
//  SwiftLoginViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/17/14.
//
//

import UIKit

class LoginModalViewController : UIViewController {
    @IBOutlet var usernameField : UITextField
    @IBOutlet var passwordField : UITextField
    @IBOutlet var remember      : UISwitch
    @IBOutlet var loggingIn     : UIActivityIndicatorView
    @IBOutlet var insutructions : UILabel
    @IBOutlet var loginButton   : UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(sender : UIButton) {
        self.loggingIn.startAnimating()
        self.loginButton.setTitle("    ", forState: UIControlState.Normal)
        self.usernameField.enabled = false
        self.passwordField.enabled = false
        
        var downloadQueue = dispatch_queue_create("Download queue", nil)
        dispatch_async(downloadQueue) {
            //in new thread, load user info
            var user = User(username: self.usernameField.text, password: self.passwordField.text)
            
            //go back to main thread
            dispatch_async(dispatch_get_main_queue()) {
                if user == nil {
                    self.loggingIn.stopAnimating()
                    self.loginButton.setTitle("Login", forState: UIControlState.Normal)
                    self.usernameField.enabled = true
                    self.passwordField.enabled = true
                    self.insutructions.text = "Username or password is invalid."
                } else {
                    if self.remember.on {
                        var userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setObject(self.usernameField.text, forKey: "bowdoin_username")
                        userDefaults.setObject(self.passwordField.text, forKey: "bowdoin_password")
                        userDefaults.synchronize()
                    }
                    
                    self.loggingIn.stopAnimating()
                    self.performSegueWithIdentifier("userDidLogin", sender: self)
                }
            }
        }
    }
    
    @IBAction func nextItem(textfield : UITextField) {
        var nextTag = textfield.tag + 1
        // Try to find next responder
        var nextResponder = textfield.superview.viewWithTag(nextTag)
        
        if(nextResponder) {
            // Found next responder, so set it.
            nextResponder.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textfield.resignFirstResponder()
        }
    }
    
    @IBAction func hideKeyboard(textfield : UITextField) {
        textfield.resignFirstResponder()
    }
}