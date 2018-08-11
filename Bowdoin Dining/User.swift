//
//  User.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez Jr on 7/17/14.
//


import Foundation

class User {
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
    var thorneScore : Double?
    var moultonScore : Double?
    var expressScore : Double?
    
    init(username : String, password : String) {
        self.username = username
        self.password = password
        self.loggedIn = true
    }
    
    //returns true if user credentials are stored
    class func credentialsStored() -> Bool {
        let userDefaults = UserDefaults.standard
        let username     = userDefaults.object(forKey: "bowdoin_username") as? NSString
        let password     = userDefaults.object(forKey: "bowdoin_password") as? NSString
        
        if username != nil && password != nil {
            return true
        }
        
        return false
    }
    
    class func forget() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "bowdoin_username")
        userDefaults.removeObject(forKey: "bowdoin_password")
        userDefaults.synchronize()
    }
    
    func remember() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.username, forKey: "bowdoin_username")
        userDefaults.set(self.password, forKey: "bowdoin_password")
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
        self.moultonScore = nil
        self.thorneScore  = nil
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
        if BowdoinAPIParser.isDiningHallOpen("thorne") || BowdoinAPIParser.isDiningHallOpen("moulton") {
            BowdoinAPIController(user: self).getLineData()
        }
    }

    func parseData(_ data: Data, type: String) {
        self.dataLoaded = true

        do {
            let doc = try GDataXMLDocument(data: data, options: 0)
            let root = doc.rootElement
            
            let soapBody = root()?.elements(forName: "soap:Body").first as! GDataXMLElement?
            
            if soapBody != nil {
                switch type {
                case "account":
                    let accountDetails = BowdoinAPIParser.parseAccountData(soapBody!)
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
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "AccountFinishedLoading"),
                            object: nil,
                            userInfo: nil)
                    } else {
                        self.dataLoadingFailed()
                    }
                case "transactions":
                    let transactions = BowdoinAPIParser.parseTransactions(soapBody!)
                    if transactions != nil {
                        self.transactions = transactions
                        
                        //success! Finished loading Transactions.
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "TransactionsFinishedLoading"),
                            object: nil,
                            userInfo: nil)
                    } else {
                        self.dataLoadingFailed()
                    }
                case "lines":
                    let lines = BowdoinAPIParser.parseLines(soapBody!)
                    
                    if lines != nil {
                        self.thorneScore  = BowdoinAPIParser.isDiningHallOpen("thorne")  ? score(lines!.thorneLine, lineName: "thorne")  : nil
                        self.moultonScore = BowdoinAPIParser.isDiningHallOpen("moulton") ? score(lines!.thorneLine, lineName: "moulton") : nil
                    } else {
                        self.thorneScore = nil
                        self.moultonScore = nil
                    }
                    
                    //success! Finished loading.
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "LineDataLoaded"),
                        object: nil,
                        userInfo: nil)
                default:
                    break
                }
            }
        } catch {
            print("Error Parsing Menu")
        }
    }
    
    func score(_ line: [Int], lineName: String) -> Double {
        let length = line.count
        
        //if no entries or no line, return
        if length == 0 || line.sum() == 0 {
            return 0
        }
        
        // Crowdedness Threshold based on Location
        // Allowable Points assumes crowdedness threshold reached every minute
        var crowdednessThreshold : Double
        let maximumPossibleScore = 4.5
        if lineName == "thorne" {
            crowdednessThreshold = 20
        } else if lineName == "moulton" {
            crowdednessThreshold = 15
        } else {
            crowdednessThreshold = 5
        }
        
        var totalScore = 0.0
        for i in 0 ..< length {
            if i >= length-10 {
                let currentLineCount = line[i]
                let minuteCrowdedness = Double(currentLineCount) / crowdednessThreshold
                let index = i - (length-11)
                let scaleMultiplier = log10(Double(index))
                let score = minuteCrowdedness*scaleMultiplier
                
                totalScore += score
            }
        }
        
        let finalScore = totalScore / maximumPossibleScore

        return finalScore
    }
    
    func dataLoadingFailed() {
        self.dataLoaded = false
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "UserLoadingFailed"),
            object: nil,
            userInfo: nil)
    }
}

protocol UserDelegate {
    func dataLoadingFailed(_ notification : Notification)
}
