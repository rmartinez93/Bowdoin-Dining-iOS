//
//  User.swift
//  Bowdoin Dining
//
//  Created by Ruben on 7/17/14.
//
//
//
//import Foundation
//
//class User {
//    var username : NSString = ""
//    var password : NSString = ""
//    var lastname : NSString = ""
//    var firstname : NSString = ""
//    var polarPoints : Double = 0.0
//    var cardBalance : Double = 0.0
//    var mealsLeft   : Int = 0
//    
//    func loadDataFor(username: NSString, password: NSString) -> Bool {
//        self.username = username;
//        self.password = password;
//        
//        var controller = CSGoldController();
//        var userData   = controller.getCSGoldDataWithUserName(username, password: password)
//        if(userData != nil) {
//            self.parseData(userData)
//            return true
//        } else {
//            return false
//        }
//    }
//    


        //Couldn't get this function working...Swift didn't seem to recognize methods of GDataXML



//    func parseData(data: NSData) {
//        var error : NSError?
//        
//        var doc = GDataXMLDocument(data: data, options: 0, error: &error)
//        var root = doc.rootElement;
//        var soapBody = root.elementsForName("")
//        var CSGoldSVCBalancesResponse = soapBody.elementsForName("GetCSGoldSVCBalancesResponse").firstObject()
//        var CSGoldSVCBalancesResult   = CSGoldSVCBalancesResponse.elementsForName("GetCSGoldSVCBalancesResult").firstObject()
//        var diffgrDiffgram            = CSGoldSVCBalancesResult.elementsForName("diffgr:diffgram").firstObject()
//        var DocumentElement           = diffgrDiffgram.elementsForName("DocumentElement").firstObject()
//        var dtCSGoldSVCBalances1      = DocumentElement.elementsForName("dtCSGoldSVCBalances").firstObject()
//        var dtCSGoldSVCBalances2      = DocumentElement.elementsForName("dtCSGoldSVCBalances").lastObject()
////        
////        GDataXMLElement *dtCSGoldSVCBalances1 = [[DocumentElement elementsForName:@"dtCSGoldSVCBalances"] firstObject];
////        GDataXMLElement *dtCSGoldSVCBalances2 = [[DocumentElement elementsForName:@"dtCSGoldSVCBalances"]  lastObject];
////        GDataXMLElement *firstName = [[dtCSGoldSVCBalances1 elementsForName:@"FIRSTNAME"] firstObject];
////        GDataXMLElement *lastName  = [[dtCSGoldSVCBalances1 elementsForName:@"LASTNAME"]  firstObject];
////        GDataXMLElement *balance   = [[dtCSGoldSVCBalances1 elementsForName:@"BALANCE"]   firstObject];
////        GDataXMLElement *ppoints   = [[dtCSGoldSVCBalances2 elementsForName:@"BALANCE"]   firstObject];
////        
////        [self setFirstname: firstName.stringValue];
////        [self setLastname: lastName.stringValue];
////        [self setCardBalance: [balance.stringValue doubleValue]/100.0];
////        [self setPolarPoints: [ppoints.stringValue doubleValue]/100.0];
////        [self setMealsLeft:   [@"123" intValue]]; //TBD
////        
////        //return user to waiting classes
////        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self forKey:@"User"];
////        [[NSNotificationCenter defaultCenter]
////        postNotificationName:@"UserFinishedLoading"
////        object:nil
////        userInfo:userInfo];
//    }
//}