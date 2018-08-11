//
//  BowdoinAPIParser.swift
//  Bowdoin Dining
//
//  Created by Ruben on 2/19/15.
//
//

import Foundation

class BowdoinAPIParser {
    
    //Parses Balance and Polar Point XML
    //returns a tuple with user data, or nil if failed
    class func parseAccountData(_ soapBody : GDataXMLElement) -> (firstName : String, lastName : String, cardBalance : Double, polarPoints : Double)? {
        let CSGoldSVCBalancesResponse = soapBody.elements(forName: "GetCSGoldSVCBalancesResponse")?.first as! GDataXMLElement?

        if CSGoldSVCBalancesResponse != nil {
            let CSGoldSVCBalancesResult = CSGoldSVCBalancesResponse!.elements(forName: "GetCSGoldSVCBalancesResult")?.first as! GDataXMLElement?
            
            let diffgrDiffgram = CSGoldSVCBalancesResult!.elements(forName: "diffgr:diffgram")?.first as! GDataXMLElement?
            
            if diffgrDiffgram != nil {
                let DocumentElement = diffgrDiffgram!.elements(forName: "DocumentElement")?.first as! GDataXMLElement?
                
                if DocumentElement != nil {
                    let dtCSGoldSVCBalances1 = DocumentElement!.elements(forName: "dtCSGoldSVCBalances")?.first as! GDataXMLElement?
                    
                    let dtCSGoldSVCBalances2 = DocumentElement!.elements(forName: "dtCSGoldSVCBalances")?.last as! GDataXMLElement?
                    
                    if dtCSGoldSVCBalances1 != nil && dtCSGoldSVCBalances2 != nil {
                        let firstName = dtCSGoldSVCBalances1!.elements(forName: "FIRSTNAME")?.first as! GDataXMLElement?
                        let lastName  = dtCSGoldSVCBalances1!.elements(forName: "LASTNAME")?.first as! GDataXMLElement?
                        let balance   = dtCSGoldSVCBalances1!.elements(forName: "BALANCE")?.first as! GDataXMLElement?
                        let ppoints   = dtCSGoldSVCBalances2!.elements(forName: "BALANCE")?.first as! GDataXMLElement?
                        
                        if firstName != nil && lastName != nil && balance != nil && ppoints != nil {
                            return
                                (firstName!.stringValue(),
                                    lastName!.stringValue(),
                                    Double(Int(balance!.stringValue())!)/100.0,
                                    Double(Int(ppoints!.stringValue())!)/100.0)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    //Parses Meals Remaining XML
    //returns number of meals left, or nil if failed
    class func parseMealsLeft(_ soapBody : GDataXMLElement) -> Int? {
        let CSGoldMPBalancesResponse = soapBody.elements(forName: "GetCSGoldMPBalancesResponse")?.first as! GDataXMLElement?
        
        if CSGoldMPBalancesResponse != nil {
            let CSGoldMPBalancesResult = CSGoldMPBalancesResponse!.elements(forName: "GetCSGoldMPBalancesResult")?.first as! GDataXMLElement?
            
            if CSGoldMPBalancesResult != nil {
                let diffgrDiffgram = CSGoldMPBalancesResult!.elements(forName: "diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement  = diffgrDiffgram!.elements(forName: "DocumentElement")?.first as! GDataXMLElement?
                    
                    if diffgrDiffgram!.elements(forName: "DocumentElement") != nil {//if user is on a meal plan
                        var CSGoldMPBalances : GDataXMLElement? = nil
                        
                        //different element depending on semester
                        let components = (Calendar.current as NSCalendar).components(NSCalendar.Unit.month, from: Date())
                        if components.month! > 6 {
                            CSGoldMPBalances = DocumentElement!.elements(forName: "csGoldMPBalances")?.first as! GDataXMLElement?
                        } else {
                            CSGoldMPBalances = DocumentElement!.elements(forName: "csGoldMPBalances")?.last as! GDataXMLElement?
                        }
                        
                        if CSGoldMPBalances != nil {
                            let smallBucket  = CSGoldMPBalances!.elements(forName: "SMALLBUCKET")?.first as! GDataXMLElement?
                            
                            let mediumBucket = CSGoldMPBalances!.elements(forName: "MEDIUMBUCKET")?.first as! GDataXMLElement?
                            
                            if smallBucket != nil && mediumBucket != nil {
                                return Int(smallBucket!.stringValue())! + Int(mediumBucket!.stringValue())!
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
    
    //parses Transaction Data XML
    //returns array of Transaction objects with transaction data, or nil if failed
    class func parseTransactions(_ soapBody : GDataXMLElement) -> [Transaction]? {
        let CSGoldGLTransResponse = soapBody.elements(forName: "GetCSGoldGLTransResponse")?.first as! GDataXMLElement?
        
        if CSGoldGLTransResponse != nil {
            let GetCSGoldGLTransResult = CSGoldGLTransResponse!.elements(forName: "GetCSGoldGLTransResult")?.first as! GDataXMLElement?
            
            if GetCSGoldGLTransResult != nil {
                let diffgrDiffgram = GetCSGoldGLTransResult!.elements(forName: "diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement = diffgrDiffgram!.elements(forName: "DocumentElement")?.first as! GDataXMLElement?
                    
                    if DocumentElement != nil {
                        let CSGoldGLTrans = DocumentElement!.elements(forName: "dtCSGoldGLTrans")
                        if CSGoldGLTrans != nil {
                            var transactions : [Transaction] = []
                            for trans in (CSGoldGLTrans?.reversed())! {
                                let date = ((trans as AnyObject).elements(forName: "TRANDATE")?.first as AnyObject).stringValue
                                let desc = ((trans as AnyObject).elements(forName: "LONGDES")?.first as AnyObject).stringValue
                                let amnt = ((trans as AnyObject).elements(forName: "APPRVALUEOFTRAN")?.first as AnyObject).stringValue
                                let blnc = ((trans as AnyObject).elements(forName: "BALVALUEAFTERTRAN")?.first as AnyObject).stringValue
                                transactions.append(Transaction(name: desc!, date: date!, amount: amnt!, balance: blnc!))
                            }
                            
                            return transactions
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    //parses Line Data XML
    //returns a tuple of 3 arrays (one per dining venue) with number of swipes each minute for last 30 minutes; or nil if failed
    class func parseLines(_ soapBody : GDataXMLElement) -> (thorneLine: [Int], moultonLine: [Int], expressLine: [Int])? {
        var thorneLine : [Int] = []
        var moultonLine : [Int] = []
        var expressLine : [Int] = []
        
        let CSGoldLineResponse = soapBody.elements(forName: "GetCSGoldLineCountsHistogramResponse")?.first as! GDataXMLElement?
        
        if CSGoldLineResponse != nil {
            let GetCSGoldLineResult = CSGoldLineResponse!.elements(forName: "GetCSGoldLineCountsHistogramResult")?.first as! GDataXMLElement?
            
            if GetCSGoldLineResult != nil {
                let diffgrDiffgram = GetCSGoldLineResult!.elements(forName: "diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement = diffgrDiffgram!.elements(forName: "DocumentElement")?.first as! GDataXMLElement?
                    
                    if DocumentElement != nil {
                        let dtCSGoldLineHistogram = DocumentElement!.elements(forName: "dtCSGoldLineHistogram")
                        
                        if dtCSGoldLineHistogram != nil {
                            for dataPoint in dtCSGoldLineHistogram! {
                                let location = ((dataPoint as! GDataXMLElement).elements(forName: "LOCATION")?.first as AnyObject).stringValue
                                let count    = Int((((dataPoint as! GDataXMLElement).elements(forName: "LINECOUNT")?.first as AnyObject).stringValue)!)
                                
                                if location == "Thorne Aero 1" {
                                    thorneLine.append(count!)
                                } else if location == "Moulton Union Aero 1" {
                                    moultonLine.append(count!)
                                } else if location == "MU Aero 02 - Polar Express" {
                                    expressLine.append(count!)
                                }
                            }
                            
                            return (thorneLine: thorneLine, moultonLine: moultonLine, expressLine: expressLine)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    class func isDiningHallOpen(_ hall : String) -> Bool {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.locale = Locale(identifier: "en-US");
        
        let today = Date();
        let components = today.getComponents([.hour, .minute])
        let minute  = components.minute!
        let hour    = components.hour!
        
        if hall == "thorne" {
            if today.isWeekday() {
                if ((hour > 7 && hour < 9) || (hour == 7 && minute >= 30) || (hour == 9 && minute <= 30)) ||
                    ((hour >= 11 && hour < 13) || (hour == 13 && minute <= 30)) ||
                    ((hour >= 17 && hour < 19) || (hour == 19 && minute <= 30)) {
                        return true //Thorne Open
                } else {
                    return false //Thorne Closed
                }
            } else {
                if ((hour >= 11 && hour < 13) || (hour == 13 && minute <= 30)) ||
                    ((hour >= 17 && hour < 19) || (hour == 19 && minute <= 30)) {
                        return true //Thorne Open
                } else {
                    return false //Thorne Closed
                }
            }
        } else if hall == "moulton" {
            if today.isWeekday() {
                if ((hour >= 7 && hour < 10) || (hour == 10 && minute <= 30)) ||
                    (hour >= 11 && hour < 14) ||
                    (hour >= 17 && hour < 19) {
                        return true //Moulton Open
                } else {
                    return false //Moulton Closed
                }
            } else {
                if (hour >= 9 && hour < 11) ||
                    ((hour >= 11 && hour < 12) || (hour == 12 && minute <= 30)) ||
                    ((hour >= 17 && hour < 19) || (hour == 19 && minute <= 30)) {
                        return true //Moulton Open
                } else {
                    return false //Moulton Closed
                }
            }
        } else {
            return false
        }
    }
    
    class func nameOfDiningHallWithId(_ id : Int) -> String {
        return id == 0 ? "Moulton" : "Thorne"
    }
}
