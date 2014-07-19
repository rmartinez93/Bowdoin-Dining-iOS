//
//  LYRError.h
//  DataExchange
//
//  Created by Klemen Verdnik on 7/22/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LYREKey(code)           [@((NSInteger)code) stringValue]

FOUNDATION_EXTERN NSString *const kLYRErrorUserInfoExceptionKey;

typedef NS_ENUM(NSInteger, LYRErrorKey) {
    LYRErrorKeyDomain           = 0,
    LYRErrorKeyDescription      = 1,
    LYRErrorKeyReason           = 2,
    LYRErrorKeySuggestion       = 3,
};

@interface LYRErrorLookup : NSObject

+ (NSArray*)errorDataWithCode:(NSInteger)code;
+ (void)addToLookupWithDictionary:(NSDictionary*)dict withDomain:(NSString*)domain;

@end

@interface NSError (LYRError)

+ (NSError*)errorWithCode:(NSInteger)code;
+ (NSError*)errorWithCode:(NSInteger)code userInfo:(NSDictionary*)dict;
+ (NSError*)errorWithCode:(NSInteger)code embedException:(NSException*)exception;
+ (NSError*)errorWithCode:(NSInteger)code embedException:(NSException*)exception userInfo:(NSDictionary*)userInfoDict;

@end