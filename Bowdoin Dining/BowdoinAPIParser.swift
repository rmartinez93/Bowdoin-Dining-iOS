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
    class func parseAccountData(soapBody : GDataXMLElement) -> (firstName : String, lastName : String, cardBalance : Double, polarPoints : Double)? {
        let CSGoldSVCBalancesResponse = soapBody.elementsForName("GetCSGoldSVCBalancesResponse")?.first as! GDataXMLElement?
        
        if CSGoldSVCBalancesResponse != nil {
            let CSGoldSVCBalancesResult = CSGoldSVCBalancesResponse!.elementsForName("GetCSGoldSVCBalancesResult")?.first as! GDataXMLElement?
            
            let diffgrDiffgram = CSGoldSVCBalancesResult!.elementsForName("diffgr:diffgram")?.first as! GDataXMLElement?
            
            if diffgrDiffgram != nil {
                let DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as! GDataXMLElement?
                
                if DocumentElement != nil {
                    let dtCSGoldSVCBalances1 = DocumentElement!.elementsForName("dtCSGoldSVCBalances")?.first as! GDataXMLElement?
                    
                    let dtCSGoldSVCBalances2 = DocumentElement!.elementsForName("dtCSGoldSVCBalances")?.last as! GDataXMLElement?
                    
                    if dtCSGoldSVCBalances1 != nil && dtCSGoldSVCBalances2 != nil {
                        var firstName = dtCSGoldSVCBalances1!.elementsForName("FIRSTNAME")?.first as! GDataXMLElement?
                        var lastName  = dtCSGoldSVCBalances1!.elementsForName("LASTNAME")?.first as! GDataXMLElement?
                        var balance   = dtCSGoldSVCBalances1!.elementsForName("BALANCE")?.first as! GDataXMLElement?
                        var ppoints   = dtCSGoldSVCBalances2!.elementsForName("BALANCE")?.first as! GDataXMLElement?
                        
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
    
    //Parses Meals Remaining XML
    //returns number of meals left, or nil if failed
    class func parseMealsLeft(soapBody : GDataXMLElement) -> Int? {
        let CSGoldMPBalancesResponse = soapBody.elementsForName("GetCSGoldMPBalancesResponse")?.first as! GDataXMLElement?
        
        if CSGoldMPBalancesResponse != nil {
            let CSGoldMPBalancesResult = CSGoldMPBalancesResponse!.elementsForName("GetCSGoldMPBalancesResult")?.first as! GDataXMLElement?
            
            if CSGoldMPBalancesResult != nil {
                let diffgrDiffgram = CSGoldMPBalancesResult!.elementsForName("diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement  = diffgrDiffgram!.elementsForName("DocumentElement")?.first as! GDataXMLElement?
                    
                    if diffgrDiffgram!.elementsForName("DocumentElement") != nil {//if user is on a meal plan
                        var CSGoldMPBalances : GDataXMLElement? = nil
                        
                        //different element depending on semester
                        var components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMonth, fromDate: NSDate())
                        if components.month > 6 {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances")?.first as! GDataXMLElement?
                        } else {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances")?.last as! GDataXMLElement?
                        }
                        
                        if CSGoldMPBalances != nil {
                            var smallBucket  = CSGoldMPBalances!.elementsForName("SMALLBUCKET")?.first as! GDataXMLElement?
                            
                            var mediumBucket = CSGoldMPBalances!.elementsForName("MEDIUMBUCKET")?.first as! GDataXMLElement?
                            
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
    
    //parses Transaction Data XML
    //returns array of Transaction objects with transaction data, or nil if failed
    class func parseTransactions(soapBody : GDataXMLElement) -> [Transaction]? {
        let CSGoldGLTransResponse = soapBody.elementsForName("GetCSGoldGLTransResponse")?.first as! GDataXMLElement?
        
        if CSGoldGLTransResponse != nil {
            let GetCSGoldGLTransResult = CSGoldGLTransResponse!.elementsForName("GetCSGoldGLTransResult")?.first as! GDataXMLElement?
            
            if GetCSGoldGLTransResult != nil {
                let diffgrDiffgram = GetCSGoldGLTransResult!.elementsForName("diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as! GDataXMLElement?
                    
                    if DocumentElement != nil {
                        let CSGoldGLTrans = DocumentElement!.elementsForName("dtCSGoldGLTrans")
                        if CSGoldGLTrans != nil {
                            var transactions : [Transaction] = []
                            for trans in reverse(CSGoldGLTrans) {
                                var date = trans.elementsForName("TRANDATE")?.first?.stringValue
                                var desc = trans.elementsForName("LONGDES")?.first?.stringValue
                                var amnt = trans.elementsForName("APPRVALUEOFTRAN")?.first?.stringValue
                                var blnc = trans.elementsForName("BALVALUEAFTERTRAN")?.first?.stringValue
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
    class func parseLines(soapBody : GDataXMLElement) -> (thorneLine: [Int], moultonLine: [Int], expressLine: [Int])? {
        var thorneLine : [Int] = []
        var moultonLine : [Int] = []
        var expressLine : [Int] = []
        
        let CSGoldLineResponse = soapBody.elementsForName("GetCSGoldLineCountsHistogramResponse")?.first as! GDataXMLElement?
        
        if CSGoldLineResponse != nil {
            let GetCSGoldLineResult = CSGoldLineResponse!.elementsForName("GetCSGoldLineCountsHistogramResult")?.first as! GDataXMLElement?
            
            if GetCSGoldLineResult != nil {
                let diffgrDiffgram = GetCSGoldLineResult!.elementsForName("diffgr:diffgram")?.first as! GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    let DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as! GDataXMLElement?
                    
                    if DocumentElement != nil {
                        let dtCSGoldLineHistogram = DocumentElement!.elementsForName("dtCSGoldLineHistogram")
                        
                        if dtCSGoldLineHistogram != nil {
                            for dataPoint in dtCSGoldLineHistogram {
                                let location = (dataPoint as! GDataXMLElement).elementsForName("LOCATION")?.first?.stringValue
                                let count    = (dataPoint as! GDataXMLElement).elementsForName("LINECOUNT")?.first?.stringValue.toInt()
                                
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
    
    class func isDiningHallOpen(hall : String) -> Bool {
        var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en-US");
        
        let today = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday, fromDate: NSDate())
        let weekday = today.weekday
        let minute  = today.minute
        let hour    = today.hour
        
        if hall == "thorne" {
            if isWeekday(weekday) {
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
            if isWeekday(weekday) {
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
    
    class func nameOfDiningHallWithId(id : Int) -> String {
        return id == 0 ? "Moulton" : "Thorne"
    }
}