//
//  AppDelegate.swift
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window    : UIWindow?
    public var user      : User            = User()
    var filters   : NSMutableArray  = NSMutableArray()
    let thorneId  : NSInteger       = 1
    let moultonId : NSInteger       = 0
    var daysAdded : NSInteger       = 0
    var day       : NSInteger       = 0
    var month     : NSInteger       = 0
    var year      : NSInteger       = 0
    var offset    : NSInteger       = 0
    var selectedSegment : NSInteger = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        
        if let window = self.window {
            window.makeKeyAndVisible()
            
            var splash = SplashView(frame: CGRectMake(0, 0, window.frame.width, window.frame.height))
            splash.backgroundColor = UIColor.blackColor()
            window.addSubview(splash)
            window.bringSubviewToFront(splash)
        }
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        if self.window {
            //set tab bar to be light gray
            (self.window!.rootViewController as UITabBarController).tabBar.barStyle = UIBarStyle.Default
            
            //set more navbar light gray
            (self.window!.rootViewController as UITabBarController).moreNavigationController.navigationBar.barTintColor = UIColor(red: 0.97, green:0.97, blue:0.97, alpha:1)
            (self.window!.rootViewController as UITabBarController).moreNavigationController.navigationBar.translucent = false
        }
        
        var currentFilter : NSInteger? = NSUserDefaults.standardUserDefaults().objectForKey("diet-filter") as? NSInteger
        if currentFilter {
            self.updateDietFilter(currentFilter!)
        }
        
        return true
    }

    func updateDietFilter(filterIndex : NSInteger) {
        self.filters.removeAllObjects()
        switch filterIndex {
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

