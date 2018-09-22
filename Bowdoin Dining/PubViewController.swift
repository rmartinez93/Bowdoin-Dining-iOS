//
//  PubViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//  Copyright (c) 2014 Ruben Martinez Jr. All rights reserved.
//

import UIKit

class PubViewController: UIViewController, UINavigationBarDelegate {
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var shareGesture : UIScreenEdgePanGestureRecognizer?
    @IBOutlet var MageesMenu : UIWebView!
    @IBOutlet var navBar     : UINavigationBar!
    
    // Get the menu from the web
    let pubMenuUrl = "http://www.bowdoin.edu/dining/pdf/magees-menu.pdf"
    let pubSpecialsUrl = "https://www.bowdoin.edu/atreus/diningspecials/specials.jsp"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = URL(string: pubMenuUrl)
        let request = URLRequest(url: url!)

        //load menu
        self.MageesMenu.loadRequest(request)
        
        //fixes issue with bottom not showing, but keeps translucency
        self.MageesMenu.scrollView.contentInset.bottom = 50
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.topAttached
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //shares an invite to the currently browsed meal
    @objc func inviteToMeal() {
        var invite = [AnyObject]()
        invite.append("Let's get a meal at the Pub?" as AnyObject)
        
        let activityViewController = UIActivityViewController(activityItems: invite, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate.window!.removeGestureRecognizer(shareGesture!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //sharing gesture
        self.shareGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(PubViewController.inviteToMeal))
        self.shareGesture!.edges = UIRectEdge.left
        self.delegate.window!.addGestureRecognizer(self.shareGesture!)
    }
    
    @IBAction func showSpecials() {
        let url = URL(string: pubSpecialsUrl)
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func dialPub() {
//        if pubIsOpen() {
        let phoneNumberURL = URL(string:"tel://2077253888")!
        UIApplication.shared.openURL(phoneNumberURL)
//        } else {
//            var alert = UIAlertView(title: "Pub Closed",
//                message: "Sorry, the pub seems to be closed at this time. Please try again later!",
//                delegate: self,
//                cancelButtonTitle: "OK")
//            alert.show()
//        }
    }
    
    // Pub schedule (WIP)
    var pubSchedule: Schedule = {
        let sundaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Sunday, hour: 18, minute: 30),
            endTime:   ScheduleTime(day: Day.Sunday, hour: 23, minute: 59)
        )
        
        let mondaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Monday, hour: 11, minute: 30),
            endTime:   ScheduleTime(day: Day.Monday, hour: 23, minute: 59)
        )
        
        let tuesdaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Tuesday, hour: 11, minute: 30),
            endTime:   ScheduleTime(day: Day.Tuesday, hour: 23, minute: 59)
        )
        
        let wednesdaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Wednesday, hour: 11, minute: 30),
            endTime:   ScheduleTime(day: Day.Wednesday, hour: 23, minute: 59)
        )
        
        let thursdaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Thursday, hour: 11, minute: 30),
            endTime:   ScheduleTime(day: Day.Thursday, hour: 23, minute: 59)
        )
        
        let fridaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Friday, hour: 11, minute: 30),
            endTime:   ScheduleTime(day: Day.Friday, hour: 23, minute: 59)
        )
        
        let saturdaySchedule = try! ScheduleEntry(
            startTime: ScheduleTime(day: Day.Saturday, hour: 0, minute: 0),
            endTime:   ScheduleTime(day: Day.Saturday, hour: 0, minute: 1)
        )
        
        return Schedule([
            sundaySchedule,
            mondaySchedule,
            tuesdaySchedule,
            wednesdaySchedule,
            thursdaySchedule,
            fridaySchedule,
            saturdaySchedule
        ])
    }()
    
    // Checks if pub is open.
    func isPubOpen() -> Bool {
        let components = Date().getComponents([.hour, .minute, .weekday])

        let hour = components.hour!
        let min  = components.minute!
        
        let day  = Day(rawValue: components.weekday!)!
        let time = ScheduleTime(day: day, hour: hour, minute: min)
        
        return pubSchedule.hasConflicts(time: time)
    }
}
