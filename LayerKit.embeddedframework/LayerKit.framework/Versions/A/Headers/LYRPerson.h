//
//  LYRPerson.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/25/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#if TARGET_OS_IPHONE
#   import <UIKit/UIKit.h>
typedef UIImage LYRImage;
#else
#   import <AppKit/AppKit.h>
typedef NSImage LYRImage;
#endif

#import "LYRAddress.h"
#import "LYRProfileInfo.h"

/**
 The `LYRPerson` class defines an object containing information about the current person.
 */

@interface LYRPerson : NSObject

/**
 @name Properties
 */

/**
 @abstract The person identifier.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract The first name of the person represented with the responder.
 */
@property (nonatomic) NSString *firstName;

/**
 @abstract The last name of the person represented with the responder.
 */
@property (nonatomic) NSString *lastName;

/**
 @abstract The profile image of the person represented with the responder.
 */
@property (nonatomic) LYRImage *profileImage;

/**
 @abstract An array of email addresses of the person associated with the responder. Each item is a `LYREmailAddress` object.
 */
@property (nonatomic, readonly) NSArray *emailAddresses;

/**
 @abstract An array of postal addresses of the person associated with the responder. Each item is a `LYRPostalAddress` object.
 */
@property (nonatomic, readonly) NSArray *postalAddresses;

/**
 @abstract An array of phone numbers of the person associated with the responder. Each item is a `LYRPhoneNumber` object.
 */
@property (nonatomic, readonly) NSArray *phoneNumbers;

/**
 @abstract An array of URLs of the person associated with this account. Each item is an `LYRURL` object.
 */
@property (nonatomic, readonly) NSArray *URLs;

/**
 @abstract An array of layer addresses of the person. Each item is an `LYRAddress` object.
 */
@property (nonatomic, readonly) NSArray *addresses;

/**
 @abstract Returns a Boolean value that indicates whether a given person is equal to the receiver.
 @param person The person with which to compare the receiver.
 @return A Boolean value that determines the two persons equality.
 */
- (BOOL)isEqualToPerson:(LYRPerson *)person;

/**
 @abstract The person's full name composed of firstName + ' ' + lastName.
 */
- (NSString *)fullName;

- (BOOL)addEmailAddress:(LYREmailAddress *)emailAddress error:(NSError **)error;
- (BOOL)addEmailAddresses:(NSArray *)emailAddresses error:(NSError **)error;
- (BOOL)removeEmailAddress:(LYREmailAddress *)emailAddress error:(NSError **)error;
- (BOOL)removeEmailAddresses:(NSArray *)emailAddresses error:(NSError **)error;

- (BOOL)addPostalAddress:(LYRPostalAddress *)postalAddress error:(NSError **)error;
- (BOOL)addPostalAddresses:(NSArray *)postalAddresses error:(NSError **)error;
- (BOOL)removePostalAddress:(LYRPostalAddress *)postalAddress error:(NSError **)error;
- (BOOL)removePostalAddresses:(NSArray *)postalAddresses error:(NSError **)error;

- (BOOL)addPhoneNumber:(LYRPhoneNumber *)phoneNumber error:(NSError **)error;
- (BOOL)addPhoneNumbers:(NSArray *)phoneNumbers error:(NSError **)error;
- (BOOL)removePhoneNumber:(LYRPhoneNumber *)phoneNumber error:(NSError **)error;
- (BOOL)removePhoneNumbers:(NSArray *)phoneNumbers error:(NSError **)error;

- (BOOL)addURL:(LYRURL *)URL error:(NSError **)error;
- (BOOL)addURLs:(NSArray *)URLs error:(NSError **)error;
- (BOOL)removeURL:(LYRURL *)URL error:(NSError **)error;
- (BOOL)removeURLs:(NSArray *)URLs error:(NSError **)error;

@end
