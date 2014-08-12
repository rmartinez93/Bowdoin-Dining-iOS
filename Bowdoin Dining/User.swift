//
//  User.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//


import Foundation

class User : NSObject {
    var username : String?
    var password : String?
    var lastname    : String?
    var firstname   : String?
    var polarPoints : Double?
    var cardBalance : Double?
    var mealsLeft   : Int?
    var dataLoaded  : Bool = false
    
    func logout() {
        self.username = ""
        self.password = ""
        self.lastname = ""
        self.firstname = ""
        self.polarPoints = 0.0
        self.cardBalance = 0.0
        self.mealsLeft   = 0
        self.dataLoaded  = false
    }
    
    func loadDataFor(username: NSString, password: NSString) {
        self.username = username;
        self.password = password;
        
        var controller = BowdoinAPIController(username: username, password: password, user: self)
        controller.getAccountData()
    }

    func parseData(data: NSData) {
        self.dataLoaded = true
        var error : NSError?
        
        var doc = GDataXMLDocument(data: data, options: 0, error: &error)
        var root = doc.rootElement
        var soapBody = (root().elementsForName("soap:Body") as NSArray).firstObject as GDataXMLElement
        var CSGoldSVCBalancesResponse = (soapBody.elementsForName("GetCSGoldSVCBalancesResponse") as NSArray).firstObject as GDataXMLElement
        var CSGoldSVCBalancesResult
            = (CSGoldSVCBalancesResponse.elementsForName("GetCSGoldSVCBalancesResult") as NSArray).firstObject as GDataXMLElement
        var diffgrDiffgram
            = (CSGoldSVCBalancesResult.elementsForName("diffgr:diffgram") as NSArray).firstObject as GDataXMLElement
        var DocumentElement
            = (diffgrDiffgram.elementsForName("DocumentElement") as NSArray).firstObject as GDataXMLElement
        var dtCSGoldSVCBalances1
            = (DocumentElement.elementsForName("dtCSGoldSVCBalances") as NSArray).firstObject as GDataXMLElement
        var dtCSGoldSVCBalances2
            = (DocumentElement.elementsForName("dtCSGoldSVCBalances") as NSArray).lastObject as GDataXMLElement
        
        var firstName = (dtCSGoldSVCBalances1.elementsForName("FIRSTNAME")   as NSArray).firstObject.stringValue
        var lastName  = (dtCSGoldSVCBalances1.elementsForName("LASTNAME")    as NSArray).firstObject.stringValue
        var balance   = (dtCSGoldSVCBalances1.elementsForName("BALANCE")     as NSArray).firstObject.stringValue
        var ppoints   = (dtCSGoldSVCBalances2.elementsForName("BALANCE")     as NSArray).firstObject.stringValue
        var meals     = (dtCSGoldSVCBalances2.elementsForName("DESCRIPTION") as NSArray).firstObject.stringValue
        self.firstname = firstName
        self.lastname  = lastName
        self.cardBalance = (balance as NSString).doubleValue/100.0
        self.polarPoints = (ppoints as NSString).doubleValue/100.0
        self.mealsLeft   = (meals   as String).extractNumericsAsInt()

        var userInfo = NSDictionary(object: self, forKey: "User")
        NSNotificationCenter.defaultCenter().postNotificationName("UserFinishedLoading",
            object: nil,
            userInfo: userInfo)
    }
    
    func dataLoadingFailed() {
        self.dataLoaded = false
    }
}

extension Array {
    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in enumerate(self) {
            str += "\(item)"
            if idx < self.count-1 {
                str += separator
            }
        }
        return str
    }
}

extension String {
    func extractNumerics() -> String {
        var numerics     = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return self.componentsSeparatedByCharactersInSet(numerics).combine("")
    }
    
    func extractNumericsAsInt() -> Int {
        var numerics     = NSCharacterSet(charactersInString: "0123456789").invertedSet
        return (self.componentsSeparatedByCharactersInSet(numerics).combine("") as NSString).integerValue
    }
}