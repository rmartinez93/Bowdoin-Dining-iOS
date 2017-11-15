//
//  AppDelegate.swift
//
//  Created by Ruben on 7/17/14.
//  Copyright (c) 2014 Ruben. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    var handleReply : (([AnyHashable: Any]?) -> Void)?
    
    var lineDataLoaded = false
    var thorneColor : UIColor?
    var moultonColor : UIColor?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //dark background, light text status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        
        //set tabBar style, moreNavigationController delegate
        if self.window != nil {
            //set tab bar to be light gray
            (self.window!.rootViewController as! UITabBarController).tabBar.tintColor = UIColor.white
            (self.window!.rootViewController as! UITabBarController).tabBar.barTintColor = UIColor.clear
            (self.window!.rootViewController as! UITabBarController).tabBar.barStyle = UIBarStyle.black
            (self.window!.rootViewController as! UITabBarController).tabBar.isTranslucent = true
            
            //setting delegate for styling
            (self.window!.rootViewController as! UITabBarController).moreNavigationController.delegate = self
            let tableView = ((self.window!.rootViewController as! UITabBarController).moreNavigationController.viewControllers[0]).view as! UITableView
            tableView.tintColor = UIColor.black
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        
        //update filter to last setting
        let currentFilter = UserDefaults.standard.object(forKey: "diet-filter") as! NSInteger?
        if currentFilter != nil {
            self.updateDietFilter(currentFilter!)
        }
        
        //launched from one of my shortut items
        if #available(iOS 9.0, *) {
            if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem
            {
                self.handleShortcutItem(shortcutItem)
                return false
            }
        }

        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.handleShortcutItem(shortcutItem)
    }

    //handles case where shortcut item launched the app
    @available(iOS 9.0, *)
    func handleShortcutItem(_ shortcutItem : UIApplicationShortcutItem) {
        if let shortcutType = ShortcutType(rawValue: shortcutItem.type) {
            //Get root tab bar viewcontroller and its first controller
            let rootTabBarController = window!.rootViewController as! UITabBarController
            switch shortcutType {
            case .Thorne:
                rootTabBarController.selectedIndex = 0
            case .Moulton:
                rootTabBarController.selectedIndex = 1
            case .Pub:
                rootTabBarController.selectedIndex = 2
            case .Account:
                rootTabBarController.selectedIndex = 3
            }
        }
    }

    //sets diet fielters from settings
    func updateDietFilter(_ filterIndex : NSInteger) {
        self.filters.removeAll(keepingCapacity: false)
        switch filterIndex {
            case 1:
                self.filters.append("V")
                self.filters.append("VE")
            case 2:
                self.filters.append("VE")
            case 3:
                self.filters.append("NGI")
            case 4:
                self.filters.append("GF")
            case 5:
                self.filters.append("DF")
            case 6:
                self.filters.append("L")
            case 7:
                self.filters.append("H")
            default:
                break;
        }
    }
    
    //sets defaults during "More" View Controller
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        /* We don't need Edit button in More screen. */
        navigationController.navigationBar.topItem!.rightBarButtonItem = nil;
        
        //style
        navigationController.navigationBar.titleTextAttributes
            = [NSAttributedStringKey.font : UIFont(name: "Helvetica Neue", size: 28.0)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.barTintColor = UIColor.clear
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.navigationBar.isTranslucent = true
        
        if viewController.title == "Settings" {
            viewController.navigationItem.title = "Settings"
        }
        if viewController.title == "Hours" {
            viewController.navigationItem.title = "Hours"
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        self.lineDataLoaded = false
        NotificationCenter.default.removeObserver("LineDataLoaded")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //tell VC to watch for success notifications from User obj
        NotificationCenter.default.addObserver(self,
            selector: #selector(AppDelegate.linesDidFinishLoading),
            name: NSNotification.Name(rawValue: "LineDataLoaded"),
            object: nil)
        
        self.getLineData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //loads line data & user as necessary
    func getLineData() {
        if self.user == nil { //if we don't have a user, create one and load line data
            let userDefaults = UserDefaults.standard
            let username     = userDefaults.object(forKey: "bowdoin_username") as? String
            let password     = userDefaults.object(forKey: "bowdoin_password") as? String
            
            //if we have user info saved, download their data
            if username != nil && password != nil {
                let downloadQueue = DispatchQueue(label: "Download queue", attributes: []);
                downloadQueue.async {
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
    @objc func linesDidFinishLoading() {
        let thorneScore = self.user?.thorneScore
        let moultonScore = self.user?.moultonScore
        let dict = ["thorneScore" : thorneScore ?? -1, "moultonScore" : moultonScore ?? -1]
        
        if handleReply != nil {
            handleReply!(dict)
        }
        
        //first, translate thorne score to color
        if thorneScore != nil { //if open, parse
            if thorneScore > 0.66 { //busy line
                self.thorneColor = UIColor.red
            } else if thorneScore > 0.33 { //wait
                self.thorneColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            } else { //no line
                self.thorneColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            }
        } else { //else default to white
            self.thorneColor = UIColor.white
        }
        
        //now translate moulton score
        if moultonScore != nil { //if open, parse
            if moultonScore > 0.66 { //busy line
                self.moultonColor = UIColor.red
            } else if moultonScore > 0.33 { //wait
                self.moultonColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1)
            } else { //no line
                self.moultonColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
            }
        } else { //else default to white
            self.moultonColor = UIColor.white
        }
        
        //update UI
        self.lineDataLoaded = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "LinesFinishedLoading"),
            object: nil,
            userInfo: nil)
    }
}

enum ShortcutType: String {
    case Thorne = "Thorne"
    case Moulton = "Moulton"
    case Pub = "Pub"
    case Account = "Account"
}
