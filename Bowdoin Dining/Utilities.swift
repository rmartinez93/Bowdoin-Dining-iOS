//
//  Utilities.swift
//  Bowdoin Dining
//
//  Created by Ruben on 2/25/15.
//
//

import Foundation

extension Array {
    func intersects(_ arr: [Any]) -> Bool {
        let overlap = NSMutableSet(array: self as [Any])
        overlap.intersect(NSSet(array: arr) as Set<NSObject>)
        
        return overlap.allObjects.count > 0
    }
    
    func combine(   _ separator: String) -> String {
        var str : String = ""
        for i in 0 ..< self.count {
            str += "\(self[i])"
            if i < self.count-1 {
                str += separator
            }
        }
        return str
    }
    
    func sum() -> Int {
        return self.reduce(0, { ($0 as Int) + ($1 as! Int) })
    }
}

extension Data {
    var stringValue: String? {
        return String(data: self, encoding: .utf8)
    }
    var base64EncodedString: String? {
        return base64EncodedString(options: .lineLength64Characters)
    }
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func extractNumerics() -> String {
        let numerics = CharacterSet(charactersIn: "0123456789").inverted
        return self.components(separatedBy: numerics).combine("")
    }
    
    func extractNumericsAsInt() -> Int {
        let numerics = CharacterSet(charactersIn: "0123456789").inverted
        return (self.components(separatedBy: numerics).combine("") as NSString).integerValue
    }
    
    var utf8StringEncodedData: Data? {
        return data(using: .utf8)
    }
    var base64DecodedData: Data? {
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

class console {
    class func log(_ arg : Any) {
        print(arg)
    }
}

func divide (_ left: Double, right: Double) -> Double {
    return Double(left) / Double(right)
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


extension Date {
    static func daysOffsetFromToday(_ offset: Int) -> Date {
        return Date(timeIntervalSinceNow: TimeInterval(60*60*24*offset))
    }
    
    func getComponents(_ types: Set<Calendar.Component>) -> DateComponents {
        //load gregorian calendar
        let calendar = Calendar(identifier: .gregorian)
        //create DateComponents from the Date and Calendar
        let components = calendar.dateComponents(types, from: self)
        
        return components
    }
    
    // date into convert into day month year
    func getDayMonthYear() -> (day: Int, month: Int, year: Int) {
        let components = self.getComponents([.year, .month, .day])
        
        // convert to day month year
        let day   = components.day!
        let month = components.month!
        let year  = components.year!
        
        return (day, month, year)
    }
    
    func isWeekday() -> Bool {
        let components = self.getComponents([.weekday])
        
        // get day of week
        let weekday = components.weekday!
        
        return (weekday < 7 && weekday > 1)
    }
}
