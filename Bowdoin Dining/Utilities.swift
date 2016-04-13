//
//  Utilities.swift
//  Bowdoin Dining
//
//  Created by Ruben on 2/25/15.
//
//

import Foundation

extension Array {
    func combine(separator: String) -> String {
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
        return self.reduce(0, combine: { ($0 as Int) + ($1 as! Int) })
    }
}

extension String {
    func extractNumerics() -> String {
        let numerics     = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return self.componentsSeparatedByCharactersInSet(numerics).combine("")
    }
    
    func extractNumericsAsInt() -> Int {
        let numerics     = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return (self.componentsSeparatedByCharactersInSet(numerics).combine("") as NSString).integerValue
    }
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

class console {
    class func log(arg : Any) {
        print(arg)
    }
}

func divide (left: Double, right: Double) -> Double {
    return Double(left) / Double(right)
}

func isWeekday(dayOfWeek : NSInteger) -> Bool {
    return (dayOfWeek < 7 && dayOfWeek > 1)
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}