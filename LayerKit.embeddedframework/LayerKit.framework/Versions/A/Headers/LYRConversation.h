//
//  LYRConversation.h
//  LayerKit
//
//  Created by Klemen Verdnik on 11/01/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYRMessage;

/**
 Possible `LYRConversationType` states.
 */
typedef NS_ENUM(NSUInteger, LYRConversationType) {
    /** A conversation type which distincts and threads messages based on their `threadIdentifier` property */
    LYRConversationTypeThread = 0,
    /** A conversation type which threads messages that are linked together by the `parentMessageIdentifier` property */
    LYRConversationTypeTree = 1,
    /** A conversation type which threads messages based on their set of participants (which is an union of `sender` and `recipients`) */
    LYRConversationTypeParticipants = 2,
};

/**
 The `LYRConversation` class defines a threaded structure of `LYRMessage` objects which form a conversation. Each `LYRMessage` that was ever sent or received becomes a part of at least one conversation. There are three methods of threading:
    - by the `threadIdentifier` property of the `LYRMessage` object,
    - by a message tree map which is dictated by the `parrentMessageIdentifier` property of the `LYRMessage` object, and lastly
    - by a set of participants, which is an union set of `sender` and `recipients` properties of the `LYRMessage`.
*/
@interface LYRConversation : NSObject

/**
 @name Properties
 */

/**
 @abstract Conversation identifier.
 @discussion This property can be very useful for fetching messages that belong to a specific conversation, and also with `LYRMessageController`.
*/
@property (nonatomic, readonly) NSString *identifier;

/**
 @abstract Type of the conversation.
 @see LYRConversationType
 */
@property (nonatomic, readonly) LYRConversationType type;

/**
 @abstract A set of all participants in the conversation, which is a union of `sender` and `recipients`.
 @discussion This property is only valid for conversations of type `LYRConversationTypeParticipants`.
 */
@property (nonatomic, readonly) NSSet *participants;

/**
 @abstract The last message that was added to the conversation, either by the ```sendMessage``` operation or by an incoming message.
 */
@property (nonatomic, readonly) LYRMessage *lastMessage;

@end
