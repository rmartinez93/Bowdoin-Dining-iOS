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
    var transactions : [Transaction]?
    
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
        
        //first load account
        BowdoinAPIController(username: username, password: password, user: self).getAccountData()
    }

    func parseData(data: NSData, type: String) {
        self.dataLoaded = true
        var error : NSError?
        var doc = GDataXMLDocument(data: data, options: 0, error: &error)
        var root = doc.rootElement

        var soapBody = (root().elementsForName("soap:Body") as NSArray).firstObject as GDataXMLElement

        if type == "account" {
            var CSGoldSVCBalancesResponse = (soapBody.elementsForName("GetCSGoldSVCBalancesResponse") as NSArray).firstObject as GDataXMLElement
            var CSGoldSVCBalancesResult   = (CSGoldSVCBalancesResponse.elementsForName("GetCSGoldSVCBalancesResult") as NSArray).firstObject as GDataXMLElement
            var diffgrDiffgram  = CSGoldSVCBalancesResult.elementsForName("diffgr:diffgram").first as GDataXMLElement
            var DocumentElement = diffgrDiffgram.elementsForName("DocumentElement").first as GDataXMLElement
            var dtCSGoldSVCBalances1 = DocumentElement.elementsForName("dtCSGoldSVCBalances").first as GDataXMLElement
            var dtCSGoldSVCBalances2 = DocumentElement.elementsForName("dtCSGoldSVCBalances").last as GDataXMLElement
            
            var firstName = dtCSGoldSVCBalances1.elementsForName("FIRSTNAME").first!.stringValue
            var lastName  = dtCSGoldSVCBalances1.elementsForName("LASTNAME").first!.stringValue
            var balance   = dtCSGoldSVCBalances1.elementsForName("BALANCE").first!.stringValue
            var ppoints   = dtCSGoldSVCBalances2.elementsForName("BALANCE").first!.stringValue
            
            self.firstname = firstName
            self.lastname  = lastName
            self.cardBalance = (balance as NSString).doubleValue/100.0
            self.polarPoints = (ppoints as NSString).doubleValue/100.0
            
            //now load meals
            BowdoinAPIController(username: username!, password: password!, user: self).getMealData()
        } else if type == "meals" {
            var CSGoldMPBalancesResponse = soapBody.elementsForName("GetCSGoldMPBalancesResponse").first as GDataXMLElement
            var CSGoldMPBalancesResult   = CSGoldMPBalancesResponse.elementsForName("GetCSGoldMPBalancesResult").first as GDataXMLElement
            var diffgrDiffgram   = CSGoldMPBalancesResult.elementsForName("diffgr:diffgram").first as GDataXMLElement
            var DocumentElement  = diffgrDiffgram.elementsForName("DocumentElement").first as GDataXMLElement
            var CSGoldMPBalances = DocumentElement.elementsForName("csGoldMPBalances").first as GDataXMLElement
            
            var smallBucket  = CSGoldMPBalances.elementsForName("SMALLBUCKET").first!.stringValue
            var mediumBucket = CSGoldMPBalances.elementsForName("MEDIUMBUCKET").first!.stringValue
            self.mealsLeft   = smallBucket.toInt()! + mediumBucket.toInt()!
            
            //lastly, load transactions
            BowdoinAPIController(username: username!, password: password!, user: self).getTransactionData()
        } else if type == "transactions" {
            var CSGoldGLTransResponse  = soapBody.elementsForName("GetCSGoldGLTransResponse").first as GDataXMLElement
            var GetCSGoldGLTransResult = CSGoldGLTransResponse.elementsForName("GetCSGoldGLTransResult").first as GDataXMLElement
            var diffgrDiffgram  = GetCSGoldGLTransResult.elementsForName("diffgr:diffgram").first as GDataXMLElement
            var DocumentElement = diffgrDiffgram.elementsForName("DocumentElement").first as GDataXMLElement
            var CSGoldGLTrans   = DocumentElement.elementsForName("dtCSGoldGLTrans")
            
            transactions = []
            
            for trans in reverse(CSGoldGLTrans) {
                var date = trans.elementsForName("TRANDATE").first!.stringValue
                var desc = trans.elementsForName("LONGDES").first!.stringValue
                var amnt = trans.elementsForName("APPRVALUEOFTRAN").first!.stringValue
                var blnc = trans.elementsForName("BALVALUEAFTERTRAN").first!.stringValue
                transactions!.append(Transaction(name: desc, date: date, amount: amnt, balance: blnc))
            }
            
            var userInfo = NSDictionary(object: self, forKey: "User")
            NSNotificationCenter.defaultCenter().postNotificationName("UserFinishedLoading",
                object: nil,
                userInfo: userInfo)
        }
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