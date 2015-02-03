//
//  PubViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//  Copyright (c) 2014 Ruben Martinez Jr. All rights reserved.
//

import UIKit

class PubViewController: UIViewController, UINavigationBarDelegate {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    var shareGesture : UIScreenEdgePanGestureRecognizer?
    @IBOutlet var MageesMenu : UIWebView!
    @IBOutlet var navBar     : UINavigationBar!
    
    //Opening Hour (OH) / Opening Minute (OM), Closing Hour (CH) / Closing Minute (CM) for all days as of 10/11/14
    let sunOH = 18
    let sunOM = 30
    let sunCH = 23
    let sunCM = 59
    
    let monOH = 11
    let monOM = 30
    let monCH = 23
    let monCM = 59
    
    let tueOH = 11
    let tueOM = 30
    let tueCH = 23
    let tueCM = 59
    
    let wedOH = 11
    let wedOM = 30
    let wedCH = 23
    let wedCM = 59
    
    let thuOH = 11
    let thuOM = 30
    let thuCH = 23
    let thuCM = 59
    
    let friOH = 11
    let friOM = 30
    let friCH = 23
    let friCM = 59
    
    let satOH = 18
    let satOM = 00
    let satCH = 23
    let satCM = 59
    // End opening times and closing times
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var url = NSBundle.mainBundle().URLForResource("pub-menu", withExtension: "pdf") as NSURL!
        var request = NSURLRequest(URL: url)

        //load menu
        self.MageesMenu.loadRequest(request)
        
        //fixes issue with bottom not showing, but keeps translucency
        self.MageesMenu.scrollView.contentInset.bottom = 50
        
        //sets navbar style
        self.navBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    //shares an invite to the currently browsed meal
    func inviteToMeal() {
        var invite = [AnyObject]()
        invite.append("Let's get a meal at the Pub?")
        
        let activityViewController = UIActivityViewController(activityItems: invite, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.window!.removeGestureRecognizer(shareGesture!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //sharing gesture
        self.shareGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "inviteToMeal")
        self.shareGesture!.edges = UIRectEdge.Left
        self.delegate.window!.addGestureRecognizer(self.shareGesture!)
    }
    
    @IBAction func dialPub() {
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en-US");
        
        var components = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: NSDate())
        
        let hour = components.hour
        let min  = components.minute
        let day  = components.weekday
        
        //if pubIsOpen(day, hour: hour, min: min) {
        var phoneNumberURL = NSURL(string:"tel://2077253888")!
        UIApplication.sharedApplication().openURL(phoneNumberURL)
//        } else {
//            var alert = UIAlertView(title: "Pub Closed",
//                message: "Sorry, the pub seems to be closed at this time. Please try again later!",
//                delegate: self,
//                cancelButtonTitle: "OK")
//            alert.show()
//        }
    }
    
    func pubIsOpen(day : Int, hour : Int, min : Int) -> Bool {
        let OH = [sunOH, monOH, tueOH, wedOH, thuOH, friOH, satOH]
        let OM = [sunOM, monOM, tueOM, wedOM, thuOM, friOM, satOM]
        let CH = [sunCH, monCH, tueCH, wedCH, thuCH, friCH, satCH]
        let CM = [sunCM, monCM, tueCM, wedCM, thuCM, friCM, satCM]
        
        return after(hour, minute1: min, hour2: OH[day-1], minute2: OM[day-1]) && before(hour, minute1: min, hour2: CH[day-1], minute2: CM[day-1])
    }
    
    //is time1 before time2
    func before(hour1 : Int, minute1 : Int, hour2 : Int, minute2 : Int) -> Bool {
        return  hour1 < hour2 || (hour1 == hour2 && minute1 < minute2)
    }
    
    //is time1 after time2
    func after(hour1 : Int, minute1 : Int, hour2 : Int, minute2 : Int) -> Bool {
        return  hour1 > hour2 || (hour1 == hour2 && minute1 >= minute2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}