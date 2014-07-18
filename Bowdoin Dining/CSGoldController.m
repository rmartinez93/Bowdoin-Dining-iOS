//
//  CSGoldController.m
//  Bowdoin Dining
//
//  Created by Ben Johnson on 9/23/10.
//  Copyright Two Fourteen Software. All rights reserved.
//

#import "CSGoldController.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation CSGoldController

@synthesize userName, password;

/***** CSGold SOAP request/actions *****/
// [soapEnvelope appendString:@"<tem:GetCSGoldGLTrans/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldSVCBalances/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldLineCounts/>"];
// [soapEnvelope appendString:@"<tem:GetCSGoldMPBalances/>"];

// Line Counts
// [soapEnvelope appendString:@"<tem:GetCSGoldLineCountsHistogram/>"];

//gets user account data (balance, points, meals)
- (NSData *)getCSGoldDataWithUserName:(NSString*)user password:(NSString*)pass {
    if (!user || !pass) {
		user = @"test";
		pass = @"testing";
	}
	
	self.userName = user;
	self.password = pass;
	
	NSLog(@"UN: %@ PW: %@", userName, password);
    
    NSData *userInfo = [self createSOAPRequestWithEnvelope:[self returnSoapEnvelopeForService:@"<tem:GetCSGoldSVCBalances/>"]];
    
	return userInfo;
}

//gets line status
- (NSData*)getCSGoldLineCountsWithUserName:(NSString*)user password:(NSString*)pass {
	// Sets the CSGold controllers UserName and Password
	self.userName = user;
	self.password = pass;
	
	[self createSOAPRequestWithEnvelope:[self returnSoapEnvelopeForService:@"<tem:GetCSGoldLineCountsHistogram/>"]];

	return storedDate;
}

//gets recent transactions
- (NSData*)getCSGoldTransactionsWithUserName:(NSString*)user password:(NSString*)pass {
	// Sets the CSGold controllers UserName and Password
	self.userName = user;
	self.password = pass;
	
	[self createTransactionSOAPRequestWithEnvelope:[self returnSoapEnvelopeForService:@"<tem:GetCSGoldGLTrans/>"]];
	
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

- (NSData *)createSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope{
	ASIHTTPRequest *SOAPRequest = [[ASIHTTPRequest alloc]
									initWithURL:[NSURL URLWithString:@"https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx"]];
	
	[SOAPRequest addRequestHeader:@"Content-Type" value:@"text/xml"];	
	[SOAPRequest addRequestHeader:@"Host" value:@"bowdoin.edu"];
    /* ***** values need to be set here ***** */
	[SOAPRequest setUsername:self.userName];
	[SOAPRequest setPassword:self.password];
	[SOAPRequest setDomain:@"bowdoincollege"];
	[SOAPRequest setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
	[SOAPRequest setUseSessionPersistence:YES];
	[SOAPRequest setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
	[SOAPRequest setUseCookiePersistence:NO];
	[SOAPRequest setUseKeychainPersistence:NO];
	[SOAPRequest setValidatesSecureCertificate:YES];
	[SOAPRequest setPostBody:(NSMutableData*)[SOAPEnvelope dataUsingEncoding:NSUTF8StringEncoding]];
	[SOAPRequest startSynchronous];
    
	// Makes sure authentication was successful
	if (SOAPRequest.responseStatusCode == 200) {
		NSLog(@"Authenticated");
		NSData *responseData = [SOAPRequest responseData];
        return responseData;
	}
    return nil;
}

- (void)createTransactionSOAPRequestWithEnvelope:(NSMutableString*)SOAPEnvelope{
	
	
	ASIHTTPRequest *SOAPRequest = [[ASIHTTPRequest alloc]
								   initWithURL:[NSURL URLWithString:@"https://gooseeye.bowdoin.edu/ws-csGoldShim/Service.asmx"]];
	
	[SOAPRequest addRequestHeader:@"Content-Type" value:@"text/xml"];	
	[SOAPRequest addRequestHeader:@"Host" value:@"bowdoin.edu"];
    /* ***** values need to be set here ***** */
	[SOAPRequest setUsername:self.userName];
	[SOAPRequest setPassword:self.password];
	[SOAPRequest setDomain:@"bowdoincollege"];
	[SOAPRequest setCachePolicy:ASIDoNotReadFromCacheCachePolicy];
	[SOAPRequest setUseSessionPersistence:YES];
	[SOAPRequest setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
	[SOAPRequest setUseCookiePersistence:NO];
	[SOAPRequest setUseKeychainPersistence:NO];
	[SOAPRequest setValidatesSecureCertificate:YES];
	[SOAPRequest setPostBody:(NSMutableData*)[SOAPEnvelope dataUsingEncoding:NSUTF8StringEncoding]];
	[SOAPRequest startSynchronous];
	
	// Makes sure authentication was successful
	if (SOAPRequest.responseStatusCode == 200) {
		NSData *responseData = [SOAPRequest responseData];
		transactionData = responseData;
	}
	
	NSLog(@"Request used Cached Response? %d", [SOAPRequest didUseCachedResponse]);
}

@end
