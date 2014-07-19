//
//  LYRAddress.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/26/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#define sortedByAddress(x) [x sortedArrayUsingComparator:^NSComparisonResult(LYRAddress *a, LYRAddress *b) {\
    NSComparisonResult result = [a.userIdentifier compare:b.userIdentifier];\
    if (result != NSOrderedSame) return result;\
    result = [a.deviceIdentifier compare:b.deviceIdentifier];\
    if (result != NSOrderedSame) return result;\
    return [a.appIdentifier compare:b.appIdentifier];\
}]

/**
 The `LYRAddress` defines an address which is used internally within the Layer platform to address other peers. An `LYRAddress` object is a compound of three components: The app identifier, user identifier and device identifier.

 An `LYRAddress` object can be represented in a form of a string: `@"`<appIdentifier>`@`<userIdentifier>`@`<deviceIdentifier>`"`
 */

@interface LYRAddress : NSObject

/**
 @name Properties
 */

/**
 @abstract App identifier component of the Layer address.
 */
@property (nonatomic) NSString *appIdentifier;

/**
 @abstract User identifier component of the Layer address.
 */
@property (nonatomic) NSString *userIdentifier;

/**
 @abstract Device identifier component of the Layer address.
 */
@property (nonatomic) NSString *deviceIdentifier;

/**
 @abstract Returns a Boolean value that indicates whether a given address is equal to the receiver.
 @param address The address with which to compare the receiver.
 @return A Boolean value that determines the two addresses equality.
 */
- (BOOL)isEqualToAddress:(LYRAddress *)address;

/**
 @abstract Returns a Boolean value that indicates whether a given address is equal to the receiver (without comparing the device identifier).
 @param address The address with which to compare the receiver.
 @return A Boolean value that determines the two addresses equality (without comparing the device identifier).
 */
- (BOOL)isEqualToAddressIgnoringDeviceIdentifier:(LYRAddress *)address;

/**
 @abstract A string representation of the address.
 */
- (NSString *)stringRepresentation;

/**
 @abstract Converts the provided string to a Layer address.
 @param string A string containing the address.
 @return An `LYRAddress` object converted from the string parameter.
 */
+ (instancetype)addressWithString:(NSString *)string;

@end
