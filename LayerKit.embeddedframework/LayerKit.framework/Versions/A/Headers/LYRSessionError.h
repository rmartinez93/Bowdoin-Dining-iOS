//
//  LYRSessionError.h
//  LayerKit
//
//  Created by Klemen Verdnik on 8/26/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRError.h"

#ifdef ErrorCodeScope
#undef ErrorCodeScope
#endif

#define ErrorCodeScope                                  -1000

typedef NS_ENUM(NSInteger, LYRErrorCode_Session) {
    LYRErrorCode_Session_UNDEFINED_ERROR               = ErrorCodeScope - 0,
    LYRErrorCode_Session_INVALID_CREDENTIALS           = ErrorCodeScope - 1,
    LYRErrorCode_Session_AUTHENTICATION_FAILED         = ErrorCodeScope - 2,
    LYRErrorCode_Session_ALREADY_AUTHENTICATED         = ErrorCodeScope - 3,
};

FOUNDATION_EXTERN NSString *const kLYRErrorDomainSession;

@interface LYRSessionError : NSObject

@end
