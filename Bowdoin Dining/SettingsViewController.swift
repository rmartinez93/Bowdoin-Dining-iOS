//
//  SettingsViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//  Copyright (c) 2014 Ruben Martinez Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var delegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet var dietFilter : UISegmentedControl!
    @IBOutlet var logoutButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //defaults to 0 (off) if none set
        self.dietFilter.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "diet-filter")
        
        if (self.delegate.user != nil && self.delegate.user!.loggedIn) || User.credentialsStored() {
            self.logoutButton.isEnabled = true
            self.logoutButton.backgroundColor = UIColor.red
        } else {
            self.logoutButton.isEnabled = false
            self.logoutButton.backgroundColor = UIColor.lightGray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func indexDidChangeForSegmentedControl(_ sender: UISegmentedControl) {
        delegate.updateDietFilter(sender.selectedSegmentIndex)
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(sender.selectedSegmentIndex, forKey: "diet-filter")
        userDefaults.synchronize()
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        if self.delegate.user != nil {
            self.delegate.user!.logout()
        } else {
            User.forget()
        }
        
        self.logoutButton.isEnabled = false
        self.logoutButton.backgroundColor = UIColor.lightGray
    }
}

