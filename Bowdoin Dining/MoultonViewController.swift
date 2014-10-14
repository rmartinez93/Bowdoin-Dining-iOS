//
//  MoultonViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//
//

import UIKit
import QuartzCore
import AVFoundation

class MoultonViewController: UIViewController, UITableViewDelegate, UITabBarControllerDelegate, UITableViewDataSource, UINavigationBarDelegate {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    var courses : [Course] = []
    var shareGesture : UIScreenEdgePanGestureRecognizer?
    
    @IBOutlet var navBar    : UINavigationBar!
    @IBOutlet var menuItems : UITableView!
    @IBOutlet var loading   : UIActivityIndicatorView!
    @IBOutlet var meals     : UISegmentedControl!
    @IBOutlet var backButton    : UIBarButtonItem!
    @IBOutlet var forwardButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //set navbar style
        self.navBar.setBackgroundImage(UIImage(named: "bar.png"), forBarMetrics: UIBarMetrics.Default)
    }
    
    func positionForBar(bar: UIBarPositioning!) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //set the text label to day we're browsing
        self.navBar.topItem!.title = self.getTextForDaysAdded()
        
        //update selected segment in case changed elsewhere
        self.meals.selectedSegmentIndex = self.delegate.selectedSegment
        
        //verify correct buttons are showing
        self.makeCorrectButtonsVisible()
        
        //fixes issue with last item not showing, but keeps translucency
        self.menuItems.contentInset.bottom = 50
    }
    
    override func viewDidAppear(animated: Bool) {
        //load menu based on delegate settings
        self.updateVisibleMenu();
    }
    
    @IBAction func indexDidChangeForSegmentedControl(sender : UISegmentedControl) {
        //if this was a valid selection, update our delegate and update the menu
        if UISegmentedControlNoSegment != sender.selectedSegmentIndex {
            self.delegate.selectedSegment = self.meals.selectedSegmentIndex;
            self.updateVisibleMenu();
        }
    }
    
    @IBAction func backButtonPressed(sender : AnyObject) {
        if self.delegate.daysAdded > 0 {
            self.changeDayBy(-1)
            self.updateVisibleMenu()
        }
    }
    
    @IBAction func forwardButtonPressed(sender : AnyObject) {
        if self.delegate.daysAdded < 6 {
            self.changeDayBy(1)
            self.updateVisibleMenu()
        }
    }
    
    func changeDayBy(amount: NSInteger) {
        self.delegate.daysAdded += amount
        self.navBar!.topItem!.title = self.getTextForDaysAdded()
    }
    
    func isWeekday(dayOfWeek : NSInteger) -> Bool {
        return (dayOfWeek < 7 && dayOfWeek > 1);
    }
    
    func disableAllButtons() {
        self.backButton.enabled = false
        self.forwardButton.enabled = false
        self.meals.enabled = false
    }
    
    func makeCorrectButtonsVisible() {
        //handle visibility of back/foward
        self.backButton.enabled = true
        self.forwardButton.enabled = true
        if self.delegate.daysAdded == 6 {
            self.forwardButton.enabled = false
        }
        else if self.delegate.daysAdded == 0 {
            self.backButton.enabled = false
        }
        
        //disable/enable segmented buttons
        var date = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
        var formattedDate = Menus.formatDate(date)
        var offset = (formattedDate.lastObject as NSNumber).integerValue
        
        //insert/remove meals depending on day of the week
        if self.isWeekday(offset) {
            if self.meals.titleForSegmentAtIndex(0) != "Breakfast" {
                self.meals.removeSegmentAtIndex(0, animated: false)
                self.meals.insertSegmentWithTitle("Breakfast", atIndex: 0, animated: false)
                self.meals.insertSegmentWithTitle("Lunch",     atIndex: 1, animated: false)
                self.meals.selectedSegmentIndex = self.delegate.selectedSegment
            }
        } else {
            if self.meals.titleForSegmentAtIndex(0) != "Brunch" {
                self.meals.removeSegmentAtIndex(0, animated: false)
                self.meals.removeSegmentAtIndex(0, animated: false)
                self.meals.insertSegmentWithTitle("Brunch", atIndex: 0, animated: false)
                self.meals.selectedSegmentIndex = self.delegate.selectedSegment
            }
        }
        self.meals.enabled = true
    }
    
    func segmentIndexOfCurrentMeal() -> NSInteger {
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar.locale = NSLocale(localeIdentifier: "en-US");
        
        var today = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: NSDate())
        var weekday = today.weekday
        var hour    = today.hour
        
        if self.isWeekday(weekday) {
            if hour < 11 {
                return 0 //breakfast
            } else if hour < 14 {
                return 1 //lunch
            } else {
                return 2 //dinner
            }
        } else {
            if hour < 14 {
                return 0 //brunch
            } else {
                return 1 //dinner
            }
        }
    }
    
    func getTextForDaysAdded() -> NSString {
        if self.delegate.daysAdded == 0 {
            return "Today"
        } else if self.delegate.daysAdded == 1 {
            return "Tomorrow"
        } else {
            var newDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.stringFromDate(newDate)
        }
    }
    
    //UITableView delegate method, returns number of rows/meal items in a given section/course
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.courses.count {
            return self.courses[section].menuItems.count
        } else {
            return 0
        }
    }
    
    //UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let simpleTableIdentifier: NSString = "SimpleTableCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: simpleTableIdentifier)
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        if indexPath.section < self.courses.count {
            var course = self.courses[indexPath.section]
            if indexPath.row < course.menuItems.count {
                var this : MenuItem? = course.menuItems[indexPath.row]
                
                if let item = this {
                    cell!.textLabel!.text = item.name as NSString
                    cell!.textLabel!.numberOfLines = 0
                    
                    cell!.detailTextLabel!.text = item.descriptors
                    cell!.detailTextLabel!.textColor = UIColor.lightGrayColor()
                    
                    var favorited = Course.allFavoritedItems()
                    if favorited.containsObject(item.itemId) {
                        cell!.backgroundColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
                    } else {
                        cell!.backgroundColor = UIColor.whiteColor()
                    }
                    cell!.sizeToFit()
                }
            }
        }
        
        return cell!
    }
    
    //UITableView delegate method, returns name of section/course
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        if section < self.courses.count {
            var course = self.courses[section]
            return course.courseName
        } else {
            return "Other"
        }
    }
    
    //UITableView delegate method, what to do after side-swiping cell
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        //first, load in menu course this cell belongs to
        var course = self.courses[indexPath.section]
        //get item from course
        var item   = course.menuItems[indexPath.row]
        
        //load favorited items
        var favorited = Course.allFavoritedItems()
        
        //if this cell is NOT favorited, show favoriting action
        if !favorited.containsObject(item.itemId) {
            //create favoriting action
            var faveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
                title: "Favorite",
                handler: {
                    void in
                    //if item is favorited, save it to our centralized list of favorited items
                    Course.addToFavoritedItems(item.itemId)
                    //update styling of cell
                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
                    cell.backgroundColor = UIColor(red: 1, green: 0.84, blue:0, alpha:1)
                    tableView.setEditing(false, animated: true)
            })
            faveAction.backgroundColor = UIColor(red:1, green:0.84, blue:0, alpha:1)
            return [faveAction]
        } else {
            var unfaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
                title: "Remove",
                handler: {
                    void in
                    //otherwise if this cell is favorited, show un-favoriting action
                    Course.removeFromFavoritedItems(item.itemId)
                    //update styling of cell
                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
                    cell.backgroundColor = UIColor.whiteColor()
                    tableView.setEditing(false, animated: true)
            })
            unfaveAction.backgroundColor = UIColor.lightGrayColor()
            return [unfaveAction]
        }
    }
    
    //UITableView delegate method, needed because of bug in iOS 8 for now
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // No statement or algorithm is needed in here. Just the implementation
    }
    
    //UITableView delegate method, sets section header styles
    func tableView(tableView: UITableView!, willDisplayHeaderView view: UIView!, forSection section: Int) {
        var header = view as UITableViewHeaderFooterView
        header.textLabel.textColor = UIColor(red:0, green: 0.4, blue: 0.8, alpha: 1)
        header.textLabel.font = UIFont.boldSystemFontOfSize(12)
        header.contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
    
    //UITableView delegate method, creates animation when displaying cell
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
    }
    
    func divide (left: Double, right: Double) -> Double {
        return Double(left) / Double(right)
    }
    
    //UITableView delegate method, returns number of sections/courses in loaded menu
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.courses.count
    }
    
    //shares an invite to the currently browsed meal
    func inviteToMeal() {
        var invite = [AnyObject]()
        invite.append("Let's get \(self.meals.titleForSegmentAtIndex(self.meals.selectedSegmentIndex)!.lowercaseString) at Moulton \(self.getTextForDaysAdded().lowercaseString)?")
        
        let activityViewController = UIActivityViewController(activityItems: invite, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    //handles all logic related to updating the tableView with new menu items
    func updateVisibleMenu() {
        //creates date based on days added to current day, saves to delegate
        var date = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
        var formattedDate = Menus.formatDate(date)
        self.delegate.day    = formattedDate[0] as NSInteger
        self.delegate.month  = formattedDate[1] as NSInteger
        self.delegate.year   = formattedDate[2] as NSInteger
        self.delegate.offset = formattedDate[3] as NSInteger
        
        //firstly, remove everything from the UITableView
        self.courses.removeAll(keepCapacity: false)
        self.menuItems.reloadData()
        
        //disable user interaction and begin loading indicator
        self.disableAllButtons()
        self.loading.startAnimating()
        self.menuItems.beginUpdates()
        
        //create a new thread...
        var downloadQueue = dispatch_queue_create("Download queue", nil);
        dispatch_async(downloadQueue) {
            //in new thread, load menu for this day
            var xml = Menus.loadMenuForDay(self.delegate.day, month: self.delegate.month, year: self.delegate.year, offset: self.delegate.offset)
            //go back to main thread
            dispatch_async(dispatch_get_main_queue()) {
                //if the response was nil, handle
                if xml == nil {
                    self.loading.stopAnimating()
                    self.menuItems.endUpdates()
                    self.menuItems.setContentOffset(CGPointZero, animated: true)
                    
                    var alert = UIAlertView(title: "Network Error",
                        message: "Sorry, we could not load the menu at this time. Check your network connection and try again later.",
                        delegate: self,
                        cancelButtonTitle: "OK")
                    alert.show()
                    
                    self.makeCorrectButtonsVisible()
                }
                    //else we successfully loaded XML!
                else {
                    //create a menu from this data and save it to delegate
                    self.courses = Menus.createMenuFromXML(xml!,
                        forMeal:     self.meals.selectedSegmentIndex,
                        onWeekday:   self.isWeekday(self.delegate.offset),
                        atLocation:  self.delegate.moultonId,
                        withFilters: self.delegate.filters)
                    
                    //insert new menu items to UITableView
                    var newSet   = NSMutableIndexSet()
                    newSet.addIndexesInRange(NSMakeRange(0, self.courses.count))
                    self.menuItems.insertSections(newSet, withRowAnimation:UITableViewRowAnimation.Right)
                    
                    //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
                    self.loading.stopAnimating()
                    self.menuItems.endUpdates()
                    self.menuItems.setContentOffset(CGPointZero, animated: true)
                    
                    self.makeCorrectButtonsVisible()
                }
            }
        }
    }
    
    //UITableView delegate method, creates animation when displaying cell; removed, not popular
    func animateIn(this : UIView) {
        var init_angle : Double = divide(90*M_PI, right: 180)
        var rotation = CATransform3DMakeRotation(CGFloat(init_angle), 0.0, 0.7, 0.4) as CATransform3D
        rotation.m34 = (-1.0/600.0)
        
        this.layer.shadowColor = UIColor.blackColor().CGColor
        this.layer.shadowOffset = CGSizeMake(10, 10)
        this.layer.opacity = 0
        
        this.layer.transform = rotation
        this.layer.anchorPoint = CGPointMake(0, 0.5)
        
        if this.layer.position.x != 0 {
            this.layer.position = CGPointMake(0, this.layer.position.y);
        }
        
        UIView.beginAnimations("rotation",  context: nil)
        UIView.setAnimationDuration(0.4)
        this.layer.transform = CATransform3DIdentity
        this.layer.opacity = 1
        this.layer.shadowOffset = CGSizeMake(0, 0)
        UIView.commitAnimations()
    }
    
    
    //Uses TTS to speak menus aloud; potential future use
    func speakMenu() {
        var menu = "For "+self.meals.titleForSegmentAtIndex(self.delegate.selectedSegment)!+" "+self.getTextForDaysAdded()+" at Moulton we have "
        for course in self.courses {
            for item in course.menuItems {
                if item == course.menuItems.last && course == self.courses.last {
                    menu += "and "+item.name+". "
                } else {
                    menu += item.name+", "
                }
            }
        }
        
        var speaker = AVSpeechSynthesizer()
        var phrase = AVSpeechUtterance(string: menu)
        phrase.rate = 0.15
        speaker.speakUtterance(phrase)
    }
}