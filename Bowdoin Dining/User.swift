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
    var lines : [AnyObject]?
    
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
    
    func loadAccountData() {
        //load account
        BowdoinAPIController(user: self).getAccountData()
    }
    
    func loadTransactionData() {
        //load account
        BowdoinAPIController(user: self).getTransactionData()
    }
    
    func loadLineData() {
        //load account
        BowdoinAPIController(user: self).getLineData()
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
                var accountDetails = BowdoinAPIParser.parseAccountData(soapBody!)
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
                let mealsLeft = BowdoinAPIParser.parseMealsLeft(soapBody!)
                if mealsLeft != nil {
                    self.mealsLeft = mealsLeft                    
                    
                    //success! Finished loading Account.
                    NSNotificationCenter.defaultCenter().postNotificationName("AccountFinishedLoading",
                        object: nil,
                        userInfo: nil)
                } else {
                    self.dataLoadingFailed()
                }
            case "transactions":
                let transactions = BowdoinAPIParser.parseTransactions(soapBody!)
                if transactions != nil {
                    println("transactions loaded")
                    self.transactions = transactions
                    
                    //success! Finished loading Transactions.
                    NSNotificationCenter.defaultCenter().postNotificationName("TransactionsFinishedLoading",
                        object: nil,
                        userInfo: nil)
                } else {
                    self.dataLoadingFailed()
                }
            case "lines":
                let lines = BowdoinAPIParser.parseLines(soapBody!)
                if lines != nil {
                    var thorneScore = score(lines!.thorneLine, lineName: "thorne")
                    
                    //success! Finished loading.
                    NSNotificationCenter.defaultCenter().postNotificationName("LinesFinishedLoading",
                        object: nil,
                        userInfo: nil)
                } else {
                    self.dataLoadingFailed()
                }
            default:
                break
            }
        }
    }
    
    func score(line: [Int], lineName: String) -> Float {
        return 0
    }
    
    func dataLoadingFailed() {
        self.dataLoaded = false
        
        var userInfo = NSDictionary(object: self, forKey: "User")
        NSNotificationCenter.defaultCenter().postNotificationName("UserLoadingFailed",
            object: nil,
            userInfo: userInfo)
    }
}

protocol UserDelegate {
    func dataLoadingFailed(notification : NSNotification)
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