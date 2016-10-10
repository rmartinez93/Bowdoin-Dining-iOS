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
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var courses : [Course] = []
    var favoritesData : [String : Int] = [:]
    var speaker : AVSpeechSynthesizer?
    var diningHallName : String?
    var refreshControl: UIRefreshControl!
    
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
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(MenuViewController.loadFavoritesData), for: UIControlEvents.valueChanged)
        menuItems.addSubview(refreshControl)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition  {
        return UIBarPosition.topAttached
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = UIColor.white
        NotificationCenter.default.removeObserver(self)
        
        if speaker != nil {
            speaker!.stopSpeaking(at: AVSpeechBoundary.immediate)
            DispatchQueue.main.async {
                self.speakButton.setImage(UIImage(named: "speaker"), for: UIControlState())
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        NotificationCenter.default.addObserver(self,
            selector: #selector(MenuViewController.linesDidLoad),
            name: NSNotification.Name(rawValue: "LinesFinishedLoading"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //load menu based on delegate settings
        self.updateVisibleMenu()
    }
    
    @IBAction func indexDidChangeForSegmentedControl(_ sender : UISegmentedControl) {
        //if this was a valid selection, update our delegate and update the menu
        if UISegmentedControlNoSegment != sender.selectedSegmentIndex {
            self.delegate.selectedSegment = self.meals.selectedSegmentIndex
            self.updateVisibleMenu()
        }
    }
    
    @IBAction func backButtonPressed(_ sender : AnyObject) {
        if self.delegate.daysAdded > 0 {
            self.changeDayBy(-1)
            self.updateVisibleMenu()
        }
    }
    
    @IBAction func forwardButtonPressed(_ sender : AnyObject) {
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
            let newDate = Date(timeIntervalSinceNow: TimeInterval(60*60*24*self.delegate.daysAdded))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: newDate)
        }
    }
    
    func changeDayBy(_ amount: NSInteger) {
        self.delegate.daysAdded += amount
        self.navBar!.topItem!.title = self.getTextForDaysAdded() as String
    }
    
    func disableAllButtons() {
        self.backButton.isEnabled = false
        self.forwardButton.isEnabled = false
        self.meals.isEnabled = false
    }
    
    func makeCorrectButtonsVisible() {
        //handle visibility of back/foward
        self.backButton.isEnabled = true
        self.forwardButton.isEnabled = true
        if self.delegate.daysAdded == 6 {
            self.forwardButton.isEnabled = false
        }
        else if self.delegate.daysAdded == 0 {
            self.backButton.isEnabled = false
        }
        
        //disable/enable segmented buttons
        let date = Date(timeIntervalSinceNow: TimeInterval(60*60*24*self.delegate.daysAdded))
        let formattedDate = Menus.formatDate(date)
        let offset = (formattedDate.lastObject as! NSNumber).intValue
        
        //insert/remove meals depending on day of the week
        if isWeekday(offset) {
            if self.meals.titleForSegment(at: 0) != "Breakfast" {
                self.meals.removeSegment(at: 0, animated: false)
                self.meals.insertSegment(withTitle: "Breakfast", at: 0, animated: false)
                self.meals.insertSegment(withTitle: "Lunch",     at: 1, animated: false)
                self.meals.selectedSegmentIndex = self.delegate.selectedSegment
            }
        } else {
            if self.meals.titleForSegment(at: 0) != "Brunch" {
                self.meals.removeSegment(at: 0, animated: false)
                self.meals.removeSegment(at: 0, animated: false)
                self.meals.insertSegment(withTitle: "Brunch", at: 0, animated: false)
                self.meals.selectedSegmentIndex = self.delegate.selectedSegment
            }
        }
        self.meals.isEnabled = true
    }
    
    func segmentIndexOfCurrentMeal() -> NSInteger {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en-US");
        
        let today = (calendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.weekday], from: Date())
        let weekday = today.weekday
        let hour    = today.hour
        
        if isWeekday(weekday!) {
            if hour! < 11 {
                return 0 //breakfast
            } else if hour! < 14 {
                return 1 //lunch
            } else {
                return 2 //dinner
            }
        } else {
            if hour! < 14 {
                return 0 //brunch
            } else {
                return 1 //dinner
            }
        }
    }
    
    //UITableView delegate method, returns number of rows/meal items in a given section/course
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.courses.count {
            return self.courses[section].menuItems.count
        } else {
            return 0
        }
    }
    
    //UITableView delegate method, sets settings for cell/menu item to be displayed at a given section->row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleTableIdentifier = "BasicCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) as! UIMenuItemView!
        
        if cell == nil {
            cell = Bundle.main.loadNibNamed("UIMenuItemView", owner: self, options: nil)?.first as? UIMenuItemView
        }
        
        //if this is a valid section->row, grab right menu item from course and set cell properties
        if (indexPath as NSIndexPath).section < self.courses.count {
            let course = self.courses[(indexPath as NSIndexPath).section]
            if (indexPath as NSIndexPath).row < course.menuItems.count {
                let this : MenuItem? = course.menuItems[(indexPath as NSIndexPath).row]
                
                if let item = this {
                    cell!.title!.text = item.name
                    cell!.detail!.text = item.descriptors
                    
                    let faveCount = self.favoritesData[item.itemId] != nil
                        ? self.favoritesData[item.itemId]! : 0
                    
                    let allFavorited = Course.allFavoritedItems()
                    var favorited = false;
                    if allFavorited.contains(item.itemId) {
                        favorited = true;
                    }
                    
                    cell!.initData(faveCount, favorited: favorited, itemId: item.itemId, delegate: self)
                    cell!.sizeToFit()
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let course = self.courses[(indexPath as NSIndexPath).section]
        if (indexPath as NSIndexPath).row < course.menuItems.count {
            let this : MenuItem? = course.menuItems[(indexPath as NSIndexPath).row]
            if let item = this {
                let options = unsafeBitCast(NSStringDrawingOptions.usesLineFragmentOrigin.rawValue |
                    NSStringDrawingOptions.usesFontLeading.rawValue,
                    to: NSStringDrawingOptions.self)
                
                let screenSize: CGRect = UIScreen.main.bounds
                
                let textAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]
                let nameSize = (item.name as NSString).boundingRect(with: CGSize(width: screenSize.width - 80, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: textAttributes, context: nil)
                
                let descSize = (item.descriptors as NSString).boundingRect(with: CGSize(width: screenSize.width, height: CGFloat.greatestFiniteMagnitude), options: options, attributes: textAttributes, context: nil)
                
                return nameSize.height + descSize.height + 5
            }
        }
        
        return 0
    }
    
    //UITableView delegate method, returns name of section/course
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < self.courses.count {
            let course = self.courses[section]
            return course.courseName
        } else {
            return "Other"
        }
    }
    
    //UITableView delegate method, sets section header styles
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        header.textLabel!.font = UIFont.boldSystemFont(ofSize: 12)
        header.contentView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
    
    //UITableView delegate method, creates animation when displaying cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 10)
    }
    
    //UITableView delegate method, returns number of sections/courses in loaded menu
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.courses.count
    }
    
    //shares an invite to the currently browsed meal
    @IBAction func inviteToMeal() {
        let invite = "Let's get \(self.meals.titleForSegment(at: self.meals.selectedSegmentIndex)!.lowercased()) at \(BowdoinAPIParser.nameOfDiningHallWithId(self.view.tag)) \(self.getTextForDaysAdded())?"
        
        let activityViewController = UIActivityViewController(activityItems: [invite], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
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
        let date = Date(timeIntervalSinceNow: TimeInterval(60*60*24*self.delegate.daysAdded))
        let formattedDate = Menus.formatDate(date)
        self.delegate.day    = formattedDate[0] as! NSInteger
        self.delegate.month  = formattedDate[1] as! NSInteger
        self.delegate.year   = formattedDate[2] as! NSInteger
        self.delegate.offset = formattedDate[3] as! NSInteger
        
        //firstly, remove everything from the UITableView
        self.courses.removeAll(keepingCapacity: false)
        self.menuItems.reloadData()
        
        //disable user interaction and begin loading indicator
        self.disableAllButtons()
        self.loading.startAnimating()
        self.menuItems.beginUpdates()
    }
    
    func loadMenu(_ callback: @escaping (Data?) -> ()) {
        //create a new thread...
        let downloadQueue = DispatchQueue(label: "Download queue", attributes: []);
        downloadQueue.async {
            //in new thread, load menu for this day
            let xml = Menus.loadMenuForDay(self.delegate.day, month: self.delegate.month, year: self.delegate.year, offset: self.delegate.offset)
            //go back to main thread
            DispatchQueue.main.async {
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
        newSet.add(in: NSMakeRange(0, self.courses.count))
        self.menuItems.insertSections(newSet as IndexSet, with:UITableViewRowAnimation.right)
        
        //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
        self.loading.stopAnimating()
        self.menuItems.endUpdates()
        self.menuItems.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func presentMenu(_ xml : Data) {
        //update the buttons
        self.makeCorrectButtonsVisible()
        
        //create a menu from this data and save it to delegate
        self.courses = Menus.createMenuFromXML(xml,
            forMeal:     self.meals.selectedSegmentIndex,
            onWeekday:   isWeekday(self.delegate.offset),
            atLocation:  self.view.tag,
            withFilters: self.delegate.filters as NSArray)
        
        //insert new menu items to UITableView
        let newSet   = NSMutableIndexSet()
        newSet.add(in: NSMakeRange(0, self.courses.count))
        self.menuItems.insertSections(newSet as IndexSet, with:UITableViewRowAnimation.right)
        
        //stop loading indicator, end updates to UITableView, scroll to top and reenable user interaction
        self.loading.stopAnimating()
        self.menuItems.endUpdates()
        self.menuItems.setContentOffset(CGPoint.zero, animated: true)
        
        self.loadFavoritesData()
    }
    
    func loadFavoritesData() {
        //create a new thread...
        let downloadQueue = DispatchQueue(label: "Download queue", attributes: []);
        downloadQueue.async {
            let favoritesData = Menus.loadFavoritesDataForCourses(self.courses)
            
            DispatchQueue.main.async {
                self.favoritesData += favoritesData
                
                //reload with favorites data
                self.menuItems.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    //UITableView delegate method, creates animation when displaying cell; removed, not popular
    func animateIn(_ this : UIView) {
        let init_angle : Double = divide(90*M_PI, right: 180)
        var rotation = CATransform3DMakeRotation(CGFloat(init_angle), 0.0, 0.7, 0.4) as CATransform3D
        rotation.m34 = (-1.0/600.0)
        
        this.layer.shadowColor = UIColor.black.cgColor
        this.layer.shadowOffset = CGSize(width: 10, height: 10)
        this.layer.opacity = 0
        
        this.layer.transform = rotation
        this.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        if this.layer.position.x != 0 {
            this.layer.position = CGPoint(x: 0, y: this.layer.position.y);
        }
        
        UIView.beginAnimations("rotation",  context: nil)
        UIView.setAnimationDuration(0.4)
        this.layer.transform = CATransform3DIdentity
        this.layer.opacity = 1
        this.layer.shadowOffset = CGSize(width: 0, height: 0)
        UIView.commitAnimations()
    }
    
    //Uses TTS to speak menus aloud
    @IBAction func speakMenu() {
        if speaker != nil {
            if speaker!.isSpeaking {
                speaker!.stopSpeaking(at: AVSpeechBoundary.immediate)
                DispatchQueue.main.async {
                    self.speakButton.setImage(UIImage(named: "speaker"), for: UIControlState())
                }
                return
            }
        } else {
            speaker = AVSpeechSynthesizer()
            speaker!.delegate = self
        }
        
        DispatchQueue.main.async {
            self.speakButton.setImage(UIImage(named: "speaker_active"), for: UIControlState())
        }
        
        var menu = "For "+self.meals.titleForSegment(at: self.delegate.selectedSegment)!+" "+(self.getTextForDaysAdded())+" at \(BowdoinAPIParser.nameOfDiningHallWithId(self.view.tag)) we have "
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
        phrase.rate = 0.5
        speaker!.speak(phrase)
    }
    
    //resets speech button color when finished
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.speakButton.setImage(UIImage(named: "speaker"), for: UIControlState())
        }
    }
    
    //displays line data if loaded
    func linesDidLoad() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                if self.view.tag == self.delegate.thorneId {
                    (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = self.delegate.thorneColor!
                } else if self.view.tag == self.delegate.moultonId {
                    (self.delegate.window!.rootViewController as! UITabBarController).tabBar.tintColor = self.delegate.moultonColor!
                }
            })
        }
    }
    
    func toggleFavorite(_ itemId: String) {
        //load favorited items
        let allFavorited = Course.allFavoritedItems()
        
        var endpoint = "http://bowdoindining.meteorapp.com/methods/"
        //if this cell is NOT favorited, show favoriting action
        if !allFavorited.contains(itemId) {
            //if item is favorited, save it to our centralized list of favorited items
            Course.addToFavoritedItems(itemId)
            endpoint += "favorite"
        } else {
            Course.removeFromFavoritedItems(itemId)
            endpoint += "unfavorite"
        }
        
        //create a new thread...
        let downloadQueue = DispatchQueue(label: "Download queue", attributes: []);
        downloadQueue.async {
            let url = URL(string: endpoint)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = itemId.utf8StringEncodedData!
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                data, response, error in
                
                if error != nil {
                    print("error=\(error)")
                    return
                }
            }) 
            task.resume()
        }
    }
}
