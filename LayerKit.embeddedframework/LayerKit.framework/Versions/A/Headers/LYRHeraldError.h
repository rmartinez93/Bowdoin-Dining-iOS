//
//  LYRDataExchangeError.h
//  DataExchange
//
//  Created by Klemen Verdnik on 7/22/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import "LYRError.h"

#ifdef ErrorCodeScope
#undef ErrorCodeScope
#endif

#define ErrorCodeScope                                  -5000

typedef NS_ENUM(NSInteger, LYRErrorCode_Herald) {
    LYRErrorCode_Herald_UNDEFINED_ERROR                 = ErrorCodeScope - 0,
    LYRErrorCode_Herald_CONNECT_NETWORK_ERROR           = ErrorCodeScope - 1,
    LYRErrorCode_Herald_CONNECT_TIMEOUT_ERROR           = ErrorCodeScope - 2,
    LYRErrorCode_Herald_CONNECT_CONFIG_ERROR            = ErrorCodeScope - 3,
    LYRErrorCode_Herald_REMOTE_CLOSED_ERROR             = ErrorCodeScope - 4,
    LYRErrorCode_Herald_PROTOCOL_INIT_ERROR             = ErrorCodeScope - 5,
    LYRErrorCode_Herald_AUTH_INVALID_TOKEN_ERROR        = ErrorCodeScope - 6,
    LYRErrorCode_Herald_AUTH_UNDEF_ERROR                = ErrorCodeScope - 7,
    LYRErrorCode_Herald_ADD_RPC_CHANNEL_ERROR           = ErrorCodeScope - 8,
    LYRErrorCode_Herald_ADD_PUSH_CHANNEL_ERROR          = ErrorCodeScope - 9,
    LYRErrorCode_Herald_REMOVE_CHANNEL_ERROR            = ErrorCodeScope - 10,
    LYRErrorCode_Herald_KEEPALIVE_ERROR                 = ErrorCodeScope - 11,
    LYRErrorCode_Herald_TIMEOUT_ERROR                   = ErrorCodeScope - 12,
    LYRErrorCode_Herald_SHUTTING_DOWN                   = ErrorCodeScope - 13,
};

FOUNDATION_EXTERN NSString *const kLYRErrorDomainHerald;

@interface LYRHeraldError : NSObject

@end