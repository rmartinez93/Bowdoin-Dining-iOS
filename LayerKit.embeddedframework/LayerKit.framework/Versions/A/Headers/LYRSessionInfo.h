//
//  LYRSessionInfo.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/26/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

/**
 The `LYRSessionInfo` class defines a session info object.

 @discussion The session info is useful for debugging purposes, when remote logging is enabled in Layer administrative pages `http://layer.com/admin`.
 */

@interface LYRSessionInfo : NSObject

/**
 @name Properties
 */

/**
@abstract The app identifier.
*/
@property (nonatomic, readonly) NSString *appIdentifier;

/**
 @abstract The access token creation date.
 */
@property (nonatomic, readonly) NSDate *createdDate;

/**
 @abstract The access token date expiration.
 */
@property (nonatomic, readonly) NSDate *expirationDate;

/**
 @abstract The access token.
 */
@property (nonatomic, readonly) NSString *accessToken;

/**
 @abstract The refresh token.
 */
@property (nonatomic, readonly) NSString *refreshToken;

@end
