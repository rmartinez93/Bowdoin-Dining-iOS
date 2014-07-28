//
//  User.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//


import Foundation

class User : NSObject {
    var username : NSString = ""
    var password : NSString = ""
    var lastname : NSString = ""
    var firstname : NSString = ""
    var polarPoints : Double = 0.0
    var cardBalance : Double = 0.0
    var mealsLeft   : Int = 0
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
        
        var controller = CSGoldController();
        var userData   = controller.getCSGoldDataWithUserName(username, password: password, forUser: self)
        if(userData != nil) {
            self.parseData(userData)
            self.dataLoaded = true
        } else {
            self.dataLoaded = false
        }
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
        
        var firstName = (dtCSGoldSVCBalances1.elementsForName("FIRSTNAME") as NSArray).firstObject.stringValue
        var lastName  = (dtCSGoldSVCBalances1.elementsForName("LASTNAME")  as NSArray).firstObject.stringValue
        var balance   = (dtCSGoldSVCBalances1.elementsForName("BALANCE")   as NSArray).firstObject.stringValue
        var ppoints   = (dtCSGoldSVCBalances2.elementsForName("BALANCE")   as NSArray).firstObject.stringValue
        
        self.firstname = firstName
        self.lastname  = lastName
        self.cardBalance = balance.bridgeToObjectiveC().doubleValue/100.0
        self.polarPoints = ppoints.bridgeToObjectiveC().doubleValue/100.0
        self.mealsLeft   = 123 //TBD

        var userInfo = NSDictionary(object: self, forKey: "User")
        NSNotificationCenter.defaultCenter().postNotificationName("UserFinishedLoading",
            object: nil,
            userInfo: userInfo)
    }
}