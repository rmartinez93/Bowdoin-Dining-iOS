//
//  CSGoldController.h
//  Bowdoin Dining
//
//  Created by Ben Johnson on 9/23/10.
//  Updated by Ruben Martinez Jr, Summer 2014
//  Copyright Two Fourteen Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSGoldController : NSObject <NSURLConnectionDelegate> {
	
	NSData *storedDate;
	NSMutableData *transactionData;
	
}

@property (nonatomic, assign) NSString *userName;
@property (nonatomic, assign) NSString *password;


// Public Methods
- (NSData *)getCSGoldDataWithUserName:(NSString*)user password:(NSString*)pass forUser:(id)sender;
- (NSData*)getCSGoldLineCountsWithUserName:(NSString*)user password:(NSString*)pass forUser:(id)sender;
- (NSData*)getCSGoldTransactionsWithUserName:(NSString*)user password:(NSString*)pass;

// Private Methods
- (NSMutableString*)returnSoapEnvelopeForService:(NSString*)serviceRequested;
- (NSData *)createSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope;

@end
