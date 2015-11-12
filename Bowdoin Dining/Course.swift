//
//  Course.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/18/14.
//
//

import Foundation

class Course : NSObject {
    var courseName = ""
    var menuItems : [MenuItem] = []
    
    //array of all favorited items grabbed from our favorites file
    class func allFavoritedItems() -> NSMutableArray {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let allFavorited : NSArray? = userDefaults.objectForKey("favorited") as? NSArray
        if allFavorited != nil {
            return NSMutableArray(array: allFavorited!)
        } else {
            return []
        }
    }
    
    //add this item to the array of our favorited items and update plist
    class func removeFromFavoritedItems(item_id_string : NSString) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let favorited    = self.allFavoritedItems()
        favorited.removeObject(item_id_string)
        userDefaults.setObject(favorited, forKey: "favorited")
        userDefaults.synchronize()
    }
    
    //remove this item from the array of our favorited items and update plist
    class func addToFavoritedItems(item_id_string : NSString) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let favorited    = self.allFavoritedItems()
        favorited.addObject(item_id_string)
        userDefaults.setObject(favorited, forKey: "favorited")
        userDefaults.synchronize()
    }
}