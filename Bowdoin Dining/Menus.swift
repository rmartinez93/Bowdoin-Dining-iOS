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
    class func formatDate(_ todayDate : Date) -> NSMutableArray {
        //load gregorian calendar
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en-US")
        
        //create DateComponents from the NSDate and NSCalendar
        var today = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday], from: todayDate)
        
        //calculate offset from sunday (day menu begins)
        let offset  = today.weekday
        
        //set current day to sunday (first day) of this week, and create NSDateComponents for that day
        today.weekday = 1
        let lastSundayDate = calendar.date(from: today) as Date!
        let lastSunday = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekday], from: lastSundayDate!)
        
        //store info about last sunday's date for use with Bowdoin XML API
        let day   = lastSunday.day
        let month = lastSunday.month! - 1
        let year  = lastSunday.year
        
        return [day, month, year, offset]
    }
    
    class func clearOldCache() {
        let cachePath = self.cachePath()
        do {
            let allCache = try FileManager.default.contentsOfDirectory(atPath: cachePath)

            for item in allCache {
                let attributes = try FileManager.default.attributesOfItem(atPath: item)
                console.log(attributes)
                
                let creationDate = attributes[FileAttributeKey.creationDate] as! Date
                if creationDate.compare(Date()) == ComparisonResult.orderedAscending {
                    try FileManager.default.removeItem(atPath: item)
                }
            }
        } catch {
            // Unexpected error!
            print("Could not clear cache.")
        }
    }
    
    //load menu for a given day
    class func loadMenuForDay(_ day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> Data? {
        //first, search local path in case cached
        let path = self.localURLForDay(day, month: month, year: year, offset: offset) as String
        let fileExists = FileManager.default.fileExists(atPath: path) as Bool
        if fileExists { //if cached, return cached file
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        } else { //else not cached
            //begin network activity
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            //download menu for this day
            let urlString = self.externalURLForDay(day, month: month, year: year, offset: offset) as String
            let url = URL(string: urlString)!

            let xmlData = NSMutableData(contentsOf: url)
            
            //end network activity
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if xmlData != nil {
                //cache file, return
                xmlData!.write(toFile: path, atomically: true)
            }
            return xmlData as Data?
        }
    }
    
    class func createMenuFromXML(_ xmlData : Data, forMeal mealSegment : NSInteger, onWeekday weekday : Bool, atLocation locationId : NSInteger, withFilters filters : NSArray) -> [Course] {
        let ignoreList = ["Salad Bar", "...", "Salads"]
        
        //Create Google XML parsing object from NSData, grab "<meal>"s below root
        do {
            let doc = try GDataXMLDocument(data: xmlData, options: 0)
            
            let root = doc.rootElement()
            let meals = root?.elements(forName: "meal") as! [GDataXMLElement]
            
            //compensate for disappearing meals
            var mealIndex : Int = 0;
            switch mealSegment {
            case 0:
                if !weekday {
                    mealIndex = 1
                }
            case 1:
                if weekday {
                    mealIndex = 2
                } else {
                    mealIndex = 3
                }
            case 2:
                mealIndex = 3
            default: break
            }
            
            let meal  = meals[mealIndex]
            
            //each meal has two units (locations), create an XML Element for this locationId's menu
            let units = meal.elements(forName: "unit") as! [GDataXMLElement]
            let unit  = units[locationId]
            let menu  = (unit.elements(forName: "menu") as! [GDataXMLElement]).first!
            
            //create array for records (menu items), initialize array of courses (a menu item attribute)
            let menuArray = menu.elements(forName: "record") as? [GDataXMLElement]
            var courses : [Course] = []
            
            //if there are menu items available, loop through them
            if let menuItems = menuArray {
                for item in menuItems {
                    //grab information about this menu item: name & id
                    let item_name = (item.elements(forName: "webLongName") as! [GDataXMLElement]).first!
                    if !ignoreList.contains(item_name.stringValue()) {
                        let item_id   = (item.elements(forName: "itemID") as! [GDataXMLElement]).first!
                        do {
                            //create regex for removing diet attributes from item name, find matches in string
                            let regex = try NSRegularExpression(pattern: "\\b(NGI|VE|V|L|H)\\b", options: [])
                            
                            let attributeMatches = regex.matches(in: item_name.stringValue(), options: [], range: NSMakeRange(0, (item_name.stringValue() as NSString).length)) as NSArray
                            
                            //store diet attributes for filtering
                            var attributes : [String] = []
                            
                            if attributeMatches.count != 0 { //if there were matches, loop through them and add them to string
                                for i in 0 ..< attributeMatches.count {
                                    let special = attributeMatches.object(at: i) as! NSTextCheckingResult
                                    attributes += [(item_name.stringValue() as NSString).substring(with: special.range) as String]
                                }
                            }
                            
                            //replace matches with empty space
                            let cleaned = regex.stringByReplacingMatches(in: item_name.stringValue(), options: [], range: NSMakeRange(0, (item_name.stringValue() as NSString).length), withTemplate: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                            
                            //check if any diet attributes match our filter
                            let overlap = NSMutableSet(array: filters as [AnyObject])
                            overlap.intersect(NSSet(array: attributes) as Set<NSObject>)
                            
                            //if there is no active diet filter, or this item passes our filter
                            if filters.count == 0 || overlap.allObjects.count != 0 {
                                //determine course for this item and check if it already exists in our courses array
                                let courseObject = (item.elements(forName: "course") as! [GDataXMLElement]).first!
                                //check if item course exists
                                var coursePosition = -1;
                                for i in 0 ..< courses.count {
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
            
            return courses
        } catch {
            print("Menu Parsing Error")
            return []
        }
    }
    
    class func loadFavoritesDataForCourses(_ courses : [Course]) -> [String : Int] {
        var itemIds : [String] = []
        for course in courses {
            for item in course.menuItems {
                if item.itemId != "NA" {
                    itemIds.append(item.itemId)
                }
            }
        }
        
        //begin network activity
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //make request to get info from itemIds
        let endPointURL = "http://bowdoindining.meteorapp.com/favorites/\(itemIds.combine(","))"
        let url = URL(string: endPointURL)
        let data = try? Data(contentsOf: url!)
        
        //end network activity
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        do {
            //extract favorites data into dictionary
            var favoritesData : [String: Int] = [:]
            if let jsonData = data {
                if let json: NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let favorites = json["favorites"] as? NSArray {
                        for item in favorites {
                            if let favorite = item as? NSDictionary {
                                let itemId = favorite["itemId"] as! String
                                let favorites = favorite["favorites"] as! Int
                                favoritesData[itemId] = favorites
                            }
                        }
                    }
                }
            }
            
            //return courses together with favorites data
            return favoritesData
        } catch {
            return [:]
        }
    }
    
    class func externalURLForDay(_ day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        return "\(Menus().serverURL)\(year)-\(month)-\(day)/\(offset).xml" as NSString
    }
    
    class func localURLForDay(_ day : NSInteger, month : NSInteger, year : NSInteger, offset : NSInteger) -> NSString {
        let file = "local-\(year)-\(month)-\(day)-\(offset).xml"
        return "\(self.cachePath())\(file)" as NSString
    }
    
    class func cachePath() -> String {
        let cachePath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!)
        let menusPath = cachePath.appendingPathComponent("menus")
        
        //create path if it doesn't exist
        if (!FileManager.default.fileExists(atPath: menusPath.path)) {
            do {
                try FileManager.default.createDirectory(atPath: menusPath.path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Cache Path Error")
            }
        }
        
        return menusPath.path
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
