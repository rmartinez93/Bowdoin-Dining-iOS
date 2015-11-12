//
//  Transaction.swift
//  Bowdoin Dining
//
//  Created by Ruben on 10/9/14.
//
//

import Foundation

class Transaction : NSObject {
    var name    : String
    var date    : String
    var amount  : Double
    var balance : Double
    
    init(name : String, date : String, amount : String, balance : String) {
        self.name    = name
        self.amount  = Double(Int(amount)!)/100.0
        self.date    = date.parseDate()
        self.balance = Double(Int(balance)!)/100.0
        
        super.init()
    }
}

extension String {
    func parseDate() -> String {
        //example: 2014-09-10T21:47:22-04:00
        let stringDate  = (self as NSString).substringToIndex(16)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let date = formatter.dateFromString(stringDate)
        formatter.dateFormat = "MM/dd/yyyy hh:mm a"
        return formatter.stringFromDate(date!)
    }
}