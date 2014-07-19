//
//  LYRProfileInfo.h
//  LayerKit
//
//  Created by Klemen Verdnik on 8/8/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#define sortedByValue(x) [x sortedArrayUsingComparator:^NSComparisonResult(LYRProfileInfo *a, LYRProfileInfo *b) {\
    return [a.value compare:b.value];\
}]

/**
 The `LYRProfileInfo` class defines an object used for storing profile information and it's identifier.
 */

@interface LYRProfileInfo : NSObject

/**
 @name Properties
 */

/**
 @abstract Create a new `LYRProfileInfo` object and assigned the value.
 @param value The value to be assigned.
 @return An `LYRProfileInfo` object with an assigned value.
 */
+ (instancetype)objectWithValue:(NSString *)value;

/**
 @abstract The value of the profile information.
 */
@property (nonatomic) NSString *value;

/**
 @abstract The identifier of the profile information.
 */
@property (nonatomic) NSString *identifier;

@end


/**
 The `LYRPrimaryProfileInfo` class defines the primary profile info object.
 */

@interface LYRPrimaryProfileInfo : LYRProfileInfo

/**
 @name Properties
 */

/**
 @abstract Determines whether this is the primary profile information.
 */
@property (nonatomic, getter = isPrimary) BOOL primary;

@end


/**
 The `LYRPhoneNumber` class defines a phone object used in a profile and contains its phone number, identification number and determines whether this is the primary phone.
 */

@interface LYRPhoneNumber : LYRPrimaryProfileInfo

@end


/**
 The `LYREmailAddress` class defines an email object used in a profile and contains its email address, identifier and determines whether this is the primary email address.
 */

@interface LYREmailAddress : LYRPrimaryProfileInfo

@end


/**
 The `LYRURL` class defines an URL object used in a profile and contains the URL and its identifier.
 */

@interface LYRURL : LYRProfileInfo

@end


/**
 The `LYRPostalAddress` class defines a postal address object and contains its address and identifier.
 */

@interface LYRPostalAddress : LYRProfileInfo

@end