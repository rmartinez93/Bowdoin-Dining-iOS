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
    var loggedIn    : Bool = false
    var dataLoaded  : Bool = false
    var transactions : [Transaction]?
    
    init(username : String, password : String) {
        self.username = username
        self.password = password
        self.loggedIn = true
    }
    
    //returns true if user credentials are stored
    class func credentialsStored() -> Bool {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        var username     = userDefaults.objectForKey("bowdoin_username") as? NSString
        var password     = userDefaults.objectForKey("bowdoin_password") as? NSString
        
        if username != nil && password != nil {
            return true
        }
        
        return false
    }
    
    class func forget() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("bowdoin_username")
        userDefaults.removeObjectForKey("bowdoin_password")
        userDefaults.synchronize()
    }
    
    func remember() {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(self.username, forKey: "bowdoin_username")
        userDefaults.setObject(self.password, forKey: "bowdoin_password")
        userDefaults.synchronize()
    }
    
    func logout() {
        self.username = ""
        self.password = ""
        self.lastname = ""
        self.firstname = ""
        self.polarPoints = 0.0
        self.cardBalance = 0.0
        self.mealsLeft   = 0
        self.dataLoaded  = false
        self.loggedIn    = false
        User.forget()
    }
    
    func loadData() {
        //load account
        BowdoinAPIController(user: self).getAccountData()
    }

    func parseData(data: NSData, type: String) {
        self.dataLoaded = true
        var error : NSError?
        var doc = GDataXMLDocument(data: data, options: 0, error: &error)
        var root = doc.rootElement

        var soapBody = root().elementsForName("soap:Body").first as GDataXMLElement?
        
        if soapBody != nil {
            switch type {
            case "account":
                var accountDetails = parseAccountData(soapBody!)
                if accountDetails != nil {
                    self.firstname = accountDetails!.firstName
                    self.lastname  = accountDetails!.lastName
                    self.polarPoints = accountDetails!.polarPoints
                    self.cardBalance = accountDetails!.cardBalance
                    
                    //now load meals
                    BowdoinAPIController(user: self).getMealData()
                } else {
                    self.dataLoadingFailed()
                }
            case "meals":
                let mealsLeft = parseMealsLeft(soapBody!)
                if mealsLeft != nil {
                    self.mealsLeft = mealsLeft
                    
                    //lastly, load transactions
                    BowdoinAPIController(user: self).getTransactionData()
                } else {
                    self.dataLoadingFailed()
                }
            case "transactions":
                let transactions = parseTransactions(soapBody!)
                if transactions != nil {
                    self.transactions = transactions
                    
                    //success! Finished loading.
                    var userInfo = NSDictionary(object: self, forKey: "User")
                    NSNotificationCenter.defaultCenter().postNotificationName("UserFinishedLoading",
                        object: nil,
                        userInfo: userInfo)
                } else {
                    self.dataLoadingFailed()
                }
            default:
                break
            }
        }
    }
    
    func dataLoadingFailed() {
        self.dataLoaded = false
        
        var userInfo = NSDictionary(object: self, forKey: "User")
        NSNotificationCenter.defaultCenter().postNotificationName("UserLoadingFailed",
            object: nil,
            userInfo: userInfo)
    }
    
    func parseAccountData(soapBody : GDataXMLElement) -> (firstName : String, lastName : String, cardBalance : Double, polarPoints : Double)? {
        var CSGoldSVCBalancesResponse = (soapBody.elementsForName("GetCSGoldSVCBalancesResponse") != nil)
            ? soapBody.elementsForName("GetCSGoldSVCBalancesResponse").first as GDataXMLElement?
            : nil
        
        if CSGoldSVCBalancesResponse != nil {
            var CSGoldSVCBalancesResult = (CSGoldSVCBalancesResponse!.elementsForName("GetCSGoldSVCBalancesResult") != nil)
                ? CSGoldSVCBalancesResponse!.elementsForName("GetCSGoldSVCBalancesResult").first as GDataXMLElement?
                : nil
            
            var diffgrDiffgram = (CSGoldSVCBalancesResult!.elementsForName("diffgr:diffgram") != nil)
                ? CSGoldSVCBalancesResult!.elementsForName("diffgr:diffgram").first as GDataXMLElement?
                : nil
            
            if diffgrDiffgram != nil {
                var DocumentElement = (diffgrDiffgram!.elementsForName("DocumentElement") != nil)
                    ? diffgrDiffgram!.elementsForName("DocumentElement").first as GDataXMLElement?
                    : nil
                
                if DocumentElement != nil {
                    var dtCSGoldSVCBalances1 = (DocumentElement!.elementsForName("dtCSGoldSVCBalances") != nil)
                        ? DocumentElement!.elementsForName("dtCSGoldSVCBalances").first as GDataXMLElement?
                        : nil
                    var dtCSGoldSVCBalances2 = (DocumentElement!.elementsForName("dtCSGoldSVCBalances") != nil)
                        ? DocumentElement!.elementsForName("dtCSGoldSVCBalances").last as GDataXMLElement?
                        : nil
                    
                    if dtCSGoldSVCBalances1 != nil && dtCSGoldSVCBalances2 != nil {
                        var firstName = (dtCSGoldSVCBalances1!.elementsForName("FIRSTNAME") != nil)
                            ? dtCSGoldSVCBalances1!.elementsForName("FIRSTNAME").first as GDataXMLElement?
                            : nil
                        var lastName  = (dtCSGoldSVCBalances1!.elementsForName("LASTNAME") != nil)
                            ? dtCSGoldSVCBalances1!.elementsForName("LASTNAME").first as GDataXMLElement?
                            : nil
                        var balance   = (dtCSGoldSVCBalances1!.elementsForName("BALANCE") != nil)
                            ? dtCSGoldSVCBalances1!.elementsForName("BALANCE").first as GDataXMLElement?
                            : nil
                        var ppoints   = (dtCSGoldSVCBalances2!.elementsForName("BALANCE") != nil)
                            ? dtCSGoldSVCBalances2!.elementsForName("BALANCE").first as GDataXMLElement?
                            : nil
                        
                        if firstName != nil && lastName != nil && balance != nil && ppoints != nil {
                            return
                                (firstName!.stringValue(),
                                lastName!.stringValue(),
                                Double(balance!.stringValue().toInt()!)/100.0,
                                Double(ppoints!.stringValue().toInt()!)/100.0)
                        }
                    }
                }
            }
        }

        return nil
    }
    
    func parseMealsLeft(soapBody : GDataXMLElement) -> Int? {
        var CSGoldMPBalancesResponse = (soapBody.elementsForName("GetCSGoldMPBalancesResponse") != nil)
                ? soapBody.elementsForName("GetCSGoldMPBalancesResponse").first as GDataXMLElement?
                : nil
        
        if CSGoldMPBalancesResponse != nil {
            var CSGoldMPBalancesResult = (CSGoldMPBalancesResponse!.elementsForName("GetCSGoldMPBalancesResult") != nil)
                    ? CSGoldMPBalancesResponse!.elementsForName("GetCSGoldMPBalancesResult").first as GDataXMLElement?
                    : nil
            
            if CSGoldMPBalancesResult != nil {
                var diffgrDiffgram   = (CSGoldMPBalancesResult!.elementsForName("diffgr:diffgram") != nil)
                    ? CSGoldMPBalancesResult!.elementsForName("diffgr:diffgram").first as GDataXMLElement?
                    : nil
                
                if diffgrDiffgram != nil {
                    var DocumentElement  = (diffgrDiffgram!.elementsForName("DocumentElement") != nil)
                        ? diffgrDiffgram!.elementsForName("DocumentElement").first as GDataXMLElement?
                        : nil
                    
                    if diffgrDiffgram!.elementsForName("DocumentElement") != nil {//if user is on a meal plan
                        var CSGoldMPBalances : GDataXMLElement? = nil
                        
                        //different element depending on semester
                        var components = NSCalendar.currentCalendar().components(NSCalendarUnit.MonthCalendarUnit, fromDate: NSDate())
                        if components.month > 6 {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances").first as GDataXMLElement?
                        } else {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances").last as GDataXMLElement?
                        }
                        
                        if CSGoldMPBalances != nil {
                            var smallBucket  = (CSGoldMPBalances!.elementsForName("SMALLBUCKET") != nil)
                                ? CSGoldMPBalances!.elementsForName("SMALLBUCKET").first as GDataXMLElement?
                                : nil
                            var mediumBucket = (CSGoldMPBalances!.elementsForName("MEDIUMBUCKET") != nil)
                                ? CSGoldMPBalances!.elementsForName("MEDIUMBUCKET").first as GDataXMLElement?
                                : nil
                            
                            if smallBucket != nil && mediumBucket != nil {
                                return smallBucket!.stringValue().toInt()! + mediumBucket!.stringValue().toInt()!
                            }
                        }
                    } else {
                        return 0 //not on a meal plan
                    }
                }
            }
        }
        
        return nil
    }
    
    func parseTransactions(soapBody : GDataXMLElement) -> [Transaction]? {
        var CSGoldGLTransResponse = (soapBody.elementsForName("GetCSGoldGLTransResponse") != nil) ? soapBody.elementsForName("GetCSGoldGLTransResponse").first as GDataXMLElement? : nil
        
        if CSGoldGLTransResponse != nil {
            var GetCSGoldGLTransResult = (CSGoldGLTransResponse!.elementsForName("GetCSGoldGLTransResult") != nil)
                ? CSGoldGLTransResponse!.elementsForName("GetCSGoldGLTransResult").first as GDataXMLElement?
                : nil
            if GetCSGoldGLTransResult != nil {
                var diffgrDiffgram = (GetCSGoldGLTransResult!.elementsForName("diffgr:diffgram") != nil)
                    ? GetCSGoldGLTransResult!.elementsForName("diffgr:diffgram").first as GDataXMLElement?
                    : nil
                if diffgrDiffgram != nil {
                    var DocumentElement = (diffgrDiffgram!.elementsForName("DocumentElement") != nil)
                        ? diffgrDiffgram!.elementsForName("DocumentElement").first as GDataXMLElement?
                        : nil
                    if DocumentElement != nil {
                        var CSGoldGLTrans = DocumentElement!.elementsForName("dtCSGoldGLTrans")
                        if CSGoldGLTrans != nil {
                            var transactions : [Transaction] = []
                            for trans in reverse(CSGoldGLTrans) {
                                var date = trans.elementsForName("TRANDATE").first!.stringValue
                                var desc = trans.elementsForName("LONGDES").first!.stringValue
                                var amnt = trans.elementsForName("APPRVALUEOFTRAN").first!.stringValue
                                var blnc = trans.elementsForName("BALVALUEAFTERTRAN").first!.stringValue
                                transactions.append(Transaction(name: desc, date: date, amount: amnt, balance: blnc))
                            }
                            return transactions
                        }
                    }
                }
            }
        }
        
        return nil
    }
}

protocol UserDelegate {
    func userDidLoad(notification : NSNotification)
    func userLoadingFailed(notification : NSNotification)
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