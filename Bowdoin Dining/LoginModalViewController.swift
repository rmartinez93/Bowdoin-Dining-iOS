//
//  SwiftLoginViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//
//

import UIKit

class LoginModalViewController : UIViewController {
    @IBOutlet var usernameField : UITextField!
    @IBOutlet var passwordField : UITextField!
    @IBOutlet var remember      : UISwitch!
    @IBOutlet var loggingIn     : UIActivityIndicatorView!
    @IBOutlet var insutructions : UILabel!
    @IBOutlet var loginButton   : UIButton!
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self,
            selector: #selector(LoginModalViewController.accountDidLoad(_:)),
            name: NSNotification.Name(rawValue: "AccountFinishedLoading"),
            object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender : UIButton) {
        self.loggingIn.startAnimating()
        self.loginButton.setTitle("    ", for: UIControlState())
        self.usernameField.isEnabled = false
        self.passwordField.isEnabled = false
        
        //create user with new credentials
        self.delegate.user = User(username: self.usernameField.text!, password: self.passwordField.text!)
        
        let downloadQueue = DispatchQueue(label: "Download queue", attributes: [])
        downloadQueue.async {
            //in new thread, load user info
            self.delegate.user!.loadAccountData()
        }
    }
    
    func accountDidLoad(_ notification : Notification) {
        //go to main thread
        DispatchQueue.main.async {
            if !self.delegate.user!.dataLoaded {
                self.loggingIn.stopAnimating()
                self.loginButton.setTitle("Login", for: UIControlState())
                self.usernameField.isEnabled = true
                self.passwordField.isEnabled = true
                self.insutructions.text = "Username or password is invalid."
            } else {
                if self.remember.isOn {
                    self.delegate.user!.remember()
                }
                
                self.loggingIn.stopAnimating()
                self.performSegue(withIdentifier: "userDidLogin", sender: self)
            }
        }
    }
    
    @IBAction func nextItem(_ textfield : UITextField) {
        let nextTag = textfield.tag + 1
        // Try to find next responder
        let nextResponder = textfield.superview?.viewWithTag(nextTag)
        
        if nextResponder != nil {
            // Found next responder, so set it.
            nextResponder!.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textfield.resignFirstResponder()
        }
    }
    
    @IBAction func hideKeyboard(_ textfield : UITextField) {
        textfield.resignFirstResponder()
    }
}
