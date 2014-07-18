//
//  User.m
//  Bowdoin Dining
//
//  Created by Ruben on 7/16/14.
//
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Course.h"
#import "GDataXMLNode.h"
#import "CSGoldController.h"
@interface User ()
@end

@implementation User
-(id) initWithUsername:(NSString *) username password:(NSString *) password {
    // Call superclass's initializer
    self = [super init];
    if( !self ) return nil;
    
    [self setUsername:username];
    [self setPassword:password];
    
    CSGoldController *controller = [[CSGoldController alloc] init];
    NSData *userData = [controller getCSGoldDataWithUserName: username password: password];
    
    if(userData != nil) {
        [self parseData:userData];
        return self;
    } else {
        return nil;
    }
}

-(void)parseData:(NSData *)userData {
    NSError *error;
    //Create Google XML parsing object from NSData, grab "<meal>"s below root
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:userData options:0 error:&error];
    GDataXMLElement *root = doc.rootElement;
    GDataXMLElement *soapBody = [[root elementsForName:@"soap:Body"] firstObject];
    GDataXMLElement *CSGoldSVCBalancesResponse = [[soapBody elementsForName:@"GetCSGoldSVCBalancesResponse"] firstObject];
    GDataXMLElement *CSGoldSVCBalancesResult = [[CSGoldSVCBalancesResponse elementsForName:@"GetCSGoldSVCBalancesResult"] firstObject];
    GDataXMLElement *diffgrDiffgram = [[CSGoldSVCBalancesResult elementsForName:@"diffgr:diffgram"] firstObject];
    GDataXMLElement *DocumentElement = [[diffgrDiffgram elementsForName:@"DocumentElement"] firstObject];
    
    GDataXMLElement *dtCSGoldSVCBalances1 = [[DocumentElement elementsForName:@"dtCSGoldSVCBalances"] firstObject];
    GDataXMLElement *dtCSGoldSVCBalances2 = [[DocumentElement elementsForName:@"dtCSGoldSVCBalances"]  lastObject];
    GDataXMLElement *firstName = [[dtCSGoldSVCBalances1 elementsForName:@"FIRSTNAME"] firstObject];
    GDataXMLElement *lastName  = [[dtCSGoldSVCBalances1 elementsForName:@"LASTNAME"]  firstObject];
    GDataXMLElement *balance   = [[dtCSGoldSVCBalances1 elementsForName:@"BALANCE"]   firstObject];
    GDataXMLElement *ppoints   = [[dtCSGoldSVCBalances2 elementsForName:@"BALANCE"]   firstObject];
    
    [self setFirstname: firstName.stringValue];
    [self setLastname: lastName.stringValue];
    [self setCardBalance: [balance.stringValue doubleValue]/100.0];
    [self setPolarPoints: [ppoints.stringValue doubleValue]/100.0];
    [self setMealsLeft:   [@"123" intValue]]; //TBD
    
    //return user to waiting classes
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self forKey:@"User"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UserFinishedLoading"
     object:nil
     userInfo:userInfo];
}

@end