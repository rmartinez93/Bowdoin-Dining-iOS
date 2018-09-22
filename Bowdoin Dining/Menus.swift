//
//  Menus.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/25/14.
//
//

import Foundation
import UIKit

class Menus {
    static let menuUrl = "https://apps.bowdoin.edu/orestes/api.jsp"
    static let blackList = ["Salad Bar", "...", "Salads", "Salad Bar L & D -- Summer", "Deli Bar"]
    static let unitBase = 48
    
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
    
    class func clearOldCache() {
        let cachePath = self.cachePath()
        do {
            let allCache = try FileManager.default.contentsOfDirectory(atPath: cachePath)

            for item in allCache {
                let today = Date()
                let attributes = try FileManager.default.attributesOfItem(atPath: item)
                let creationDate = attributes[FileAttributeKey.creationDate] as! Date
                if creationDate.compare(today) == ComparisonResult.orderedAscending {
                    try FileManager.default.removeItem(atPath: item)
                }
            }
        } catch {
            // Unexpected error!
            print("Could not clear cache.")
        }
    }
    
    class func apiMenuURL(day: Int, month: Int, year: Int, unit: Int, mealName: String) -> String {
        let monthString = "\(month)".leftPadding(toLength: 2, withPad: "0")
        let dayString = "\(day)".leftPadding(toLength: 2, withPad: "0")
        let locationUnit = Menus.unitBase + unit
        
        return "\(Menus.menuUrl)?date=\(year)\(monthString)\(dayString)&unit=\(locationUnit)&meal=\(mealName)"
    }
    
    class func cacheMenuURL(day: Int, month: Int, year : Int, unit: Int, mealName: String) -> String {
        let monthString = NSString(string: "\(month)").padding(toLength: 2, withPad: "0", startingAt: 0)
        let dayString = NSString(string: "\(day)").padding(toLength: 2, withPad: "0", startingAt: 0)
        
        let file = "local-\(year)-\(monthString)-\(dayString)-\(unit)-\(mealName).xml"
        return "\(self.cachePath())\(file)"
    }
    
    class func writeMenuToCache(day : Int, month : Int, year : Int, unit: Int, mealName: String, data: Data?) {
        if let menu = data {
            let path = Menus.cacheMenuURL(day: day, month: month, year: year, unit: unit, mealName: mealName)
            let url = URL(string: path)!
            
            //cache file, return
            try? menu.write(to: url, options: [.atomic])
        }
    }
    
    class func readMenuFromCache(day: Int, month: Int, year: Int, unit: Int, mealName: String) -> Data? {
        let path = self.cacheMenuURL(day: day, month: month, year: year, unit: unit, mealName: mealName)
        
        return FileManager.default.fileExists(atPath: path) as Bool
            ? try? Data(contentsOf: URL(fileURLWithPath: path))
            : nil;
    }
    
    class func readMenuFromAPI(day : Int, month : Int, year : Int, unit: Int, mealName: String) -> Data? {
        let path = self.apiMenuURL(day: day, month: month, year: year, unit: unit, mealName: mealName)
        let url = URL(string: path)!
        
        // Begin network activity.
        Menus.activityIndicator(on: true)
        
        // Download menu for this day.
        let xmlData = try? Data(contentsOf: url)
        
        // End network activity.
        Menus.activityIndicator(on: false)
        
        // Cache data.
        Menus.writeMenuToCache(day: day, month: month, year: year, unit: unit, mealName: mealName, data: xmlData)
        
        return xmlData as Data?
    }
    
    //load menu for a given day
    class func loadMenu(date: Date, unit: Int, meal: Int) -> Data? {
        // Extract day/month/year.
        let components      = date.getDayMonthYear()
        let day             = components.day
        let month           = components.month
        let year            = components.year
        let mealName        = Menus.getMealNameForMeal(date: date, meal: meal)
        
        // Default to cached menu if it exists.
        var menu = Menus.readMenuFromCache(day: day, month: month, year: year, unit: unit, mealName: mealName)
        
        // Menu not cached, read externally.
        if menu == nil {
            menu = Menus.readMenuFromAPI(day: day, month: month, year: year, unit: unit, mealName: mealName)
        }
        
        return menu
    }
    
