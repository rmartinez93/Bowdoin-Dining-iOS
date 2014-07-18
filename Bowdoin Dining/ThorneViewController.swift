////
////  ThorneViewController.swift
////  Bowdoin Dining
////
////  Created by Ruben on 7/17/14.
////
////
//
//import UIKit
//
//class ThorneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    var delegate = UIApplication.sharedApplication().delegate as AppDelegate
//    var courses = NSMutableArray()
//    
//    @IBOutlet var menuItems : UITableView
//    @IBOutlet var loading   : UIActivityIndicatorView
//    @IBOutlet var meals     : UISegmentedControl
//    @IBOutlet var dayLabel  : UILabel
//    @IBOutlet var backButton    : UIButton
//    @IBOutlet var forwardButton : UIButton
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        var splash = SplashView(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
//        splash.backgroundColor = UIColor.blackColor()
//        self.view.addSubview(splash)
//        
//        //set selected segment to current meal on launch
//        self.meals.selectedSegmentIndex = self.segmentIndexOfCurrentMeal(NSDate())
//        //share selected segment between Moulton/Thorne
//        self.delegate.selectedSegment = self.meals.selectedSegmentIndex
//        
//        //style
//        self.tabBarController.tabBar.barStyle = UIBarStyle.Black
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        //show status bar
//        UIApplication.sharedApplication().statusBarHidden = false;
//        
//        //set the text label to day we're browsing
//        self.dayLabel.text = self.getTextForCurrentDay();
//        
//        //update selected segment in case changed elsewhere
//        self.meals.selectedSegmentIndex = self.delegate.selectedSegment;
//        
//        //if day is today, hide the back button
//        if self.delegate.daysAdded == 0 {
//            self.backButton.hidden = true;
//        }
//        //if day is a week from now, hide forward button
//        else if self.delegate.daysAdded == 6 {
//            self.forwardButton.hidden = true;
//        }
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        //load menu based on delegate settings
//        self.updateVisibleMenu();
//    }
//    
//    @IBAction func indexDidChangeForSegmentedControl(sender : UISegmentedControl) {
//        //if this was a valid selection, update our delegate and update the menu
//        if (UISegmentedControlNoSegment != sender.selectedSegmentIndex) {
//            self.delegate.selectedSegment = self.meals.selectedSegmentIndex;
//            self.updateVisibleMenu();
//        }
//    }
//    
//    @IBAction func backButtonPressed(sender : UIButton) {
//        if self.delegate.daysAdded > 0 {
//            self.delegate.daysAdded--;
//            if self.delegate.daysAdded == 0 {
//                self.backButton.hidden = true;
//            } else if delegate.daysAdded == 5 {
//                self.forwardButton.hidden = false;
//            }
//            
//            self.updateVisibleMenu()
//            
//            var textWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
//            var center    = self.dayLabel.center
//            UIView.animateWithDuration(0.5,
//                animations: {
//                    self.dayLabel.alpha = 0
//                    self.dayLabel.center = CGPointMake(320+(textWidth/2), self.dayLabel.center.y)
//                }, completion: {
//                    (value: Bool) in
//                    self.dayLabel.text = self.getTextForCurrentDay()
//                    var newWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
//                    self.dayLabel.center = CGPointMake(0-(newWidth/2), self.dayLabel.center.y)
//                    UIView.animateWithDuration(0.2,
//                        animations: {
//                            self.dayLabel.alpha = 1
//                            self.dayLabel.center = center
//                        }, completion: {
//                            (value: Bool) in
//                        })
//                })
//        }
//    }
//    
//    @IBAction func forwardButtonPressed(sender : UIButton) {
//        if self.delegate.daysAdded < 6 {
//            self.delegate.daysAdded++;
//            if self.delegate.daysAdded == 6 {
//                self.forwardButton.hidden = true;
//            } else if delegate.daysAdded == 1 {
//                self.backButton.hidden = false;
//            }
//            
//            var textWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
//            var center    = self.dayLabel.center
//            UIView.animateWithDuration(0.5,
//                animations: {
//                    self.dayLabel.alpha = 0
//                    self.dayLabel.center = CGPointMake(0-(textWidth/2), self.dayLabel.center.y)
//                }, completion: {
//                    (value: Bool) in
//                    self.updateVisibleMenu()
//                    self.dayLabel.text = self.getTextForCurrentDay()
//                    var newWidth = (self.dayLabel.text as NSString).sizeWithAttributes([NSFontAttributeName:self.dayLabel.font]).width
//                    self.dayLabel.center = CGPointMake(320+(newWidth/2), self.dayLabel.center.y)
//                    UIView.animateWithDuration(0.2,
//                        animations: {
//                            self.dayLabel.alpha = 1
//                            self.dayLabel.center = center
//                        }, completion: {
//                            (value: Bool) in
//                        })
//                })
//        }
//    }
//    
//    func segmentIndexOfCurrentMeal(now: NSDate) -> NSInteger {
//        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
//        calendar.locale = NSLocale(localeIdentifier: "en-US");
//        
//        var today = calendar.components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: now)
//        var weekday = today.weekday
//        var hour    = today.hour
//        
//        if(hour < 11 && weekday > 1 && weekday < 7) {
//            return 0; //breakfast
//        } else if(hour < 14) {
//            if(weekday == 1 || weekday == 7) {
//                return 1; //brunch
//            } else {
//                return 2; //lunch
//            }
//        } else {
//            return 4; //dinner
//        }
//    }
//    
//    func getTextForCurrentDay() -> NSString {
//        if(self.delegate.daysAdded == 0) {
//            return "Today"
//        } else if(self.delegate.daysAdded == 1) {
//            return "Tomorrow"
//        } else {
//            var newDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
//            var dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "EEEE"
//            return dateFormatter.stringFromDate(newDate)
//        }
//    }
//    
//    //UITableView delegate method, returns number of rows/meal items in a given section/course
//    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        if(section < self.courses.count) {
//            var courseObj : AnyObject! = self.courses.objectAtIndex(section)
//            var course = courseObj as Course
//            return course.items.count
//        } else {
//            return 0
//        }
//    }
//    
//    //UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
//    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
//        let simpleTableIdentifier: NSString = "SimpleTableCell"
//
//        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as UITableViewCell
//        
//        if(cell == nil) {
//            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: simpleTableIdentifier)
//        }
//        
//        if(indexPath.section < self.courses.count) {
//            var course = self.courses.objectAtIndex(indexPath.section) as Course
//            if(course != nil && indexPath.row < course.items.count) {
//                cell.textLabel.text = course.items.objectAtIndex(indexPath.row) as NSString
//                if cell.detailTextLabel {
//                    cell.detailTextLabel!.text = course.descriptions.objectAtIndex(indexPath.row) as NSString
//                    cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
//                }
//                
//                var favorited = Course.allFavoritedItems()
//                var itemId    = course.itemIds.objectAtIndex(indexPath.row) as NSString
//                if(favorited.containsObject(itemId)) {
//                    cell.backgroundColor = UIColor(red: 1, green: 0.84, blue: 0, alpha: 1)
//                } else {
//                    cell.backgroundColor = UIColor.whiteColor()
//                }
////                cell.textLabel.numberOfLines = 0;
//                cell.textLabel.sizeToFit()
//            }
//        }
//        
//        return cell;
//    }
//    
//    //UITableView delegate method, sets section header styles
//    func tableView(tableView: UITableView!, willDisplayHeaderView view: UIView, forSection section: Int) {
//        var header = UITableViewHeaderFooterView()
//        header.textLabel.textColor = UIColor(red:0, green: 0.4, blue: 0.8, alpha: 1)
//        header.contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
//    }
//    
//    //UITableView delegate method, returns name of section/course
//    func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String! {
//        if(section < self.courses.count) {
//            var course = self.courses.objectAtIndex(section) as Course
//            return course.courseName
//        } else {
//            return "Other"
//        }
//    }
//   
//    //UITableView delegate method, what to do after side-swiping cell
//    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> AnyObject[]!{
//        //first, load in menu course this cell belongs to
//        var course = self.courses.objectAtIndex(indexPath.section) as Course
//        //get item from course
//        var item   = course.itemIds.objectAtIndex(indexPath.row) as NSString
//        
//        //load favorited items
//        var favorited = Course.allFavoritedItems()
//        
//        //if this cell is NOT favorited, show favoriting action
//        if !favorited.containsObject(item) {
//            //create favoriting action
//            var faveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
//                title: "Favorite",
//                handler: {
//                    void in
//                    //if item is favorited, save it to our centralized list of favorited items
//                    Course.addToFavoritedItems(item)
//                    //update styling of cell
//                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
//                    cell.backgroundColor = UIColor(red: 1, green: 0.84, blue:0, alpha:1)
//                    tableView.setEditing(false, animated: true)
//                    
//                })
//            faveAction.backgroundColor = UIColor(red:1, green:0.84, blue:0, alpha:1)
//            return [faveAction]
//        } else {
//            var unfaveAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default,
//                title: "Remove",
//                handler: {
//                    void in
//                    //otherwise if this cell is favorited, show un-favoriting action
//                    Course.addToFavoritedItems(item)
//                    //update styling of cell
//                    var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
//                    cell.backgroundColor = UIColor.whiteColor()
//                    tableView.setEditing(false, animated: true)
//                })
//            unfaveAction.backgroundColor = UIColor.lightGrayColor()
//            return [unfaveAction]
//        }
//    }
//    
//    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
//    
//    }
//    
//    //UITableView delegate method, creates animation when displaying cell
////    func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell, forRowAtIndexPath path: NSIndexPath) {
////        var rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
////        rotation.m34 = 1.0/ -600
////        
////    }
//    //    -(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    //    //1. Setup the CATransform3D structure
//    //    CATransform3D rotation;
//    //    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    //    rotation.m34 = 1.0/ -600;
//    ////2. Define the initial state (Before the animation)
//    //    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    //    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    //    cell.alpha = 0;
//    //
//    //    cell.layer.transform = rotation;
//    //    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    //
//    //    //3. Define the final state (After the animation) and commit the animation
//    //    [UIView beginAnimations:@"rotation" context:NULL];
//    //    [UIView setAnimationDuration:0.8];
//    //    cell.layer.transform = CATransform3DIdentity;
//    //    cell.alpha = 1;
//    //    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    //    [UIView commitAnimations];
//    //    }
//    
//    //UITableView delegate method, returns number of sections/courses in loaded menu
//    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
//        return self.courses.count
//    }
//    
//    //handles all logic related to updating the tableView with new menu items
//    func updateVisibleMenu() {
//        //creates date based on days added to current day, saves to delegate
//        var date = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
//        var formattedDate = Menus.formatDate(date)
//        self.delegate.day    = formattedDate[0] as NSInteger
//        self.delegate.month  = formattedDate[1] as NSInteger
//        self.delegate.year   = formattedDate[2] as NSInteger
//        self.delegate.offset = formattedDate[3] as NSInteger
//        
//        //firstly, remove everything from the UITableView
//        var originalRange = NSMakeRange(0, self.courses.count)
//        self.menuItems.beginUpdates()
//        self.menuItems.deleteSections(NSIndexSet(indexesInRange: originalRange), withRowAnimation: UITableViewRowAnimation.Right)
//        self.courses.removeAllObjects()
//        
//        //disable user interaction on segmented control and begin loading indicator
//        self.meals.userInteractionEnabled = false
//        self.loading.startAnimating()
//        
//        //create a new thread...
//        var downloadQueue = dispatch_queue_create("Download queue", nil);
//        dispatch_async(downloadQueue) {
//            //in new thread, load menu for this day
//            var xml = Menus.loadMenuForDay(self.delegate.day, month: self.delegate.month, year: self.delegate.year, offset: self.delegate.offset)
//            //go back to main thread
//            dispatch_async(dispatch_get_main_queue()) {
//                //if the response was nil, handle
//                if(xml == nil) {
//                    self.loading.stopAnimating()
//                    self.menuItems.reloadData()
//                    var alert = UIAlertController(title: "Network Error", message: "Sorry, we couldn't get the menu at this time. Check your internet connection or try again later.", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//                //else we successfully loaded XML!
//                else {
//                    //create a menu from this data and save it to delegate
//                    self.courses = Menus.createMenuFromXML(xml, forMeal: self.meals.selectedSegmentIndex, atLocation: self.delegate.thorneId, withFilters: self.delegate.filters)
//
//                    //insert new menu items to UITableView
//                    var newSet   = NSMutableIndexSet()
//                    newSet.addIndexesInRange(NSMakeRange(0, self.courses.count))
//                    self.menuItems.insertSections(newSet, withRowAnimation:UITableViewRowAnimation.Right)
//
//                    //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
//                    self.loading.stopAnimating()
//                    self.menuItems.endUpdates()
//                    self.menuItems.setContentOffset(CGPointZero, animated: true)
//                    self.meals.userInteractionEnabled = true;
//                }
//            }
//        }
//    }
//}
