//
//  SettingsViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//  Copyright (c) 2014 Ruben Martinez Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    @IBOutlet var dietFilter : UISegmentedControl!
    @IBOutlet var logoutButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        //defaults to 0 (off) if none set
        self.dietFilter.selectedSegmentIndex = NSUserDefaults.standardUserDefaults().integerForKey("diet-filter")
        
        if self.delegate.user == nil {
            self.logoutButton.enabled = false;
            self.logoutButton.backgroundColor = UIColor.lightGrayColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func indexDidChangeForSegmentedControl(sender: UISegmentedControl) {
        delegate.updateDietFilter(sender.selectedSegmentIndex)
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(sender.selectedSegmentIndex, forKey: "diet-filter")
        userDefaults.synchronize()
    }
    
    @IBAction func logout(sender: AnyObject) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("bowdoin_username")
        userDefaults.removeObjectForKey("bowdoin_password")
        userDefaults.synchronize()
        self.delegate.user!.logout()
        self.logoutButton.enabled = false
        self.logoutButton.backgroundColor = UIColor.lightGrayColor()
    }
}

