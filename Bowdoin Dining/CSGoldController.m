//
//  CSGoldController.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 9/23/10.
//  Updated by Ruben Martinez Jr, Summer 2014
//  Copyright Two Fourteen Software. All rights reserved.
//

#import "CSGoldController.h"
#import "BowdoinDining-Swift.h"

@implementation CSGoldController

@synthesize userName, password;
User *sender;
/***** CSGold SOAP request/actions *****/
// [soapEnvelope appendString:@"<tem:GetCSGoldGLTrans/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldSVCBalances/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldLineCounts/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldMPBalances/>"];

// Line Counts
// [soapEnvelope appendString:@"<tem:GetCSGoldLineCountsHistogram/>"];

//gets user account data (balance, points, meals)
- (NSData *)getCSGoldDataWithUserName:(NSString*)user password:(NSString*)pass forUser:(id)userSender {
    if (!user || !pass) {
		user = @"test";
		pass = @"testing";
	}
	
	self.userName = user;
	self.password = pass;
    
    sender = (User *) userSender;
    
    NSData *userInfo = [self createSOAPRequestWithEnvelope:
                        [self returnSoapEnvelopeForService:@"<tem:GetCSGoldSVCBalances/>"]];
    
	return userInfo;
}

//gets line status
- (NSData*)getCSGoldLineCountsWithUserName:(NSString*)user password:(NSString*)pass forUser:(id)userSender {
	// Sets the CSGold controllers UserName and Password
	self.userName = user;
	self.password = pass;
    
    sender = (User *) userSender;
    
    [self createSOAPRequestWithEnvelope:[self returnSoapEnvelopeForService:@"<tem:GetCSGoldLineCountsHistogram/>"]];

	return storedDate;
}

//gets recent transactions
- (NSData*)getCSGoldTransactionsWithUserName:(NSString*)user password:(NSString*)pass {
	// Sets the CSGold controllers UserName and Password
	self.userName = user;
	self.password = pass;
	
	[self createTransactionSOAPRequestWithEnvelope:
     [self returnSoapEnvelopeForService:@"<tem:GetCSGoldGLTrans/>"]];
	
	return transactionData;
}

- (NSMutableString*)returnSoapEnvelopeForService:(NSString*)serviceRequested{
	NSMutableString *soapEnvelope = [[NSMutableString alloc] initWithString:@""];
	
	[soapEnvelope appendString:@"<?xml version=\"1.0\"?>"];
	[soapEnvelope appendString:@"<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">"];
	[soapEnvelope appendString:@"<soapenv:Header/>"];
	[soapEnvelope appendString:@"<soapenv:Body>"];
	[soapEnvelope appendString:serviceRequested];
	[soapEnvelope appendString:@"</soapenv:Body>"];
	[soapEnvelope appendString:@"</soapenv:Envelope>"];
	
	return soapEnvelope;
}

- (NSData *)createSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope {
    //create request
    NSURL *url = [NSURL URLWithString:@"https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval: 5000];
    [req addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"bowdoin.edu" forHTTPHeaderField:@"Host"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody: [SOAPEnvelope dataUsingEncoding:NSUTF8StringEncoding]];
    
    //begin connection
    NSURLConnection * connection = [[NSURLConnection alloc]
                                    initWithRequest:req
                                    delegate:self
                                    startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
    
    return nil;
}
- (void)createTransactionSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope {
    //create request
    NSURL *url = [NSURL URLWithString:@"https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx"];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval: 5000];
    [req addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [req addValue:@"bowdoin.edu" forHTTPHeaderField:@"Host"];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody: [SOAPEnvelope dataUsingEncoding:NSUTF8StringEncoding]];
    
    //begin connection
    NSURLConnection * connection = [[NSURLConnection alloc]
                                    initWithRequest:req
                                    delegate:self
                                    startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
}

//takes care of HTTP Authentication
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSString* authMethod = [[challenge protectionSpace] authenticationMethod];
    
    if ([authMethod isEqualToString:NSURLAuthenticationMethodNTLM]) {
        NSURLCredential *credential = [NSURLCredential credentialWithUser:[NSString stringWithFormat:@"bowdoincollege\\%@", self.userName]
                                                                 password:self.password
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Response received, clear out data
    transactionData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Store received data
    [transactionData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [sender parseData:transactionData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"ERR %@", error);
}

@end
