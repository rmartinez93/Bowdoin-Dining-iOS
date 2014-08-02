//
//  AppDelegate.swift
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window    : UIWindow?
    var user      : User?
    var filters   : [String] = []
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
        //dark background, light text status bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.BlackOpaque, animated: false)
        
        //show splash screen
        if let window = self.window {
            window.makeKeyAndVisible()
            
            var splash = SplashView(frame: CGRectMake(0, 0, window.frame.width, window.frame.height))
            splash.backgroundColor = UIColor.blackColor()
            window.addSubview(splash)
            window.bringSubviewToFront(splash)
        }
        
        //set tabBar style, moreNavigationController delegate
        if self.window {
            //set tab bar to be light gray
            (self.window!.rootViewController as UITabBarController).tabBar.backgroundImage = UIImage(named: "tab.png")
            (self.window!.rootViewController as UITabBarController).tabBar.translucent = false
            //setting delegate for styling
            (self.window!.rootViewController as UITabBarController).moreNavigationController.delegate = self
        }
        
        //update filter to last setting
        var currentFilter : NSInteger? = NSUserDefaults.standardUserDefaults().objectForKey("diet-filter") as? NSInteger
        if currentFilter {
            self.updateDietFilter(currentFilter!)
        }
        
        return true
    }

    func updateDietFilter(filterIndex : NSInteger) {
        self.filters.removeAll(keepCapacity: false)
        switch filterIndex {
            case 1:
                self.filters += "V"
                self.filters += "VE"
            case 2:
                self.filters += "VE"
            case 3:
                self.filters += "GF"
            case 4:
                self.filters += "L"
            default:
                break;
        }
    }
    
    func navigationController(navigationController: UINavigationController!, willShowViewController viewController: UIViewController!, animated: Bool) {
        /* We don't need Edit button in More screen. */
        navigationController.navigationBar.topItem.rightBarButtonItem = nil;
        
        //style
        navigationController.navigationBar.titleTextAttributes
            = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 28), NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
        
        if (viewController.title as NSString).isEqualToString("Settings") {
            viewController.navigationItem.title = "Settings"
        }
        if (viewController.title as NSString).isEqualToString("Hours") {
            viewController.navigationItem.title = "Hours"
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

