//
//  MenuItem.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/18/14.
//
//

import Foundation

class MenuItem {
    var name        = ""
    var itemId      = ""
    var descriptors = ""
    
    init(name: String, itemId: String, attributes: [String]?) {
        self.name = name
        self.itemId = itemId
        self.descriptors = attributes != nil ? attributes!.combine(" ").trim() : ""
    }
}
