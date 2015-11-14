//
//  Menus.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/25/14.
//
//

import Foundation
import UIKit

class Menus : NSObject {
    var serverURL = "https://www.bowdoin.edu/atreus/lib/xml/"
    
    //format an NSDate for our use
    class func formatDate(todayDate : NSDate) -> NSMutableArray {
        //load gregorian calendar
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en-US")
        
        //create DateComponents from the NSDate and NSCalendar
        let today = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday], fromDate: todayDate)
        
        //calculate offset from sunday (day menu begins)
        let offset  = today.weekday
        
        //set current day to sunday (first day) of this week, and create NSDateComponents for that day
        today.weekday = 1
        let lastSundayDate = calendar.dateFromComponents(today) as NSDate!
        let lastSunday = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Weekday], fromDate: lastSundayDate)
        
        //store info about last sunday's date for use with Bowdoin XML API
        let day   = lastSunday.day
        let month = lastSunday.month - 1
        let year  = lastSunday.year
        
        return [day, month, year, offset]
    }
    
    class func clearOldCache() {
        let cachePath = self.cachePath()
        do {
            let allCache = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(cachePath)

            for item in allCache {
                let attributes = try NSFileManager.defaultManager().attributesOfItemAtPath(item)
                console.log(attributes)
                
                let creationDate = attributes[NSFileCreationDate] as! NSDate
                if creationDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                    try NSFileManager.defaultManager().removeItemAtPath(item)
                }
            }
        } catch {
            // Unexpected error!
            print("Could not clear cache.")
        }
    }
    
    //load menu for a given day
    class func loadMenuForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSData? {
        //first, search local path in case cached
        let path = self.localURLForDay(day, month: month, year: year, offset: offset) as String
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(path) as Bool
        if fileExists { //if cached, return cached file
            return NSData(contentsOfFile: path)
        } else { //else not cached
            //begin network activity
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true

            //download menu for this day
            let urlString = self.externalURLForDay(day, month: month, year: year, offset: offset) as String
            let url = NSURL(string: urlString)!

            let xmlData = NSMutableData(contentsOfURL: url)
            
            //end network activity
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            if xmlData != nil {
                //cache file, return
                xmlData!.writeToFile(path, atomically: true)
            }
            return xmlData
        }
    }
    
    class func createMenuFromXML(xmlData : NSData, forMeal mealSegment : NSInteger, onWeekday weekday : Bool, atLocation locationId : NSInteger, withFilters filters : NSArray) -> [Course] {
        let ignoreList = ["Salad Bar", "..."]
        
        //Create Google XML parsing object from NSData, grab "<meal>"s below root
        do {
            let doc = try GDataXMLDocument(data: xmlData, options: 0)
            
            let root = doc.rootElement()
            let meals = root.elementsForName("meal") as NSArray
            
            //compensate for disappearing meals
            var mealId : NSInteger = 0;
            switch mealSegment {
            case 0:
                if !weekday {
                    mealId = 1
                }
            case 1:
                if weekday {
                    mealId = 2
                } else {
                    mealId = 3
                }
            case 2:
                mealId = 3
            default: break
            }
            
            let meal  = meals.objectAtIndex(mealId) as! GDataXMLElement
            
            //each meal has two units (locations), create an XML Element for this locationId's menu
            let units = meal.elementsForName("unit") as NSArray
            let unit  = units.objectAtIndex(locationId) as! GDataXMLElement
            let menu  = (unit.elementsForName("menu") as NSArray).firstObject as! GDataXMLElement
            
            //create array for records (menu items), initialize array of courses (a menu item attribute)
            let menuArray = menu.elementsForName("record") as NSArray?
            var courses : [Course] = []
            
            //if there are menu items available, loop through them
            if let menuItems = menuArray {
                for item in menuItems {
                    //grab information about this menu item: name & id
                    let item_name = ((item as! GDataXMLElement).elementsForName("webLongName") as NSArray).firstObject as! GDataXMLElement
                    
                    if !ignoreList.contains(item_name.stringValue()) {
                        let item_id   = ((item as! GDataXMLElement).elementsForName("itemID") as NSArray).firstObject as! GDataXMLElement
                        
                        do {
                            //create regex for removing diet attributes from item name, find matches in string
                            let regex = try NSRegularExpression(pattern: "\\b(NGI|VE|V|L)\\b", options: [])
                            
                            let attributeMatches = regex.matchesInString(item_name.stringValue(), options: [], range: NSMakeRange(0, (item_name.stringValue() as NSString).length)) as NSArray
                            
                            //store diet attributes for filtering
                            var attributes : [String] = []
                            
                            if attributeMatches.count != 0 { //if there were matches, loop through them and add them to string
                                for var i = 0; i < attributeMatches.count; i++ {
                                    let special = attributeMatches.objectAtIndex(i) as! NSTextCheckingResult
                                    attributes += [(item_name.stringValue() as NSString).substringWithRange(special.range) as String]
                                }
                            }
                            
                            //replace matches with empty space
                            let cleaned = regex.stringByReplacingMatchesInString(item_name.stringValue(), options: [], range: NSMakeRange(0, (item_name.stringValue() as NSString).length), withTemplate: "").stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
                            
                            //check if any diet attributes match our filter
                            let overlap = NSMutableSet(array: filters as [AnyObject])
                            overlap.intersectSet(NSSet(array: attributes) as Set<NSObject>)
                            
                            //if there is no active diet filter, or this item passes our filter
                            if filters.count == 0 || overlap.allObjects.count != 0 {
                                //determine course for this item and check if it already exists in our courses array
                                let courseObject = ((item as! GDataXMLElement).elementsForName("course") as NSArray).firstObject as! GDataXMLElement
                                
                                //check if item course exists
                                var coursePosition = -1;
                                for var i = 0; i < courses.count; i++ {
                                    let course = courses[i] as Course
                                    if course.courseName == courseObject.stringValue() {
                                        coursePosition = i
                                    }
                                }
                                
                                //declare this course
                                var thiscourse : Course
                                
                                //if course already exists in our array
                                if coursePosition >= 0 {
                                    //grab a copy of it, and and add this item to the course
                                    thiscourse = courses[coursePosition] as Course
                                    
                                    let item  = MenuItem()
                                    item.name = cleaned.trim()
                                    item.itemId = item_id.stringValue()
                                    item.descriptors = attributes.combine(" ").trim()
                                    
                                    thiscourse.menuItems.append(item)
                                } else { //new course, create it and add item to it
                                    thiscourse = Course()
                                    thiscourse.courseName = courseObject.stringValue()
                                    
                                    let item = MenuItem()
                                    item.name = cleaned.trim()
                                    item.itemId = item_id.stringValue()
                                    item.descriptors = attributes.combine(" ").trim()
                                    
                                    thiscourse.menuItems.append(item)
                                    courses.append(thiscourse)
                                }
                            }
                        } catch {
                            
                        }
                    }
                }
            } else { //no menu items available, add error item to courses array
                let closed = Course()
                closed.courseName = ""
                
                let item = MenuItem()
                item.name = "No Menu Available"
                item.itemId = "NA"
                
                closed.menuItems.append(item)
                
                courses.append(closed)
            }
            
            return courses; //return array of courses
        } catch {
            print("Menu Parsing Error")
            return []
        }
    }
    
    class func externalURLForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        return "\(Menus().serverURL)\(year)-\(month)-\(day)/\(offset).xml"
    }
    
    class func localURLForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        let file = "local-\(year)-\(month)-\(day)-\(offset).xml"
        return "\(self.cachePath())\(file)"
    }
    
    class func cachePath() -> String {
        let cachePath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!)
        let menusPath = cachePath.URLByAppendingPathComponent("menus")
        
        //create path if it doesn't exist
        if (!NSFileManager.defaultManager().fileExistsAtPath(menusPath.path!)) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(menusPath.path!, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Cache Path Error")
            }
        }
        
        return menusPath.path!
    }
}

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}