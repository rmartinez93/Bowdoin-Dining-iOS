//
//  MoultonViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/17/14.
//
//

import UIKit
import QuartzCore

class MoultonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
    var courses = NSMutableArray()
    
    @IBOutlet var menuItems : UITableView!
    @IBOutlet var loading   : UIActivityIndicatorView!
    @IBOutlet var meals     : UISegmentedControl!
    @IBOutlet var dayLabel  : UILabel!
    @IBOutlet var backButton    : UIButton!
    @IBOutlet var forwardButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //show status bar
        UIApplication.sharedApplication().statusBarHidden = false;
        
        //set the text label to day we're browsing
        self.dayLabel.text = self.getTextForCurrentDay();
        
        //update selected segment in case changed elsewhere
        self.meals.selectedSegmentIndex = self.delegate.selectedSegment;
        
        //verify correct buttons are showing
        self.makeCorrectButtonsVisible()
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
    
    @IBAction func backButtonPressed(sender : UIButton) {
        if self.delegate.daysAdded > 0 {
            self.delegate.daysAdded--;
            self.makeCorrectButtonsVisible()
            
            var textWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
            var center    = self.dayLabel.center
            UIView.animateWithDuration(0.2,
                animations: {
                    self.dayLabel.alpha = 0
                    self.dayLabel.center = CGPointMake(320+(textWidth/2), self.dayLabel.center.y)
                }, completion: {
                    (value: Bool) in
                    self.updateVisibleMenu()
                    self.dayLabel.text = self.getTextForCurrentDay()
                    var newWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
                    self.dayLabel.center = CGPointMake(0-(newWidth/2), self.dayLabel.center.y)
                    UIView.animateWithDuration(0.1,
                        animations: {
                            self.dayLabel.alpha = 1
                            self.dayLabel.center = center
                        }, completion: {
                            (value: Bool) in
                        })
                })
        }
    }
    
    @IBAction func forwardButtonPressed(sender : UIButton) {
        if self.delegate.daysAdded < 6 {
            self.delegate.daysAdded++;
            self.makeCorrectButtonsVisible()
            
            var textWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
            var center    = self.dayLabel.center
            
            UIView.animateWithDuration(0.2,
                animations: {
                    self.dayLabel.alpha = 0
                    self.dayLabel.center = CGPointMake(0-(textWidth/2), self.dayLabel.center.y)
                }, completion: {
                    (value: Bool) in
                    self.updateVisibleMenu()
                    self.dayLabel.text = self.getTextForCurrentDay()
                    var newWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
                    self.dayLabel.center = CGPointMake(320+(newWidth/2), self.dayLabel.center.y)
                    UIView.animateWithDuration(0.1,
                        animations: {
                            self.dayLabel.alpha = 1
                            self.dayLabel.center = center
                        }, completion: {
                            (value: Bool) in
                        })
                })
        }
    }
    
    func makeCorrectButtonsVisible() {
        if self.delegate.daysAdded == 6 {
            self.forwardButton.hidden = true;
        }
        else if self.delegate.daysAdded == 0 {
            self.backButton.hidden = true;
        }
        else {
            self.backButton.hidden = false;
            self.forwardButton.hidden = false;
        }
    }
    
    func segmentIndexOfCurrentMeal(now: NSDate) -> NSInteger {
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar.locale = NSLocale(localeIdentifier: "en-US");
        
        var today = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: now)
        var weekday = today.weekday
        var hour    = today.hour
        
        if hour < 11 && weekday > 1 && weekday < 7 {
            return 0; //breakfast
        } else if hour < 14 {
            if weekday == 1 || weekday == 7 {
                return 1; //brunch
            } else {
                return 2; //lunch
            }
        } else {
            return 4; //dinner
        }
    }
    
    func getTextForCurrentDay() -> NSString {
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
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section < self.courses.count {
            var courseObj : AnyObject! = self.courses.objectAtIndex(section)
            var course = courseObj as Course
            return course.menuItems.count
        } else {
            return 0
        }
    }
    
    //UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let simpleTableIdentifier: NSString = "SimpleTableCell2"
        
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: simpleTableIdentifier)
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        if indexPath.section < self.courses.count {
            var course = self.courses.objectAtIndex(indexPath.section) as Course
            if indexPath.row < course.menuItems.count {
                var item = course.menuItems.objectAtIndex(indexPath.row) as MenuItem
                
                if item != nil {
                    cell.textLabel.text = item.name as NSString
                    if cell.detailTextLabel {
                        cell.detailTextLabel!.text = item.descriptors
                        cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
                    }
                    
                    var favorited = Course.allFavoritedItems()
                    if favorited.containsObject(item.itemId) {
                        cell.backgroundColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
                    } else {
                        cell.backgroundColor = UIColor.whiteColor()
                    }
                    cell.textLabel.sizeToFit()
                }
            }
        }
        
        return cell;
    }
    
    //UITableView delegate method, returns name of section/course
    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
        if section < self.courses.count {
            var course = self.courses.objectAtIndex(section) as Course
            return course.courseName
        } else {
            return "Other"
        }
    }
    
    //UITableView delegate method, what to do after side-swiping cell
    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
        //first, load in menu course this cell belongs to
        var course = self.courses.objectAtIndex(indexPath.section) as Course
        //get item from course
        var item   = course.menuItems.objectAtIndex(indexPath.row) as MenuItem
        
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
                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
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
                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
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
        var header = UITableViewHeaderFooterView()
        header.textLabel.textColor = UIColor(red:0, green: 0.4, blue: 0.8, alpha: 1)
        header.contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)