    class func createMenuFromXML(_ xmlData : Data, withFilters filters : [String]) -> [Course] {
        // Read the document.
        let doc = try! GDataXMLDocument(data: xmlData, options: 0)
        
        // Check if we have a menu & menu items.
        let menu = doc.rootElement()
        let menuItems = menu?.elements(forName: "record") as? [GDataXMLElement] ?? []
        
        // If no menu array, give up here.
        if menuItems.count == 0 {
            return Menus.errorMenu()
        }
        
        var courses : [Course] = []
        
        for item in menuItems {
            // Grab information about this menu item: course, name & id.
            let courseName = (item.elements(forName: "course") as? [GDataXMLElement])?.first?.stringValue() ?? ""
            let itemName = (item.elements(forName: "webLongName") as? [GDataXMLElement])?.first?.stringValue() ?? ""
            let itemId   = (item.elements(forName: "itemID") as? [GDataXMLElement])?.first?.stringValue() ?? ""
            
            // Give up here if we're ignoring this item.
            let passesBlackList = !Menus.blackList.contains(itemName)
            if !passesBlackList {
                continue;
            }
            
            // Parse out attributes (e.g. GF)
            let (name, attributes) = Menus.splitAttributesFromItemName(itemName)
            
            // Give up here if this item doesn't pass our filter.
            let passesFilter = filters.count == 0 || attributes.intersects(filters)
            if !passesFilter {
                continue;
            }
            
            // Check if course already exists in our courses array
            let existingCourse = courses.first(where: { (item) -> Bool in
                item.courseName == courseName
            });
            let courseExists = existingCourse != nil
            
            // Use existing or create new course.
            let course = courseExists ? existingCourse! : Course(name: courseName)
            
            // Create a new menuItem.
            let item = MenuItem(name: name, itemId: itemId, attributes: attributes)
            
            // Add to course menu items.
            course.menuItems.append(item)
            
            //if did not exist, add it to our courses.
            if !courseExists {
                courses.append(course)
            }
        }
        
        return courses
    }
    
    class func splitAttributesFromItemName(_ itemName: String) -> (name: String, attributes: [String]) {
        // Create regex for removing diet attributes from item name, find matches in string
        let regex = try! NSRegularExpression(pattern: "\\b(NGI|GF|DF|VE|V|L|H)\\b", options: [])
        
        let attributeMatches = regex.matches(in: itemName, options: [], range: NSMakeRange(0, itemName.count)) as NSArray
        
        // Store diet attributes for filtering
        var attributes : [String] = []
        
        // If there were matches, loop through them and add them to string
        if attributeMatches.count > 0 {
            for i in 0 ..< attributeMatches.count {
                let special = attributeMatches.object(at: i) as! NSTextCheckingResult
                attributes += [(itemName as NSString).substring(with: special.range) as String]
            }
        }
        
        //replace matches with empty space
        let name = regex.stringByReplacingMatches(in: itemName, options: [], range: NSMakeRange(0, itemName.count), withTemplate: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").trim()
        
        return (
            name,
            attributes
        )
    }
    
    class func errorMenu() -> [Course] {
        //no menu items available, add error item to courses array
        let closed = Course(name: "")
        
        let item = MenuItem(name: "No Menu Available", itemId: "NA", attributes: nil)
        closed.menuItems.append(item)
        
        return [closed]
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
        Menus.activityIndicator(on: true)
        
        //make request to get info from itemIds
        let endPointURL = "https://app.bowdoin.menu/favorites/\(itemIds.combine(","))"
        let url = URL(string: endPointURL)
        let data = try? Data(contentsOf: url!)
        
        //end network activity
        Menus.activityIndicator(on: false)
        
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
    
    // Converts a meal and a date into a meal name param for api.
    class func getMealNameForMeal(date: Date, meal: Int) -> String {
        if date.isWeekday() {
            switch(meal) {
            case 0: return "breakfast"
            case 1: return "lunch"
            case 2: return "dinner"
            default: return ""
            }
        }
        else {
            switch(meal) {
            case 0: return "brunch"
            case 1: return "dinner"
            default: return ""
            }
        }
    }
    
    class func activityIndicator(on: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = on
        }
    }
}
