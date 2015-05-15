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
    var handleReply : (([NSObject : AnyObject]!) -> Void)?
    
    var lineDataLoaded = false
    var thorneColor : UIColor?
    var moultonColor : UIColor?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        //dark background, light text status bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //set tabBar style, moreNavigationController delegate
        if self.window != nil {
            //set tab bar to be light gray
            (self.window!.rootViewController as! UITabBarController).tabBar.tintColor = UIColor.whiteColor()
            (self.window!.rootViewController as! UITabBarController).tabBar.barTintColor = UIColor.clearColor()
            (self.window!.rootViewController as! UITabBarController).tabBar.barStyle = UIBarStyle.Black
            (self.window!.rootViewController as! UITabBarController).tabBar.translucent = true
            
            //setting delegate for styling
            (self.window!.rootViewController as! UITabBarController).moreNavigationController.delegate = self
            var tableView = ((self.window!.rootViewController as! UITabBarController).moreNavigationController.viewControllers[0] as! UIViewController).view as! UITableView
            tableView.tintColor = UIColor.blackColor()
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        //update filter to last setting
        var currentFilter = NSUserDefaults.standardUserDefaults().objectForKey("diet-filter") as! NSInteger?
        if currentFilter != nil {
            self.updateDietFilter(currentFilter!)
        }
        
        return true
    }

    //sets diet fielters from settings
    func updateDietFilter(filterIndex : NSInteger) {
        self.filters.removeAll(keepCapacity: false)
        switch filterIndex {
            case 1:
                self.filters.append("V")
                self.filters.append("VE")
            case 2:
                self.filters.append("VE")
            case 3:
                self.filters.append("NGI")
            case 4:
                self.filters.append("L")
            default:
                break;
        }
    }
    
    //sets defaults during "More" View Controller
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        /* We don't need Edit button in More screen. */
        navigationController.navigationBar.topItem!.rightBarButtonItem = nil;
        
        //style
        navigationController.navigationBar.titleTextAttributes
            = [NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 28.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        navigationController.navigationBar.barTintColor = UIColor.clearColor()
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        navigationController.navigationBar.translucent = true
        
        if viewController.title == "Settings" {
            viewController.navigationItem.title = "Settings"
        }
        if viewController.title == "Hours" {
            viewController.navigationItem.title = "Hours"
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.lineDataLoaded = false
        NSNotificationCenter.defaultCenter().removeObserver("LineDataLoaded")
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
        
        //tell VC to watch for success notifications from User obj
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "linesDidFinishLoading",
            name: "LineDataLoaded",
            object: nil)
        
        self.getLineData()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication,
        handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]!) -> Void)!) {
            println("NOW ON IPHONE!")
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "linesDidFinishLoading",
                name: "LineDataLoaded",
                object: nil)
            
            handleReply = reply
            self.getLineData()
    }

    //loads line data & user as necessary
    func getLineData() {
        println("GETTING LINE DATA")
        if self.user == nil { //if we don't have a user, create one and load line data
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let username     = userDefaults.objectForKey("bowdoin_username") as? String
            let password     = userDefaults.objectForKey("bowdoin_password") as? String
            
            //if we have user info saved, download their data
            if username != nil && password != nil {
                var downloadQueue = dispatch_queue_create("Download queue", nil);
                dispatch_async(downloadQueue) {
                    //in new thread, load user info if not loaded or if force-reloaded
                    self.user = User(username: username!, password: password!)
                    
                    self.user?.loadLineData()
                }
            }
        } else { //else, just load the line data
            self.user!.loadLineData()
        }
        
        //attempt to load again every 60 seconds
        delay(60) {
            self.getLineData()
        }
    }
    
    //parses line data to color once loaded
    func linesDidFinishLoading() {
        println("RETURNED LINE DATA")
        let thorneScore = self.user?.thorneScore
        let moultonScore = self.user?.moultonScore
        let dict = ["thorneScore" : thorneScore ?? -1, "moultonScore" : moultonScore ?? -1]
        
        if handleReply != nil {
            println("SENDING REPLY")
            handleReply!(dict)
        }
        
        //first, translate thorne score to color
        if thorneScore != nil { //if open, parse
            if thorneScore > 0.66 { //busy line
                self.thorneColor = UIColor.redColor()
            } else if thorneScore > 0.33 { //wait
                self.thorneColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            } else { //no line
                self.thorneColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            }
        } else { //else default to white
            self.thorneColor = UIColor.whiteColor()
        }
        
        //now translate moulton score
        if moultonScore != nil { //if open, parse
            if moultonScore > 0.66 { //busy line
                self.moultonColor = UIColor.redColor()
            } else if moultonScore > 0.33 { //wait
                self.moultonColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            } else { //no line
                self.moultonColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            }
        } else { //else default to white
            self.moultonColor = UIColor.whiteColor()
        }
        
        //update UI
        self.lineDataLoaded = true
        NSNotificationCenter.defaultCenter().postNotificationName("LinesFinishedLoading",
            object: nil,
            userInfo: nil)
    }
    
}

