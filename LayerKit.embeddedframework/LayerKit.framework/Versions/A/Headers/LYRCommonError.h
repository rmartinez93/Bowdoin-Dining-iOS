//
//  LYRCommonError.h
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

#define ErrorCodeScope                                  -0000

typedef NS_ENUM(NSInteger, LYRErrorCode_Common) {
    LYRErrorCode_Common_UNDEFINED_ERROR                 = ErrorCodeScope - 1,
    LYRErrorCode_Common_LAYERKIT_NOT_RUNNING            = ErrorCodeScope - 2,
    LYRErrorCode_Common_LAYERKIT_NOT_CONNECTED          = ErrorCodeScope - 3,
    LYRErrorCode_Common_LAYERKIT_NOT_LOGGEDIN           = ErrorCodeScope - 4,
    LYRErrorCode_Common_LAYERKIT_SYSMSG_SEND_FAIL       = ErrorCodeScope - 5,
    LYRErrorCode_Common_LAYERKIT_FAILED_TO_GET_RPC      = ErrorCodeScope - 6,
    LYRErrorCode_Common_LAYERKIT_ALREADY_RUNNING        = ErrorCodeScope - 7,
    LYRErrorCode_Common_LAYERKIT_FETCH_INPROGRESS       = ErrorCodeScope - 8,
};

FOUNDATION_EXTERN NSString *const kLYRErrorDomainCommon;

@interface LYRCommonError : NSObject

@end