//        self.animateIn(header)
    }
    
    //UITableView delegate method, creates animation when displaying cell
    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!) {
//        self.animateIn(cell)
    }
    
    func divide (left: Double, right: Double) -> Double {
        return Double(left) / Double(right)
    }
    
    //UITableView delegate method, creates animation when displaying cell
    func animateIn(view : UIView) {
        var init_angle : Double = divide(90*M_PI, right: 180)
        var rotation = CATransform3DMakeRotation(CGFloat(init_angle), 0.0, 0.7, 0.4) as CATransform3D
        rotation.m34 = (-1.0/600.0)
        
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(10, 10)
        view.layer.opacity = 0
        
        view.layer.transform = rotation
        view.layer.anchorPoint = CGPointMake(0, 0.5)
        
        if view.layer.position.x != 0 {
            view.layer.position = CGPointMake(0, view.layer.position.y);
        }
        
        UIView.beginAnimations("rotation", context: nil)
        UIView.setAnimationDuration(0.8)
        view.layer.transform = CATransform3DIdentity
        view.layer.opacity = 1
        view.layer.shadowOffset = CGSizeMake(0, 0)
    }
    
    //UITableView delegate method, returns number of sections/courses in loaded menu
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return self.courses.count
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
        self.courses.removeAllObjects()
        self.menuItems.reloadData()
        
        //disable user interaction on segmented control and begin loading indicator
        self.meals.userInteractionEnabled = false
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
                    self.menuItems.reloadData()
                    var alert = UIAlertController(title: "Network Error",
                        message: "Sorry, we couldn't get the menu at this time. Check your internet connection or try again later.",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK",
                        style: UIAlertActionStyle.Default,
                        handler: nil))
                    self.presentViewController(alert,
                        animated: true,
                        completion: nil)
                }
                    //else we successfully loaded XML!
                else {
                    //create a menu from this data and save it to delegate
                    self.courses = Menus.createMenuFromXML(xml,
                        forMeal: self.meals.selectedSegmentIndex,
                        atLocation: self.delegate.moultonId,
                        withFilters: self.delegate.filters)
                    
                    //insert new menu items to UITableView
                    var newSet   = NSMutableIndexSet()
                    newSet.addIndexesInRange(NSMakeRange(0, self.courses.count))
                    self.menuItems.insertSections(newSet, withRowAnimation:UITableViewRowAnimation.Right)
                    
                    //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
                    self.loading.stopAnimating()
                    self.menuItems.endUpdates()
                    self.menuItems.setContentOffset(CGPointZero, animated: true)
                    self.meals.userInteractionEnabled = true;
                }
            }
        }
    }
}
