//
//  CSGoldController.h
//  Bowdoin Dining
//
//  Created by Ben Johnson on 9/23/10.
//  Copyright Two Fourteen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSGoldController : NSObject {
	
	NSData *storedDate;
	NSData *transactionData;
	
}

@property (nonatomic, assign) NSString *userName;
@property (nonatomic, assign) NSString *password;


// Public Methods
- (NSData *)getCSGoldDataWithUserName:(NSString*)user password:(NSString*)pass;
- (NSData*)getCSGoldLineCountsWithUserName:(NSString*)user password:(NSString*)pass;
- (NSData*)getCSGoldTransactionsWithUserName:(NSString*)user password:(NSString*)pass;

// Private Methods
- (NSMutableString*)returnSoapEnvelopeForService:(NSString*)serviceRequested;
- (NSData *)createSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope;

@end
