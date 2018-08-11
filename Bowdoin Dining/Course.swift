//
//  Course.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/18/14.
//
//

import Foundation

class Course {
    var courseName = ""
    var menuItems : [MenuItem] = []
    
    init(name: String) {
        self.courseName = name
    }
    
    //array of all favorited items grabbed from our favorites file
    class func allFavoritedItems() -> NSMutableArray {
        let userDefaults = UserDefaults.standard
        let allFavorited : NSArray? = userDefaults.object(forKey: "favorited") as? NSArray
        if allFavorited != nil {
            return NSMutableArray(array: allFavorited!)
        } else {
            return []
        }
    }
    
    //add this item to the array of our favorited items and update plist
    class func removeFromFavoritedItems(_ item_id_string : String) {
        let userDefaults = UserDefaults.standard
        let favorited    = self.allFavoritedItems()
        favorited.remove(item_id_string)
        userDefaults.set(favorited, forKey: "favorited")
        userDefaults.synchronize()
    }
    
    //remove this item from the array of our favorited items and update plist
    class func addToFavoritedItems(_ item_id_string : String) {
        let userDefaults = UserDefaults.standard
        let favorited    = self.allFavoritedItems()
        favorited.add(item_id_string)
        userDefaults.set(favorited, forKey: "favorited")
        userDefaults.synchronize()
    }
}
