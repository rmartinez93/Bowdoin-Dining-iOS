//
//  AppDelegate.swift
//  SwiftTest
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window    : UIWindow?
    let thorneId  : NSInteger       = 1
    let moultonId : NSInteger       = 0
    var filters   : NSMutableArray  = NSMutableArray()
    var daysAdded : NSInteger       = 0
    var day       : NSInteger       = 0
    var month     : NSInteger       = 0
    var year      : NSInteger       = 0
    var offset    : NSInteger       = 0
    var selectedSegment : NSInteger = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        self.updateDietFilter(NSUserDefaults.standardUserDefaults().integerForKey("diet-filter"))
        
        return true
    }

    func updateDietFilter(filterIndex : NSInteger) {
        self.filters.removeAllObjects()
        switch(filterIndex) {
            case 1:
                self.filters.addObject("V")
                self.filters.addObject("VE")
            case 2:
                self.filters.addObject("VE")
            case 3:
                self.filters.addObject("GF")
            case 4:
                self.filters.addObject("L")
            default:
                break;
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

