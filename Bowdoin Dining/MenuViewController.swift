//
//  MenuViewController.swift
//  Bowdoin Dining
//
//  Created by Ruben on 4/22/15.
//
//

import UIKit
import QuartzCore
import AVFoundation

class MenuViewController: UIViewController, UITableViewDelegate, UITabBarControllerDelegate, UITableViewDataSource, UINavigationBarDelegate, AVSpeechSynthesizerDelegate, UIMenuItemViewDelegate {
    var delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var courses : [Course] = []
    var favoritesData : [String : Int] = [:]
    var speaker : AVSpeechSynthesizer?
    var diningHallName : String?
    
    @IBOutlet var navBar    : UINavigationBar!
    @IBOutlet var menuItems : UITableView!
    @IBOutlet var loading   : UIActivityIndicatorView!
    @IBOutlet var meals     : UISegmentedControl!
    @IBOutlet var backButton    : UIBarButtonItem!
    @IBOutlet var forwardButton : UIBarButtonItem!
    @IBOutlet var speakButton   : UIButton!
    @IBOutlet var businessLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Menus.clearOldCache()
        
        if self.view.tag == self.delegate.thorneId {            
            //set selected segment to current meal on launch
            self.meals.selectedSegmentIndex = self.segmentIndexOfCurrentMeal()
            
            //share selected segment between Moulton/Thorne
            self.delegate.selectedSegment = self.meals.selectedSegmentIndex
        } else {
            
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.TopAttached
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        if speaker != nil {
            speaker!.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
            dispatch_async(dispatch_get_main_queue()) {
                self.speakButton.setImage(UIImage(named: "speaker"), forState: UIControlState.Normal)
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //set the text label to day we're browsing
        self.navBar.topItem!.title = self.getTextForDaysAdded() as String
        
        //update selected segment in case changed elsewhere
        self.meals.selectedSegmentIndex = self.delegate.selectedSegment
        
        //verify correct buttons are showing
        self.makeCorrectButtonsVisible()
        
        //fixes issue with last item not showing, but keeps translucency
        self.menuItems.contentInset.bottom = 50
        
        //checks if lines loaded, updates UI
        if self.delegate.lineDataLoaded {
            self.linesDidLoad()
        }
        
        //tell VC to watch for success notifications from User obj, in case lines not loaded
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "linesDidLoad",
            name: "LinesFinishedLoading",
            object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        //load menu based on delegate settings
        self.updateVisibleMenu()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if !defaults.boolForKey("ShownLineDataTutorial") {
            let alert = UIAlertController(title: "New Feature", message: "The Bowdoin Dining & OneCard app will now let you know if there's a line at either dining hall! Simply tap into the 'Thorne' or 'Moulton' tabs at the bottom—They will turn green if there's a short line, yellow if the dining hall is busy, or red if it's very busy. You must be signed in under the 'Accounts' tab to use this feature!", preferredStyle: UIAlertControllerStyle.Alert)
            
            let okay = UIAlertAction(title: "Okay!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                defaults.setBool(true, forKey: "ShownLineDataTutorial")
            })
            
            alert.addAction(okay)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func indexDidChangeForSegmentedControl(sender : UISegmentedControl) {
        //if this was a valid selection, update our delegate and update the menu
        if UISegmentedControlNoSegment != sender.selectedSegmentIndex {
            self.delegate.selectedSegment = self.meals.selectedSegmentIndex
            self.updateVisibleMenu()
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
    
    func getTextForDaysAdded() -> String {
        if self.delegate.daysAdded == 0 {
            return "Today"
        } else if self.delegate.daysAdded == 1 {
            return "Tomorrow"
        } else {
            let newDate = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.stringFromDate(newDate)
        }
    }
    
    func changeDayBy(amount: NSInteger) {
        self.delegate.daysAdded += amount
        self.navBar!.topItem!.title = self.getTextForDaysAdded() as String
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
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
        let formattedDate = Menus.formatDate(date)
        let offset = (formattedDate.lastObject as! NSNumber).integerValue
        
        //insert/remove meals depending on day of the week
        if isWeekday(offset) {
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
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en-US");
        
        let today = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Weekday], fromDate: NSDate())
        let weekday = today.weekday
        let hour    = today.hour
        
        if isWeekday(weekday) {
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
        let simpleTableIdentifier = "BasicCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(simpleTableIdentifier) as! UIMenuItemView!
        
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("UIMenuItemView", owner: self, options: nil).first as! UIMenuItemView
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        if indexPath.section < self.courses.count {
            let course = self.courses[indexPath.section]
            if indexPath.row < course.menuItems.count {
                let this : MenuItem? = course.menuItems[indexPath.row]
                
                if let item = this {
                    cell!.title!.text = item.name
                    
                    cell!.detail!.text = item.descriptors
                    cell!.detail!.textColor = UIColor.lightGrayColor()
                    
                    let faveCount = self.favoritesData[item.itemId] != nil
                        ? self.favoritesData[item.itemId]! : 0
                    
                    let allFavorited = Course.allFavoritedItems()
                    var favorited = false;
                    if allFavorited.containsObject(item.itemId) {
                        favorited = true;
                    }
                    
                    cell!.initData(faveCount, favorited: favorited, itemId: item.itemId, delegate: self)
                    
                    cell!.sizeToFit()
                }
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let course = self.courses[indexPath.section]
        if indexPath.row < course.menuItems.count {
            let this : MenuItem? = course.menuItems[indexPath.row]
            if let item = this {
                let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
                    NSStringDrawingOptions.UsesFontLeading.rawValue,
                    NSStringDrawingOptions.self)
                
                let screenSize: CGRect = UIScreen.mainScreen().bounds
                
                let textAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
                let nameSize = (item.name as NSString).boundingRectWithSize(CGSizeMake(screenSize.width - 80, CGFloat.max), options: options, attributes: textAttributes, context: nil)
                
                let descSize = (item.descriptors as NSString).boundingRectWithSize(CGSizeMake(screenSize.width, CGFloat.max), options: options, attributes: textAttributes, context: nil)
                
                return nameSize.height + descSize.height + 5
            }
        }
        
        return 0
    }
    
    //UITableView delegate method, returns name of section/course
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < self.courses.count {
            let course = self.courses[section]
            return course.courseName
        } else {
            return "Other"
        }
    }
    
    //UITableView delegate method, needed because of bug in iOS 8 for now
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // No statement or algorithm is needed in here. Just the implementation
    }
    
    //UITableView delegate method, sets section header styles
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor(red:0, green: 0.4, blue: 0.8, alpha: 1)
        header.textLabel!.font = UIFont.boldSystemFontOfSize(12)
        header.contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
    
    //UITableView delegate method, creates animation when displaying cell
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont.systemFontOfSize(16)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
    }
    
    //UITableView delegate method, returns number of sections/courses in loaded menu
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.courses.count
    }
    
    //shares an invite to the currently browsed meal
    @IBAction func inviteToMeal() {
        var invite = [AnyObject]()
        invite.append("Let's get \(self.meals.titleForSegmentAtIndex(self.meals.selectedSegmentIndex)!.lowercaseString) at \(BowdoinAPIParser.nameOfDiningHallWithId(self.view.tag)) \(self.getTextForDaysAdded())?")
        
        let activityViewController = UIActivityViewController(activityItems: invite, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    //handles all logic related to updating the tableView with new menu items
    func updateVisibleMenu() {
        self.prepareForMenuLoad();
        
        self.loadMenu({ (xml) -> () in
            //handle incorrectly loaded menu
            if xml == nil {
                self.menuLoadFailed();
            }
            //else we successfully loaded XML!
            else {
                self.presentMenu(xml!);
            }
        })
    }
    
    func prepareForMenuLoad() {
        //creates date based on days added to current day, saves to delegate
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(60*60*24*self.delegate.daysAdded))
        let formattedDate = Menus.formatDate(date)
        self.delegate.day    = formattedDate[0] as! NSInteger
        self.delegate.month  = formattedDate[1] as! NSInteger
        self.delegate.year   = formattedDate[2] as! NSInteger
        self.delegate.offset = formattedDate[3] as! NSInteger
        
        //firstly, remove everything from the UITableView
        self.courses.removeAll(keepCapacity: false)
        self.menuItems.reloadData()
        
        //disable user interaction and begin loading indicator
        self.disableAllButtons()
        self.loading.startAnimating()
        self.menuItems.beginUpdates()
    }
    
    func loadMenu(callback: (NSData?) -> ()) {
        //create a new thread...
        let downloadQueue = dispatch_queue_create("Download queue", nil);
        dispatch_async(downloadQueue) {
            //in new thread, load menu for this day
            let xml = Menus.loadMenuForDay(self.delegate.day, month: self.delegate.month, year: self.delegate.year, offset: self.delegate.offset)
            //go back to main thread
            dispatch_async(dispatch_get_main_queue()) {
                callback(xml);
            }
        }

    }
    
    func menuLoadFailed() {
        //update the buttons
        self.makeCorrectButtonsVisible()
        
        let error = Course()
        error.courseName = "No Menu Available"
        
        self.courses = [error]
        
        //insert new menu items to UITableView
        let newSet   = NSMutableIndexSet()
        newSet.addIndexesInRange(NSMakeRange(0, self.courses.count))
        self.menuItems.insertSections(newSet, withRowAnimation:UITableViewRowAnimation.Right)
        
        //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
        self.loading.stopAnimating()
        self.menuItems.endUpdates()
        self.menuItems.setContentOffset(CGPointZero, animated: true)
    }
    
    func presentMenu(xml : NSData) {
        //update the buttons
        self.makeCorrectButtonsVisible()
        
        //create a new thread...
        let downloadQueue = dispatch_queue_create("Download queue", nil);
        dispatch_async(downloadQueue) {
            //create a menu from this data and save it to delegate
            let menuData = Menus.createMenuFromXML(xml,
                forMeal:     self.meals.selectedSegmentIndex,
                onWeekday:   isWeekday(self.delegate.offset),
                atLocation:  self.view.tag,
                withFilters: self.delegate.filters)
            
            self.courses = menuData.courses
            self.favoritesData = menuData.favoritesData
            
            dispatch_async(dispatch_get_main_queue()) {
                //insert new menu items to UITableView
                let newSet   = NSMutableIndexSet()
                newSet.addIndexesInRange(NSMakeRange(0, self.courses.count))
                self.menuItems.insertSections(newSet, withRowAnimation:UITableViewRowAnimation.Right)
                
                //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
                self.loading.stopAnimating()
                self.menuItems.endUpdates()
                self.menuItems.setContentOffset(CGPointZero, animated: true)
            }
        }
    }
    
    //UITableView delegate method, creates animation when displaying cell; removed, not popular
    func animateIn(this : UIView) {
        let init_angle : Double = divide(90*M_PI, right: 180)
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
    
    //Uses TTS to speak menus aloud
    @IBAction func speakMenu() {
        if speaker != nil {
            if speaker!.speaking {
                speaker!.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
                dispatch_async(dispatch_get_main_queue()) {
                    self.speakButton.setImage(UIImage(named: "speaker"), forState: UIControlState.Normal)
                }
                return
            }
        } else {
            speaker = AVSpeechSynthesizer()
            speaker!.delegate = self
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.speakButton.setImage(UIImage(named: "speaker_active"), forState: UIControlState.Normal)
        }
        
        var menu = "For "+self.meals.titleForSegmentAtIndex(self.delegate.selectedSegment)!+" "+(self.getTextForDaysAdded())+" at \(BowdoinAPIParser.nameOfDiningHallWithId(self.view.tag)) we have "
        for course in self.courses {
            for item in course.menuItems {
                if item == course.menuItems.last && course == self.courses.last {
                    menu += "and "+item.name+". "
                } else {
                    menu += item.name+", "
                }
            }
        }
        
        let phrase = AVSpeechUtterance(string: menu)
        phrase.rate = 0.18
        speaker!.speakUtterance(phrase)
    }
    
    //resets speech button color when finished
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        dispatch_async(dispatch_get_main_queue()) {
            self.speakButton.setImage(UIImage(named: "speaker"), forState: UIControlState.Normal)
        }
    }
    
    //displays line data if loaded
    func linesDidLoad() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                if self.view.tag == self.delegate.thorneId {
                    (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = self.delegate.thorneColor!
                } else if self.view.tag == self.delegate.moultonId {
                    (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = self.delegate.moultonColor!
                }
            })
        }
    }
    
    func toggleFavorite(itemId: String) {
        //load favorited items
        let allFavorited = Course.allFavoritedItems()
        
        var endpoint = "http://bowdoindining.meteor.com/methods/"
        //if this cell is NOT favorited, show favoriting action
        if !allFavorited.containsObject(itemId) {
            //if item is favorited, save it to our centralized list of favorited items
            Course.addToFavoritedItems(itemId)
            endpoint += "favorite"
        } else {
            Course.removeFromFavoritedItems(itemId)
            endpoint += "unfavorite"
        }
        
        //create a new thread...
        let downloadQueue = dispatch_queue_create("Download queue", nil);
        dispatch_async(downloadQueue) {
            let url = NSURL(string: endpoint)
            
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            
            request.HTTPBody = NSString(string: "\(itemId)").dataUsingEncoding(NSUTF8StringEncoding)
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
                data, response, error in
                
                if error != nil {
                    print("error=\(error)")
                    return
                }
                
                console.log(response)
            }
            task.resume()
        }
    }
}