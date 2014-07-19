//
//  LYRMessageSyncError.h
//  LayerKit
//
//  Created by Klemen Verdnik on 19/11/13.
//  Copyright (c) 2013 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRError.h"

#ifdef ErrorCodeScope
#undef ErrorCodeScope
#endif

#define ErrorCodeScope                                  -9000

typedef NS_ENUM(NSInteger, LYRErrorCode_MsgSync) {
    LYRErrorCode_MsgSync_UNDEFINED_ERROR                = ErrorCodeScope - 0,
    LYRErrorCode_MsgSync_MESSAGE_ALREADY_EXISTS         = ErrorCodeScope - 1,
    LYRErrorCode_MsgSync_MESSAGE_DOESNT_EXIST           = ErrorCodeScope - 2,
    LYRErrorCode_MsgSync_USER_NOT_SENDER_OF_MESSAGE     = ErrorCodeScope - 3,
    LYRErrorCode_MsgSync_USER_IS_SENDER_OF_MESSAGE      = ErrorCodeScope - 4,
    LYRErrorCode_MsgSync_SYNC_EXCEPTION                 = ErrorCodeScope - 5,
    LYRErrorCode_MsgSync_BODY_DOWNLOAD_EXCEPTION        = ErrorCodeScope - 6,
    LYRErrorCode_MsgSync_BODY_ALREADY_FETCHING          = ErrorCodeScope - 7,
    LYRErrorCode_MsgSync_BODY_ALREADY_FETCHED           = ErrorCodeScope - 8,
};

FOUNDATION_EXTERN NSString *const kLYRErrorDomainMsgSync;

@interface LYRMessageSyncError : NSObject

@end
