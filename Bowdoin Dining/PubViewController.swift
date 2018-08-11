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
        
        let url = Bundle.main.url(forResource: "pub-menu", withExtension: "pdf")
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
        let url = URL(string: "https://www.bowdoin.edu/atreus/diningspecials/specials.jsp")
        UIApplication.shared.openURL(url!)
    }
    
    @IBAction func dialPub() {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en-US");
        
//        let components = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday], fromDate: NSDate())
//        
//        let hour = components.hour
//        let min  = components.minute
//        let day  = components.weekday
//        
        //if pubIsOpen(day, hour: hour, min: min) {
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
    
    func pubIsOpen(_ day : Int, hour : Int, min : Int) -> Bool {
        let OH = [sunOH, monOH, tueOH, wedOH, thuOH, friOH, satOH]
        let OM = [sunOM, monOM, tueOM, wedOM, thuOM, friOM, satOM]
        let CH = [sunCH, monCH, tueCH, wedCH, thuCH, friCH, satCH]
        let CM = [sunCM, monCM, tueCM, wedCM, thuCM, friCM, satCM]
        
        return after(hour, minute1: min, hour2: OH[day-1], minute2: OM[day-1]) && before(hour, minute1: min, hour2: CH[day-1], minute2: CM[day-1])
    }
    
    //is time1 before time2
    func before(_ hour1 : Int, minute1 : Int, hour2 : Int, minute2 : Int) -> Bool {
        return  hour1 < hour2 || (hour1 == hour2 && minute1 < minute2)
    }
    
    //is time1 after time2
    func after(_ hour1 : Int, minute1 : Int, hour2 : Int, minute2 : Int) -> Bool {
        return  hour1 > hour2 || (hour1 == hour2 && minute1 >= minute2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
