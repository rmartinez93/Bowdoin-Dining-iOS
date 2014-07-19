//
//  LYRUserInfo.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/25/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRPerson.h"
#import "LYRDevice.h"

/**
 The `LYRUserInfo` class defines an object containing information about the current user.
 */

@interface LYRUserInfo : LYRPerson

/**
 @name Properties
 */

/**
 @abstract The username of the user represented with the responder.
 */
@property (nonatomic, readonly) NSString *username;

/**
 @abstract An array of `LYRDevice` objects representing information about user's devices.
 */
@property (nonatomic, readonly) NSArray *devices;

/**
 @abstract Returns a Boolean value that indicates whether a given user is equal to the receiver.
 @param userInfo The user with which to compare the receiver.
 @return A Boolean value that determines the two users equality.
 */
- (BOOL)isEqualToUserInfo:(LYRUserInfo *)userInfo;

@end
