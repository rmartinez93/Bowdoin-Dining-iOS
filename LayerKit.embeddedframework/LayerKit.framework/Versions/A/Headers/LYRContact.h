//
//  LYRContact.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/26/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRPerson.h"

/**
 The `LYRContact` class defines a contact object and stores its information.
 */

@interface LYRContact : LYRPerson

/**
 @abstract Returns a Boolean value that indicates whether a given contact is equal to the receiver.
 @param contact The contact with which to compare the receiver.
 @return A Boolean value that determines the two contacts equality.
 */
- (BOOL)isEqualToContact:(LYRContact *)contact;

@end
