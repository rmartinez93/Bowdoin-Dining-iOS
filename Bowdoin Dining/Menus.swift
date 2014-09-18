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
    var serverURL = "http://www.bowdoin.edu/atreus/lib/xml/"
    
    //format an NSDate for our use
    class func formatDate(todayDate : NSDate) -> NSMutableArray {
        //load gregorian calendar
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar.locale = NSLocale(localeIdentifier: "en-US")
        
        //create DateComponents from the NSDate and NSCalendar
        var today = calendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.WeekOfYearCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: todayDate)
        
        //calculate offset from sunday (day menu begins)
        var offset  = today.weekday;
        
        //set current day to sunday (first day) of this week, and create NSDateComponents for that day
        today.weekday = 1
        var lastSundayDate = calendar.dateFromComponents(today) as NSDate!
        var lastSunday = calendar.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.WeekdayCalendarUnit, fromDate: lastSundayDate)
        
        //store info about last sunday's date for use with Bowdoin XML API
        var day   = lastSunday.day
        var month = lastSunday.month - 1
        var year  = lastSunday.year
        
        return [day, month, year, offset]
    }
    
    //load menu for a given day
    class func loadMenuForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSData? {
        //first, search local path in case cached
        var path = self.localURLForDay(day, month: month, year: year, offset: offset)
        var fileExists = NSFileManager.defaultManager().fileExistsAtPath(path) as Bool
        
        if fileExists { //if cached, return cached file
            var error : NSError?
            var cached = NSData.dataWithContentsOfFile(path, options: nil, error: &error)
            
            return cached;
        } else { //else not cached
            //begin network activity
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true

            //download menu for this day
            var urlString = self.externalURLForDay(day, month: month, year: year, offset: offset)
            var url = NSURL(string: urlString)
            var error : NSError?
            var xmlData = NSMutableData.dataWithContentsOfURL(url, options: nil, error: &error)
            
            //end network activity
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            //cache file, return
            if xmlData != nil {
                xmlData.writeToFile(path, atomically: true)
                return xmlData
            }
            return nil
        }
    }
    
    class func createMenuFromXML(xmlData : NSData, forMeal mealSegment : NSInteger, onWeekday weekday : Bool, atLocation locationId : NSInteger, withFilters filters : NSArray) -> [Course] {
        var error : NSError?
        //Create Google XML parsing object from NSData, grab "<meal>"s below root
        var doc = GDataXMLDocument(data: xmlData, options: 0, error: &error)
        var root = doc.rootElement()
        var meals = root.elementsForName("meal") as NSArray
        
        //compensate for disappearing meals
        var mealId : NSInteger = 0;
        switch (mealSegment) {
            case 0:
                if !weekday {
                    mealId = 1;
                }
                break;
            case 1:
                if weekday {
                    mealId = 2;
                } else {
                    mealId = 3;
                }
                break;
            case 2:
                mealId = 3;
            default:
                break;
        }
        
        var meal  = meals.objectAtIndex(mealId) as GDataXMLElement
        
        //each meal has two units (locations), create an XML Element for this locationId's menu
        var units = meal.elementsForName("unit") as NSArray
        var unit  = units.objectAtIndex(locationId) as GDataXMLElement
        var menu  = (unit.elementsForName("menu") as NSArray).firstObject as GDataXMLElement
        
        //create array for records (menu items), initialize array of courses (a menu item attribute)
        var menuArray = menu.elementsForName("record") as NSArray?
        var courses : [Course] = []
        
        //if there are menu items available, loop through them
        if let menuItems = menuArray {
            for item in menuItems {
                //determine course for this item and check if it already exists in our courses array
                var courseObject = ((item as GDataXMLElement).elementsForName("course") as NSArray).firstObject as GDataXMLElement
                
                //check if this course exists
                var coursePosition = -1;
                for var i = 0; i < courses.count; i++ {
                    var course = courses[i] as Course
                    if course.courseName == courseObject.stringValue() {
                        coursePosition = i
                    }
                }
                
                //grab information about this menu item: name & id
                var item_name = ((item as GDataXMLElement).elementsForName("webLongName") as NSArray).firstObject as GDataXMLElement
                var item_id   = ((item as GDataXMLElement).elementsForName("itemID") as NSArray).firstObject as GDataXMLElement
                
                //create regex for removing diet attributes from item name, find matches in string
                var error : NSError?
                var regex   = NSRegularExpression(pattern: "\\b(NGI|VE|V|L)\\b", options: nil, error: &error)
                var details = regex.matchesInString(item_name.stringValue(), options: nil, range: NSMakeRange(0, (item_name.stringValue() as NSString).length)) as NSArray
                
                //store returned attributes into string for presentation
                var detail = ""
                if details.count != 0 { //if there were matches, loop through them and add them to string
                    for var i = 0; i < details.count; i++ {
                        var special = details.objectAtIndex(i) as NSTextCheckingResult
                        detail = "\(detail) \(((item_name.stringValue() as NSString).substringWithRange(special.range) as NSString).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))"
                    }
                }
                
                //replace matches with empty space
                var cleaned = regex.stringByReplacingMatchesInString(item_name.stringValue(), options: nil, range: NSMakeRange(0, (item_name.stringValue() as NSString).length), withTemplate: "").stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "")
                
                //break up string of diet attributes in array for filtering
                var attributes = detail.componentsSeparatedByString(" ")
                
                //check if diet attributes match our filter
                var overlap    = NSMutableSet(array: filters)
                overlap.intersectSet(NSSet(array: attributes))
                
                //if there is no active filter, or this item passes our filter
                if filters.count == 0 || overlap.allObjects.count != 0 {
                    //declare this course
                    var thiscourse : Course
                    
                    //if course already exists in our array
                    if coursePosition >= 0 {
                        //grab a copy of it, and and add this item to the course
                        thiscourse = courses[coursePosition] as Course
                        
                        var item  = MenuItem()
                        item.name = cleaned
                        item.itemId = item_id.stringValue()
                        item.descriptors = detail
                        
                        thiscourse.menuItems.append(item)
                    } else { //new course, create it and add item to it
                        thiscourse = Course()
                        thiscourse.courseName = courseObject.stringValue()
                        
                        var item = MenuItem()
                        item.name = cleaned
                        item.itemId = item_id.stringValue()
                        item.descriptors = detail
                        
                        thiscourse.menuItems.append(item)
                        courses.append(thiscourse)
                    }
                }
            }
        } else { //no menu items available, add error item to courses array
            var closed = Course()
            closed.courseName = ""
            
            var item = MenuItem()
            item.name = "No Menu Available"
            item.itemId = "NA"
            
            closed.menuItems.append(item)
            
            courses.append(closed)
        }

        return courses; //return array of courses
    }
    
    class func externalURLForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        return "\(Menus().serverURL)\(year)-\(month)-\(day)/\(offset).xml"
    }
    
    class func localURLForDay(day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        var path = "local-\(year)-\(month)-\(day)-\(offset).xml"
        var cache = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray).firstObject as NSString
        return "\(cache)\(path)"
    }
}