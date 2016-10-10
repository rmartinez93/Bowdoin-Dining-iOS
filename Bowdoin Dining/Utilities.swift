//
//  Utilities.swift
//  Bowdoin Dining
//
//  Created by Ruben on 2/25/15.
//
//

import Foundation

extension Array {
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
    func extractNumerics() -> String {
        let numerics     = CharacterSet(charactersIn: "0123456789").inverted
        return self.components(separatedBy: numerics).combine("")
    }
    
    func extractNumericsAsInt() -> Int {
        let numerics     = CharacterSet(charactersIn: "0123456789").inverted
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

func isWeekday(_ dayOfWeek : NSInteger) -> Bool {
    return (dayOfWeek < 7 && dayOfWeek > 1)
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
