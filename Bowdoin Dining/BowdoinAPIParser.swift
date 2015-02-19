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
        var CSGoldSVCBalancesResponse = soapBody.elementsForName("GetCSGoldSVCBalancesResponse")?.first as GDataXMLElement?
        
        if CSGoldSVCBalancesResponse != nil {
            var CSGoldSVCBalancesResult = CSGoldSVCBalancesResponse!.elementsForName("GetCSGoldSVCBalancesResult")?.first as GDataXMLElement?
            
            var diffgrDiffgram = CSGoldSVCBalancesResult!.elementsForName("diffgr:diffgram")?.first as GDataXMLElement?
            
            if diffgrDiffgram != nil {
                var DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as GDataXMLElement?
                
                if DocumentElement != nil {
                    var dtCSGoldSVCBalances1 = DocumentElement!.elementsForName("dtCSGoldSVCBalances")?.first as GDataXMLElement?
                    
                    var dtCSGoldSVCBalances2 = DocumentElement!.elementsForName("dtCSGoldSVCBalances")?.last as GDataXMLElement?
                    
                    if dtCSGoldSVCBalances1 != nil && dtCSGoldSVCBalances2 != nil {
                        var firstName = dtCSGoldSVCBalances1!.elementsForName("FIRSTNAME")?.first as GDataXMLElement?
                        var lastName  = dtCSGoldSVCBalances1!.elementsForName("LASTNAME")?.first as GDataXMLElement?
                        var balance   = dtCSGoldSVCBalances1!.elementsForName("BALANCE")?.first as GDataXMLElement?
                        var ppoints   = dtCSGoldSVCBalances2!.elementsForName("BALANCE")?.first as GDataXMLElement?
                        
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
        var CSGoldMPBalancesResponse = soapBody.elementsForName("GetCSGoldMPBalancesResponse")?.first as GDataXMLElement?
        
        if CSGoldMPBalancesResponse != nil {
            var CSGoldMPBalancesResult = CSGoldMPBalancesResponse!.elementsForName("GetCSGoldMPBalancesResult")?.first as GDataXMLElement?
            
            if CSGoldMPBalancesResult != nil {
                var diffgrDiffgram = CSGoldMPBalancesResult!.elementsForName("diffgr:diffgram")?.first as GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    var DocumentElement  = diffgrDiffgram!.elementsForName("DocumentElement")?.first as GDataXMLElement?
                    
                    if diffgrDiffgram!.elementsForName("DocumentElement") != nil {//if user is on a meal plan
                        var CSGoldMPBalances : GDataXMLElement? = nil
                        
                        //different element depending on semester
                        var components = NSCalendar.currentCalendar().components(NSCalendarUnit.MonthCalendarUnit, fromDate: NSDate())
                        if components.month > 6 {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances")?.first as GDataXMLElement?
                        } else {
                            CSGoldMPBalances = DocumentElement!.elementsForName("csGoldMPBalances")?.last as GDataXMLElement?
                        }
                        
                        if CSGoldMPBalances != nil {
                            var smallBucket  = CSGoldMPBalances!.elementsForName("SMALLBUCKET")?.first as GDataXMLElement?
                            
                            var mediumBucket = CSGoldMPBalances!.elementsForName("MEDIUMBUCKET")?.first as GDataXMLElement?
                            
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
        var CSGoldGLTransResponse = soapBody.elementsForName("GetCSGoldGLTransResponse")?.first as GDataXMLElement?
        
        if CSGoldGLTransResponse != nil {
            var GetCSGoldGLTransResult = CSGoldGLTransResponse!.elementsForName("GetCSGoldGLTransResult")?.first as GDataXMLElement?
            
            if GetCSGoldGLTransResult != nil {
                var diffgrDiffgram = GetCSGoldGLTransResult!.elementsForName("diffgr:diffgram")?.first as GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    var DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as GDataXMLElement?
                    
                    if DocumentElement != nil {
                        var CSGoldGLTrans = DocumentElement!.elementsForName("dtCSGoldGLTrans")
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
        
        var CSGoldLineResponse = soapBody.elementsForName("GetCSGoldLineCountsHistogramResponse")?.first as GDataXMLElement?
        
        if CSGoldLineResponse != nil {
            var GetCSGoldLineResult = CSGoldLineResponse!.elementsForName("GetCSGoldLineCountsHistogramResult")?.first as GDataXMLElement?
            
            if GetCSGoldLineResult != nil {
                var diffgrDiffgram = GetCSGoldLineResult!.elementsForName("diffgr:diffgram")?.first as GDataXMLElement?
                
                if diffgrDiffgram != nil {
                    var DocumentElement = diffgrDiffgram!.elementsForName("DocumentElement")?.first as GDataXMLElement?
                    
                    if DocumentElement != nil {
                        var dtCSGoldLineHistogram = DocumentElement!.elementsForName("dtCSGoldLineHistogram")
                        
                        if dtCSGoldLineHistogram != nil {
                            for dataPoint in dtCSGoldLineHistogram {
                                var location = (dataPoint as GDataXMLElement).elementsForName("LOCATION")?.first?.stringValue
                                var count    = (dataPoint as GDataXMLElement).elementsForName("LINECOUNT")?.first?.stringValue.toInt()
                                
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
}